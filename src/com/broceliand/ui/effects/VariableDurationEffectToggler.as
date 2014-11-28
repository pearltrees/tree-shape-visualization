package com.broceliand.ui.effects
{
   import mx.effects.Effect;
   
   public class VariableDurationEffectToggler extends EffectToggler
   {
      private var _forwardDuration:int;
      private var _backwardDuration:int;
      public function VariableDurationEffectToggler(effect:Effect, forwardDuration:int, backwardDuration:int, waitForEndOfForwardAnim:Boolean = true, waitForEndOfBackwardAnim:Boolean = true)
      {
         super(effect, waitForEndOfForwardAnim, waitForEndOfBackwardAnim);
         _forwardDuration = forwardDuration;
         _backwardDuration = backwardDuration;
      }
      
      override protected function handledObjectPlayForward():void{
         if(!_effect.isPlaying){
            
            _effect.duration = _forwardDuration;
         }
         super.handledObjectPlayForward();
      }
      
      override protected function handledObjectPlayBackward():void{
         if(!_effect.isPlaying){         
            _effect.duration = _backwardDuration;
         }
         super.handledObjectPlayBackward();
      }   

   }
}