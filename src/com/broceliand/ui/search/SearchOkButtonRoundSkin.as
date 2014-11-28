package com.broceliand.ui.search
{
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.display.Graphics;
   
   import mx.skins.ProgrammaticSkin;
   
   public class SearchOkButtonRoundSkin extends ProgrammaticSkin {
      
      override protected  function updateDisplayList(w:Number, h:Number):void {
         super.updateDisplayList(w, h);
         
         var backgroundFillColor:int;
         
         switch (name) {
            case "upSkin":
               backgroundFillColor = ColorPalette.getInstance().pearltreesColor;
               break;
            case "overSkin":
               backgroundFillColor = ColorPalette.getInstance().pearltreesDarkColor;
               break;
            case "downSkin":
               backgroundFillColor = ColorPalette.getInstance().pearltreesDarkColor;
               break;
            case "disabledSkin":
               backgroundFillColor = ColorPalette.getInstance().pearltreesColor;
               break;
         }
         
         var g:Graphics = graphics;
         g.clear();
         g.beginFill(backgroundFillColor);
         g.drawCircle(w / 2.0, h / 2.0, (w / 2.0) - 3);
         g.endFill();
      }      
   }
}