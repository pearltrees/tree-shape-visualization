package com.broceliand.ui.util
{
   import mx.controls.Label;
   
   public class LabelFontAdjuster
   {
      private var _label:Label;
      private var _minFontSize:int;
      private var _maxFontSize:int;
      private var _labelFontSize:int;
      public function LabelFontAdjuster(label:Label, minFontSize:int, maxFontSize:int) {
         _label = label;
         _maxFontSize = maxFontSize;
         _minFontSize = minFontSize;
         labelFontSize = maxFontSize;
      }
      
      private function set labelFontSize(size:Number):void {
         if (_labelFontSize != size) {
            _labelFontSize = size;
            _label.setStyle("fontSize", _labelFontSize);
         }
      }

      public function adjustSize(maxWidth:int):void {
         var mustCheckFontSize:Boolean =false;
         var startSize:Number = _labelFontSize;
         if (_label.textWidth != 0) {
            mustCheckFontSize = _label.textWidth > maxWidth;
            if (!mustCheckFontSize && _labelFontSize != _maxFontSize) {
               mustCheckFontSize =  _label.textWidth < (maxWidth- 50);
            }
         }
         mustCheckFontSize = true;
         if (mustCheckFontSize) {
            var targetSize :Number =Math.floor(_labelFontSize * maxWidth / _label.textWidth);
            if (targetSize <_minFontSize) {
               targetSize = _minFontSize;
            } else if (targetSize >_maxFontSize) {
               targetSize = _maxFontSize;
            }
            labelFontSize = targetSize;
            
            if (_label.measureText(_label.text).width> maxWidth) {
               labelFontSize =  startSize;
            }
         }
      }
   }
}