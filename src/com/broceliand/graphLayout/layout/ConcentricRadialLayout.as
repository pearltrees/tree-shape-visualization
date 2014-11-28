package com.broceliand.graphLayout.layout {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.util.NullSkin;
   
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class ConcentricRadialLayout extends AnimatedBaseLayout implements ILayoutAlgorithm {

      public static const DEFAULT_RADIUS:Number = 50;

      private var _minNodeSeparation:int=45;

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
      
      protected var _currentDrawing:ConcentricRadialLayoutDrawing;
      public function set minNodeSeparation (value:int):void
      {
         _minNodeSeparation = value;
      }
      
      public function get minNodeSeparation ():int
      {
         return _minNodeSeparation;
      }

      public function ConcentricRadialLayout(vg:IVisualGraph = null):void {
         
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

      override public function layoutPass():Boolean {
         var rv:Boolean;

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
         
         killTimer();
         
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
         
         /* establish the spanning tree, but have it restricted to
         * visible nodes */
         _stree = _graph.getTree(_root, true, false);
         
         computeRadius(_stree);
         /* calculate the relative width and the
         * new max Depth */
         _maxDepth = 0;
         
         calcAngularWidth(_root,0);
         if(_maxDepth > 0) {
            calculateStaticLayout(_root,1,_theta1,_theta2, true);
         }
         updateRadius();
         /* calculate the radius increment to fit the screen */
         if(_autoFitEnabled) {
            autoFit();
         }
         
         /* we may have preset angular bounds
         * XXX this is untested, yet */

         /* do a static layout pass */
         if(_maxDepth > 0) {
            calculateStaticLayout(_root,1,_theta1,_theta2, false);
         }
         
         /* now if we have no previous drawing we can just
         * apply the result and display it
         * if we do have (but maybe even if we don't have)
         * we interpolate the polar coordinates of the nodes */
         reduceTree();
         resetAnimation();
         
         /* start the animation by interpolating polar coordinates */
         startAnimation();
         
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
         if (scale<1) {
            return  1 + GeometricalConstants.ZOOM_DENSITY_FACTOR_ZOOM_OUT* (scale - 1) ;	
         } else {
            return  1 + GeometricalConstants.ZOOM_DENSITY_FACTOR* (scale - 1) ;
         }
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

      private function autoFit():void {
         var r:Number;
         r = Math.min(_vgraph.width, _vgraph.height) / 2.0;
         
         if(_maxDepth > 0) {
            _radiusInc = (r - (2 *DEFAULT_MARGIN)) / _maxDepth;
         }
      }
      
      private function  computeRadius(tree:IGTree):void {
         _radiusArray = new Array();
         var i:int=1;
         var nbNode:int=0;
         var currentRadius :Number= 0;
         while ((nbNode=tree.getNumberNodesWithDistance(i))>0) {
            i++;
            currentRadius = Math.round(Math.max(currentRadius+_radiusInc, nbNode*minNodeSeparation/(2*Math.PI)));
            _radiusArray.push(currentRadius);
            
         }
         
      }
      
      private function getRadius(depth:int):Number {
         return _radiusArray[depth-1];
      }
      
      private function calcAngularWidth(n:INode, d:int):Number {
         var aw:Number = 0;
         var diameter:Number;
         var cn:INode; 
         
         if(n == null) {
            throw Error("Node to calculate Angular width is null");
         }
         if(n.vnode == null) {
            throw Error("Node has no vnode");
         }

         if(!n.vnode.isVisible) {
            trace("Node:"+n.id+" not yet visible but called in angular width calc");
            return 0;
         }
         
         /* update current max Depth */
         if(d > _maxDepth) {
            _maxDepth = d;
         }

         if(d == 0) {
            diameter = 0; 
         } else {
            /* in another implementation this divided the real
            * diameter by d not by d times the radiusINcrement
            * which yields way too large values */
            diameter = minNodeSeparation / getRadius(d);
         }
         
         /* diameter is an angular width value in radians,
         * so we convert it to degrees when used */
         diameter = Geometry.rad2deg(diameter);

         /* here the code checks if the node 'is expanded'
         * which means if he has visible children
         * we do it differently, if the node is invisible
         * his angular width is 0, so is it for all his
         * children in case they are not visible
         * this may be a bit less efficient, but it fits
         * our code */
         if(_stree.getNoChildren(n) > 0) {
            
            for each(cn in _stree.getChildren(n)) {
               aw += calcAngularWidth(cn, d+1);
               
            }
            aw = Math.max(diameter,aw);
         } else {
            
            aw = diameter;
            
         }
         
         _currentDrawing.setAngularWidth(n,aw);

         return aw;
      }
      private var _incrArray : Array; 
      private function increaseRadius(d:Number, newRadius:Number):Number{
         if (_incrArray == null) {
            _incrArray = new Array();
         }
         while (_incrArray.length< d) {
            _incrArray.push(0);
         }
         if (_incrArray [d-1]==null ? 0:_incrArray [d-1] + _radiusArray[d-1]<newRadius ) {
            _incrArray[d-1]= newRadius-_radiusArray[d-1];
            return _incrArray[d-1];
         }
         return 0;
      }
      private function updateRadius() :void{
         var increase:Number= 0;
         if (_incrArray==null) {
            return;
            
         }
         for (var i:int=0; i<_maxDepth; i++) {
            if (i<_incrArray.length)
               increase = Math.max(increase, _incrArray[i]);
            _radiusArray[i]+=increase;
         }
         _incrArray = null;
      }

      private function calculateStaticLayout(n:INode, depth:Number, theta1:Number, theta2:Number, forRadiusOnly:Boolean, maxIncrease:Number =0):void {
         
         var dtheta:Number;
         var dtheta2:Number;
         var awidth:Number;
         var cfrac:Number;
         var nfrac:Number;
         var i:int;
         var cindex:int;
         var cc:int;
         var cn:INode;
         
         dtheta = theta2 - theta1;
         nfrac = 0.0;
         cfrac = 0.0;
         
         awidth = _currentDrawing.getAngularWidth(n);    

         var aWidthInRad:Number = Geometry.deg2rad(awidth) * _reduceRadiusHackFactor;
         var dthetaInRad:Number = Geometry.deg2rad(dtheta);
         if (awidth<dtheta) {

            theta2= (awidth + theta1+theta2) /2;
            theta1= theta2-awidth;
            dtheta = awidth;
            
         } 
         else if (forRadiusOnly && aWidthInRad > dthetaInRad) {

            var realAWidthFactor:Number =  getRadius(depth) / (getRadius(depth)+maxIncrease)
            
            if (depth>0 && aWidthInRad == minNodeSeparation / getRadius(depth)) { 
               maxIncrease = Math.max(maxIncrease, increaseRadius(depth-1,getRadius(depth-1) *  aWidthInRad/ dthetaInRad));
            } else {
               maxIncrease = Math.max(maxIncrease, increaseRadius(depth,  getRadius(depth) *  aWidthInRad /dthetaInRad));
            }

         }
         dtheta2 = dtheta / 2.0;
         
         cc = _stree.getNoChildren(n);
         for(cindex=0; cindex < cc; ++cindex) {
            cn = _stree.getIthChildPerNode(n,cindex);           
            cfrac = _currentDrawing.getAngularWidth(cn) / awidth;
            if (cc==1) {
               cfrac = 1;
            }      
            /* do we need to recurse, 
            * we just recurse if the node has children */
            if(_stree.getNoChildren(cn) > 0) {
               calculateStaticLayout(cn, depth+1, 
                  theta1 + (nfrac * dtheta),
                  theta1 + ((nfrac + cfrac) * dtheta), forRadiusOnly, maxIncrease);
            }

            if (!forRadiusOnly) {
               _currentDrawing.setPolarCoordinates(cn, getRadius(depth), theta1+(nfrac*dtheta)+(cfrac*dtheta2));
               
               var vnode:IPTVisualNode = cn.vnode as IPTVisualNode;
               if (vnode) {
                  vnode.distanceToClosestBrother = 0;
               }
            }

            /* set the orientation in the visual node */
            cn.vnode.orientAngle = theta1+(nfrac*dtheta)+(cfrac*dtheta2);
            
            nfrac += cfrac; 
         }
      }
      override protected function commitNode(vn: IVisualNode ):void {
         
      }

      private var _tetaModifier:Dictionary ;
      private var _thread:Dictionary ;
      private function reduceTree():void {
         _tetaModifier = new Dictionary();
         _thread = new Dictionary();
         reduceTreeAngles(_root);
         applyModification(_root,0);
      }
      private function reduceTreeAngles(n:INode):void {
         var cindex:int;
         var i:int;
         var cc:int;
         var cn:INode;
         var leftNode:INode;
         cc = _stree.getNoChildren(n);
         if (cc==0) return;
         _tetaModifier[n]=0;
         leftNode =  _stree.getIthChildPerNode(n,0);
         _tetaModifier[leftNode] =0;
         reduceTreeAngles(leftNode);
         
         for(cindex=1; cindex < cc; ++cindex) {
            cn = _stree.getIthChildPerNode(n,cindex);  
            reduceTreeAngles(cn);
            _tetaModifier[cn]= angularReductionBetweenTreesInDeg(leftNode, cn, minNodeSeparation); 	
            leftNode = cn;
            
         }
         var tetaDown:Number= _tetaModifier[leftNode];
         if (tetaDown>0) {
            for(cindex=0; cindex< cc; ++cindex ) {
               cn = _stree.getIthChildPerNode(n,cindex);  
               _tetaModifier[cn]-= tetaDown/2; 	
            }
         }    

      }
      private function applyModification(node:INode, teta:Number):void {
         var children: Array = _stree.getChildren(node);
         for each (var child:INode in children) {
            applyModification(child, teta + getModifier(child));
         }
         
         if (_currentDrawing.getPolarPhi(node)>180 && _currentDrawing.getPolarPhi(node)-teta<180) 
            
            trace("Pbm with " + IPTNode(node).name + " going to the wrong side !");
         _currentDrawing.setPolarCoordinates(node,_currentDrawing.getPolarR(node),_currentDrawing.getPolarPhi(node)-teta);
         
      } 
      private function getModifier(node:INode):Number {
         var teta:Object= _tetaModifier[node];
         return teta==null?0:_tetaModifier[node];
         
      }        
      
      private function angularReductionBetweenTreesInDeg(leftRootNode:INode, rightRootNode:INode, minDistance:Number):Number{
         
         var ancestor:INode = getFirstCommonAncestor(leftRootNode,rightRootNode);
         var d1 :Number= _stree.getDistance(leftRootNode);
         var d2:Number = _stree.getDistance(rightRootNode);
         var d:Number = _stree.getDistance(ancestor);
         while (d1>d+1) {
            leftRootNode = leftRootNode.predecessors[0];
            d1--; 
         }
         while (d2>d+1) {
            rightRootNode= rightRootNode.predecessors[0];
            d2--; 
         }  
         var outsideRight:INode = rightRootNode;
         var outsideLeft:INode = INode(leftRootNode.predecessors[0]).successors[0];
         
         var bestAngularOffset:Number = 1E10;
         var angularOffset :Number= 1E10;
         var rightTeta:Number = 0;
         var leftTeta:Number = 0;
         var prevRight:INode= rightRootNode;
         var prevLeft:INode= leftRootNode;
         var prevORight:INode= outsideRight;
         var prevOLeft:INode= leftRootNode;
         while (rightRootNode != null && leftRootNode != null) {
            
            rightTeta+= getModifier(rightRootNode);
            leftTeta += getModifier(leftRootNode);
            d = distanceBetweenNode(leftRootNode, leftTeta,  rightRootNode, rightTeta);
            if( d<=minDistance) {
               bestAngularOffset = 0;
            } else {
               angularOffset = (d-minDistance)/_currentDrawing.getPolarR(leftRootNode)
               if (angularOffset< bestAngularOffset) {
                  bestAngularOffset = angularOffset;
               }
            }
            
            prevRight= rightRootNode;
            prevLeft= leftRootNode;
            prevOLeft = outsideLeft;
            prevORight= outsideRight;
            leftRootNode = nextRight(leftRootNode);
            rightRootNode= nextLeft(rightRootNode);
            outsideRight = nextRight(outsideRight);
            outsideLeft = nextLeft(outsideLeft);

            if (leftRootNode != null  && leftRootNode.predecessors[0] != prevLeft) {
               ancestor = getFirstCommonAncestor(prevLeft,leftRootNode);
               while (prevLeft!= ancestor) {
                  leftTeta -= getModifier(prevLeft);
                  prevLeft = prevLeft.predecessors[0];
               }
               prevLeft = leftRootNode.predecessors[0];
               while (prevLeft!= ancestor) {
                  leftTeta += getModifier(prevLeft);
                  prevLeft = prevLeft.predecessors[0];
                  
               }
               
            } 
            if (rightRootNode!= null  && rightRootNode.predecessors[0] != prevRight) {
               ancestor = getFirstCommonAncestor(prevRight,rightRootNode);
               while (prevRight!= ancestor) {
                  rightTeta -= getModifier(prevRight);
                  prevRight = prevRight.predecessors[0];
               }
               prevRight = rightRootNode.predecessors[0];
               while (prevRight!= ancestor) {
                  rightTeta += getModifier(prevRight);
                  prevRight = prevRight.predecessors[0];
                  
               }
               
            } 
         }
         if (bestAngularOffset<0) {
            bestAngularOffset = -Geometry.rad2deg(-bestAngularOffset);
         }  else {      
            bestAngularOffset = Geometry.rad2deg(bestAngularOffset);
         }
         
         if ((leftRootNode != null) && (outsideRight == null)) {
            _thread[prevORight] = leftRootNode;
         }
         if ((rightRootNode != null) && (outsideLeft == null)) {
            _thread[prevOLeft] = rightRootNode;
         }

         if (rightRootNode != null && leftRootNode == null) {

            rightTeta += bestAngularOffset;  
            while (rightRootNode !=null ) {
               var originalPhi :Number =_currentDrawing.getPolarPhi(rightRootNode);
               
               rightTeta +=  getModifier(rightRootNode);
               if (originalPhi>180 && originalPhi- rightTeta<180) {
                  bestAngularOffset -= rightTeta- (originalPhi-180);
                  rightTeta = (originalPhi-180);

               } 

               rightRootNode = nextLeft(rightRootNode);

            } 
         }
         return bestAngularOffset;

      }
      private function distanceBetweenNode(lNode:INode, ltetaModifier:Number,rNode:INode, rtetaModifier:Number):Number {
         var phi:Number = (_currentDrawing.getPolarPhi(lNode) - ltetaModifier ) - (_currentDrawing.getPolarPhi(rNode) - rtetaModifier) ;
         phi = Geometry.deg2rad(phi);
         return Math.abs(_currentDrawing.getPolarR(lNode)*phi);
         
      }
      private function getFirstCommonAncestor(lNode:INode,rNode:INode):INode {
         var d1 :Number= _stree.getDistance(lNode);
         var d2:Number = _stree.getDistance(rNode);
         while (d1<d2) {
            rNode= rNode.predecessors[0];
            d2--;
         }
         while (d2<d1) {
            lNode= lNode.predecessors[0];
            d1--;
         }
         while (lNode != rNode) {
            lNode = lNode.predecessors[0];
            rNode = rNode.predecessors[0];
         }
         return lNode;
      } 
      private function nextRight(v:INode):INode {
         var nochildren:uint;
         
         nochildren = _stree.getNoChildren(v);
         
         /* if the node has children we return the rightmost
         * child, if not, we return the thread of the node */
         if(nochildren > 0) {
            return _stree.getIthChildPerNode(v,nochildren - 1);
         } else {
            var ret:INode =_thread[v];

            return ret;
         }
      }

      private function nextLeft(v:INode):INode {
         /* if the node has children we return the leftmost
         * child, if not, we return the thread of the node */
         if(_stree.getNoChildren(v) > 0) {
            return _stree.getIthChildPerNode(v,0);
         } else {
            var ret:INode = _thread[v];

         }
         return ret;
      }
      
   }
}
