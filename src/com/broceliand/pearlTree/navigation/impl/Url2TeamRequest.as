package com.broceliand.pearlTree.navigation.impl {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.team.TeamRequestNavigationHelper;
   import com.broceliand.util.UrlNavigationController;
   
   import mx.managers.IHistoryManagerClient;

   public class Url2TeamRequest implements IHistoryManagerClient {
      
      private static const TEAMREQUEST_CLIENT_NAME:String="teamRequest";
      private static const ACCEPT_REQUEST_FIELD:String="a";
      private static const SHARE_REQUEST_FIELD:String="s";
      private static const DECIDE_REQUEST_FIELD:String="d";
      private static const MY_CANDIDACY_IS_ACCEPTED_FIELD:String="mcia";
      
      public function Url2TeamRequest() {
         UrlNavigationController.registerHistory(TEAMREQUEST_CLIENT_NAME, this);
      }
      
      public function saveState():Object {
         return null;
      }
      
      public function loadState(state:Object):void {
         if(!state) return;
         var requestId:int;
         if(state[DECIDE_REQUEST_FIELD]) {
            requestId = parseInt(state[DECIDE_REQUEST_FIELD]);
            TeamRequestNavigationHelper.getInstance().navigateToTeamRequestById(requestId, false, false, false, true);
         } else if(state[ACCEPT_REQUEST_FIELD]) {
            requestId = parseInt(state[ACCEPT_REQUEST_FIELD]);
            TeamRequestNavigationHelper.getInstance().navigateToTeamRequestById(requestId, true, true);
         }
         else if(state[SHARE_REQUEST_FIELD]) {
            requestId = parseInt(state[SHARE_REQUEST_FIELD]);
            TeamRequestNavigationHelper.getInstance().navigateToTeamRequestById(requestId, true, false, false);
         }
         else if(state[MY_CANDIDACY_IS_ACCEPTED_FIELD]) {
            requestId = parseInt(state[MY_CANDIDACY_IS_ACCEPTED_FIELD]);
            TeamRequestNavigationHelper.getInstance().navigateToTeamRequestById(requestId, true, false);
         }
      }   
      
      public static function hasTeamRequestNavigationUrl():Boolean {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var currentUrl:String = am.urlNavigationController.currentUrl;
         return (currentUrl && currentUrl.lastIndexOf(TEAMREQUEST_CLIENT_NAME+"-") != -1);
      }
      
      public function toString():String {
         return TEAMREQUEST_CLIENT_NAME;
      }
   }
}