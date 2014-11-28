package com.broceliand.ui.effects {
   
   import mx.containers.Canvas;

   public class ResizeCanvas extends Canvas {
      
      override public function set width(value:Number):void {
         if(super.width != value) {
            super.width = value;
            validateDisplayList();
         }
      } 
   }
}