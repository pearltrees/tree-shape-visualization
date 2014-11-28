package com.broceliand.util.resources
{
   import flash.utils.ByteArray;

   public interface IResourceLoadedCallback
   {
      function onLoaded(loadedData:Object, url:String=null):void;
      function onError(fault:Object, url:String=null):void;
   }
}