package com.broceliand.util.resources
{
   import com.broceliand.io.LoadingManager;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   
   public class RemoteResourceManagers
   {
      
      private var _loadingManager:LoadingManager;
      private var _remoteImageManager:IRemoteResourceManager;
      private var _previewImageManager:IRetryingResourceManager;
      
      public function RemoteResourceManagers(navManager:INavigationManager)
      {
         _loadingManager = new LoadingManager(navManager);
         _remoteImageManager = new RemoteResourceManager();
         _previewImageManager = new RetryingRemoteResourceManager(100, 20);
      }
      
      public function get remoteImageManager():IRemoteResourceManager {
         return _remoteImageManager;
      }
      
      public function get previewImageManager():IRetryingResourceManager {
         return _previewImageManager;
      }

      public function get helpImageManager():IRemoteResourceManager{
         return _previewImageManager;
      }
      public function get loadingManager():LoadingManager {
         return _loadingManager;
      }
   }
}