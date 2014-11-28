package com.broceliand.graphLayout.layout {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.util.NullSkin;
   import com.broceliand.util.BroUtilFunction;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.geom.Point;
   import flash.net.SharedObject;
   import flash.sampler.getLexicalScopes;
   import flash.utils.Dictionary;
   
   import mx.controls.RichTextEditor;
   import mx.messaging.channels.PollingChannel;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class ConcentricRadialLayoutV2 extends AnimatedBaseLayout implements ILayoutAlgorithm {

      public static var DEFAULT_RADIUS:Number = 100;
      
      public static const DEBUG:Boolean = false;
      public static var   REPOSITION_PARENT:int = 1;

      public static var OVERLOAD_FACTOR:Number = 90;
      
      public static var FIRST_LEVEL_MAX_NODE_SEPARATION:Number = 100;
      public static var FIRST_LEVEL_MAX_NODE_FOUR_PEARL_SEPARATION:Number = 120;
      public static var FIRST_LEVEL_PREFERRED_RADIUS:Number = 150;
      public static var SECOND_LEVEL_INCREASE:Number = 1.2; 
      public static var THIRD_LEVEL_INCREASE:Number = 1;  
      public static var MAX_DECREASE_RADIUS:Number = 0.95;
      
      private var _minNodeSeparation:int; 
      
      private var _nodesByLevel:Array;
      
      private static var _preferredRadius:Array;
      private static var _preferredRadiusSO:SharedObject;

      private var _previousRoot:INode;        

      private var _maxDepth:int = 0;

      private var _radiusInc:Number = 0;
      private var _reduceRadiusHackFactor:Number = 1;
      /* the two bounding angles */
      private var _theta1:Number;
      private var _theta2:Number;
      private var _setBounds:Boolean;     
      
      /* if we add views the initial size is 0,
      * so we just keep track of the other nodes and
      * use the largest size of a node to measure
      */
      private var _maxviewwidth:Number = 0;
      private var _maxviewheight:Number = 0;
      
      private var  _radiusArray:Array;

      private function getComputedPreferredRadiusAtLevel(i:int, nbOfPearlsAtLevel:int):Number {
         if (i==1) {
            if ( nbOfPearlsAtLevel < 10) {
               return _radiusInc+ (FIRST_LEVEL_PREFERRED_RADIUS -_radiusInc)* nbOfPearlsAtLevel /10
            }  else if ( nbOfPearlsAtLevel > 9 && nbOfPearlsAtLevel < 15) {
               return FIRST_LEVEL_PREFERRED_RADIUS + (nbOfPearlsAtLevel - 10) / 5 * 10;
            } else return FIRST_LEVEL_PREFERRED_RADIUS +10;
         } else if (i == 2) {
            if (_radiusArray[0] > SECOND_LEVEL_INCREASE * _radiusInc) {
               return _radiusArray[0]  + SECOND_LEVEL_INCREASE * _radiusInc;
            }
            return 2 * _radiusArray[0];
         } else if (i ==3) {
            return _radiusArray[1] + THIRD_LEVEL_INCREASE * _radiusInc;
         } 
         return _radiusArray[i-2] + _radiusInc;
      }
      public static function getDeltaRadiusAtLevel(i:int):Number {
         i--;
         if (i<0) {
            i = 0;
         }
         if (!_preferredRadius) {

            if (!_preferredRadius) {
               _preferredRadius = new Array();  
            }
            
         }
         while (_preferredRadius.length <= i) {
            _preferredRadius.push(0);
         }
         if (_preferredRadius[i] == 0) {
            if (i==0) { 
               _preferredRadius[i] = 0;
            } else {
               return 0;
            }
         }
         return _preferredRadius[i];
      }
      public static function setPreferredRadiusAtLevel(i:int, value:Number):void {
         if (getDeltaRadiusAtLevel(i) != value) {
            if (i<0) {
               i =0;
            }
            _preferredRadius[i-1] = value;
            saveRadiusSO(); 
         }
      }
      
      private static function saveRadiusSO():void {
         if (_preferredRadiusSO) {
            try {
               _preferredRadiusSO.data["values"] = _preferredRadius;
               _preferredRadiusSO.flush();
            } catch (e:Error) {
               
            }
         }
      }
      public static function resetPreferredRadius():void {
         _preferredRadius = new Array();
         saveRadiusSO();
      }

      protected var _currentDrawing:ConcentricRadialLayoutDrawing;
      public function set minNodeSeparation (value:int):void
      {
         _minNodeSeparation = value;
      }
      
      public function get minNodeSeparation ():int
      {
         return _minNodeSeparation;
      }

      public function ConcentricRadialLayoutV2(vg:IVisualGraph = null):void {
         
         super(vg);
         
         /* this is inherited */
         animationType = ANIM_RADIAL;
         
         _currentDrawing = null;
         
         _radiusInc = DEFAULT_RADIUS;
         _previousRoot = null;
         _theta1 = 180;
         _theta2 = _theta1 + 360;
         _setBounds = false;
         _maxviewwidth = MINIMUM_NODE_WIDTH;
         _maxviewheight = MINIMUM_NODE_HEIGHT;
         if (!ApplicationManager.getInstance().isEmbed()) {
            _reduceRadiusHackFactor = 0.9;
         }
         initDrawing();
      }

      public override function resetAll():void {
         super.resetAll();
         _stree = null;
         _graph.purgeTrees();
      }

      [Bindable]
      override public function set linkLength(r:Number):void {
         _radiusInc = r;
      }

      override public function get linkLength():Number {
         return _radiusInc;
      }
      
      private function fillNodesByLevel(node:INode, level:int):void {
         var arrayLevel:Array = null;
         if (_nodesByLevel.length <= level) {
            arrayLevel = new Array();
            _nodesByLevel.push(arrayLevel);
         } else {
            arrayLevel = _nodesByLevel[level];
         }
         arrayLevel.push(node);
         var children:Array =_stree.getChildren(node);
         if (children) {
            for each(var n:INode in children) {
               fillNodesByLevel(n , level +1);
            } 
         }
      }
      
      override public function layoutPass():Boolean {
         var rv:Boolean;

         _minNodeSeparation = GeometricalConstants.MIN_NODE_SEPARATION;
         if(!_vgraph) {
            trace("No Vgraph set in ConcentricRadialLayouter, aborting");
            return false;
         }
         
         if(!_vgraph.currentRootVNode) {
            trace("This Layouter always requires a root node!");
            return false;
         }
         /* nothing to do if we have no nodes */
         if(_graph.noNodes < 1) {
            return false;
         }
         
         /* establish the current root, if it has 
         * changed we need to reinit the drawing */
         if(_root != _vgraph.currentRootVNode.node) {
            /* don't forget to save the root here */
            _previousRoot = _root;
            _root = _vgraph.currentRootVNode.node;
            _layoutChanged = true;
         }
         
         /* we test to always reinit the drawing */
         if(_layoutChanged || true) {
            initDrawing();
         }

         /* set the coordinates in the drawing of root
         * to 0,0 */
         _currentDrawing.setCartCoordinates(_root,new Point(0,0));
         
         var endNode:IPTNode = (_root as PTRootNode).containedPearlTreeModel.endNode;
         var parentEndnode :IPTNode = null;
         if (endNode && endNode.parent) {
            parentEndnode = endNode.parent;
            _vgraph.unlinkNodes(parentEndnode.vnode, endNode.vnode);
         } 
         
         /* establish the spanning tree, but have it restricted to
         * visible nodes */
         _stree = _graph.getTree(_root, true, false);
         
         _nodesByLevel = new Array();
         fillNodesByLevel(_root,0);
         var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");
         if (DEBUG) logger.info("################################ LAYOUT PASS #################################");
         var deltasByLevel:Array = new Array(_nodesByLevel.length);
         var leftSpaceAvailableByLevel:Array = new Array(_nodesByLevel.length);
         var tetaByLevel:Array = new Array(_nodesByLevel.length);
         computeRadius(_stree);

         performLayoutAtLevelWithMinSquareDeviation(_nodesByLevel, 0, deltasByLevel, tetaByLevel);
         
         /* calculate the relative width and the
         * new max Depth */
         _maxDepth = 0;
         
         resetAnimation();
         if (parentEndnode) {
            var endNodeR:Number = _currentDrawing.getPolarR(parentEndnode) + _radiusInc;
            if (!isNaN(endNodeR)) {
               var endNodePhi:Number = _currentDrawing.getPolarPhi(parentEndnode);
               if (isNaN(endNodePhi)) {
                  endNodePhi =0;
               }
               _currentDrawing.setPolarCoordinates(endNode, endNodeR, endNodePhi);
               _vgraph.linkNodes(parentEndnode.vnode, endNode.vnode);   
            }
            
         }
         /* start the animation by interpolating polar coordinates */
         startAnimation();
         _nodesByLevel = null; 
         
         _layoutChanged = true;
         return rv;
      }

      public function setAngularBounds(theta:Number, width:Number):void {
         _theta1 = theta;
         _theta2 = _theta1 + width;
         _setBounds = true;
      }
      
      /*
      * private functions
      * */
      
      public static function computeScaleFactor(scale:Number):Number {
         var drawingScaleFactor:Number = 1;
         if (scale<1) {
            drawingScaleFactor = 1 + GeometricalConstants.ZOOM_DENSITY_FACTOR_ZOOM_OUT* (scale - 1) ;	
         } else {
            drawingScaleFactor = 1 + GeometricalConstants.ZOOM_DENSITY_FACTOR * (scale - 1) ;
         }
         return drawingScaleFactor * GeometricalConstants.DENSITY_FACTOR;
         
      }
      
      protected function initDrawing():void {           
         _currentDrawing = new ConcentricRadialLayoutDrawing();
         _currentDrawing.scaleFactor = computeScaleFactor(_vgraph.scale);
         
         /* don't forget to set the object also in the 
         * BaseLayouter */
         super.currentDrawing = _currentDrawing;
         
         _currentDrawing.originOffset = _vgraph.origin;
         _currentDrawing.centerOffset = _vgraph.center;
         _currentDrawing.centeredLayout = true;
         
      }

      private function  computeRadius(tree:IGTree):void {
         _radiusArray = new Array();
         var i:int=1;
         var nbNode:int=0;
         var currentRadius :Number= 0;
         while ((nbNode=tree.getNumberNodesWithDistance(i))>0) {
            currentRadius = Math.round(Math.max(currentRadius+_radiusInc, nbNode*minNodeSeparation/(2*Math.PI)));
            var preferredRadius:Number = getComputedPreferredRadiusAtLevel(i, nbNode) + getDeltaRadiusAtLevel(i);
            if (preferredRadius> currentRadius) {
               currentRadius = preferredRadius;
            }
            _radiusArray.push(currentRadius);
            i++;
            
         }
         
      }
      
      private function getRadius(depth:int):Number {
         return _radiusArray[depth-1];
      }

      private function distanceBetweenNode(lNode:INode, ltetaModifier:Number,rNode:INode, rtetaModifier:Number):Number {
         var phi:Number = (_currentDrawing.getPolarPhi(lNode) - ltetaModifier ) - (_currentDrawing.getPolarPhi(rNode) - rtetaModifier) ;
         phi = Geometry.deg2rad(phi);
         return Math.abs(_currentDrawing.getPolarR(lNode)*phi);
         
      }

      public function computeRadiusForLevel( level:int, nodesByLevel:Array, tetaByLevel:Array):Number {
         var nbNode:int= (level +1) <nodesByLevel.length ? (nodesByLevel[level +1 ] as Array).length  :0;
         var currentRadius:Number = 0;
         if (level>1) {
            currentRadius = _radiusArray[level - 1];
         }
         var minRadius:Number = Math.round(Math.max(currentRadius+_radiusInc, nbNode*minNodeSeparation/(2*Math.PI)));
         var preferredRadius:Number = getComputedPreferredRadiusAtLevel(level +1 , nbNode) + getDeltaRadiusAtLevel(level +1);
         if (preferredRadius> minRadius) {
            currentRadius = preferredRadius;
         } else {
            currentRadius = minRadius;
         }
         var overloadFactor:Number = 0;
         if (level>0) 
            overloadFactor = computeOverloadFactor(level, nodesByLevel, tetaByLevel, currentRadius) ;
         
         _radiusArray[level] = Math.round(currentRadius + overloadFactor * (OVERLOAD_FACTOR /100) *_radiusInc);

         if (level > 1) {
            var incrRadius:Number = _radiusArray[level] - _radiusArray[level -1];
            var prevRadiusIncr:Number  = _radiusArray[level-1] - (level > 1 ? _radiusArray[level -2] : 0);
            if (incrRadius < MAX_DECREASE_RADIUS * prevRadiusIncr) {
               incrRadius = MAX_DECREASE_RADIUS * prevRadiusIncr;
               _radiusArray[level] = Math.round(_radiusArray[level-1] + incrRadius);
            }
         }
         return _radiusArray[level];
      }
      override protected function commitNode(vn: IVisualNode ):void {
         
      }

      private function getOverlapBetweenChildGroup(r:Number, nodesOnPreviousLevel:Array, tetaAtLevel:Array, leftIndex:int, rightIndex:int):Number {
         var leftNode:IPTNode = nodesOnPreviousLevel[leftIndex];
         var rightNode:IPTNode = nodesOnPreviousLevel[rightIndex];
         var rightTeta:Number = tetaAtLevel[leftIndex] - (leftNode.successors.length * _minNodeSeparation) /  (2 * r); 
         var leftTeta:Number = tetaAtLevel[rightIndex] + (rightNode.successors.length * _minNodeSeparation) / (2 * r);
         return leftTeta - rightTeta;
      }
      
      private function positionFirstLevel(tetaAtLevel:Array, nodesAtNextLevel:Array):void {
         var minNodeSeparation:Number = _minNodeSeparation;
         var startAngle:Number  = Math.PI;
         var r:Number = _radiusArray[0];
         var preferredRadiusAtLevel0:Number = getComputedPreferredRadiusAtLevel(1, nodesAtNextLevel.length);
         if (_radiusArray[0] == preferredRadiusAtLevel0) {
            minNodeSeparation = 2 * Math.PI * preferredRadiusAtLevel0/ nodesAtNextLevel.length;
            if (nodesAtNextLevel.length  == 4 && minNodeSeparation > FIRST_LEVEL_MAX_NODE_FOUR_PEARL_SEPARATION) {
               minNodeSeparation = FIRST_LEVEL_MAX_NODE_FOUR_PEARL_SEPARATION;
               startAngle =  0.5 * nodesAtNextLevel.length  * minNodeSeparation /  preferredRadiusAtLevel0 ; 
            }  else if (minNodeSeparation > FIRST_LEVEL_MAX_NODE_SEPARATION && nodesAtNextLevel.length < 10) {
               minNodeSeparation = FIRST_LEVEL_MAX_NODE_SEPARATION;
               startAngle =  0.5 * nodesAtNextLevel.length  * minNodeSeparation /  preferredRadiusAtLevel0 ; 
            }
         }
         for (var i:int =0; i < nodesAtNextLevel.length; ++ i) {
            tetaAtLevel[i] =  startAngle -  minNodeSeparation * (i + 0.5) / r ;
         }
      }   

      public function performLayoutAtLevelWithMinSquareDeviation(nodesByLevel:Array, level:int, deltasByLevel:Array, tetaByLevel:Array):void {
         if (nodesByLevel.length == level+1) {
            return;
         }
         var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");

         var r:Number = computeRadiusForLevel(level, nodesByLevel, tetaByLevel);
         
         if (DEBUG) logger.info("-------------------- Radius at level {0} = {1}  -----------------", level, r);
         
         var nodesAtNextLevel:Array = nodesByLevel[level+1];
         var tetaAtLevel:Array = new Array();
         tetaByLevel[level+1] = tetaAtLevel;
         if (level  == 0) {
            positionFirstLevel(tetaAtLevel, nodesAtNextLevel);
         } else {
            var parentNodes:Array = nodesByLevel[level]; 
            var parentTetas:Array = tetaByLevel[level]; 

            var indexWithChildren:Array = new Array();
            var deltaByParent:Array = new Array(parentNodes.length);
            var sizeInRadOfNode:Number = _minNodeSeparation / r;
            
            for (i =0; i< parentNodes.length; i++) {
               if (IPTNode(parentNodes[i]).getChildCount() > 0) {
                  indexWithChildren.push(i);
                  deltaByParent[i] = 0;
               }   
            }
            
            if (indexWithChildren.length > 1) {
               var offsetBetweenDeltasInGroup:Array = new Array(indexWithChildren.length);

               for (i = 0; i < offsetBetweenDeltasInGroup.length; i++) {
                  var leftIndex:int  = i>0? indexWithChildren[i-1]:indexWithChildren[indexWithChildren.length-1];
                  var rightIndex:int = indexWithChildren[i];
                  
                  offsetBetweenDeltasInGroup[i] = parentTetas[leftIndex] - parentTetas[rightIndex] -  sizeInRadOfNode 
                     * (IPTNode(parentNodes[leftIndex]).getChildCount() + IPTNode(parentNodes[rightIndex]).getChildCount()) / 2;
                  if (i==0) {

                     offsetBetweenDeltasInGroup[i] += 2 * Math.PI;
                  }
               }

               var groups:Array = new Array();
               for (i=0; i < indexWithChildren.length;i++) {
                  groups.push(new PearlGroup(i));
               }
               var lastGroupSize:int = groups.length;
               var hasNewGroups:Boolean  = true; 
               
               while (lastGroupSize != 1  && hasNewGroups) {
                  
                  for (i=0; i<groups.length; i++) {
                     var g:PearlGroup  = groups[i];
                     g.positionNodesInGroup(parentNodes, indexWithChildren, deltaByParent, offsetBetweenDeltasInGroup);
                  }
                  groups = regroupHittingGroups(groups, parentNodes, indexWithChildren, parentTetas, deltaByParent, sizeInRadOfNode, true);
                  hasNewGroups = groups.length != lastGroupSize;
                  if (DEBUG) {
                     logger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");   
                     logger.info("regrouping iteration result : {0} to {1} groups", lastGroupSize, groups.length); 
                  }
                  lastGroupSize = groups.length;
               }
               
               if (lastGroupSize == 1) {
                  (groups[0] as PearlGroup).positionNodesInGroup(parentNodes, indexWithChildren, deltaByParent, offsetBetweenDeltasInGroup);
               }
            }

            var childIndex:int = 0;
            var parentIndex:int = 0;
            var parentNode:IPTNode;
            var childCount:int;
            deltasByLevel[level-1] = deltasByLevel;
            for (parentIndex= 0; parentIndex< parentNodes.length; parentIndex ++) {
               parentNode = parentNodes[parentIndex] as IPTNode;
               childCount = parentNode.getChildCount();
               for (var c:int=0; c < childCount; c++) {
                  tetaAtLevel[childIndex++] = parentTetas[parentIndex] + deltaByParent[parentIndex] + sizeInRadOfNode * (childCount  /2 - (c+0.5));
               }
            }
         }
         
         for (var  i:int =0; i < nodesAtNextLevel.length; ++ i) {
            var tetaInDeg:Number  = Geometry.rad2deg(tetaAtLevel[i]);
            var distWithPrevious:Number = i>0 ? tetaAtLevel[i-1] - tetaAtLevel[i] : (tetaAtLevel[nodesAtNextLevel.length-1] + 2 * Math.PI - tetaAtLevel[i]);
            var distWithNext:Number = (i<nodesAtNextLevel.length-1) ? tetaAtLevel[i] - tetaAtLevel[i+1]: tetaAtLevel[i] - (tetaAtLevel[0] - 2*Math.PI);
            var minDist:Number = Math.min(distWithPrevious, distWithNext);
            var vnode:IPTVisualNode = nodesAtNextLevel[i].vnode as IPTVisualNode;
            if (vnode) {
               vnode.distanceToClosestBrother = r * minDist;
            }
            if (DEBUG) logger.info("Child #{0} position in deg = {1}     node name :{2}", i, tetaInDeg, IPTNode(nodesAtNextLevel[i]).name);
            
            _currentDrawing.setPolarCoordinates(nodesAtNextLevel[i], r, -tetaInDeg);
         }
         if (level >0) {
            if (DEBUG) logger.info("-------------------- Repositioning : level {0} = radius = {1}  -----------------", level, _radiusArray[level-1]);
            if (REPOSITION_PARENT>0) {
               repositionPreviousLevelNodes(parentNodes, tetaByLevel[level], deltaByParent, _radiusArray[level-1]);  
            }
            if (DEBUG) logger.info("-------------------- End  Repositioning : level {0}  -----------------", level);
            
         }

         performLayoutAtLevelWithMinSquareDeviation(nodesByLevel, level + 1, deltasByLevel, tetaByLevel);
      }
      
      private function repositionPreviousLevelNodes(nodes:Array, currentPosition:Array, deltaByParent:Array, radiusAtLevel:Number):void {
         var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");   
         var offsetBetweenDeltasInGroup:Array = new Array(nodes.length);
         var parentTetas:Array = new Array(nodes.length);
         var indexWithChildren:Array = new Array(nodes.length);
         var sizeInRadOfNode:Number = _minNodeSeparation / radiusAtLevel;
         for (i = 0; i < offsetBetweenDeltasInGroup.length; i++) {
            parentTetas[i] = currentPosition[i];
            if ((nodes[i] as IPTNode).getChildCount()>0) {
               parentTetas[i] += deltaByParent[i];
            }
            deltaByParent[i] = 0;
            indexWithChildren[i] = i;
         }
         for (i = 0; i < offsetBetweenDeltasInGroup.length; i++) {
            var leftIndex:int  = i>0? i-1:nodes.length-1;
            offsetBetweenDeltasInGroup[i] = parentTetas[leftIndex] - parentTetas[i] -  sizeInRadOfNode; 
            if (i==0) {

               offsetBetweenDeltasInGroup[i] += 2 * Math.PI;
            }
         }

         var groups:Array = new Array();
         for (i=0; i < nodes.length;i++) {
            groups.push(new PearlGroup(i));
         }
         var lastGroupSize:int = groups.length;
         var hasNewGroups:Boolean  = true; 
         
         if (groups.length == 1) {
            (groups[0] as PearlGroup).positionNodesInGroup(nodes, indexWithChildren, deltaByParent, offsetBetweenDeltasInGroup);
         }
         while (lastGroupSize != 1  && hasNewGroups) {
            
            for (i=0; i<groups.length; i++) {
               var g:PearlGroup  = groups[i];
               g.positionNodesInGroup(nodes, indexWithChildren, deltaByParent, offsetBetweenDeltasInGroup);
            }
            groups = regroupHittingGroups(groups, nodes, indexWithChildren, parentTetas, deltaByParent, sizeInRadOfNode, false);
            hasNewGroups = groups.length != lastGroupSize;
            if (DEBUG) {
               logger.info("regrouping iteration result : {0} to {1} groups", lastGroupSize, groups.length); 
            }
            lastGroupSize = groups.length;
            
            if (lastGroupSize == 1) {
               (groups[0] as PearlGroup).positionNodesInGroup(nodes, indexWithChildren, deltaByParent, offsetBetweenDeltasInGroup);
            }
         }
         for (var  i:int =0; i < nodes.length; ++ i) {
            var tetaInDeg:Number  = Geometry.rad2deg(parentTetas[i] + deltaByParent[i]);
            if (DEBUG) logger.info("Reposition in deg = {1}     node name :{2}", i, tetaInDeg, IPTNode(nodes[i]).name);
            
            _currentDrawing.setPolarCoordinates(nodes[i], radiusAtLevel, -tetaInDeg);
         }

      }

      private function regroupHittingGroups(positionnedGroups:Array, parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaAtLevel:Array, sizeInRadOfNode:Number, checkChildrendHitting:Boolean):Array {
         var result:Array = new Array();
         var currentGroup:PearlGroup = positionnedGroups.shift();
         result.push(currentGroup);
         var leftGroup:PearlGroup = currentGroup;
         while (positionnedGroups.length > 0) {
            var rightGroup:PearlGroup = positionnedGroups.shift();
            if (leftGroup.isHittingRightGroup(rightGroup, parentNodes, indexWithChildren, tetaAtLevel, deltaAtLevel, sizeInRadOfNode, checkChildrendHitting)) {
               
               if (DEBUG) {
                  var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");
                  logger.info("-> Regroup Left Group : {0} with {1} ", currentGroup.getName(parentNodes, indexWithChildren), rightGroup.getName(parentNodes, indexWithChildren));
               }  
               currentGroup.addRightGroup(rightGroup);
            } else {
               
               currentGroup = rightGroup;
               result.push(currentGroup);
            }
            leftGroup = rightGroup;
         } 
         
         if (result.length > 1) {
            if (leftGroup.isHittingRightGroup(result[0] as PearlGroup, parentNodes, indexWithChildren, tetaAtLevel, deltaAtLevel, sizeInRadOfNode, checkChildrendHitting)) {
               if (DEBUG) {
                  logger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");
                  logger.info("-> Regroup Last With First- Left Group : {0} with {1} ", currentGroup.getName(parentNodes, indexWithChildren), (result[0] as PearlGroup).getName(parentNodes, indexWithChildren));
               }  
               currentGroup.addRightGroup(result[0]);
               result[0] = currentGroup;
               result.pop();
               
            }
         }
         
         return result;
         
      }
      
      private function computeOverloadFactor(level:int, nodesByLevel:Array, tetaByLevel:Array, radiusAtChildLevel:Number):Number {
         if (level > 0) {
            var totalOverlappingSize:Number = 0;
            var nodesOnPreviousLevel:Array = nodesByLevel[level];
            var tetaOnPreviousLevel:Array = tetaByLevel[level];
            var leftIndex:int = -1;
            var rightIndex:int = -1;
            var maxValue:Number = 0;
            var leftMaxIndex:int = -1;
            var rightMaxIndex:int = -1;
            var lastOverlap:Number = 0;
            var maxOverlap:Number =0;
            for (var i:int = 0; i<nodesOnPreviousLevel.length;i++) {
               var n:IPTNode = nodesOnPreviousLevel[i];
               if (n.getChildCount()>0) {
                  if (leftIndex == -1) {
                     leftIndex = i;
                  } else {
                     if (rightIndex != -1) {
                        leftIndex = rightIndex;
                     }
                     rightIndex = i;
                     var overlap : Number = getOverlapBetweenChildGroup(radiusAtChildLevel, nodesOnPreviousLevel, tetaOnPreviousLevel, leftIndex, rightIndex);
                     if (overlap + lastOverlap > 0) {
                        lastOverlap = overlap + lastOverlap;
                        Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2").info("overlap between {0} and  {1} = {2} ", IPTNode(nodesOnPreviousLevel[leftIndex]).name, IPTNode(nodesOnPreviousLevel[rightIndex]).name, overlap);
                        totalOverlappingSize += lastOverlap;
                        if (lastOverlap> maxOverlap) {
                           maxOverlap = lastOverlap;
                        }
                     } else {
                        lastOverlap = 0;
                     }
                  }
               }
            }
            if (DEBUG) {
               Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2").info("total overlapping facotor for level {0} is {1} ", level, totalOverlappingSize/ Math.PI);
            }
            return maxOverlap / Math.PI;
         }
         return 0;
      }
      
   }
}
import com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.util.Assert;
import com.broceliand.util.logging.BroLogger;
import com.broceliand.util.logging.Log;

import flash.utils.Dictionary;

import org.un.cava.birdeye.ravis.utils.Geometry;

class PearlGroup {
   
   private var _indexes:Array;
   private var _groupLeftIndex:int;
   private var _isPositioned:Boolean;
   public function PearlGroup(parentIndex:int):void {
      _indexes = new Array();
      _groupLeftIndex = parentIndex;
      _indexes.push(parentIndex);
      _isPositioned = false;
   }
   
   public function positionNodesInGroup(parentNodes:Array, indexWithChildren:Array, deltaToFill:Array, offsetBetweenDeltasInGroup:Array):void {
      if (!_isPositioned) {
         _isPositioned = true;
         var i:int;
         var currentSum:Number = 0;
         var totalSum:Number = 0;
         for (i=1; i<_indexes.length; i++) {
            currentSum += offsetBetweenDeltasInGroup[_indexes[i]];
            totalSum += currentSum;
         }

         var delta:Number = - totalSum / _indexes.length;
         for (i=0; i<_indexes.length; i++) {
            if (i>0) {
               delta += offsetBetweenDeltasInGroup[_indexes[i]]; 
            }
            deltaToFill[indexWithChildren[_indexes[i]]] = delta;
            if (delta != 0 && ConcentricRadialLayoutV2.DEBUG) {
               var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");
               logger.info("Positioning group {2} : Delta Position of {0} in deg = {1}", ( parentNodes[indexWithChildren[_indexes[i]]] as IPTNode).name, Geometry.rad2deg(delta),
                  (parentNodes[indexWithChildren[_groupLeftIndex]] as IPTNode).name);  
            }
         }
      } 
      
   }
   
   private function getRightGroupAngle(parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaOfParent:Array, sizeInRadOfNode:Number, checkChildrendHitting:Boolean):Number {
      var lastIndex:int = _indexes.length -1;
      var leftIndex:int =indexWithChildren[_indexes[lastIndex]];
      var leftNode:IPTNode = parentNodes[leftIndex];
      var childCount:int = checkChildrendHitting?leftNode.getChildCount():1;
      return tetaAtLevel[leftIndex] + deltaOfParent[leftIndex] - childCount  * (sizeInRadOfNode/2); 
      
   }
   private function getLeftGroupAngle(parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaOfParent:Array, sizeInRadOfNode:Number,checkChildrendHitting:Boolean):Number {
      var rightIndex:int =indexWithChildren[_indexes[0]];
      var rightNodeParent:IPTNode = parentNodes[rightIndex];
      var childCount:int = checkChildrendHitting?rightNodeParent.getChildCount():1;
      return tetaAtLevel[rightIndex] + deltaOfParent[rightIndex] + childCount * (sizeInRadOfNode/2);
   }
   
   public function isHittingRightGroup(rightGroup:PearlGroup, parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaOfParent:Array, sizeInRadOfNode:Number, checkChildrendHitting:Boolean):Boolean {
      
      var rightAngleLeftGroup:Number = getRightGroupAngle(parentNodes, indexWithChildren, tetaAtLevel, deltaOfParent, sizeInRadOfNode, checkChildrendHitting );
      var add2PI:Boolean = _indexes[_indexes.length-1] > rightGroup._groupLeftIndex;
      if (add2PI ) {
         rightAngleLeftGroup += Math.PI * 2;
      }
      
      var leftAngleRightGroup:Number = rightGroup.getLeftGroupAngle(parentNodes, indexWithChildren, tetaAtLevel, deltaOfParent, sizeInRadOfNode, checkChildrendHitting);
      if (ConcentricRadialLayoutV2.DEBUG) {
         var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");
         logger.info("Test grouping grouping left group {0} (angle = {2}) with right group {1} (angle = {3}", this.getName(parentNodes, indexWithChildren), rightGroup.getName(parentNodes, indexWithChildren),
            Geometry.rad2deg(rightAngleLeftGroup), Geometry.rad2deg(leftAngleRightGroup));     
      }
      if (rightAngleLeftGroup  < leftAngleRightGroup) {
         return true;
      } else {
         return false;
      }
   }
   public function addRightGroup(rightGroup:PearlGroup):void {
      _isPositioned = false;
      for (var i:int =0; i< rightGroup._indexes.length; i++) {
         _indexes.push(rightGroup._indexes[i]);
      }
   }
   
   public function getName(parentNodes:Array, indexWithChildren:Array):String {
      var s:String = "[";
      for (var i:int =0; i< _indexes.length; i++) {
         if (i>0) {
            s+= ",";
         }
         s += _indexes[i];
      }
      s += "]";
      return (parentNodes[indexWithChildren[_groupLeftIndex]] as IPTNode).name + s;
   }

}
