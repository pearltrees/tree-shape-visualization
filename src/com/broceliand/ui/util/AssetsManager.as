package com.broceliand.ui.util {
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   import com.broceliand.util.resources.RemoteImage;
   
   import mx.core.UIComponent;
   
   public class AssetsManager {
      
      private static const DEBUG:Boolean = false;
      
      private static const USE_APP_VERSION_AS_ASSET_VERSION:Boolean = true;
      
      private static const STATIC_ASSET_VERSION:String = "20120920-1644";
      
      private static var _version:String = null;
      
      public static function getEmbededAsset(assetClass:Class):Class {
         if(DEBUG) {
            trace("getEmbededAsset: "+assetClass);
         }
         return assetClass;
      }
      
      public static function getRemoteAssetUrl(assetLocalPath:String):String {
         if(DEBUG) {
            trace("getRemoteAssetUrl: "+assetLocalPath);
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if(!_version) {
            _version = STATIC_ASSET_VERSION;
            if(USE_APP_VERSION_AS_ASSET_VERSION) {
               _version =  am.getAppVersion();
               if(!_version || _version == "") _version = new Date().getTime().toString();
            }
         }
         return am.getStaticContentUrl() + assetLocalPath + "?v=" + _version;
      }
      
      public static function preloadRemoteAsset(assetLocalPath:String):void {
         var imageManager:IRemoteResourceManager = ApplicationManager.getInstance().remoteResourceManagers.remoteImageManager;
         imageManager.getRemoteResource(null, getRemoteAssetUrl(assetLocalPath), true);
      }
      
      public static function applyRemoteAssetToComponentStyle(component:UIComponent, styleName:String, assetLocalPath:String):RemoteAssetToStyleHelper {
         var helper:RemoteAssetToStyleHelper = new RemoteAssetToStyleHelper(component, styleName, getRemoteAssetUrl(assetLocalPath));
         helper.downloadAndApply();
         return helper;
      }
      
      public static function applyRemoteAssetToImage(image:RemoteImage, assetLocalPath:String):void {
         var imageManager:IRemoteResourceManager = ApplicationManager.getInstance().remoteResourceManagers.remoteImageManager;
         imageManager.getRemoteResource(image, getRemoteAssetUrl(assetLocalPath));
      }
   }
}