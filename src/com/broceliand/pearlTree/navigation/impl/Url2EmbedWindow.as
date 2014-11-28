package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.util.UrlNavigationController;
   
   import flash.external.ExternalInterface;
   
   import mx.managers.IHistoryManagerClient;
   
   public class Url2EmbedWindow implements IHistoryManagerClient
   {
      public static const EMBED_WINDOW_CLIENT_NAME:String="embedWindow";
      public static const PARENT_FIELD:String="parent";
      public static const NOTIFY_INIT_FIELD:String="notifyInit";
      
      public function Url2EmbedWindow() {
         UrlNavigationController.registerHistory(EMBED_WINDOW_CLIENT_NAME, this);     
      }
      
      public function saveState():Object {
         return null;
      }
      
      public function loadState(state:Object):void {
         if (state) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            if(state[PARENT_FIELD] != null) {
               am.setEmbedWindowParentUrl(state[PARENT_FIELD]);
            }
            if(state[NOTIFY_INIT_FIELD] != null) {
               if(StartPolicyLogger.getInstance().isMainPanelCreated()) {
                  am.notifyEmbedWindowInitialized();
               }
            }
         }
      }
      
      public static function hasEmbedWindowUrl():Boolean {
         var currentUrl:String = getCurrentUrl();
         return (currentUrl && currentUrl.lastIndexOf(EMBED_WINDOW_CLIENT_NAME+"=1") != -1);
      }
      
      public static function notifyInit():Boolean {
         var currentUrl:String = getCurrentUrl();
         return (currentUrl && currentUrl.lastIndexOf(NOTIFY_INIT_FIELD+"=1") != -1);         
      }
      
      private static function getCurrentUrl():String {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var currentUrl:String = (am.isDebug)?am.getCustomStartLocation():null;
         if(!currentUrl) {
            try {
               currentUrl = ExternalInterface.call("getStartLocationFromURL");
            }catch(error:Error) {
               
            }
         }
         return currentUrl;
      }
      
      public function toString():String {
         return EMBED_WINDOW_CLIENT_NAME;
      }      
   }
}