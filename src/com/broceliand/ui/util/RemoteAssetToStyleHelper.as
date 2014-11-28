package com.broceliand.ui.util {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   import com.broceliand.util.resources.IResourceLoadedCallback;
   
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   
   import mx.controls.Image;
   import mx.core.UIComponent;

   public class RemoteAssetToStyleHelper extends EventDispatcher implements IResourceLoadedCallback {
      
      public static const REMOTE_ASSET_LOADED:String = "remoteAssetLoaded";
      
      private var _imageManager:IRemoteResourceManager;
      private var _component:UIComponent; 
      private var _styleName:String; 
      private var _assetUrl:String;
      
      public function RemoteAssetToStyleHelper(component:UIComponent, styleName:String, assetUrl:String) {
         _imageManager = ApplicationManager.getInstance().remoteResourceManagers.remoteImageManager;
         _component = component;
         _styleName = styleName;
         _assetUrl = assetUrl;
      }
      
      public function downloadAndApply():void {
         
         _imageManager.getRemoteResource(this, _assetUrl);
      }
      
      public function onLoaded(loadedData:Object, url:String=null):void {
         
         var byteArray:ByteArray = loadedData as ByteArray;
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
         loader.loadBytes(byteArray);
      }
      
      private function onLoaderComplete(event:Event):void {
         
         var bitmapData:BitmapData = Bitmap(event.target.content).bitmapData;
         LoadedImageClass.addLoadedImage(_component, _styleName, bitmapData);
         _component.setStyle(_styleName, NullSkin);
         _component.setStyle(_styleName, LoadedImageClass);
         dispatchEvent(new Event(REMOTE_ASSET_LOADED));
      }
      
      public function onError(fault:Object, url:String=null):void {}
      
   }
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.utils.Dictionary;

import mx.core.BitmapAsset;
import mx.core.UIComponent;

internal class LoadedImageClass extends BitmapAsset {
   
   private static var _loadedImages:Dictionary = new Dictionary();
   
   public function LoadedImageClass() {
      addEventListener(Event.ADDED, onAdded, false, 0, true);
   }
   
   private function onAdded(event:Event):void {
      var component:UIComponent = this.parent as UIComponent;
      var styleName:String = this.name;
      if(_loadedImages[component]) {
         if(_loadedImages[component][styleName]) {
            bitmapData = _loadedImages[component][styleName];
            component.invalidateSize();
         }
      }
   }
   
   public static function addLoadedImage(component:UIComponent, styleName:String, bitmapData:BitmapData):void {
      if(!_loadedImages) {
         _loadedImages = new Dictionary();
      }
      if(!_loadedImages[component]) {
         _loadedImages[component] = new Dictionary();
      }
      _loadedImages[component][styleName] = bitmapData;
   }
}