package com.broceliand.util.resources {

   public interface IRetryingResourceManager extends IRemoteResourceManager {
      function stopRetryingResource(url:String):void;
   }
}