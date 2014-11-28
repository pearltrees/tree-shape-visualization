package com.broceliand.ui.sticker.eventBlocker
{
   import flash.events.IEventDispatcher;
   
   import mx.core.UIComponent;
   
   public interface IEventBlocker extends IEventDispatcher
   {
      function getActive():Boolean;
      function setActive(value:Boolean, addWhitebackground:Boolean=false):void;
      function addException(comp:UIComponent):void;
      function removeException(comp:UIComponent):void;		
   }
}