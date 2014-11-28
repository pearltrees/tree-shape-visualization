package com.broceliand.util {
   
   import com.broceliand.ApplicationManager;
   
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.Event;
   
   import mx.core.UIComponent;
   import mx.managers.FocusManager;
   import mx.managers.IFocusManager;
   import mx.managers.IFocusManagerComponent;
   import mx.managers.IFocusManagerContainer;

   public class PTFocusManager extends FocusManager {
      
      private static const DEBUG:Boolean = false;
      
      private var _lastFocusObject:Object;
      
      override public function PTFocusManager(container:IFocusManagerContainer, popup:Boolean=false) {
         super(container, popup);
         if(DEBUG) {
            container.addEventListener(Event.ENTER_FRAME, onEnterFrame);
         }
      }
      
      private function onEnterFrame(event:Event):void {
         var currentFocus:Object = getFocus();
         if(currentFocus != _lastFocusObject) {
            _lastFocusObject = currentFocus; 
            if(_lastFocusObject) {
               trace("Focus: "+_lastFocusObject.name);
            }else{
               trace("Focus null");
            }
         }
      }   
      
      public static function unfocus(comp:UIComponent):void {
         if (!comp || !comp.focusManager) {
            return;
         }
         var currentFocus:IFocusManagerComponent = comp.focusManager.getFocus();
         if(comp && currentFocus == comp) {
            var stage:Stage = ApplicationManager.flexApplication.stage;
            if(stage) {
               stage.focus = null;
            }
            var parentComp:UIComponent = comp.parent as UIComponent;
            if(parentComp) {
               parentComp.setFocus();
            }
         }
      }
   }
}