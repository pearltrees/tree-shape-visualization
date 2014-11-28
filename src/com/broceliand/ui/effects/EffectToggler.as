package com.broceliand.ui.effects
{
   import mx.effects.Effect;
   import mx.events.EffectEvent;

   public class EffectToggler extends ForwardBackwardTogglerBase
   {
      protected var _effect:Effect
      
      public function EffectToggler(effect:Effect, waitForEndOfForwardAnim:Boolean = true, waitForEndOfBackwardAnim:Boolean = true)
      {
         
         _effect = effect;
         _effect.addEventListener(EffectEvent.EFFECT_END, onEnd);
         super(waitForEndOfForwardAnim, waitForEndOfBackwardAnim);
      }
      
      override protected function handledObjectPlayForward():void{
         if(_effect.isPlaying && !_waitForEndOfBackwardAnim){
            _effect.reverse();         
         }else{
            _effect.play();
         }
      }
      
      override protected function handledObjectPlayBackward():void{
         if(_effect.isPlaying && !_waitForEndOfForwardAnim){
            _effect.reverse();         
         }else{
            _effect.play(null, true);
         }
      }   

      public function get effect():Effect{
         return _effect;
      }      
      public function clearMemory():void {
         _effect.stop();
         _effect.removeEventListener(EffectEvent.EFFECT_END, onEnd);
      }
   }
}