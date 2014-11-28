package com.broceliand.util.resources
{
   
   import com.broceliand.util.IAction;
   import flash.events.Event;
   public class ProcessOnUrlCompletedAction implements IAction
   {
      private var _remoteResourceManager:RemoteResourceManager;
      private var _event:Event;
      private var _isSuccess:Boolean;
      private var _errorCode:int = -1;
      
      public function ProcessOnUrlCompletedAction(remoteResourceManager:RemoteResourceManager,event:Event, isSuccess:Boolean = true, errorCode:int = -1):void {
         _remoteResourceManager = remoteResourceManager;
         _event = event;
         _isSuccess = isSuccess;
         _errorCode = errorCode;   
      }
      
      public function performAction():void {
         _remoteResourceManager.processOnUrlCompleted(_event, _isSuccess, _errorCode);
      }
      
   }
}