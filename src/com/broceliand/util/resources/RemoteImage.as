package com.broceliand.util.resources
{
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   import mx.controls.Image;
   
   [Event(name="remoteImageLoaded", type="flash.events.Event")]
   
   public class RemoteImage extends Image implements IResourceLoadedCallback {
      
      public static const REMOTE_IMAGE_LOADED:String = "remoteImageLoaded";
      private var _callback:Function;
      private var _allowParallelLoad:Boolean = false;
      
      public function RemoteImage(callBack:Function = null) {
         super();
         _callback = callBack;
      }
      
      public function onLoaded(loadedData:Object, url:String=null):void {
         source = loadedData as ByteArray;
         dispatchEvent(new Event(REMOTE_IMAGE_LOADED));
         if(_callback != null){
            _callback.call((this));
         }
      }
      
      public function get allowParallelLoad():Boolean{
         return _allowParallelLoad;
      }
      
      public function onError(fault:Object, url:String=null):void{
         source = null;
      }
   }
}