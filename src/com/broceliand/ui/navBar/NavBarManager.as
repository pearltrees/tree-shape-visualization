package com.broceliand.ui.navBar {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   
   public class NavBarManager {
      
      private var _navigationModel:NavBarModel;
      private var _searchModel:NavBarSearchModel;
      private var _mostConnectedModel:NavBarMostConnectedModel;
      private var _whatsHotModel:NavBarWhatsHotModel;
      private var _navBar:INavBar;
      
      public function NavBarManager(navBar:INavBar) {
         _navBar = navBar;
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);         
         refreshModel();
      }
      
      private function onNavigationChange(event:NavigationEvent):void {
         refreshModel();
      }
      
      private function refreshModel():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var modelToUse:INavBarModel;
         
         if(navModel.isWhatsHot()) {
            if(!_whatsHotModel) {
               _whatsHotModel = new NavBarWhatsHotModel();
            }
            modelToUse = _whatsHotModel;
         }
         else if(navModel.isShowingSearchResult() || navModel.isShowingSearchPeopleResult()) {
            if(!_searchModel) {
               _searchModel = new NavBarSearchModel();
            }
            modelToUse = _searchModel;
         }
         else if(navModel.isShowingPearlTreesWorld()) {
            if(!_mostConnectedModel) {
               _mostConnectedModel = new NavBarMostConnectedModel();
            }
            modelToUse = _mostConnectedModel;
         }
         else{
            if(!_navigationModel) {
               _navigationModel = new NavBarModel();
            }
            modelToUse = _navigationModel;
         }
         
         _navBar.model = modelToUse;
         if(modelToUse) {
            modelToUse.refreshModel();
         }
      }
   }
}