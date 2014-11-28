package com.broceliand.ui.effects
{
   import mx.effects.Fade;
   
   public class UnfocusPearlEffect extends Fade
   {
      public function UnfocusPearlEffect(target:Object=null, disappear:Boolean = true)
      {
         super(target);
         if (disappear) {
            alphaTo = 0;   
         } else {
            alphaTo = 1;
         }
         duration = 300;
      }
      
   }
}