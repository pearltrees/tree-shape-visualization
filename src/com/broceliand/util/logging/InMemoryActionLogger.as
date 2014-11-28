package com.broceliand.util.logging
{
   import mx.logging.LogEvent;

   public class InMemoryActionLogger extends BroFormattedTarget
   {
      private var _logActions:MaxSizedStack;
      public function InMemoryActionLogger(memoryMaxSize:int = 300)
      {
         _logActions = new MaxSizedStack(memoryMaxSize);
      }
      
      override public function logEvent(event:LogEvent):void {
         var broLogEvent:BroLogEvent  = event as BroLogEvent;
         if (broLogEvent) {
            _logActions.push(broLogEvent.makeLogAction());
         }
      }
      
      public function getActions():String {
         var result:String = new String();
         for (var i:int =0; i< _logActions.length; i++) {
            var la:LogAction = _logActions.getElement(i) as LogAction;
            result += super.computeMessage(la.toString(), la.date, la.category)+"\n";
         }
         return result;
      }
      
   }
}