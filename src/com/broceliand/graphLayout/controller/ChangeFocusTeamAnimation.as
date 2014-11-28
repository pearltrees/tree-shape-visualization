package com.broceliand.graphLayout.controller
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.interactors.EditionController;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   
   import mx.effects.Fade;
   import mx.effects.Parallel;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   
   public class ChangeFocusTeamAnimation implements IAction
   {
      private var _editionController:IPearlTreeEditionController;
      private var _animationProcessor:GraphicalAnimationRequestProcessor;
      private var _vgraph:IVisualGraph;
      private var _nodesToDelete:Array;
      public function ChangeFocusTeamAnimation(animationProcessor:GraphicalAnimationRequestProcessor, edc:IPearlTreeEditionController, vgraph:IVisualGraph)
      {
         _animationProcessor = animationProcessor;
         _editionController = edc;
         _vgraph = vgraph;
      }
      public function performAction():void {
         _nodesToDelete= _editionController.clearGraph(false);
         playDisappearAnimation(_nodesToDelete);
      }
      private function removeAllNodes(nodes:Array):void {
         
         for each (var n:IPTNode in nodes) {
            _vgraph.removeNode(n.vnode);
         }
         _animationProcessor.notifyEndAction(this);
      }
      protected function playDisappearAnimation(nodes:Array):void {
         var par:Parallel = new Parallel();
         var effect:Fade=null;
         var duration:int = 500;
         for each (var n:IPTNode in nodes) {
            if (!n.vnode.view || !n.vnode.view.visible || n.vnode.view.alpha ==0) {
               continue;
            }
            effect = new Fade(n.vnode.view);
            effect.duration = duration;
            effect.alphaFrom =1;
            effect.alphaTo = 0;
            par.addChild(effect);
         }
         if (effect) {
            effect.addEventListener(TweenEvent.TWEEN_END,onEndDisapparition);
         } else {
            onEndDisapparition(null);
         }
         par.play();
      }
      private function onEndDisapparition(e:Event):void {
         if (e && e.target) {
            e.target.removeEventListener(TweenEvent.TWEEN_END,onEndDisapparition);
         }
         removeAllNodes(_nodesToDelete);
      }

   }
}