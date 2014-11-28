package com.broceliand.util.resources
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.io.IMonitorableTask;
   import com.broceliand.util.ActionRateLimiter;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   [Event(type=Event.COMPLETE)]
   
   public class RemoteResourceManager extends EventDispatcher implements IRemoteResourceManager
   {

      protected var _loadedResources:Dictionary = null;
      protected var _actionRateLimiter:ActionRateLimiter = new ActionRateLimiter(2);

      protected var _loader2CallbacksArray:Dictionary = null;
      protected var _url2MLoaders:Dictionary = null;
      protected var  _loader2MULoader :Dictionary = null;
      
      protected var _numResourcesLeftToDownload:Number = 0;
      protected var _isBinaryFormat:Boolean;

      protected var _numResourcesStillBeingProcessedByATarget:Number = 0;
      public function RemoteResourceManager(isBinaryFormat:Boolean=true)
      {
         _loadedResources = new Dictionary();
         _loader2CallbacksArray = new Dictionary();
         _url2MLoaders = new Dictionary();
         _loader2MULoader = new Dictionary();
         _isBinaryFormat = isBinaryFormat;
      }
      
      protected function doWithResourceThatIsAlreadyLoaded(callback:IResourceLoadedCallback, resource:Object, url:String=null):void{
         
         if(callback){
            callback.onLoaded(resource, url);
         }
      }
      
      protected function getUrlFromLoader(loader:URLLoader):String {
         var mloader:MonitorableUrlLoader = _loader2MULoader[loader];
         if (mloader) {
            return mloader.url;
         }
         return null;
      }      
      public function getRemoteResource(callback:IResourceLoadedCallback, url:String, isPreloadingOnly:Boolean= false):IMonitorableTask{
         var resource:Object= _loadedResources[url]; 
         var loadingTask:IMonitorableTask= null;
         if(resource){
            doWithResourceThatIsAlreadyLoaded(callback, resource, url);
         }else{
            var monitorableLoader:MonitorableUrlLoader =_url2MLoaders[url] ;
            if (monitorableLoader==null) {

               var loader:URLLoader= new URLLoader();
               monitorableLoader= new MonitorableUrlLoader(loader, url);
               monitorableLoader.isForPreloadingOnly = isPreloadingOnly;
               if (_isBinaryFormat) {
                  loader.dataFormat = URLLoaderDataFormat.BINARY;
               } else {
                  loader.dataFormat = URLLoaderDataFormat.TEXT;
               }
               addLoaderListeners(loader);
               var callbacksArray:Array = new Array(1);
               callbacksArray[0] = callback;
               _loader2CallbacksArray[loader] = callbacksArray;
               
               _url2MLoaders[url] = monitorableLoader;
               _loader2MULoader[loader] = monitorableLoader; 
               _numResourcesLeftToDownload++;               
               _actionRateLimiter.addActionToPerform(new LoadUrlAction(monitorableLoader)); 
            } else {
               if (!isPreloadingOnly) {
                  monitorableLoader.isForPreloadingOnly = false;
               }
               _loader2CallbacksArray[monitorableLoader.urlLoader].push(callback);
            }
            loadingTask = monitorableLoader;  				 
         }
         return loadingTask;
      }
      
      public function getResourceStatus(resourceUrl:String):int {
         var resource:ByteArray = _loadedResources[resourceUrl];
         var mloader:MonitorableUrlLoader = _url2MLoaders[resourceUrl];
         
         if(resource) {
            return ResourceStatus.STATUS_LOADED;
         }
         if(!mloader) {
            return ResourceStatus.STATUS_NEW;
         }
         else {
            return ResourceStatus.UNKOWN_STATUS;
         }
      } 

      protected function freeRemoteResourceFromCache(url:String):void{
         delete _loadedResources[url];
      }
      public function isSourceLoadingComplete():Boolean {
         return _numResourcesLeftToDownload<=0;
      }
      private function addLoaderListeners(loader:URLLoader):void {
         loader.addEventListener(Event.COMPLETE, urlLoadCompleted);
         loader.addEventListener(Event.OPEN, openHandler);
         loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
         loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
         loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      }
      private function removeLoaderListeners(loader:URLLoader):void {
         loader.removeEventListener(Event.COMPLETE, urlLoadCompleted);
         loader.removeEventListener(Event.OPEN, openHandler);
         loader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
         loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
         loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
         loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      }        

      protected function doOnUrlLoaded(url:String):void{
      }

      protected function urlLoadCompleted(event:Event, isSuccess:Boolean = true, errorCode:int = -1):void {
         new ProcessOnUrlCompletedAction(this,event, isSuccess, errorCode).performAction();
         
      }
      internal function processOnUrlCompleted(event:Event, isSuccess:Boolean = true, errorCode:int = -1):void {
         var loader:URLLoader = URLLoader(event.target);
         var callbacksArray:Array= _loader2CallbacksArray[loader];
         var url:String = null;
         
         if (callbacksArray != null) {
            var l:MonitorableUrlLoader = _loader2MULoader[loader];
            ApplicationManager.getInstance().remoteResourceManagers.loadingManager.loadingMonitor.onEndLoadingItem(l);
            if (l) {
               url = l.url;
            }
            delete _loader2CallbacksArray[loader];
            var result:Object = loader.data;

            if(isSuccess) {
               _loadedResources[url] = result;
            }
            delete _url2MLoaders[url];
            delete _loader2MULoader[loader];               
            for each (var cb:IResourceLoadedCallback in callbacksArray) {
               if(!cb){
                  continue;
               }
               if(isSuccess){
                  cb.onLoaded(result, url);
               }else{
                  cb.onError(errorCode, url);
               }
            }               
            removeLoaderListeners(loader);
            doOnUrlLoaded(url);
         }
         _numResourcesStillBeingProcessedByATarget++;
         _numResourcesLeftToDownload--;
         
         if(_numResourcesLeftToDownload == 0){
            dispatchEvent(new Event(Event.COMPLETE));
         }
         
      }

      private function httpStatusHandler(event:HTTPStatusEvent):void { 
         
      }
      
      private function ioErrorHandler(event:Event):void {
         trace("ioErrorHandler: " + event);
         _numResourcesLeftToDownload--;
         urlLoadCompleted(event, false);
      }
      
      private function openHandler(event:Event):void { 
         
      }
      
      private function progressHandler(event:ProgressEvent):void { 
         
      }
      
      private function securityErrorHandler(event:SecurityErrorEvent):void {
         trace("securityErrorHandler: " + event);
         _numResourcesLeftToDownload--;
      }
      
   }

}

import com.broceliand.util.IAction;
import com.broceliand.util.resources.MonitorableUrlLoader;

class LoadUrlAction implements IAction {
   
   private var _monitorableLoader:MonitorableUrlLoader ;
   public function LoadUrlAction(loader:MonitorableUrlLoader) {
      _monitorableLoader = loader;
      
   }      
   public function performAction():void {
      _monitorableLoader.load();
      
   }
}