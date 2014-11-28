package com.broceliand.ui.effects
{

   public class AnimForwardBackwardToggler extends ForwardBackwardTogglerBase
   {
      private var _anim:IPlayForwardBackward;
      public static const EVENT_END_ANIM:String = "EVENT_END_ANIM";
      public function AnimForwardBackwardToggler(anim:IPlayForwardBackward)
      {
         _anim = anim;
         anim.addEventListener(EVENT_END_ANIM, onEnd);
      }
      
      override protected function handledObjectPlayForward():void{
         _anim.playFoward();
      }
      
      override protected function handledObjectPlayBackward():void{
         _anim.playBackward();
      }

   }
}