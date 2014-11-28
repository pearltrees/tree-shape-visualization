package com.broceliand.ui.controller {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
   import com.broceliand.pearlTree.navigation.impl.NavigationManagerImpl;
   import com.broceliand.ui.model.SelectionModel;
   
   import flash.utils.Dictionary;
   
   public class AliasNavigationModel {
      
      private var _navManager:INavigationManager;
      private var _aliasNavigations:Dictionary;
      private var _lastLocation:NavigationLocation;
      private var _lastFocusIdFromPTW:Number;

      public function AliasNavigationModel(navManager:NavigationManagerImpl) {
         _navManager = navManager;
         _aliasNavigations = new Dictionary();
         if (isBackButtonEnabled()) {
            _navManager.addEventListener(NavigationEvent.NAVIGATION_EVENT , onNavigate);
         }
      }
      
      private function isBackButtonEnabled():Boolean {
         return ApplicationManager.getInstance().isEmbed(); 
      }
      
      private function onNavigate(event:NavigationEvent):void {
         if (event.isNewFocus) {
            _lastLocation = null;
            if (!event.isShowingPTW) {
               if (!event.wasShowingPTW) {
                  if (event.oldSelectedPearl is BroDistantTreeRefNode) {
                     if (BroDistantTreeRefNode(event.oldSelectedPearl).treeId == event.newFocusTree.id) {
                        saveAliasNavigation(event);   
                     }
                  }
               }
               else if (event.oldSearchKeyword != null && event.newFocusTree.id == _lastFocusIdFromPTW) {
                  saveSearchNavigation(event);
               } else if (event.oldSearchKeyword == null) {
                  saveDiscoverNavigation(event);
               }
               if (event.newFocusTree) {
                  _lastLocation = _aliasNavigations[event.newFocusTree.id];
               }
            }
         }
         _lastFocusIdFromPTW = 0;
      }

      public function navigateThroughAlias(distantTreeRefNode:BroDistantTreeRefNode, node:IPTNode=null):void {
         if(distantTreeRefNode.refTree.isDeleted() || distantTreeRefNode.refTree.isHidden()) {
            return;
         }
         if (node) {
            var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
            selectionModel.saveCrossingBusinessNode(node);
         }
         var associationId:int = distantTreeRefNode.refTree.getMyAssociation().associationId;
         var userId:int = distantTreeRefNode.user.persistentId;
         var treeId:int = distantTreeRefNode.refTree.id;
         declareNavigationWithBack(_navManager.getSelectedUser(), _navManager.getFocusedTree(), distantTreeRefNode, distantTreeRefNode.user, distantTreeRefNode.refTree.id);
         var navDesc:NavigationDescription = NavigationDescription.goToLocation(associationId, userId, treeId, treeId, distantTreeRefNode.refTree.getRootNode().persistentID);
         navDesc.withNavigateFromNode(true);
         navDesc.withAliasNavigation(true);
         _navManager.navigate(navDesc);
      }
      public function declareNavigationFromPTW(treeId:Number):void {
         _lastFocusIdFromPTW = treeId;
      }
      public function declareNavigationWithBack(fromUser:User, fromFocusTree:BroPearlTree, fromNode:BroPTNode, toUser:User, toFocusTreeId:Number, toPearlWindowPanel:uint=0, revealState:int=-1):void {
         if (!isBackButtonEnabled()) {
            return;
         }

         if(fromNode) {   
            var lastLocation:NavigationLocation = NavigationLocation.makeAliasNavigation(toFocusTreeId, fromFocusTree, fromUser, fromNode.owner, fromNode, toPearlWindowPanel, revealState);
            _aliasNavigations[lastLocation.navigationKey] =  lastLocation;
         }
      }
      
      public function get isBackFromAlias():Boolean {
         return _lastLocation != null;
      }

      private function saveAliasNavigation(event:NavigationEvent):void {
         declareNavigationWithBack(event.oldUser, event.oldFocusTree, event.oldSelectedPearl, event.newUser, event.newFocusTree.id);
      }

      private function saveSearchNavigation(event:NavigationEvent):void {
         var lastLocation:NavigationLocation = NavigationLocation.makeSearchNavigation(event.newFocusTree.id, event.oldSearchKeyword, event.oldSearchUserId, event.oldSearchUserOnly);
         _aliasNavigations[lastLocation.navigationKey] = lastLocation;
      }
      private function saveDiscoverNavigation(event:NavigationEvent):void {
         var oldFocusTreeId:int = 0;
         var userId:int = 0;
         if (event.oldFocusTree) {
            oldFocusTreeId = event.oldFocusTree.id;
         }
         if (event.oldUser) {
            userId = event.oldUser.persistentId;
         }
         if (!event.newFocusTree.isCurrentUserAuthor()) {
            var lastLocation:NavigationLocation = NavigationLocation.makeDiscoverNavigation(event.newFocusTree.id, event.oldFocusAssoId, userId, oldFocusTreeId);
            _aliasNavigations[lastLocation.navigationKey] = lastLocation;
         }
      }
      
      public function goBackFromCurrentLocation():void {
         if (_lastLocation) {
            delete _aliasNavigations[_lastLocation.navigationKey];
            var lastLocation:NavigationLocation = _lastLocation;
            _lastLocation = null;
            lastLocation.navigatateToLocation(_navManager);
         }
      }
      
      public function removeAllAliasNavigations():void {
         _aliasNavigations = new Dictionary();
         _lastLocation = null;
      }
   }
}