package com.broceliand.ui.iFrame
{
   import flash.events.IEventDispatcher;
   
   public interface IFrameComponentInterface extends IEventDispatcher
   {
      function set visible (value:Boolean):void;
      function get visible ():Boolean;
      function setSource (value:String, isBackward:Boolean=false, skipEffect:Boolean=false):void;
      function get source ():String;
      function clearIFrame():void;
      function onPlayerShown():void;
   }
}