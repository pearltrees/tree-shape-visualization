package com.broceliand.util.resources
{
   import com.broceliand.ApplicationManager;
   
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   import mx.controls.Image;
   
   public class ImageLoaderCallback extends EventDispatcher implements IResourceLoadedCallback
   {
      protected var _targetImage:Image = null;
      protected var _url:String;
      private var _callback:Function;
      
      public function getRemoteImage(targetImage:Image, url:String, callBack:Function):void{
         _targetImage = targetImage;
         _url = url;
         _callback = callBack;
         ApplicationManager.getInstance().remoteResourceManagers.remoteImageManager.getRemoteResource(this, url);
      }
      
      public function onLoaded(loadedData:Object):void
      {
         _targetImage.source = loadedData as ByteArray;
         if(_callback){
            _callback.call(this);
         }
      }
      
      public function onError(fault:Object):void
      {
      }
      
   }
}