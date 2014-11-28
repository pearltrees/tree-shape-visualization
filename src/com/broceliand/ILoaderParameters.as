package com.broceliand
{
   public interface ILoaderParameters
   {
      function getClientLang():String;
      function getEmbedId():String;
      function setEmbedId(value:String):void;
      function getWebSiteUrl():String;
      function getStartLocation():String;
      function isInPearltrees():Boolean;
      function getAppVersion():String;
   }
}