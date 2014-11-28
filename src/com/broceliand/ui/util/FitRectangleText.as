package com.broceliand.ui.util
{
   import com.broceliand.ui.PTStyleManager;
   
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   import mx.controls.Text;
   import mx.core.mx_internal;

   public class FitRectangleText extends NonScrollableText
   {
      public static const TYPO_UPDATED:String = "typoUpdated";
      
      private var _maxTypo : int;
      private var _minTypo : int;
      private var _rect: Rectangle;
      
      public function FitRectangleText()
      {
         super();
      }
      
      public static function measureTextHeight(text:String, format:TextFormat, rectWidth:int):int {
         var tField:TextField = getRepresentativeTextField(text, format, rectWidth);
         return tField.textHeight;
      }
      
      private static function getRepresentativeTextField(text:String, format:TextFormat, width:int):TextField {
         var tField:TextField = new TextField();
         tField.defaultTextFormat = format;
         tField.width = width;
         tField.wordWrap = true;
         tField.text = text;
         return tField;
      }
      
      public function maxTypoToFitRectangle(textValue:String, rect:Rectangle):int {
         if (rect.width <= 0) {
            return 0;
         }
         var lowLimit:int = _minTypo;
         var hiLimit:int = _maxTypo;
         var currentTypo:int = (hiLimit + lowLimit) / 2;
         var currentHeight:int = 0;
         var format:TextFormat = new TextFormat();
         format.font = this.getStyle("fontFamily");
         format.leading = this.getStyle("leading");
         
         while (hiLimit - lowLimit > 1) {
            format.size = currentTypo;
            currentHeight = measureTextHeight(textValue, format, rect.width);
            if (currentHeight > rect.height) {
               hiLimit = currentTypo - 1;
            }
            else if (currentHeight < rect.height) {
               lowLimit = currentTypo;
            }
            else {
               return currentTypo;
            }
            currentTypo = ( hiLimit + lowLimit ) / 2;
         }
         
         format.size = hiLimit;
         currentHeight = measureTextHeight(textValue, format, rect.width);
         if (currentHeight < rect.height) {
            return hiLimit;
         }
         else {
            return lowLimit;
         }
      }
      
      public function setTextAndBorder(t:String, b:Rectangle):void {
         text = t;
         rect = b;
         updateTypo();
         truncateTextIfNeeded();
         invalidateProperties();
      }
      
      public function set rect(value:Rectangle):void
      {
         if (_rect && _rect.height == value.height && _rect.width == value.width) {
            return;
         }
         _rect = value;
      }
      
      public function updateTypo():void {
         var typo:int = maxTypoToFitRectangle(this.text, rect);
         this.setStyle("fontSize", typo);
         dispatchEvent(new Event(TYPO_UPDATED));
      }
      
      private function truncateTextIfNeeded():void {
         var typo:int = getStyle("fontSize");
         var format:TextFormat = new TextFormat();
         format.size = getStyle("fontSize");
         format.leading = getStyle("leading");
         format.font = getStyle("fontFamily");
         if (typo > _minTypo) return;
         if (measureTextHeight(text, format, _rect.width) <= _rect.height) return;
         for (var i:int = text.length - 3; i >= 0; i--) {
            if (text.charAt(i) == " ") {
               continue;
            }
            var newText:String = text.substr(0, i+1) + "...";
            if (measureTextHeight(newText, format, _rect.width) < _rect.height) {
               text = newText;
               return;
            }
         }
      }
      
      public static function measureInSystemFont(t:String, fontSize:int):Number {
         var format:TextFormat = new TextFormat();
         format.size = fontSize;
         format.font = PTStyleManager.SYSTEM_FONT_FAMILY;
         var tField:TextField = new TextField();
         tField.width = 495;
         tField.defaultTextFormat = format;
         tField.wordWrap = true;
         tField.text = t;
         return tField.getLineMetrics(0).width;
      }
      
      public function get maxTypo():int
      {
         return _maxTypo;
      }
      
      public function set maxTypo(value:int):void
      {
         _maxTypo = value;
      }
      
      public function get minTypo():int
      {
         return _minTypo;
      }
      
      public function set minTypo(value:int):void
      {
         _minTypo = value;
      }
      
      public function get rect():Rectangle
      {
         return _rect;
      }
      
   }
}