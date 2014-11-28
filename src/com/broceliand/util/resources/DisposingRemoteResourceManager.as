package com.broceliand.util.resources
{
   import com.broceliand.ApplicationManager;
   
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.core.Application;

   internal class DisposingRemoteResourceManager extends RemoteResourceManager
   {
      protected static const DEFAULT_MAX_NUM_ELEMENTS:uint = 50;
      protected static const DEFAULT_NUM_ELEMENTS_TO_FLUSH_AT_A_TIME:uint = 20;
      private var _numElements:int = 0;
      private var _maxNumElements:uint; 
      private var _numToFlushAtATime:uint;
      private var _url2LastUseDate:Dictionary;
      public function DisposingRemoteResourceManager(maxNumElements:uint = DEFAULT_MAX_NUM_ELEMENTS, numToFlushAtATime:uint = DEFAULT_NUM_ELEMENTS_TO_FLUSH_AT_A_TIME)
      {
         super();
         _maxNumElements = maxNumElements;
         _numToFlushAtATime = numToFlushAtATime;
         _url2LastUseDate = new Dictionary();
      }
      
      private function getUrlsToFlush(numElementsToFind:int):Array{
         var ret:Array = new Array();
         for(var i:uint = 0; i < numElementsToFind;i++){
            var urlToFlush:String = null;
            for(var candidateUrl:String  in _url2LastUseDate){
               if(ret.indexOf(candidateUrl) > -1){
                  
                  continue;
               }
               if(urlToFlush == null){
                  urlToFlush = candidateUrl; 
               }else{
                  if(_url2LastUseDate[candidateUrl] < _url2LastUseDate[urlToFlush]){
                     urlToFlush = candidateUrl;
                  } 
               }
               
            }
            ret.push(urlToFlush);
         }
         return ret;
      }
      
      private function processResources():void{
         if(_numElements >= _maxNumElements){
            var urlsToFlush:Array = getUrlsToFlush(_numToFlushAtATime);
            for each(var url:String in urlsToFlush){
               freeRemoteResourceFromCache(url);
               delete _url2LastUseDate[url];
               _numElements--;
            }
         }
         
      }
      
      override protected function doOnUrlLoaded(url:String):void {
         super.doOnUrlLoaded(url);
         if(_url2LastUseDate[url] == null){
            _numElements++;
         }
         _url2LastUseDate[url] = getTimer();
         if(_numElements >= _maxNumElements){
            ApplicationManager.flexApplication.callLater(processResources);
         }
         
      }  
      
   }
}