package com.broceliand.ui.pearlBar.view
{
   public class ZoomEmbedSliderThumb  extends ZoomSliderThumb
   {
      override protected function measure():void {
         super.measure();
         measuredWidth = 26;
         measuredHeight = 25;
      }
   }
}