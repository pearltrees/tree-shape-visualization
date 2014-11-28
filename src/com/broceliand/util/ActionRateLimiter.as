package com.broceliand.util
{
   import com.broceliand.ApplicationManager;
   
   import mx.core.Application;
   
   public class ActionRateLimiter
   {
      private var _maxActionByRate:int;
      private var _actionStack:Array = new Array();
      private var _numberOfActionDoneThisFrame:int;
      private var _requestResetOnNextFrame:Boolean  = false;
      
      public function ActionRateLimiter(maxActionRate:int)
      {
         _maxActionByRate = maxActionRate;
      }
      
      public function addActionToPerform(action:IAction):void {
         if (_numberOfActionDoneThisFrame< _maxActionByRate) {
            performAction(action);
         } else {
            _actionStack.push(action);
         }
      }
      
      private function performAction(action:IAction):void {
         requestResetOnNextFrame();
         _numberOfActionDoneThisFrame ++;
         action.performAction();
      }
      private  function requestResetOnNextFrame():void {
         if (!_requestResetOnNextFrame) {
            _requestResetOnNextFrame = true;
            ApplicationManager.flexApplication.callLater(onNextFrameEnter)
         }
      }
      private function onNextFrameEnter():void {
         _numberOfActionDoneThisFrame =0;
         _requestResetOnNextFrame = false;
         performPendingAction();
      }
      private function performPendingAction():void {
         var actionDone:int =0; 
         while (_actionStack.length>0 && actionDone<_maxActionByRate) {
            var action:IAction = _actionStack.shift();
            performAction(action);
            actionDone++;
         }
      }
      
   }
}