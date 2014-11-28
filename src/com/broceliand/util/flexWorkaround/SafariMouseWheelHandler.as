package com.broceliand.util.flexWorkaround
{
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Mouse;
   
   import mx.core.Application;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;

   public class SafariMouseWheelHandler
   {
      private static var _singleton:SafariMouseWheelHandler;
      
      private var _lastMousePoint:Point;
      private var _lastObject:InteractiveObject;

      public static function getInstance():SafariMouseWheelHandler {
         if (!_singleton) {
            _singleton = new SafariMouseWheelHandler();
         }
         return _singleton;
      }
      
      public function handleWheel(event : Object) : void {
         var obj : InteractiveObject = null;
         var applicationStage : Stage = Application.application.stage as Stage;
         
         var mousePoint : Point = new Point(applicationStage.mouseX, applicationStage.mouseY);
         if (mousePoint == _lastMousePoint) {
            obj = _lastObject;
         } else {
            var objects : Array = applicationStage.getObjectsUnderPoint(mousePoint);
            
            for (var i : int = objects.length - 1; i >= 0; i--) {
               if (objects[i] is InteractiveObject) {
                  obj = objects[i] as InteractiveObject;
                  break;
               }
               else {
                  if (objects[i] is Shape && (objects[i] as Shape).parent) {
                     obj = (objects[i] as Shape).parent;
                     break;
                  }
               }
            }
            _lastMousePoint = mousePoint; 
            _lastObject  = obj;
         }
         
         if (obj) {
            var mEvent : MouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false,
               mousePoint.x, mousePoint.y, obj,
               event.ctrlKey, event.altKey, event.shiftKey,
               false, Number(event.delta));
            obj.dispatchEvent(mEvent);
         }
      }
      
      public function invalidateObjectUnderCursor():void {
         _lastMousePoint = null;
         _lastObject = null;
      }

   }
}