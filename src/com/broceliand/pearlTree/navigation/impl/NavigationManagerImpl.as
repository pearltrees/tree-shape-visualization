package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.INavigationResultCallback;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.AliasNavigationModel;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.welcome.tunnel.TunnelNavigationModel;
   import com.broceliand.util.Alert;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class NavigationManagerImpl extends EventDispatcher implements INavigationManager 
   {
      
      public static const FIRST_FOCUS_HAS_BEEN_PERFORMED_EVENT:String = "first_focus_performed";
      
      private static const WHATS_HOT_ID:int=0;
      private var _currentRequestPerformed:NavigationRequestBase;
      private var _user:User;
      private var _isDispatchingEvent:Boolean = false;
      private var _focusedTree:BroPearlTree;
      private var _selectedTree:BroPearlTree;
      private var _selectedPearl:BroPTNode;
      private var _selectionIntersection:int=-1;
      private var _isShowingPTW:Boolean = false;
      private var _searchKeyword:String = null;
      private var _searchUserId:Number =0;
      private var _isSearchingUserOnly:Boolean= false;
      private var _focusAssoId:int = -1;
      private var _focusNeighbourTree:BroPearlTree; 
      private var _playState:int = -1;
      private var _revealState:int = -1;
      private var _tunnelModel:TunnelNavigationModel;
      private var _pearlWindowPreferredState:Number;
      private var _isInMyWorld:Boolean;
      private var _isHomePage:Boolean;
      private var _aliasNavigationModel:AliasNavigationModel;
      private var _applicationDisplayedPageModel:ApplicationDisplayedPageModel;
      private var _isFirstFocusPerformed:Boolean = false;
      private var _navigationHistory:NavigationHistoryModel;
      private var _willShowPlayer:Boolean = false;
      private var _hasDisplayedABTestingEffectForAnonymous:Boolean = false;
      private var _urlSynchro:Url2NavigationSynchronizer;
      
      public function NavigationManagerImpl()
      {
         _urlSynchro = new Url2NavigationSynchronizer(this);
         _user = ApplicationManager.getInstance().currentUser;
         _tunnelModel = new TunnelNavigationModel(); 
         _aliasNavigationModel = new AliasNavigationModel(this);
         _navigationHistory = new NavigationHistoryModel(this);
         _applicationDisplayedPageModel = new ApplicationDisplayedPageModel();
      }
      
      public function get urlSynchro():Url2NavigationSynchronizer {
         return _urlSynchro
      }
      
      public function getTunnelModel():TunnelNavigationModel {
         return _tunnelModel;
      }
      
      public function goToWhatsHot(isHomePage:Boolean):void {
         goToPearlTreesWorld(WHATS_HOT_ID, WHATS_HOT_ID, WHATS_HOT_ID, isHomePage);   
      }
      
      public function goToPearlTreesWorld(associationId:int, userId:int, treeId:int, isHome:Boolean=false):void {
         var navDesc:NavigationDescription = NavigationDescription.goToPearltreesWorld(associationId, userId, treeId);
         if (isHome && !ApplicationManager.getInstance().currentUser.isAnonymous()) {
            isHome = false;
         }
         navDesc.withHomePage(isHome);
         navigate(navDesc);
      }
      
      public function goTo(associationId:int=-1, userId:int=-1, focusTreeId:int=-1, selectedTreeId:int=-1, pearlId:int=-1, onIntersection:int= -1, showPlayer :int= -1, pearlWindowPreferredState:int=0, navigateFromNode:Boolean=false, revealState:int=-1, followMoved:Boolean = false, resultCallback:INavigationResultCallback = null):void {      
         var navDesc:NavigationDescription = NavigationDescription.goToLocation(associationId, userId, focusTreeId, selectedTreeId, pearlId);
         navDesc.withIntersection(onIntersection).withPlayState(showPlayer).withPearlWindowPreferredState(pearlWindowPreferredState);
         navDesc.withRevealState(revealState).withFollowMoved(followMoved).withResultCallback(resultCallback);
         navigate(navDesc);
         _willShowPlayer = (showPlayer == 2);
      }
      
      private function processRequest(request:NavigationRequestBase):void {
         if (_isDispatchingEvent) {
            
            Log.getLogger("com.broceliand.pearlTree.navigation.impl").error("echo in request", new Error().getStackTrace());
            return;
         }
         _currentRequestPerformed = request;
         var navEvent:NavigationEvent = new NavigationEvent();
         saveCurrentNavigationState(navEvent);
         _currentRequestPerformed.startProcessingRequest(this, navEvent);
      }
      public function goToUser(user:User, pearlWindowPreferredState:int=-1):void {
         var userId:int = user.persistentId;
         var treeId:int = user.userWorld.treeId;         
         var pearlId:int = user.rootPearlId;
         goTo(user.getAssociation().associationId, userId, treeId, treeId, pearlId, -1, -1, pearlWindowPreferredState, false, NavigationEvent.ADD_ON_RESET_GRAPH);         
      }
      
      public function setPlayState(playState:int):void {
         var event:NavigationEvent = setPlayStateInternal(playState);
         if (event) {
            dispatchNavigationEvent(event);
         }
      }
      private function setPlayStateInternal(playState:int):NavigationEvent{
         if (_playState != playState) {
            var event:NavigationEvent = new NavigationEvent(NavigationEvent.PLAY_EVENT);
            event.oldPlayState = _playState;
            event.playState= playState;
            event.revealState = _revealState;
            _playState = playState;
            dispatchNavigationPlayStateEvent();
            event.oldUser = event.newUser = _user;
            event.oldFocusTree = event.newFocusTree= _focusedTree;
            event.oldFocusAssoId = event.newFocusAssoId = _focusAssoId;
            event.oldSelectedTree = event.newSelectedTree = _selectedTree;
            event.oldSelectedPearl = event.newSelectedPearl = _selectedPearl;
            event.newPearlWindowPreferredState= _pearlWindowPreferredState;
            event.isShowingPTW = _isShowingPTW;
            event.isHome = _isHomePage;
            event.selectionOnIntersection = _selectionIntersection;
            return event;
         }
         return null;
      }    
      
      public function getFocusNeighbourTree():BroPearlTree {
         return _focusNeighbourTree;
      }
      public function isInMyWorld():Boolean {
         return _isInMyWorld;
      }
      public function isWhatsHot():Boolean {
         return (_isShowingPTW && !_focusedTree && !isShowingSearchResult() && !_isHomePage);
      }
      public function isHomePage():Boolean {
         return _isHomePage;
      }  
      
      public function getSelectionIntersectionIndex():int  { 
         return _selectionIntersection;
      } 
      public function getSelectedUser():User {
         return _user;
      }
      public function getFocusedTree():BroPearlTree {
         if (_focusedTree ==null ) {
            var currentUser:User = ApplicationManager.getInstance().currentUser;
            if (currentUser.isAnonymous()) {
               return null;
            } else {
               return currentUser.userWorld.refTree;
            }
         }
         return _focusedTree;
      }
      
      public function getPearlWindowPreferredState():int {
         return _pearlWindowPreferredState;
      }
      
      public function getSelectedTree():BroPearlTree {
         return _selectedTree;
      }
      public function getSelectedPearl():BroPTNode {
         return _selectedPearl;
      }
      
      private function saveCurrentNavigationState(navEvent:NavigationEvent):void {
         navEvent.oldUser =  _user;
         navEvent.oldFocusTree= _focusedTree;
         navEvent.oldSelectedTree = _selectedTree;
         navEvent.oldSelectedPearl= _selectedPearl;
         navEvent.oldPlayState= _playState;  
         navEvent.oldRevealState = _revealState;
         navEvent.wasShowingPTW= _isShowingPTW;
         navEvent.oldNeighbourTree = _focusNeighbourTree;
         navEvent.oldFocusAssoId = _focusAssoId;
         navEvent.oldSearchKeyword = _searchKeyword;
         navEvent.oldSearchUserId  = _searchUserId;
         navEvent.oldSearchUserOnly = _isSearchingUserOnly;
      }
      
      public function get focusAssoId():int{
         return _focusAssoId;
      }
      
      public function isShowingPearlTreesWorld():Boolean{
         return _isShowingPTW;
      }
      
      public function isInPlayer():Boolean {
         return (_playState == 1);
      }
      
      public function isInScreenLine():Boolean {
         return (_playState == 2);
      }
      
      public function isShowingDiscover():Boolean {
         return (_isShowingPTW /* && !isShowingSearchResult() && !isWhatsHot() */ && !isHomePage());
      }

      public function notifyNavigation(request:NavigationRequestBase, event:NavigationEvent):void {
         if (_currentRequestPerformed == request) {
            _user = event.newUser;
            _focusedTree= event.newFocusTree;
            _selectedTree = event.newSelectedTree;
            _selectedPearl= event.newSelectedPearl;
            _selectionIntersection = event.selectionOnIntersection;
            _pearlWindowPreferredState = event.newPearlWindowPreferredState;
            _focusAssoId = event.newFocusAssoId;
            _isShowingPTW = event.isShowingPTW;
            _isHomePage = event.isHome;
            _focusNeighbourTree = event.newNeighbourTree;
            _searchKeyword = event.searchKeyword;
            _searchUserId = event.searchUserId;
            _isSearchingUserOnly = event.searchUserOnly;
            _revealState = event.revealState;
            _isInMyWorld = !_isShowingPTW && _user == ApplicationManager.getInstance().currentUser;

            if (ApplicationManager.getInstance().components.windowController.toUndockPWImediatelyForAnonymousUser()
               && ApplicationManager.getInstance().currentUser.isAnonymous() && _pearlWindowPreferredState == 0) {
               _pearlWindowPreferredState = 1;
            }
            
            if(!StartPolicyLogger.getInstance().isFirstNavigationEnded()) {
               StartPolicyLogger.getInstance().setFirstNavigationEnded();
               event.isFirstNavigation = true;
            }
            
            var playEvent:NavigationEvent = setPlayStateInternal(event.playState);
            
            try {
               _isDispatchingEvent = true;            
               dispatchNavigationEvent(event);
               if (playEvent) {
                  playEvent.isFirstNavigation = event.isFirstNavigation;
                  dispatchNavigationEvent(playEvent);
               }
            } finally {
               _isDispatchingEvent = false;
            }
         }
      }
      
      public function isCurrentRequest(request:NavigationRequestBase):Boolean {
         return _currentRequestPerformed == request;
      }
      public function notifyNavigationForbidden(request:NavigationRequestBase, event:NavigationEvent):void {
         if (_currentRequestPerformed == request) {
            var forbiddenEvent:NavigationEvent = new NavigationEvent(NavigationEvent.FORBIDDEN_EVENT);
            dispatchEvent(forbiddenEvent);
         }
      }
      public function goToAssociationParentPearl(assoId:int):void {
         navigate(NavigationDescription.goToAssociationParentPearl(assoId));
      }
      private function dispatchNavigationPlayStateEvent():void {
         dispatchEvent(new NavigationEvent(NavigationEvent.NAVIGATION_PLAYSTATE_UPDATE_EVENT));
      }
      private function dispatchNavigationEvent(event:NavigationEvent):void {
         dispatchEvent(event);
      }
      
      public function getPlayState():int {
         return _playState;
      }
      
      public function isTreeInCurrentUserDropZone(tree:BroPearlTree):Boolean {
         var currentUser:User = ApplicationManager.getInstance().currentUser;
         return NavigationManagerImpl.isTreeInUserDropZone(tree,currentUser);
      }
      
      public static function isTreeInUserDropZone(tree:BroPearlTree, user:User):Boolean {
         if(user.isAnonymous() || !user.dropZoneTreeRef) {
            if (tree.getMyAssociation().isUserRootAssociation()) {
               user = tree.getMyAssociation().preferredUser;
            }
            if (!user || !user.dropZoneTreeRef) {
               return false;
            }
         }
         var parents:Array = tree.treeHierarchyNode.getTreePath();
         var dropZoneId:int = user.dropZoneTreeRef.treeId;
         var dropZoneDB:int = user.dropZoneTreeRef.treeDB;
         for each(var parentTree:BroPearlTree in parents) {
            if (parentTree.id == dropZoneId && parentTree.dbId == dropZoneDB) {
               return true;
            }
         }
         return false;
      }
      public function getAliasNavigationModel():AliasNavigationModel {
         return _aliasNavigationModel;
      }
      
      public function getNavigationHistoryModel():NavigationHistoryModel {
         return _navigationHistory;
      }
      
      public function getApplicationDisplayedPageModel():ApplicationDisplayedPageModel {
         return _applicationDisplayedPageModel;
      }      
      
      public function isAddOnNavigation():Boolean {
         return _revealState ==1;
      }
      
      public function toCenterOnPearlForAnonymousArriving():Boolean {
         if (ApplicationManager.getInstance().currentUser.isAnonymous()) {
            return !hasDisplayedABTestingEffectForAnonymous && _revealState == -2;
         }
         return false;
      }
      
      public function getSearchKeyword():String {
         return _searchKeyword;
      }
      
      public function getSearchUserId():Number{
         return _searchUserId;
      }
      
      public function isShowingSearchResult():Boolean {
         return _searchKeyword != null;
      }
      public function isShowingSearchPeopleResult():Boolean {
         return _searchKeyword != null && _isSearchingUserOnly;
      }
      
      public function get isFirstSelectionPerformed():Boolean {
         return _isFirstFocusPerformed;
      }
      public function set isFirstSelectionPerformed(value:Boolean):void {
         if (!_isFirstFocusPerformed) {
            _isFirstFocusPerformed = value;
            dispatchEvent(new Event(FIRST_FOCUS_HAS_BEEN_PERFORMED_EVENT));
         }
      }
      public function cancelCurrentLoadingEvent():void {
         _currentRequestPerformed = null;
      }
      
      public function navigate(desc:NavigationDescription):void {
         var request:NavigationRequestBase = null;
         if (isAbTestingUser()) {
            desc.withRevealState(_revealState);
         }
         if (desc.navType == NavigationDescription.SEARCH_NAVIGATION) {
            request = new SearchNavigationRequest(desc);
         }
         else if (desc.navType == NavigationDescription.PARENT_TEAM_NAVIGATION) {
            request= new UnfocusTeamNavigationRequest(desc);
         }
         else {
            request = new NavigationRequest(desc);
         }
         processRequest(request);
      }
      
      public function get willShowPlayer():Boolean
      {
         return _willShowPlayer;
      }
      
      public function isAbTestingUser():Boolean {
         return _revealState < -1;
      }
      
      public function get hasDisplayedABTestingEffectForAnonymous():Boolean
      {
         return _hasDisplayedABTestingEffectForAnonymous;
      }
      
      public function set hasDisplayedABTestingEffectForAnonymous(value:Boolean):void
      {
         _hasDisplayedABTestingEffectForAnonymous = value;
      }
      
   }
}