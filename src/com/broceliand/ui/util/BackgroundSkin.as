package com.broceliand.ui.util {
   import mx.skins.ProgrammaticSkin;
   
   public class BackgroundSkin extends ProgrammaticSkin {
      
      override protected  function updateDisplayList(w:Number, h:Number):void {
         super.updateDisplayList(w, h);
         
         graphics.clear();
         graphics.beginFill(ColorPalette.getInstance().backgroundColor);
         graphics.drawRect(0,0,w,h);
         graphics.endFill();
      }
   }
}