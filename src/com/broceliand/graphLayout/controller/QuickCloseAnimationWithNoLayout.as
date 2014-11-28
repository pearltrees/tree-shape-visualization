package com.broceliand.graphLayout.controller
{
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.interactors.DepthInteractor;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   
   import mx.effects.Fade;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.events.EffectEvent;
   
   public class QuickCloseAnimationWithNoLayout extends CloseTreeAnimation
   {
      private var _nodesToDelete:Array;
      public function QuickCloseAnimationWithNoLayout(request:IAction, animationProcessor:GraphicalAnimationRequestProcessor)
      {
         super(request, animationProcessor);
      }
      override protected function playDisappearAnimation():void {
         _nodesToDelete = super.playQuickCloseAnimation();
      }
      
      override protected function canNodeBeRemoved(node:IPTNode, manipulatedNodeModel:ManipulatedNodesModel):Boolean { 
         return true;
      }
      
      override protected function onEndDisapparition(e:Event):void {
         var im:InteractorManager= ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
         if (im.draggedPearl != _fixedVNode.view) {
            im.depthInteractor.movePearlToNormalDepth(_fixedVNode.view as IUIPearl);
         } 
         
         if (_nodesToDelete) {
            for each (var n:IPTNode in _nodesToDelete) {
               if (n != _fixedVNode.node) {
                  _vgraph.removeNode(n.vnode);
               }
            }
         }
         updateCloseTreeStates();
         endAnimation(); 
      }
   }
}