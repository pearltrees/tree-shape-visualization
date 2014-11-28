package com.broceliand.util.resources
{
   import com.broceliand.io.IMonitorableTask;
   
   import flash.events.IEventDispatcher;
   
   public interface IRemoteResourceManager extends IEventDispatcher
   {
      function isSourceLoadingComplete():Boolean;
      function getRemoteResource(callback:IResourceLoadedCallback, url:String, preloadingOnly:Boolean=false):IMonitorableTask;
      function getResourceStatus(resourceUrl:String):int;
   }
}