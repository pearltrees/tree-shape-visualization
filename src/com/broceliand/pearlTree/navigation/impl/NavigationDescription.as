package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.SessionHelper;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationResultCallback;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   
   public class NavigationDescription
   {
      internal static const TREE_NAVIGATION:int = 0;
      internal static const DISCOVER_NAVIGATION:int =1;
      internal static const SEARCH_NAVIGATION:int =2;
      internal static const PARENT_TEAM_NAVIGATION:int = 3;
      
      private var _navType:int=0;
      
      private var _searchKeyword:String;
      private var _searchUserOnly:Boolean;
      
      private var _associationId:int;
      private var _userId:int;
      private var _focusedTreeId:int;
      private var _selectedTreeId:int=-1;
      private var _pearlId:int=-1;
      private var _onIntersection:int= -1;
      private var _playState :int= -1; 
      private var _pearlWindowPreferredState:int=0; 
      private var _navigateFromNode:Boolean=false; 
      private var _revealState:int=-1; 
      private var _followMoved:Boolean = false; 
      private var _resultCallback:INavigationResultCallback = null
      private var _isHistoryNavigation:Boolean = false;
      private var _isHomePage:Boolean = false;
      private var _isAliasNavigation:Boolean = false;
      
      function NavigationDescription(navType:int)
      {
         _navType = navType;
      }

      internal function get isHomePage():Boolean
      {
         return _isHomePage;
      }
      
      public static function search(keyword:String):NavigationDescription {
         var navDesc:NavigationDescription = new NavigationDescription(SEARCH_NAVIGATION);
         navDesc._searchKeyword = keyword;
         navDesc._userId = -1;
         navDesc._searchUserOnly = false;
         return navDesc;  
      }

      public static function searchInMyAccount(keyword:String, userId:int):NavigationDescription {
         var navDesc:NavigationDescription = search(keyword);
         navDesc._userId = userId;
         return navDesc;
      }
      
      public static function searchPeople(keyword:String):NavigationDescription {
         var navDesc:NavigationDescription = search(keyword);
         navDesc._searchUserOnly = true;
         return navDesc;
      }
      
      public static function goToSearch(searchKeyword:String, searchUserId:int, searchUserOnly:Boolean):NavigationDescription {
         ApplicationManager.getInstance().sessionHelper.notifySocialEvent(SessionHelper.USED_SEARCH);
         if (searchUserOnly) {
            return searchPeople(searchKeyword);
         } else if (searchUserId > 0) {
            return searchInMyAccount(searchKeyword, searchUserId);
         } 
         return search(searchKeyword);
      }
      
      public static function goToAssociationParentPearl(assoId:int):NavigationDescription {
         var navDesc:NavigationDescription = new NavigationDescription(PARENT_TEAM_NAVIGATION);
         navDesc._associationId = assoId;
         return navDesc;
         
      }
      
      public static function goToPearltreesWorld(associationId:int, userId:int, treeId:int):NavigationDescription {
         ApplicationManager.getInstance().sessionHelper.notifySocialEvent(SessionHelper.USED_RELATED);
         var navDesc:NavigationDescription = new NavigationDescription(DISCOVER_NAVIGATION);
         navDesc._associationId = associationId;
         navDesc._userId = userId;
         navDesc._focusedTreeId = treeId;
         return navDesc;
      }
      
      public static function goToPearl(node:BroPTNode):NavigationDescription {
         var tree:BroPearlTree = node.owner;
         return goToLocation(tree.getAssociationId(), -1, tree.id, tree.id, node.persistentID);
      }
      
      public static function goToLocation(associationId:int, userId:int, focusTreeId:int, selectedTreeId:int, pearlId:int):NavigationDescription {
         var navDesc:NavigationDescription = new NavigationDescription(TREE_NAVIGATION);
         navDesc._associationId = associationId;
         navDesc._userId = userId;
         navDesc._focusedTreeId = focusTreeId;
         navDesc._selectedTreeId = selectedTreeId;
         navDesc._pearlId = pearlId;
         return navDesc;
      }
      
      public static function makeBackFromEvent(event:NavigationEvent):NavigationDescription {
         var oldFocusTreeId:int = -1;
         var userId:int = -1;
         var oldSelectedTreeId:int =-1;
         var oldSelectedPearlId:int =-1;
         var navDesc:NavigationDescription = null;
         if (event.wasShowingPTW) {
            if (event.oldSearchKeyword != null) {
               navDesc = goToSearch(event.oldSearchKeyword, event.oldSearchUserId, event.oldSearchUserOnly);
            } 
            else {
               if (event.oldFocusTree) {
                  oldFocusTreeId = event.oldFocusTree.id;
               }
               if (event.oldUser) {
                  userId = event.oldUser.persistentId;
               }
               navDesc = goToPearltreesWorld(event.oldFocusAssoId, userId, oldFocusTreeId);
            }
         } else {
            var isAliasNavigation:Boolean = false;
            if (event.oldUser) {
               userId = event.oldUser.persistentId;
            }
            if (event.oldFocusTree) {
               oldFocusTreeId = event.oldFocusTree.id;
               oldSelectedTreeId = oldFocusTreeId;
            } else {
               return null;
            }
            if (event.oldSelectedTree) {
               oldSelectedTreeId = event.oldSelectedTree.id;
            } 
            if (event.oldSelectedPearl) {
               
               oldSelectedPearlId = event.oldSelectedPearl.persistentID;
            }
            if (!event.isShowingPTW) {
               if (event.oldSelectedPearl is BroDistantTreeRefNode) {
                  if (BroDistantTreeRefNode(event.oldSelectedPearl).treeId == event.newFocusTree.id) {
                     isAliasNavigation = true;   
                  }
               }
            }
            navDesc = goToLocation(event.oldFocusAssoId, userId, oldFocusTreeId, oldSelectedTreeId, oldSelectedPearlId);
            navDesc.withAliasNavigation(isAliasNavigation);
         }
         return navDesc;
      }

      public function withIntersection(intersection:int):NavigationDescription {
         _onIntersection = intersection;
         return this;
      }
      
      public function withPlayState(playState:int):NavigationDescription {
         _playState = playState;
         return this;
      }
      
      public function withHomePage(isHomePage:Boolean):NavigationDescription {
         _isHomePage = isHomePage;
         return this;
      }
      
      public function withPearlWindowPreferredState(pearlWindowPreferredState:int):NavigationDescription {
         _pearlWindowPreferredState = pearlWindowPreferredState;
         return this;
      }
      
      public function withNavigateFromNode(navFromNode:Boolean):NavigationDescription {
         _navigateFromNode = navFromNode;
         return this;
      }
      public function withRevealState(revealState:int=-1):NavigationDescription {
         _revealState = revealState;
         return this;
      }
      public function withFollowMoved(followMoved:Boolean):NavigationDescription {
         _followMoved= followMoved;
         return this;
      }
      public function withResultCallback(resultCallback:INavigationResultCallback):NavigationDescription {
         _resultCallback= resultCallback;
         return this;
      }
      
      public function withHistoryNavigation(isHistoryNavigation:Boolean):NavigationDescription {
         _isHistoryNavigation = isHistoryNavigation;
         return this;
      }
      
      public function withAliasNavigation(isAliasNavigation:Boolean):NavigationDescription {
         _isAliasNavigation = isAliasNavigation;
         return this;
      }

      internal function get navType():int
      {
         return _navType;
      }
      internal function get userId():int
      {
         return _userId;
      }
      
      internal function get searchKeyword():String
      {
         return _searchKeyword;
      }

      public function get isHistoryNavigation():Boolean
      {
         return _isHistoryNavigation;
      }
      
      internal function get resultCallback():INavigationResultCallback
      {
         return _resultCallback;
      }
      
      internal function get followMoved():Boolean
      {
         return _followMoved;
      }
      
      internal function get revealState():int
      {
         return _revealState;
      }
      
      internal function get navigateFromNode():Boolean
      {
         return _navigateFromNode;
      }
      
      internal function get pearlWindowPreferredState():int
      {
         return _pearlWindowPreferredState;
      }
      
      internal function get playState():int
      {
         return _playState;
      }
      
      internal function get onIntersection():int
      {
         return _onIntersection;
      }
      
      internal function set onIntersection(value:int):void
      {
         _onIntersection = value;
      }
      
      internal function get pearlId():int
      {
         return _pearlId;
      }
      
      internal function get searchUserOnly():Boolean
      {
         return _searchUserOnly;
      }
      
      internal function get selectedTreeId():int
      {
         return _selectedTreeId;
      }
      
      internal function get focusedTreeId():int
      {
         return _focusedTreeId;
      }
      
      internal function get associationId():int
      {
         return _associationId;
      }
      public function get isAliasNavigation():Boolean
      {
         return _isAliasNavigation;
      }
      
   }
}