package com.broceliand.ui.navBar {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.InfoPanelAssets;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.discover.DiscoverModel;
   import com.broceliand.pearlTree.model.discover.NewHexLoadedEvent;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class NavBarSearchModel extends EventDispatcher implements INavBarModel {
      
      private var _infoText:String;
      private var _isHomeButtonDisplayed:Boolean;
      private var _discoverModel:DiscoverModel;
      private var _iconType:uint;
      private var _isDiscoverMode:Boolean;
      
      public function NavBarSearchModel() {
         super();
         _discoverModel = ApplicationManager.getInstance().components.pearlTreeViewer.pearlTreeEditionController.getDiscoverModel();
         _discoverModel.addEventListener(DiscoverModel.NEW_HEX_LOADED, onNewHexLoadedInDiscover);
      }
      
      public function get items():Vector.<NavBarModelItem> {
         var items:Vector.<NavBarModelItem> = new Vector.<NavBarModelItem>();
         var item:NavBarModelItem =  new NavBarModelItem();
         item.text = _infoText;
         item.enabled = true;
         item.resizeToFit = true;
         item.isBold= !(ApplicationManager.getInstance().currentUser.isAnonymous());
         items.push(item);
         return items;
      }
      
      private function onNewHexLoadedInDiscover(event:NewHexLoadedEvent):void {
         notifyStatIfDiscoverViaSearch(event); 
         _isDiscoverMode = !event.isFirstLoad;
         refreshModel();
      }
      
      public function refreshModel():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         
         isHomeButtonDisplayed = !am.currentUser.isAnonymous();
         
         var searchKeyword:String = navigationModel.getSearchKeyword();
         
         if(_isDiscoverMode) {
            infoText = BroLocale.getInstance().getText("navBar.closestTrees.context");
            _iconType = NavBar.ICON_MOST_CONNECTED;            
         }else{
            _iconType = NavBar.ICON_SEARCH;
            
            var resultCount:int = 0;
            if (navigationModel.getFocusNeighbourTree()) {
               resultCount = navigationModel.getFocusNeighbourTree().pearlCount;
            }
            if (resultCount == 0) {
               infoText = BroLocale.getInstance().getText("navBar.search.empty", [searchKeyword]);
            } 
            else if(navigationModel.isShowingSearchPeopleResult()) {
               infoText = BroLocale.getInstance().getTextForCount("navBar.search.people", resultCount, [searchKeyword, resultCount]);
            }
            else if(navigationModel.isShowingSearchResult()) {
               if (navigationModel.getSearchUserId() > 0) {
                  infoText = BroLocale.getInstance().getTextForCount("navBar.search.account", resultCount, [searchKeyword, resultCount]);
               }
               else {
                  infoText = BroLocale.getInstance().getText("navBar.search", [searchKeyword]);
               }
            }         
            else{
               infoText = null;
            }
         }
      }     
      
      private function set infoText(value:String):void {
         if(value != _infoText) {
            _infoText = value;
            dispatchChangeEvent();
         }
      }

      public function performItemAction(item:NavBarModelItem):void {
         if(_isDiscoverMode) {
            displayOrHideRelatedInfoWindow();
         }else{
            displayOrHideSearchInfoWindow();
         }
      }
      
      public function performIconAction():void {
         if(_isDiscoverMode) {
            displayOrHideRelatedInfoWindow();
         }else{
            displayOrHideSearchInfoWindow();
         }
      }
      
      private function displayOrHideSearchInfoWindow():void {
         var am:ApplicationManager = ApplicationManager.getInstance(); 
         var wc:IWindowController = am.components.windowController;
         if (am.visualModel.navigationModel.getSearchUserId() > 0 )  {
            return;
         }
         wc.displayOrHideInfoWindow(
            "search",
            InfoPanelAssets.SEARCH);
      }
      
      private function displayOrHideRelatedInfoWindow():void {
         var am:ApplicationManager = ApplicationManager.getInstance(); 
         var wc:IWindowController = am.components.windowController;
         wc.displayOrHideInfoWindow(
            "mostconnected",
            InfoPanelAssets.RELATED);
      }
      
      public function get isHomeButtonDisplayed():Boolean {
         return _isHomeButtonDisplayed;
      }
      public function set isHomeButtonDisplayed(value:Boolean):void {
         if(value != _isHomeButtonDisplayed) {
            _isHomeButtonDisplayed = value;
            dispatchChangeEvent();
         }
      }
      
      public function get isVisible():Boolean {
         return true;
      }
      
      public function set isVisible(value:Boolean):void {}
      
      public function get avatarTree():BroPearlTree { return null; }
      
      public function get iconType():uint {
         return _iconType;
      }
      
      public function navigateToMostConnectedTrees():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var selectedNode:BroPTWDistantTreeRefNode = am.visualModel.selectionModel.getSelectedNode().getBusinessNode() as BroPTWDistantTreeRefNode;
         if(selectedNode && selectedNode.refTree) {
            var tree:BroPearlTree = selectedNode.refTree;
            navModel.goToPearlTreesWorld(tree.getMyAssociation().associationId, -1, tree.id);      
         }      
      }
      
      public function get isMostConnectedButtonDisplayed():Boolean {
         return true;
      }
      
      public function get isWhatsHotButtonDisplayed():Boolean {
         return true;
      }
      
      public function get isSimpleButtonDisplayed():Boolean{
         return true;
      }
      
      public function get iconActionOnFirstItem():Boolean{
         return true;      
      }
      
      public function get useLargeGap():Boolean{
         return false;
      }
      
      private function dispatchChangeEvent():void {
         dispatchEvent(new Event(NavBarModelEvent.MODEL_CHANGE));
      }
      public function getPuzzleColor():uint
      {
         return 0;
      }
      
      public function get compactMode():uint {
         return NavBarModel.NO_COMPACT_MODE;
      }
      
      public function get withPremiumSymbol():Boolean {
         return false;
      }
      
      public function forceViewRefresh():void {
         
      }
      
      public function get isTeamNameOrSearchResult():Boolean {
         return true;
      }
      
      private function notifyStatIfDiscoverViaSearch(event:NewHexLoadedEvent): void {
         var fromSearch: Boolean = !_isDiscoverMode;
         var switchToDiscover: Boolean = !event.isFirstLoad;
      }
   }
}