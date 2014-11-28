package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.UrlNavigationController;
   
   import flash.external.ExternalInterface;
   
   import mx.managers.IHistoryManagerClient;
   
   public class Url2Overlay implements IHistoryManagerClient
   {
      public static const OVERLAY_CLIENT_NAME:String="overlay";
      public static const URL_FIELD:String="url";
      public static const PARENT_FIELD:String="parent";
      public static const EMBED_TYPE_FIELD:String="embedType";
      
      public function Url2Overlay() {
         UrlNavigationController.registerHistory(OVERLAY_CLIENT_NAME, this);     
      }
      
      public function saveState():Object {
         return null;
      }
      
      public function loadState(state:Object):void {
         if (state) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            if(state[URL_FIELD] != null) {
               am.setOverlayStartUrl(state[URL_FIELD]);
            }
            if(state[PARENT_FIELD] != null) {
               am.setOverlayParentUrl(state[PARENT_FIELD]);
            }
            if(state[EMBED_TYPE_FIELD] != null) {
               am.setOverlayEmbedType(parseInt(state[EMBED_TYPE_FIELD]));
            }
         }
      }
      
      public static function hasOverlayUrl():Boolean {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var currentUrl:String = (am.isDebug)?am.getCustomStartLocation():null;
         if(!currentUrl) {
            try {
               currentUrl = ExternalInterface.call("getStartLocationFromURL");
            }catch(error:Error) {
               
            }
         }
         return (currentUrl && currentUrl.lastIndexOf(OVERLAY_CLIENT_NAME+"-"+URL_FIELD) != -1);
      }
      
      public function toString():String {
         return OVERLAY_CLIENT_NAME;
      }      
   }
}