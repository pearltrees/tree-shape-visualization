package com.broceliand.ui.navBar {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.ApplicationMessageBroadcaster;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.io.IPearlTreeLoaderManager;
   import com.broceliand.pearlTree.io.loader.IPearlTreeLoaderCallback;
   import com.broceliand.pearlTree.io.sync.SynchronisationManager;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.team.ITeamRequestModel;
   import com.broceliand.pearlTree.model.team.TeamRequestChangeEvent;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.interactors.SelectInteractor;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.welcome.Facepile;
   import com.broceliand.ui.window.ui.signUpBanner.SignUpBanner;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   
   public class NavBarModel extends EventDispatcher implements INavBarModel, IPearlTreeLoaderCallback {

      private var _items:Vector.<NavBarModelItem>;
      
      private var _selectedTreeItem:NavBarModelTreeItem;
      
      private var _isVisible:Boolean;
      private var _isHomeButtonDisplayed:Boolean;
      private var _isMostConnectedControlDisplayed:Boolean;
      private var _isMostConnectedControlHighlighted:Boolean;
      private var _isWhatsHotButtonDisplayed:Boolean;
      private var _avatarTree:BroPearlTree;
      private var _withPremiumSymbol:Boolean = false;
      private var _isDisplayingTeamName:Boolean = false;
      
      private var _treeListener:NavBarTreeListener;
      
      public static const NO_COMPACT_MODE:uint = 1;
      public static const ICON_WITHOUT_PEARLTREE_MODE:uint = 2;
      public static const ICON_AND_MOST_CONNECTED_WITHOUT_PEARLTREE_MODE:uint = 3;
      public static const WITHOUT_MOST_CONNECTED_MODE:uint = 4;

      private const AVERAGE_PIXEL_CHAR:int = 7;
      private const LOGOS_LENGTH_PIXEL:int = 95; 
      private const PEARLTREES_LENGTH:int = 75; 
      private const RELATED_LENGTH:int = 60; 
      
      private var _compactMode: uint = NO_COMPACT_MODE;
      
      public function NavBarModel() {
         _treeListener = new NavBarTreeListener();
         _treeListener.addEventListener(NavBarTreeListener.TREE_MODEL_CHANGED, onTreeModelChanged);
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.notificationCenter.teamRequestModel.addEventListener(TeamRequestChangeEvent.STATE_CHANGED, onTeamRequestModelChange);
         am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationEvent);
         am.persistencyQueue.synchronizer.addEventListener(SynchronisationManager.SYNCHRONIZED_EVENT, onSyncEvent);
         am.visualModel.applicationMessageBroadcaster.addEventListener(ApplicationMessageBroadcaster.WHITE_MARK_CHANGED_EVENT, onWhiteMarkEvent);
         forceViewRefresh();
      }

      private function computeCompactMode():uint{
         /* Compact mode pour utilisateur non loggué.
         Facepile est fixé à taille fixe, on calcule l'espace qu'il nous reste et on supprime les éléments en trop dans l'ordre suivant :
         - "pearltree" dans MostConnected
         - "pearltree" ou "team" ou équipe dans Icon
         - "related" ou "voisin" dans MostConnected
         */
         var am:ApplicationManager = ApplicationManager.getInstance();
         var signUpBanner:SignUpBanner = am.components.mainPanel.signUpBanner;            
         var selectedTree:BroPearlTree = getRootTree(am.visualModel.navigationModel.getSelectedTree());
         if(selectedTree && signUpBanner && (signUpBanner.signUpBannerMode == SignUpBanner.SIGN_UP_BANNER_MODE_STANDARD)) {
            var screenWidth:int = ApplicationManager.flexApplication.stage.stageWidth;
            var associationLabel : String = selectedTree.title;
            if (!selectedTree.isTeamRoot()) {
               associationLabel = selectedTree.getMyAssociation().preferredUser.name;
            }
            
            var withoutMostConnectedWidth:Number = associationLabel.length * AVERAGE_PIXEL_CHAR + LOGOS_LENGTH_PIXEL;
            var iconAndMostConnectedWithoutPearltreeWidth:Number = withoutMostConnectedWidth + PEARLTREES_LENGTH; 
            var iconWithoutPearltreeWidth:Number = iconAndMostConnectedWithoutPearltreeWidth + PEARLTREES_LENGTH;
            var noCompactWidth:Number = iconWithoutPearltreeWidth + RELATED_LENGTH;
            var spaceLeft:Number = Facepile.offset_x;
            
            if (noCompactWidth <= spaceLeft) {
               return NO_COMPACT_MODE;
            } else if (iconWithoutPearltreeWidth <= spaceLeft){
               return ICON_WITHOUT_PEARLTREE_MODE;
            } else if (iconAndMostConnectedWithoutPearltreeWidth <= spaceLeft){
               return ICON_AND_MOST_CONNECTED_WITHOUT_PEARLTREE_MODE;
            } else {
               return WITHOUT_MOST_CONNECTED_MODE;
            }
         }
         else {
            return NO_COMPACT_MODE;
         }
      }
      
      public function get compactMode():uint {
         return computeCompactMode();
      }
      
      public function set compactMode(value:uint):void {
         _compactMode = value;
      }
      
      public function forceViewRefresh():void {
         refreshModelInternal(true);   
         dispatchChangeEvent();
      }
      
      private function onTreeModelChanged(event:Event):void {
         
         refreshModelInternal(true);
      }
      
      private function onTeamRequestModelChange(event:Event):void {
         if (avatarTree && avatarTree.isTeamRoot()) {
            refreshModelInternal(true);
         }
      }
      
      public function refreshModel():void {
         refreshModelInternal();
      }
      
      public static function refreshNavbar():void {
         ApplicationManager.getInstance().components.mainPanel.navigationBar.model.refreshModel();
      }
      
      private function buildSelectedTreeTitle(tree: BroPearlTree) : String {
         var title : String = tree.title;
         withPremiumSymbol = false;
         isDisplayingTeamName = false;
         if (tree.isTeamRoot()) {
            if (tree.getMyAssociation().isMyAssociation()) {
               if (tree.isPrivate()){
                  return BroLocale.getInstance().getText("navBar.myTeams.private");
               }
               else {
                  return BroLocale.getInstance().getText("navBar.myTeams");
               }
            } else {
               var textKey:String = "navBar.team";
               if (tree.isPrivate() ||
                  compactMode == ICON_WITHOUT_PEARLTREE_MODE || 
                  compactMode == ICON_AND_MOST_CONNECTED_WITHOUT_PEARLTREE_MODE ||
                  compactMode == WITHOUT_MOST_CONNECTED_MODE){
                  textKey = "navBar.team.short";
               }
               isDisplayingTeamName = true;
               return BroLocale.getInstance().getText(textKey, [title]);
            }
         } else {
            if (tree.getMyAssociation().isMyAssociation()) {
               if (_selectedTreeItem.tree.isPrivate()){
                  return BroLocale.getInstance().getText("navBar.myPearltrees.private");
               }
               else {
                  return BroLocale.getInstance().getText("navBar.myPearltrees");
               }
            } else {
               var userName : String = tree.getMyAssociation().preferredUser.name;
               var text:String = "navBar.otherPearltrees";
               if (compactMode == ICON_WITHOUT_PEARLTREE_MODE || 
                  compactMode == ICON_AND_MOST_CONNECTED_WITHOUT_PEARLTREE_MODE ||
                  compactMode == WITHOUT_MOST_CONNECTED_MODE) {
                  text = "navBar.otherPearltrees.short";
               }
               withPremiumSymbol = tree.isPremiumUserRoot();
               return BroLocale.getInstance().getText(text, [ userName ]);
            }
         }
      }
      
      private function onNavigationEvent(event:Event):void {
         refreshModelInternal(true);
      }
      
      private function onWhiteMarkEvent(event:Event):void {
         refreshModelInternal(true);
         dispatchChangeEvent();
      }
      private function onSyncEvent(event:Event):void {
         refreshModelInternal(true);
      }
      
      private function refreshModelInternal(forceViewToRefresh:Boolean=false):void {
         var am:ApplicationManager = ApplicationManager.getInstance();  
         var anonymous:Boolean = am.currentUser.isAnonymous(); 
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         var focusedTree:BroPearlTree = navigationModel.getFocusedTree();
         var selectedTree:BroPearlTree = navigationModel.getSelectedTree();
         refreshDiscoverAvailability();
         isWhatsHotButtonDisplayed = true;

         var newItems:Vector.<NavBarModelItem> = new Vector.<NavBarModelItem>();
         var itemsChanged:Boolean = false;

         var rootTree:BroPearlTree = null;
         if(focusedTree && focusedTree.getMyAssociation()) {
            var focusAssociation:BroAssociation = focusedTree.getMyAssociation();

            if(selectedTree && selectedTree.getMyAssociation() != focusAssociation) {
               rootTree = selectedTree.getMyAssociation().treeHierarchy.getTree(selectedTree.getMyAssociation().associationId);
            }
            else {
               rootTree = am.visualModel.dataRepository.getTree(focusAssociation.associationId);
            }
         }
         
         if(!isVisible && rootTree) {
            isVisible = true;
         }
         else if(!rootTree) {
            return;
         }

         if((!_selectedTreeItem && selectedTree) || (_selectedTreeItem && _selectedTreeItem.tree != selectedTree) || forceViewToRefresh) {
            itemsChanged = true;
            if(!selectedTree) {
               _selectedTreeItem = null;
            } else {
               _selectedTreeItem = new NavBarModelTreeItem(anonymous);
               _selectedTreeItem.tree = selectedTree;
               _selectedTreeItem.text = buildSelectedTreeTitle(getRootTree(selectedTree));
               _selectedTreeItem.resizeToFit = true;
            }
         }
         
         avatarTree = selectedTree;
         if (_selectedTreeItem){
            newItems.push(_selectedTreeItem);
         }

         if(itemsChanged || forceViewToRefresh) {
            items = newItems;
            _treeListener.updateFollowedTrees(getTreesInNavBar());
         }
      }
      
      private function refreshDiscoverAvailability():void {
         var user:User = ApplicationManager.getInstance().currentUser;
         if (user.isAnonymous()) { 
            isMostConnectedButtonDisplayed = !ApplicationManager.getInstance().isWhiteMark();
            return;
         }
         var userAsso:BroAssociation = ApplicationManager.getInstance().currentUser.getAssociation();
         var userTree:BroPearlTree = userAsso.treeHierarchy.getTree(userAsso.associationId);
         if (userTree) {
            isMostConnectedButtonDisplayed = userTree && !userTree.isEmpty();
         } else {
            var pearltreeLoader:IPearlTreeLoaderManager = ApplicationManager.getInstance().pearlTreeLoader;
            pearltreeLoader.loadTree(userAsso.associationId, userAsso.associationId, this, false);
         }
      }
      
      public function onTreeLoaded(tree:BroPearlTree):void {
         refreshModel();
      }
      
      public function onErrorLoadingTree(error:Object):void {
         
      }
      
      private function getTreesInNavBar():Array {
         var trees:Array = new Array();
         for each(var item:NavBarModelItem in _items) {
            if (item is NavBarModelTreeItem){
               var treeItem:NavBarModelTreeItem = item as NavBarModelTreeItem; 
               trees.push(treeItem.tree);
            }
         }
         return trees;
      }
      
      private function getRootTree(tree : BroPearlTree) : BroPearlTree {
         var am:ApplicationManager = ApplicationManager.getInstance(); 
         var rootTree:BroPearlTree = null;
         if(tree && tree.getMyAssociation()) {
            var focusAssociation:BroAssociation = tree.getMyAssociation();

            if(tree && tree.getMyAssociation() != focusAssociation) {
               rootTree = tree.getMyAssociation().treeHierarchy.getTree(tree.getMyAssociation().associationId);
            }
            else {
               rootTree = am.visualModel.dataRepository.getTree(focusAssociation.associationId);
            }
         }
         return rootTree;
      }
      
      public function performItemAction(item:NavBarModelItem):void {
         if(item is NavBarModelTreeItem) {
            var am:ApplicationManager = ApplicationManager.getInstance(); 
            var navigationModel:INavigationManager = am.visualModel.navigationModel;            
            var tree:BroPearlTree = NavBarModelTreeItem(item).tree;
            var rootTree: BroPearlTree = getRootTree(tree);
            
            if(tree == navigationModel.getFocusedTree() && !navigationModel.isShowingPearlTreesWorld()) {
               var sm:SelectionModel = am.visualModel.selectionModel;
               sm.selectedFromNavBar = true;
               var vgraph:IVisualGraph = am.components.pearlTreeViewer.vgraph;
               if (vgraph.currentRootVNode) {
                  sm.selectNode(vgraph.currentRootVNode.node as IPTNode);
               }
            }
            
            navigationModel.goTo(
               rootTree.getMyAssociation().associationId,               /* association id */ 
               rootTree.getMyAssociation().preferredUser.persistentId,  /* user id */
               rootTree.id,                                             /* focus tree id */
               rootTree.id,                                             /* selected tree id */
               rootTree.getRootNode().persistentID, -1, -1 , 0, false, NavigationEvent.ADD_ON_RESET_GRAPH);   
         }
         
      }
      
      public function performIconAction():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var selectInteractor:SelectInteractor = am.components.pearlTreeViewer.interactorManager.getSelectInteractor();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var focusedTree:BroPearlTree =  navModel.getFocusedTree();
         var selectedTree:BroPearlTree =  navModel.getSelectedTree();
         
         navModel.goTo(focusedTree.getMyAssociation().associationId,
            focusedTree.getMyAssociation().preferredUser.persistentId,
            focusedTree.id,
            selectedTree.id,
            focusedTree.getRootNode().persistentID, -1, -1, 0, false, NavigationEvent.ADD_ON_RESET_GRAPH);
         
         selectInteractor.center();
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
      
      public function get isWhatsHotButtonDisplayed():Boolean {
         return _isWhatsHotButtonDisplayed;
      }
      public function set isWhatsHotButtonDisplayed(value:Boolean):void {
         if(value != _isWhatsHotButtonDisplayed) {
            _isWhatsHotButtonDisplayed = value;
            dispatchChangeEvent();
         }
      }      
      
      public function get isMostConnectedButtonDisplayed():Boolean {
         return _isMostConnectedControlDisplayed;
      }
      
      public function set isMostConnectedButtonDisplayed(value:Boolean):void {
         if(value != _isMostConnectedControlDisplayed) {
            _isMostConnectedControlDisplayed = value;
            dispatchChangeEvent();
         }
      }
      
      public function get isSimpleButtonDisplayed():Boolean{
         return true;
      }
      
      public function get iconActionOnFirstItem():Boolean{
         return true;
      }
      
      public function set items(value:Vector.<NavBarModelItem>):void {
         if(_items != value) {
            _items = value;
            dispatchChangeEvent();
         }
      }
      
      public function get items():Vector.<NavBarModelItem> {
         return _items;
      }
      
      public function get isVisible():Boolean {
         return _isVisible;
      } 
      public function set isVisible(value:Boolean):void {
         if(value != _isVisible) {
            _isVisible = value;
            dispatchChangeEvent();
         }
      }   
      
      public function get avatarTree():BroPearlTree {
         return getRootTree(_avatarTree);
      } 
      public function set avatarTree(value:BroPearlTree):void {
         if(value != _avatarTree) {
            _avatarTree = value;
            dispatchChangeEvent();
         }
      }      
      
      public function get iconType():uint {
         return NavBar.ICON_AVATAR;
      }      
      
      public function navigateToMostConnectedTrees():void {
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         var tree:BroPearlTree;
         if(_selectedTreeItem) {
            tree = _selectedTreeItem.tree;
         }
         if(tree) {
            navModel.goToPearlTreesWorld(tree.getMyAssociation().associationId, -1, tree.id);      
         }
      }
      
      private function dispatchChangeEvent():void {
         dispatchEvent(new Event(NavBarModelEvent.MODEL_CHANGE));
      }
      
      public function get useLargeGap():Boolean{
         return false;
      }
      
      public function getPuzzleColor():uint {
         var requestModel:ITeamRequestModel  = ApplicationManager.getInstance().notificationCenter.teamRequestModel;
         if (requestModel.hasRequestsToAccept(avatarTree)) {
            return PearlAssets.COEDIT_ACCEPT;
         }
         
         if (requestModel.hasPendingRequests(avatarTree, -1)) {
            return PearlAssets.COEDIT_PENDING;
         }
         return PearlAssets.COEDIT_NORMAL;
      }
      
      public function get withPremiumSymbol():Boolean {
         return _withPremiumSymbol;
      }
      
      public function set withPremiumSymbol(value:Boolean):void {
         if (value != _withPremiumSymbol) {
            _withPremiumSymbol = value;
            dispatchChangeEvent();
         }
      }
      
      public function get isTeamNameOrSearchResult():Boolean
      {
         return _isDisplayingTeamName;
      }
      
      public function set isDisplayingTeamName(value:Boolean):void
      {
         _isDisplayingTeamName = value;
      }

   }
}