package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.layout.PTLayouterBase;
   import com.broceliand.graphLayout.layout.UpdateTitleRendererLayout;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.effects.easing.Linear;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.GTree;
   import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class GrowingTreeAnimation extends EventDispatcher
   {
      private var _maxDepth:int=-1;
      private var _maxVisibleDistance:int=1;
      private var _nodePosition:Dictionary = null;
      private var _lastOrigin:Point;
      private var _waitBeforeNext:int=0;
      private var _stree:IGTree;
      private var _vgraph:IPTVisualGraph; 
      private var _root:IPTNode;
      private var _manipulatedNodeModel:ManipulatedNodesModel;
      
      public function GrowingTreeAnimation(root:IPTNode, nodesPositions:Dictionary, vgraph:IPTVisualGraph, manipuldatedNodeModel:ManipulatedNodesModel) {
         _nodePosition= nodesPositions;
         _vgraph = vgraph;
         _stree = new GTree(root,_vgraph.graph);
         _stree.initTree();
         _maxDepth =_stree.maxDepth;
         _root = root;
         _lastOrigin = _vgraph.origin.clone();
         _manipulatedNodeModel= manipuldatedNodeModel;
      }
      private function moveToNextAnimation(ev:EffectEvent=null):void{
         
         _waitBeforeNext --;
         if (_waitBeforeNext <=0) {
            _waitBeforeNext =0;
            if(_maxVisibleDistance >= _maxDepth){
               repositionAtEndOfAnimation();
               _vgraph.refresh();
               _nodePosition=null;
               setNodesVisible(true);
               dispatchEvent(new Event(PTLayouterBase.EVENT_LAYOUT_FINISHED));
            }else{
               _maxVisibleDistance++;
               performAnimationStep(_maxVisibleDistance);
            }
         }
         UpdateTitleRendererLayout.updateTitleRendererNow(_vgraph);
         
      }
      public function playAnimation():void  {
         setNodesVisible(false)
         performAnimationStep(1);
      }
      private function setNodesVisible(isVisible:Boolean):void {
         var nodesToAnimate:Array = _root.getDescendantsAndSelf();
         for each (var n:IPTNode in nodesToAnimate) {
            if (n != _root && n.vnode.view && !_manipulatedNodeModel.isNodeManipulated(n)) {
               n.vnode.view.visible = isVisible;
               n.vnode.view.alpha=isVisible?1:0;
            }
         }
      }
      public function repositionAtEndOfAnimation():void  {
         for each (var vn:IPTVisualNode  in _vgraph.visibleVNodes) {
            if (vn.isVisible && _nodePosition && !IPTNode(vn.node).isDocked && !_manipulatedNodeModel.isNodeManipulated(vn.ptNode)) {
               var p:Point = _nodePosition[vn];
               if (p!=null) {
                  var pearl:IUIPearl = vn.pearlView; 
                  pearl.moveWithoutZoomOffset(int (0.5 + p.x + _vgraph.origin.x - _lastOrigin.x ) , int (0.5 + p.y + _vgraph.origin.y - _lastOrigin.y));
                  
               }
            }
         }  
      }
      private function performAnimationStep(depth:Number):void{
         var p:Parallel = new Parallel();
         var scrollDeltaX :Number= _vgraph.origin.x - _lastOrigin.x;
         var scrollDeltaY :Number= _vgraph.origin.y - _lastOrigin.y;
         var nodesToProcess:Array = new Array();
         var targetPointWithScroll:Point = new Point();
         nodesToProcess.push(_root.vnode);
         var currentAncestor:IVisualNode = _root.vnode;
         var m:Move = null;
         while (nodesToProcess.length>0) {
            var useAnimToPosition:Boolean =true;
            var vn:IPTVisualNode = nodesToProcess.pop();
            var startOutsideScreen:Boolean=false;
            var targetOutsideScreen:Boolean=false;
            if (vn==null) {
               continue;
            }
            var vnodeDepth:Number= _stree.getDistance(vn.node) ;
            if(vnodeDepth> depth){
               
               continue;
            }
            if(vnodeDepth < depth){
               useAnimToPosition = false;
            } 
            currentAncestor = vn;

            var startPoint:Point;  
            var targetPoint:Point;
            
            var parentNode:INode = currentAncestor.node.predecessors[0];
            targetPoint = _nodePosition[currentAncestor];
            
            if (!targetPoint) {
               continue;
            }
            if(useAnimToPosition &&  parentNode != null && currentAncestor.node != _root) {
               startPoint= _nodePosition[parentNode.vnode];
            } else {
               startPoint= targetPoint;
            } 
            if (vn.view==null ) continue;
            if (startPoint==null) {
               
               continue;
            }
            var pearl:IUIPearl = vn.pearlView;
            pearl.moveWithoutZoomOffset(int (startPoint.x + scrollDeltaX + 0.5), int(startPoint.y + scrollDeltaY +0.5));
            pearl.visible =true;
            pearl.alpha =1;
            startOutsideScreen = !IPTNode(vn.node).isRendererInScreen();
            targetPointWithScroll.x = targetPoint.x + scrollDeltaX ;
            targetPointWithScroll.y = targetPoint.y + scrollDeltaY ;
            
            if (targetPointWithScroll.x< - pearl.pearlWidth || targetPointWithScroll.x>_vgraph.width) {
               targetOutsideScreen = true;
            }
            if (targetPointWithScroll.y< - pearl.pearlWidth || targetPointWithScroll.y>_vgraph.height) {
               targetOutsideScreen = true;
            }

            if (targetOutsideScreen && startOutsideScreen) {
               useAnimToPosition = false;
            }   
            if (targetPointWithScroll.x == pearl.x && targetPoint.y == pearl.y) {
               useAnimToPosition = false;
            }             
            
            if (!vn.isVisible || !pearl.visible)  continue;
            
            if (useAnimToPosition) {
               if (depth>2)
                  m = _vgraph.moveNodeTo(vn,  int(0.5 + targetPointWithScroll.x), int(0.5 + targetPointWithScroll.y) ,100, false);
               else m = _vgraph.moveNodeTo(vn,  int(0.5 + targetPointWithScroll.x), int(0.5 + targetPointWithScroll.y) ,250, false);
               
               m.easingFunction= Linear.easeInOut;
               m.addEventListener(TweenEvent.TWEEN_UPDATE, redrawEdgesOnTweenUpdate);
               m.addEventListener(EffectEvent.EFFECT_END, moveToNextAnimation);
               _waitBeforeNext ++;
               p.addChild(m);
            } else {
               pearl.moveWithoutZoomOffset(int(0.5 + targetPointWithScroll.x) , int (0.5 +targetPointWithScroll.y)); 
               pearl.refresh();
            }
            
            for each (var child:IPTNode in vn.node.successors) {
               if (!_manipulatedNodeModel.isNodeManipulated(child)) {
                  nodesToProcess.push(child.vnode);
               }
            }
         } 
         if (m!=null) {
            m.addEventListener(TweenEvent.TWEEN_UPDATE, redrawEdgesOnTweenUpdate);
            m.addEventListener(EffectEvent.EFFECT_END, moveToNextAnimation);
            p.play();
         } else {
            moveToNextAnimation();
         }
      }
      public function redrawEdgesOnTweenUpdate(event:Event=null):void {
         _vgraph.refresh();
      }
   }
}