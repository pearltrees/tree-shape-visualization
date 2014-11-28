package com.broceliand.pearlTree.navigation.impl {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.controller.IMenuActions;
   import com.broceliand.ui.panel.MenuActions;
   import com.broceliand.ui.welcome.tunnel.TunnelNavigationModel;
   import com.broceliand.util.UrlNavigationController;
   
   import flash.events.Event;
   
   import mx.events.FlexEvent;
   import mx.managers.IHistoryManagerClient;
   
   public class Url2DisplayedPage implements IHistoryManagerClient {
      
      public static const DISPLAY_CLIENT_NAME:String="DP"; 
      public static const NAME_FIELD:String="n"; 
      
      private static const DISPLAY_NAME_SETTINGS:String = "settings";
      private static const DISPLAY_NAME_TUNNEL:String = "tunnel";
      private static const DISPLAY_NAME_GETTING_STARTED:String = "gettingStarted";
      private static const DISPLAY_NAME_SOCIAL_SYNC:String = "socialSync";
      
      public function Url2DisplayedPage()
      {
         UrlNavigationController.registerHistory(DISPLAY_CLIENT_NAME, this);
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.addEventListener(ApplicationManager.MANAGER_INITIALIZED_EVENT, onManagerInitialized);
      }
      
      private function onManagerInitialized(event:Event):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.visualModel.navigationModel.getApplicationDisplayedPageModel().addEventListener(ApplicationDisplayedPageModel.DISPLAYED_PAGE_CHANGE, onDisplayedPageChange);
      }
      
      private function onDisplayedPageChange(event:Event):void {
         UrlNavigationController.save();
      }
      
      public function saveState():Object
      {
         var am:ApplicationManager = ApplicationManager.getInstance();         
         var pageDisplayed:uint = am.visualModel.navigationModel.getApplicationDisplayedPageModel().getPageDisplayed();
         
         var state:Object= new Object();
         if(pageDisplayed == ApplicationDisplayedPageModel.TUNNEL_PAGE) {
            state[NAME_FIELD] = DISPLAY_NAME_TUNNEL;
         }
         else if(pageDisplayed == ApplicationDisplayedPageModel.SETTINGS_PAGE) {
            state[NAME_FIELD] = DISPLAY_NAME_SETTINGS;
         }
         else if(pageDisplayed == ApplicationDisplayedPageModel.GETTING_STARTED_PAGE) {
            state[NAME_FIELD] = DISPLAY_NAME_GETTING_STARTED;
         }
         else{
            state = null;
         }
         return state;
      }
      
      public function loadState(state:Object):void
      {
         if (state) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            if (state[NAME_FIELD] == DISPLAY_NAME_SOCIAL_SYNC) {
               am.components.windowController.openSocialSyncWindow();
            }
            else if (state[NAME_FIELD] == DISPLAY_NAME_GETTING_STARTED) {
               am.components.getContextualHelp(true).show();
            }
         }
      }
      
      public function toString():String {
         return DISPLAY_CLIENT_NAME;
      }
   }
}