package com.broceliand.ui.interactors {
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.GestureEvent;
   import flash.events.PressAndTapGestureEvent;
   import flash.events.TouchEvent;
   import flash.events.TransformGestureEvent;
   import flash.system.Capabilities;
   import flash.system.TouchscreenType;
   import flash.ui.Multitouch;
   
   public class GestureInteractor implements IGestureInteractor {
      
      private var _log:BroLogger = Log.getLogger('com.broceliand.ui.interactors.gesture');
      
      private var _interactorManager:InteractorManager;
      
      public function GestureInteractor(interactorManager:InteractorManager) {
         _interactorManager = interactorManager;
         _interactorManager.pearlTreeViewer.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoomGesture);
         _interactorManager.pearlTreeViewer.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
         _interactorManager.pearlTreeViewer.addEventListener(PressAndTapGestureEvent.GESTURE_PRESS_AND_TAP, onPressAndTap);
         _interactorManager.pearlTreeViewer.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, onTwoFingerTap);
         _log.info(" InputMode : {0}", Multitouch.inputMode);
         _log.info(" TouchscreenType : {0}", Capabilities.touchscreenType);
         _log.info(" Events supported ? {0}", Multitouch.supportsTouchEvents);            
         _log.info(" Gestures supported ? {0}", Multitouch.supportsGestureEvents);
         _log.info(" Gestures: {0}", Multitouch.supportedGestures);       
      }
      
      private function onZoomGesture(event:TransformGestureEvent):void {
         
         _log.info(" Zoom gesture fired ! ");
         _interactorManager.pearlTreeViewer.vgraph.controls.zoomControl.onZoomGesture(event.scaleX,event.scaleY);
      }
      
      private function onPressAndTap(event:PressAndTapGestureEvent):void {
         _log.info(" PressAndTap fired ! ");
      }
      
      private function onTwoFingerTap(event:GestureEvent):void {
         _log.info(" TwoFingerTap fired ! ");
      }
      
      private function onTouchBegin(event:TouchEvent):void {
         _log.info(" Touch begin (x: {0}, y: {1})", event.stageX, event.stageY);
         _log.info(" Mouse position: (x: {0}, y: {1})", _interactorManager.mousePosition.x, _interactorManager.mousePosition.y);
      }
      
      public function isTouchScreen():Boolean {
         return (Capabilities.touchscreenType == TouchscreenType.FINGER);
      }
   }
}