package com.broceliand.util.error {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.system.Capabilities;

   public class UncaughtErrorHandler {
      
      private var _log:BroLogger = Log.getLogger('com.broceliand.util.error');
      
      public function UncaughtErrorHandler() {
         ApplicationManager.flexApplication.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
      }
      
      private function onUncaughtError(event:UncaughtErrorEvent):void {
         var message:String = "";
         
         if (event.error is Error) {
            if(Capabilities.isDebugger) {
               message = Error(event.error).getStackTrace();
            }else{
               message = Error(event.error).message;
            }
         }
         else if (event.error is ErrorEvent) {
            message = ErrorEvent(event.error).text;
         }
         else {
            message = event.error.toString();
         }        
         
         _log.info(" Uncaught Error : {0}", message);
      }
   }
}