package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.effects.Zoom;
   import mx.events.TweenEvent;
   
   public class ImportIntoTreeAnimation implements IAction
   {
      private var _vgraph:IPTVisualGraph;
      private var _nodesToRemove:Array;
      private var _functionOnEndAnim:Function;
      private var _rootOfTheTree:IPTNode;
      private var _displayModel:GraphicalDisplayedModel;
      public function ImportIntoTreeAnimation(vgraph: IPTVisualGraph, rootOfTheTree:IPTNode, nodesToImport:Array, displayModel:GraphicalDisplayedModel, onEndAnimation:Function=null)
      {
         _functionOnEndAnim = onEndAnimation;
         _vgraph = vgraph;  
         _nodesToRemove = nodesToImport;
         _rootOfTheTree = rootOfTheTree;
         _displayModel = displayModel; 
      }

      public function performAction():void {
         if (PTRootNode(_rootOfTheTree).isOpen()) {
            _functionOnEndAnim.call();
            
            var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
            garp.notifyEndAction(this);
            garp.postActionRequest(new LayoutAction(_vgraph, false));
            return;
         }
         var p:Parallel = new Parallel();
         var m:Move;
         var targetPoint:Point = _rootOfTheTree.pearlVnode.pearlView.pearlCenter;
         var xTarget:Number = targetPoint.x;
         var yTarget:Number = targetPoint.y;
         
         const DISAPPEAR_DURATION:int = 300; 
         var zoom:Zoom = null;
         
         for each(var descendantNode:IPTNode in _nodesToRemove){
            var pearl:IUIPearl = descendantNode.renderer;
            if (!pearl) {
               continue;
            }
            pearl.pearl.showRings = false;
            pearl.pearl.markAsDisappearing = true;
            
            if (descendantNode.edgeToParent) {
               (descendantNode.edgeToParent.data as EdgeData).visible = false;
            }
            
            m= _vgraph.moveNodeTo(descendantNode.vnode,xTarget, yTarget, DISAPPEAR_DURATION,false);
            p.addChild(m); 

            zoom = new Zoom(descendantNode.renderer);
            zoom.zoomHeightFrom = 1;
            zoom.zoomHeightTo = 0;
            zoom.zoomWidthFrom = 1;
            zoom.zoomWidthTo = 0.001;
            zoom.duration = DISAPPEAR_DURATION;
            p.addChild(zoom);
            
         }
         m.addEventListener(TweenEvent.TWEEN_END, removeAll); 
         _vgraph.refresh();
         p.play(); 
         
      }
      private function removeAll(event:Event):void {
         var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         garp.notifyEndAction(this);
         garp.postActionRequest(new LayoutAction(_vgraph, false));

         var canceLRemove:Boolean = PTRootNode(_rootOfTheTree).isOpen();
         var scale:Number = _rootOfTheTree.pearlVnode.pearlView.getScale();
         
         for each (var n:IPTNode in _nodesToRemove) {
            if (n.isDocked) {
               n.undock();
            }
            if (canceLRemove) {
               n.pearlVnode.pearlView.setScale(scale);
               n.pearlVnode.pearlView.pearl.markAsDisappearing = false;
            } else {
               _displayModel.onNodeRemovedFromGraph(n);
               _vgraph.removeNode(n.vnode);
            }
         }
         
         if (_functionOnEndAnim !=null) {
            _functionOnEndAnim.call();
         }
      }
   }
}