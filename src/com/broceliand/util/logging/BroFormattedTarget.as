package com.broceliand.util.logging
{
   import mx.logging.ILogger;
   import mx.logging.LogEvent;
   import mx.logging.targets.LineFormattedTarget;
   
   public class BroFormattedTarget extends LineFormattedTarget
   {
      
      override public function logEvent(event:LogEvent):void { 
         internalLog(computeMessage(event.message, new Date(), ILogger(event.target).category, event.level)); 
      }
      
      protected function computeMessage(message:String, d:Date, category:String = "", levelValue:int= 4):String { 
         var date:String = ""
         if (includeDate || includeTime) {
            if (includeDate)
            {
               date = Number(d.getMonth() + 1).toString() + "/" +
                  d.getDate().toString() + "/" + 
                  d.getFullYear() + fieldSeparator;
            }   
            if (includeTime)
            {
               date += padTime(d.getHours()) + ":" +
                  padTime(d.getMinutes()) + ":" +
                  padTime(d.getSeconds()) + "." +
                  padTime(d.getMilliseconds(), true) + fieldSeparator;
            }
         }
         
         var level:String = "";
         if (includeLevel) {
            level = "[" + LogEvent.getLevelString(levelValue) +
               "]" + fieldSeparator;
         }
         
         var category:String = includeCategory ?
            category :
            "";
         
         return "["+date + level + category + "] " + message;
      }
      
      private function padTime(num:Number, millis:Boolean = false):String {
         if (millis)
         {
            if (num < 10)
               return "00" + num.toString();
            else if (num < 100)
               return "0" + num.toString();
            else 
               return num.toString();
         }
         else
         {
            return num > 9 ? num.toString() : "0" + num.toString();
         }
      }
      
      protected function internalLog(message:String):void {
         trace(message)
      }
      
   }
}