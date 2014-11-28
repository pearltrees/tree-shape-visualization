package com.broceliand.ui.util
{
   import mx.skins.ProgrammaticSkin;
   import flash.display.Graphics; 
   
   public class NullSkin extends ProgrammaticSkin
   {
      public function NullSkin()
      {
         super();
      }
      
      override protected  function updateDisplayList(w:Number, h:Number):void {}
   }
}