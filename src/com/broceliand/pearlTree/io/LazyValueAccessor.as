package com.broceliand.pearlTree.io
{
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   
   import mx.rpc.events.FaultEvent;
   
   public class LazyValueAccessor
   {
      private var _value:Object;
      protected var _owner:Object;
      private var _pendingCallback:Array;
      protected var _errorCount:int = 0;
      public function LazyValueAccessor()
      {
      }
      public function loadValue(updateCB:IAction):void {
         if (_value) {
            updateCB.performAction();
         } else {
            if (_pendingCallback) {
               _pendingCallback.push(updateCB);
            } else {
               _pendingCallback = new Array();
               _pendingCallback.push(updateCB);
               launchLoadValue();
            }
         }
      }
      
      public function resetValue():void {
         _value = null;
      }
      
      public function set owner(value:Object):void {
         _owner = value;
      }
      
      public function onError(message:FaultEvent):void {
         Log.getLogger("com.broceliand.pearlTree.io").error("Error Loading lazy value :{0}", message);
         _errorCount ++;
         _pendingCallback = null;
      }
      protected function notifyValueAvailable():void {
         for each (var action:IAction in _pendingCallback) {
            action.performAction();
         }
         _pendingCallback  = null;      
      }
      
      public function isLoaded():Boolean {
         return  _value!= null;
      }
      protected function launchLoadValue():void  {
         
      }
      
      protected function get internalValue():Object
      {
         return _value;
      }
      
      protected function set internalValue(value:Object):void
      {
         _value = value;
      }
   }
}

