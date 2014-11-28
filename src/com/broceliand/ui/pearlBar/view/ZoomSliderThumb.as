package com.broceliand.ui.pearlBar.view
{
   import mx.controls.sliderClasses.SliderThumb;
   
   public class ZoomSliderThumb extends SliderThumb
   {
      public function ZoomSliderThumb()
      {
         super();
      }
      override protected function measure():void {
         super.measure();
         measuredWidth = 30; 
         measuredHeight = 26; 
      }
   }
}