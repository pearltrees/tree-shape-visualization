package com.broceliand.ui.controller
{
   import flash.events.IEventDispatcher;

   public interface IPearlbarInfo extends IEventDispatcher
   {
      function isPearlbarInstalled():Boolean;
      function isPearlbarInstalledOnThisBrowser():Boolean;      
      function isNotifyingInstallPearlbar():Boolean;
      function set pearlbarDetected(value:Boolean):void;
      function set pearlbarVersion(value:String):void;
      function get pearlbarVersion():String;
      function detectPearlbar():void;
   }
}