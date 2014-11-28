package com.broceliand.ui.effects {  
   
   import com.broceliand.util.resources.RemoteImage;
   
   public class ResizeImage extends RemoteImage {
      
      override public function set width(value:Number):void {
         if(super.width != value) {
            super.width = value;
            validateDisplayList();
         }
      }      
   }
}