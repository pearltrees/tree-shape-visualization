package com.broceliand.util.resources
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.io.IMonitorableTask;
   
   import flash.net.URLLoader;
   import flash.net.URLRequest;

   public class MonitorableUrlLoader implements IMonitorableTask {
      
      private var _loader:URLLoader;
      private var _url:String;
      
      private var _isForPreloadingOnly:Boolean;

      public function MonitorableUrlLoader(urlLoader:URLLoader, url:String) {
         _loader= urlLoader;
         _url = url;
      }
      public function get urlLoader():URLLoader {
         return _loader;
      }
      public function getDisplayName():String {
         return _url;
      }  
      public function get url():String {
         return _url;
      }
      public function load():void {
         try {
            _loader.load(new URLRequest(_url));
            
            ApplicationManager.getInstance().remoteResourceManagers.loadingManager.loadingMonitor.onStartLoadingItem(this);
         } 
         catch (error:Error) {
            trace("Error loading requested document: " + url);
         }
      }
      public function set isForPreloadingOnly (value:Boolean):void  {
         _isForPreloadingOnly = value;
      }
      
      public function get isForPreloadingOnly ():Boolean {
         return _isForPreloadingOnly;
      }
      
   }
}