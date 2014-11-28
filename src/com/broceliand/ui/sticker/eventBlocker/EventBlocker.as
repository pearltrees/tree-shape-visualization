package com.broceliand.ui.sticker.eventBlocker
{
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   import mx.containers.Canvas;
   import mx.core.UIComponent;
   
   public class EventBlocker extends Canvas implements IEventBlocker, IEventDispatcher
   {
      private static const TRACE_DEBUG:Boolean = false;
      
      private var _active:Boolean = false;
      private var _exceptions:Array = new Array();
      
      public function EventBlocker() {
         super();
         addEventListener(MouseEvent.CLICK, blockEvent);
         addEventListener(MouseEvent.DOUBLE_CLICK, blockEvent);
         addEventListener(MouseEvent.MOUSE_DOWN, blockEvent);
         addEventListener(MouseEvent.MOUSE_MOVE, blockEvent);
         addEventListener(MouseEvent.MOUSE_OUT, blockEvent);
         addEventListener(MouseEvent.MOUSE_OVER, blockEvent);
         addEventListener(MouseEvent.MOUSE_UP, blockEvent);
         addEventListener(MouseEvent.MOUSE_WHEEL, blockEvent);
         addEventListener(MouseEvent.ROLL_OUT, blockEvent);
         addEventListener(MouseEvent.ROLL_OVER, blockEvent);
         setActive(false);
      }
      
      private function blockEvent(event:MouseEvent):void {
         if(_active && !isOverException(event)) {
            event.stopPropagation();
         }
      }
      
      private function isOverException(event:MouseEvent):Boolean {
         var isOver:Boolean = false;
         
         var localPoint:Point = new Point();
         for each(var comp:UIComponent in _exceptions) {
            localPoint.x = comp.x;
            localPoint.y = comp.y;
            if (!comp.parent) {
               continue;
            }
            var compPosition:Point = comp.parent.localToGlobal(localPoint);
            if (event.stageX < compPosition.x || event.stageX > compPosition.x + comp.width) {
               isOver = false;
            }
            else if (event.stageY < compPosition.y || event.stageY > compPosition.y + comp.height) {
               isOver = false;
            }
            else {
               isOver = true;
               break;
            }
         }
         return isOver;
      }
      
      public function getActive():Boolean {
         return _active;
      }
      
      public function setActive(value:Boolean, addWhitebackground:Boolean=false):void {
         if(TRACE_DEBUG) trace("[EventBlocker] active : " + value);
         _active = value;
         visible = includeInLayout = value;
         if(value && addWhitebackground) {
            setStyle("backgroundColor", 0x000000);
            setStyle("backgroundAlpha", 0.35);
         }else{
            setStyle("backgroundColor", NaN);
            setStyle("backgroundAlpha", NaN);
         }
      }
      
      public function addException(comp:UIComponent):void {
         _exceptions.push(comp);
      }
      public function removeException(comp:UIComponent):void {
         var compIndex:int = _exceptions.indexOf(comp);
         if(compIndex != -1) {
            _exceptions.splice(compIndex, 1);
         }
      }      
   }
}