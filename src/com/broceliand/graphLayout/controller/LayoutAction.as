package com.broceliand.graphLayout.controller {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.layout.PTLayouterBase;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   
   public class LayoutAction implements IAction {
      private var _slowLayout:Boolean;
      private var _vgraph:IPTVisualGraph; 
      public function LayoutAction(vgraph:IPTVisualGraph, slowLayout:Boolean) {
         _vgraph = vgraph;
         _slowLayout = slowLayout;
      }
      public function performAction():void {
         
         _vgraph.PTLayouter.addEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, onEndLayouting);
         
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         
         _vgraph.PTLayouter.setPearlTreesWorldLayout(navModel.isShowingPearlTreesWorld());
         if (_slowLayout) {
            _vgraph.PTLayouter.performSlowLayout();
         } else {
            _vgraph.layouter.layoutPass();
         }
         _vgraph.PTLayouter.setPearlTreesWorldLayout(false);
         
      }
      public function onEndLayouting(event:Event):void {
         _vgraph.PTLayouter.removeEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, onEndLayouting);
         var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         garp.notifyEndAction(this);     
      }
   }
}
