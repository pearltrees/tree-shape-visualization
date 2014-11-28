package com.broceliand.util.logging
{
   import com.broceliand.util.BroLocale;
   
   import mx.logging.ILogger;
   import mx.logging.LogEvent;

   public class BroLogEvent extends LogEvent
   {
      private var _args:Array;
      private var _msgType:String;
      
      public function BroLogEvent(level:int, msgType:String, args:Array)
      {
         super(BroLocale.formatMessage(msgType, args), level);
         _msgType = msgType;
         _args = args;
      }
      public function makeLogAction():LogAction {
         return new LogAction(_msgType , _args, ILogger(target).category);
      }
      
      public function set args (value:Array):void
      {
         _args = value;
      }
      
      public function get args ():Array
      {
         return _args;
      }
   }
}