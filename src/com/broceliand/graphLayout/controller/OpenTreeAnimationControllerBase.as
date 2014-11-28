package com.broceliand.graphLayout.controller
{
   import com.broceliand.graphLayout.layout.UpdateTitleRendererLayout;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class OpenTreeAnimationControllerBase extends EventDispatcher implements IOpenTreeAnimationController 
   {
      protected var _vgraph:IPTVisualGraph = null; 
      protected var _isAnimating:Boolean;
      protected var _cleaningTimer:Timer; 
      protected var _treeTargetState:String;
      protected var _tree:IPearlTreeModel=null;
      private   var _request:IAction;
      private   var _animationProcessor:GraphicalAnimationRequestProcessor;
      
      public static const ANIMATION_ENDED_EVENT:String="AnimationEndedEvent";
      
      public function OpenTreeAnimationControllerBase(request:IAction, animationProcessor:GraphicalAnimationRequestProcessor) 
      {
         super();
         _request = request;
         _animationProcessor = animationProcessor;
      }
      
      public function get isAnimating():Boolean {
         return _isAnimating;
      }
      
      protected function setIsAnimating(value:Boolean):void {
         _isAnimating = value;
         if (_vgraph) {
            UpdateTitleRendererLayout.updateTitleRendererNow(_vgraph);
         }
         if (!value) {
            
            _animationProcessor.notifyEndAction(_request);

            dispatchEvent(new Event(ANIMATION_ENDED_EVENT));
         }
      }
      
      protected function startAnimation(isOpening:Boolean):void  {
         _cleaningTimer = new Timer(4900);
         if (isOpening) {
            _treeTargetState= OpeningState.OPEN;
         } else {
            _treeTargetState= OpeningState.CLOSED;
         }
         _cleaningTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endAnimation);
         setIsAnimating(true);
         _cleaningTimer.start();
      }
      
      protected function endAnimation(e:Event=null):void {
         if (_cleaningTimer && _cleaningTimer.stop()) {
            _cleaningTimer =null;
         }  
         if (_tree){
            _tree.openingState = _treeTargetState;
         }
         
         setIsAnimating(false); 

      }  
   }
}