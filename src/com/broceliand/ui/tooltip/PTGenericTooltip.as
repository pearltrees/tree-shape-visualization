package com.broceliand.ui.tooltip {
   
   import com.broceliand.ui.PTStyleManager;
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.display.Graphics;
   
   import mx.containers.Canvas;
   import mx.controls.Label;
   import mx.core.IToolTip;
   import mx.core.UIComponent;

   public class PTGenericTooltip extends Canvas implements IToolTip {
      
      private var _background:UIComponent;
      private var _label:Label;
      private var _text:String;
      private var _textChanged:Boolean;

      public static const TOOLTIP_ENABLER_PREFIX:String = "²µ°"
      public static const TOOLTIP_SHOW_DELAY:int = 3000;
      public static const TOOLTIP_SHOW_DELAY_SHORT:int = 750;
      
      public function PTGenericTooltip() {
         super();
      }
      override protected function createChildren():void {
         _background = new UIComponent();
         addChild(_background);
         _label = new Label();
         _label.text = _text;
         _label.percentWidth = 100;
         _label.setStyle('textAlign', 'center');
         _label.setStyle('fontSize', 11);
         _label.setStyle('fontWeight', 'bold');
         _label.setStyle('fontFamily', PTStyleManager.SYSTEM_FONT_FAMILY);
         _label.setStyle('paddingLeft', 3);
         _label.setStyle('paddingRight', 2);
         _label.setStyle('paddingBottom', 0);
         _label.setStyle('paddingTop', 0);
         _label.setStyle('color', ColorPalette.getInstance().pearltreesDarkColor);
         addChild(_label);
      }
      
      override protected function commitProperties():void{
         super.commitProperties();
         if (_textChanged) {
            _textChanged = false;
            if (_text) {
               _label.text = _text;
               visible = true;
            }
            else {
               visible = false;
            }
         }
      }
      
      override public function move(x:Number, y:Number):void {
         
         var mX:Number = parent.mouseX;
         var mY:Number = parent.mouseY;
         
         var newX:Number = mX - width + 4;
         var newY:Number = mY + 15;

         if (newX < 0) {
            newX = 0;
         }
         
         if (newY + height > screen.height) {
            newY = screen.height - height;
         }
         
         if (newX <= mX && mX <= newX + width && newY <= mY && mY <= newY + height) {
            
            newX = mX - width - 4;
            if (newX < 0) { 
               newX = mX + 11; 
            }
         }
         super.move(newX, newY);
      }
      
      override protected function updateDisplayList(w:Number, h:Number):void {
         super.updateDisplayList(w, h);
         if(_background) {
            var cornerRadian:Number = 6;
            var g:Graphics = _background.graphics;
            g.clear();
            g.beginFill(ColorPalette.getInstance().backgroundColor, 0.85);
            g.drawRoundRect(0, 0, w, h, cornerRadian, cornerRadian);
            g.endFill();
         }
      }
      
      public function set text(value:String):void {
         if (value &&  value.substr(0, TOOLTIP_ENABLER_PREFIX.length) == TOOLTIP_ENABLER_PREFIX) {
            _text = value.substr(TOOLTIP_ENABLER_PREFIX.length);
         }
         else {
            _text = null;
         }
         _textChanged = true;
         invalidateProperties();
         invalidateDisplayList();
         invalidateSize();
      }
      
      public function get text():String {
         return _text;
      }
      
      override public function set visible(value:Boolean):void {
         if (_text && value) {
            super.visible = true;
         }
         else {
            super.visible = false;
         }
      }
   }
}