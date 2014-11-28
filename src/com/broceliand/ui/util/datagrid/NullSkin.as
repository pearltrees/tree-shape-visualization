package com.broceliand.ui.util.datagrid
{
   import mx.skins.ProgrammaticSkin;
   import flash.display.Graphics; 
   
   public class NullSkin extends ProgrammaticSkin
   {
      public function NullSkin()
      {
         super();
      } 
      
      override public function get measuredWidth():Number {
         return 0;
      } 
      
      override public function get measuredHeight():Number {
         return 0;
      } 
      
      override protected  function updateDisplayList(w:Number, h:Number):void {}
   }
}