package com.broceliand.graphLayout.layout
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.IAction;
   
   import flash.utils.Dictionary;
   
   public class UpdateTitleRendererLayout implements IAction
   {
      
      private var _vgraph:IPTVisualGraph;
      private var _queue:GraphicalAnimationRequestProcessor;
      public function UpdateTitleRendererLayout(vgraph:IPTVisualGraph, queue:GraphicalAnimationRequestProcessor = null) {
         _vgraph = vgraph;
         _queue = queue;
      }
      public function performAction():void {
         var visVNodes:Dictionary = _vgraph.visibleVNodes;
         var vn:IPTVisualNode;
         for each(vn in visVNodes) {
            var pv:IUIPearl = vn.pearlView;
            if (pv && pv.titleRenderer) pv.titleRenderer.updateOrientation();
         }
         if (_queue) {
            _queue.notifyEndAction(this);
         }
      }
      
      public static function scheduleTitleRendererLayout(vgraph:IPTVisualGraph):void {
         var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         garp.postActionRequest(new UpdateTitleRendererLayout(vgraph,garp), 1000);
      }
      public static function updateTitleRendererNow(vgraph:IPTVisualGraph):void  {
         new UpdateTitleRendererLayout(vgraph).performAction();
      }
      
   }
}