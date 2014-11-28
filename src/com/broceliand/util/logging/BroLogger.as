package com.broceliand.util.logging
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.Alert;
   import com.broceliand.util.BroLocale;
   
   import flash.events.EventDispatcher;
   
   import mx.logging.ILogger;
   import mx.logging.LogEvent;
   import mx.logging.LogEventLevel;

   public class BroLogger extends EventDispatcher implements ILogger 
   {
      private var _isUsed:Boolean = false;
      private var _category:String;
      public function BroLogger(category:String)
      {
         _category = category;
         
         var lastIndexOfDot:int = _category.lastIndexOf(".");
         if (lastIndexOfDot != -1) {
            _category = _category.substr(lastIndexOfDot);
         }
      }
      public function get isUsed():Boolean {
         return _isUsed;
      }
      public function get category():String {
         return _category;
      }
      override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
         super.addEventListener(type,listener, useCapture, priority, useWeakReference);
         _isUsed = true;
      }
      
      public function log(level:int, msg:String, ... rest):void {
         logInternal(level, msg, rest);
      }

      private function logInternal(level:int, msg:String, rest:Array):void
      {
         if (hasEventListener(LogEvent.LOG))
         {

            dispatchEvent(new BroLogEvent(level, msg ,rest));
         }
         
         if (level >= LogEventLevel.WARN) {
            trace(new Date().toTimeString() + "["+LogEvent.getLevelString(level)+":"+ category+"+]"+BroLocale.formatMessage(msg,rest));
            if (level >= LogEventLevel.ERROR && ApplicationManager.getInstance().isDebug) {
               Alert.show(BroLocale.formatMessage(msg,rest));
            }
         }

      }
      
      public function debug(msg:String, ... rest):void
      {
         logInternal(LogEventLevel.DEBUG, msg, rest);
      }
      
      public function error(msg:String, ... rest):void
      {
         logInternal(LogEventLevel.ERROR, msg, rest);
      }
      
      public function fatal(msg:String, ... rest):void
      {
         logInternal(LogEventLevel.FATAL, msg, rest);
      }
      public function info(msg:String, ... rest):void
      {
         logInternal(LogEventLevel.INFO, msg, rest);
      }
      
      public function warn(msg:String, ... rest):void
      {
         logInternal(LogEventLevel.WARN, msg, rest);
      }
   }
}
