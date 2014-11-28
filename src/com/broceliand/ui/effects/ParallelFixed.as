package com.broceliand.ui.effects
{
   
   import mx.effects.CompositeEffect;
   public class ParallelFixed extends CompositeEffect
   {
      public function ParallelFixed(target:Object = null)
      {
         super(target);
         
         instanceClass = ParallelFixedInstance;
      }
   }
}

