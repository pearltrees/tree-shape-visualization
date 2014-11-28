package com.broceliand.ui.effects
{
   import flash.events.Event;
   
   public class ForwardBackwardTogglerBase
   {
      public static const PLAYED_FORWARD:int = 1; 
      public static const PLAYING_FORWARD:int = 2; 
      public static const PLAYED_BACKWARD:int = 3; 
      public static const PLAYING_BACKWARD:int = 4;
      
      protected var _state:int;
      protected var _targetState:int;
      protected var _waitForEndOfForwardAnim:Boolean; 
      protected var _waitForEndOfBackwardAnim:Boolean;
      
      public function ForwardBackwardTogglerBase(waitForEndOfForwardAnim:Boolean = true, waitForEndOfBackwardAnim:Boolean = true){
         _state = PLAYED_BACKWARD; 
         _targetState = PLAYED_BACKWARD;
         _waitForEndOfForwardAnim = waitForEndOfForwardAnim;
         _waitForEndOfBackwardAnim =waitForEndOfBackwardAnim;
      }
      
      public function get state():int {
         return _state;
      }
      public function get targetState():int {
         return _targetState;
      }
      
      public function playForward():void{
         _targetState = PLAYED_FORWARD;
         if((_state == PLAYED_BACKWARD) || ((_state == PLAYING_BACKWARD) && !_waitForEndOfBackwardAnim)){
            handledObjectPlayForward();            
            _state = PLAYING_FORWARD;
         }
      }
      
      public function playBackward():void{
         _targetState = PLAYED_BACKWARD;
         if((_state == PLAYED_FORWARD) ||!_waitForEndOfForwardAnim){
            handledObjectPlayBackward();            
            _state = PLAYING_BACKWARD;
         }
      }
      
      protected function handledObjectPlayForward():void{
         
      }
      
      protected function handledObjectPlayBackward():void{
         
      }

      protected function onEnd(event:Event):void{
         switch(_state){
            case PLAYING_FORWARD:
               _state = PLAYED_FORWARD;
               break;
            case PLAYING_BACKWARD:
               _state = PLAYED_BACKWARD;
               break;
         }
         if(_state != _targetState){
            switch(_state){
               case PLAYED_FORWARD:
                  playBackward();
                  break;
               case PLAYED_BACKWARD:
                  playForward();
                  break;
            }
            
         }
      }
      
   }
}