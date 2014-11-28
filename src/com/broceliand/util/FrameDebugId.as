package com.broceliand.util
{
   import com.broceliand.ApplicationManager;
   
   import flash.events.Event;
   
   import mx.core.Application;
   
   public class FrameDebugId
   {
      private static var _frameDebugId:FrameDebugId;
      private var _frameId:int;
      
      public function set frameId (value:int):void
      {
         _frameId = value;
      }
      
      public function get frameId ():int
      {
         return _frameId;
      }

      public function FrameDebugId()
      {
         Assert.assert(_frameDebugId==null, "frame debugger already instanciated");
         ApplicationManager.flexApplication.addEventListener(Event.ENTER_FRAME, onFrameEnter);
      }
      public static function getInstance():FrameDebugId {
         if(!_frameDebugId) _frameDebugId = new FrameDebugId()
         return _frameDebugId;
      }
      
      public function onFrameEnter(event:Event):void {
         _frameId ++;
      }
   }
}