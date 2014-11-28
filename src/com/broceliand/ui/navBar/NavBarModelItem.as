package com.broceliand.ui.navBar {
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   import mx.core.UIComponent;

   public class NavBarModelItem extends EventDispatcher {
      
      public static const MODEL_CHANGE:String = "modelChange";
      
      private var _text:String = null;
      private var _enabled:Boolean = true;
      private var _resizeToFit:Boolean = false;
      private var _selected:Boolean = false;
      private var _isBold:Boolean= false;
      
      public function set text(value:String):void {
         if(value != _text) {
            _text = value;
            dispatchChangeEvent();
         }
      }
      public function get text():String {
         return _text;
      }
      
      public function set enabled(value:Boolean):void {
         if(value != _enabled) {
            _enabled = value;
            dispatchChangeEvent();
         }
      }
      public function get enabled():Boolean {
         return _enabled;
      }      
      
      public function set selected(value:Boolean):void {
         if(value != _selected) {
            _selected = value;
            dispatchChangeEvent();
         }
      }
      public function get selected():Boolean {
         return _selected;
      } 
      
      public function set resizeToFit(value:Boolean):void {
         if(value != _resizeToFit) {
            _resizeToFit = value;
            dispatchChangeEvent();
         }
      }
      public function get resizeToFit():Boolean {
         return _resizeToFit;
      }
      
      private function dispatchChangeEvent():void {
         dispatchEvent(new Event(MODEL_CHANGE));
      }
      
      public function set isBold(isBold:Boolean):void {
         _isBold = isBold;
      }
      
      public function get isBold():Boolean {
         return _isBold;
      }
   }
}