package com.broceliand.ui.effects
{
   import mx.effects.Dissolve;
   import mx.effects.Zoom;
   
   public class TrashPearlEffect extends Zoom
   {
      public static const DURATION:uint = 500;
      
      protected var _fadeToBlackEffect:Dissolve;
      protected var _shrinkEffect:Zoom;
      public function TrashPearlEffect(target:Object = null)
      {
         zoomWidthFrom = 1;
         zoomWidthTo = 0;
         zoomHeightFrom = 1;
         zoomHeightTo = 0;
         duration = DURATION;		
      }
   }
}