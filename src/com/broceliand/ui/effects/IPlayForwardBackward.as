package com.broceliand.ui.effects
{
   import flash.events.IEventDispatcher;
   
   public interface IPlayForwardBackward extends IEventDispatcher
   {
      function playFoward():void;
      function playBackward():void; 
      [Event(name=AnimForwardBackwardToggler.EVENT_END_ANIM, type="flash.events.Event")]
      
   }
}