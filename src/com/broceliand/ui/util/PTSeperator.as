package com.broceliand.ui.util {
   
   import flash.display.Graphics;
   
   import mx.core.UIComponent;
   
   public class PTSeperator extends UIComponent {
      
      private static const THICKNESS:Number = 1;
      
      private var _paddingLeft:Number = 0;
      private var _paddingRight:Number = 0;
      private var _paddingTop:Number = 5;
      private var _paddingBottom:Number = 5;
      private var _color:uint = ColorPalette.getInstance().pearltreesColor;
      
      public function PTSeperator() {
         super();
         percentWidth = 100;
      }
      
      override protected function commitProperties():void {
         super.commitProperties();
         
         height = _paddingTop + THICKNESS + _paddingBottom;
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         
         var lineWidth:Number = unscaledWidth - _paddingLeft - _paddingRight;
         
         var g:Graphics = graphics;
         g.clear();
         g.beginFill(_color);
         g.drawRect(_paddingLeft, _paddingTop, lineWidth, THICKNESS);
         g.endFill();
      }
      
      public function set color(value:uint):void {
         if(value != _color) {
            _color = value;
            invalidateDisplayList();
            invalidateProperties();
            invalidateSize();
         }
      }
      
      public function set paddingLeft(value:Number):void {
         if(value != _paddingLeft) {
            _paddingLeft = value;
            invalidateDisplayList();
            invalidateProperties();
            invalidateSize();
         }
      }
      
      public function set paddingRight(value:Number):void {
         if(value != _paddingRight) {
            _paddingRight = value;
            invalidateDisplayList();
            invalidateProperties();
            invalidateSize();
         }
      } 
      
      public function set paddingTop(value:Number):void {
         if(value != _paddingTop) {
            _paddingTop = value;
            invalidateDisplayList();
            invalidateProperties();
            invalidateSize();
         }
      }
      
      public function set paddingBottom(value:Number):void {
         if(value != _paddingBottom) {
            _paddingBottom = value;
            invalidateDisplayList();
            invalidateProperties();
            invalidateSize();
         }
      }      
   }
}