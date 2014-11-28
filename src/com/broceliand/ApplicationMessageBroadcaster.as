package com.broceliand
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ApplicationMessageBroadcaster extends EventDispatcher
   {
      public static const WHITE_MARK_CHANGED_EVENT:String = "whitemarkEvent";
      
      public function ApplicationMessageBroadcaster()
      {
      }
      public function broadcastMessage(event:Event):void {
         dispatchEvent(event);
      }
   }
}