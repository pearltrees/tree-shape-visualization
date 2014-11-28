package com.broceliand.util.resources
{
   import com.broceliand.io.IMonitorableTask;
   
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   import mx.utils.StringUtil;

   public class RetryingRemoteResourceManager extends DisposingRemoteResourceManager implements IRetryingResourceManager
   {
      private static const DEBUG_TRACE:Boolean = false;
      
      public static const ERROR_CODE_RESOURCE_NOT_AVAILABLE:int = -1;
      public static const ERROR_CODE_RESOURCE_BUILDING:int = -2;
      
      private static const SERVER_CODE_BUILDING_PREVIEW:String = "1";     
      
      private static const MAX_ATTEMPT:uint = 10;
      private static const ATTEMPT_DELAY:uint = 2000; 
      
      private var _timer2Url:Dictionary;
      private var _url2Timer:Dictionary;

      public function RetryingRemoteResourceManager(maxNumElements:uint = 50, numToFlushAtATime:uint = 20) {
         super(maxNumElements, numToFlushAtATime);
         _url2Timer = new Dictionary();
         _timer2Url = new Dictionary();
      }
      
      override protected function doWithResourceThatIsAlreadyLoaded(callback:IResourceLoadedCallback, resource:Object, url:String=null):void{
         var resourceAsString:String = StringUtil.trim(resource.toString());
         if(resourceAsString == SERVER_CODE_BUILDING_PREVIEW) {
            callback.onError(ERROR_CODE_RESOURCE_BUILDING, url);
         }else{
            super.doWithResourceThatIsAlreadyLoaded(callback, resource, url);
         }
      }
      
      override public function getRemoteResource(callback:IResourceLoadedCallback, url:String, isPreloadingOnly:Boolean=false):IMonitorableTask {
         var resource:ByteArray = _loadedResources[url]; 
         var monitorableLoader:MonitorableUrlLoader =_url2MLoaders[url];
         var timer:Timer = _url2Timer[url];
         
         if(!resource && monitorableLoader && !monitorableLoader.isForPreloadingOnly && !timer) {
            startRetryingResource(url, monitorableLoader.urlLoader);
            return monitorableLoader;
         }else{
            return super.getRemoteResource(callback, url, isPreloadingOnly);
         }
      }
      
      override protected function urlLoadCompleted(event:Event, isSuccess:Boolean = true, errorCode:int = -1):void{
         var loader:URLLoader = URLLoader(event.target);
         var url:String = getUrlFromLoader(loader);

         if(!isSuccess) {
            var mloader:MonitorableUrlLoader = _loader2MULoader[loader];
            if (mloader.isForPreloadingOnly) {
               super.urlLoadCompleted(event, false, ERROR_CODE_RESOURCE_NOT_AVAILABLE);
            }
            var timer:Timer = _url2Timer[url];
            if(!timer) {
               startRetryingResource(url, loader);
            }else{
               if(timer.currentCount == MAX_ATTEMPT) {
                  stopRetryingResource(url);
                  super.urlLoadCompleted(event, false, ERROR_CODE_RESOURCE_NOT_AVAILABLE);
               }else{
                  notifyServerProcessingResource(loader);
               }
            }
         }else{
            stopRetryingResource(url);
            super.urlLoadCompleted(event, isSuccess, errorCode);
         }
      }
      
      private function startRetryingResource(url:String, loader:URLLoader):void {
         var timer:Timer = _url2Timer[url];
         if(!timer) {
            timer = new Timer(ATTEMPT_DELAY, MAX_ATTEMPT);
            timer.addEventListener(TimerEvent.TIMER, onTimeToTryAgain);
            _timer2Url[timer] = url;
            _url2Timer[url] = timer;
            timer.start();
            notifyServerProcessingResource(loader);   
         }
      }
      
      public function stopRetryingResource(url:String):void {
         var timer:Timer = _url2Timer[url];
         if(timer) {
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, onTimeToTryAgain);
            delete _timer2Url[timer];
            delete _url2Timer[url];
         }
      }
      
      private function notifyServerProcessingResource(resourceLoader:URLLoader):void {
         var callbacksArray:Array = _loader2CallbacksArray[resourceLoader];
         if (callbacksArray != null) {              
            for each (var cb:IResourceLoadedCallback in callbacksArray) {
               cb.onError(ERROR_CODE_RESOURCE_BUILDING, getUrlFromLoader(resourceLoader));
            }
         }         
      }
      
      private function onTimeToTryAgain(event:TimerEvent):void{
         var timer:Timer = event.target as Timer;
         var url:String = _timer2Url[timer];         
         var loader:MonitorableUrlLoader = _url2MLoaders[url];
         if(!loader){
            if(DEBUG_TRACE) trace("no loader found for url " + url);
            return;
         } else if (!loader.isForPreloadingOnly) {
            loader.load();
         }
      }
      
      override public function getResourceStatus(resourceUrl:String):int {
         var status:int = super.getResourceStatus(resourceUrl);         
         var timer:Timer = _url2Timer[resourceUrl];
         
         if(status != ResourceStatus.UNKOWN_STATUS) {
            
         }
         else if(!timer) {
            status = ResourceStatus.STATUS_FIRST_TIME_LOADING;
         }
         else {
            status = ResourceStatus.STATUS_SERVER_PROCESSING;
         }
         
         return status;
      }
   }
}