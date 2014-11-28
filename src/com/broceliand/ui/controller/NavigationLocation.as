package com.broceliand.ui.controller {

   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
   
   public class NavigationLocation {
      
      protected var _navigationKey:Number;
      protected var _navigationDesc:NavigationDescription;

      public function NavigationLocation(navKey:Number, navDescription:NavigationDescription):void {
         _navigationKey = navKey;
         _navigationDesc = navDescription;
      }
      
      public static function makeAliasNavigation(navKey:Number, focusTree:BroPearlTree, selectedUser:User, selectedTree:BroPearlTree, selectedPearl:BroPTNode, pwPanel:int, revealstate:int):NavigationLocation {
         return new MyWorldNavigation(navKey, focusTree, selectedUser, selectedTree, selectedPearl, pwPanel, revealstate);
      }
      
      public static function makeSearchNavigation(navKey:Number, searchWord:String, userId:int, isUserSearch:Boolean):NavigationLocation {
         return new SearchNavigation(navKey, searchWord, userId, isUserSearch);
      }
      
      public static function makeDiscoverNavigation(navKey:Number, assoctionId:int, userId:int, treeId:int):NavigationLocation  {
         return new DiscoverNavigation(navKey, assoctionId, userId, treeId);
      }
      public function  navigatateToLocation(navModel:INavigationManager):void {
         _navigationDesc.withHistoryNavigation(true);
         navModel.navigate(_navigationDesc);
      }
      public function get navigationKey ():Number
      {
         return _navigationKey;
      }
      
      public function get focusTree():BroPearlTree
      {
         return null;
      }
      
      public function get selectedUser():User
      {
         return null;
      }
      
      public function get selectedTree():BroPearlTree
      {
         return null;
      }
      public function get selectedPearl():BroPTNode
      {
         return null;
      }

   }
}
import com.broceliand.ApplicationManager;
import com.broceliand.pearlTree.model.BroPTNode;
import com.broceliand.pearlTree.model.BroPearlTree;
import com.broceliand.pearlTree.model.User;
import com.broceliand.pearlTree.navigation.INavigationManager;
import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
import com.broceliand.ui.controller.NavigationLocation;

class MyWorldNavigation extends NavigationLocation {
   private var _focusTree:BroPearlTree;
   private var _selectedUser:User;
   private var _selectedTree:BroPearlTree;
   private var _selectedPearl:BroPTNode;
   private var _pwPanel:uint;
   private var _revealState:int;
   
   public function MyWorldNavigation(navKey:Number, focusTree:BroPearlTree, selectedUser:User, selectedTree:BroPearlTree, selectedPearl:BroPTNode, pwPanel:int, revealstate:int) {
      super(navKey, null);
      _focusTree = focusTree;
      _selectedUser = selectedUser;
      _selectedTree = selectedTree;
      _selectedPearl = selectedPearl;
      _pwPanel = pwPanel;
      _revealState = revealstate;
   }
   override public function  navigatateToLocation(navModel:INavigationManager):void {
      if(!_selectedTree && _focusTree) {
         _selectedTree = _focusTree;
      }
      navModel.goTo(_selectedTree.getMyAssociation().associationId, 
         _selectedUser.persistentId, 
         _selectedTree.id,
         _selectedTree.id,
         _selectedPearl.persistentID,
         -1, -1,
         -_pwPanel, 
         false, 
         _revealState);                             
      
   }
   
   override public function get focusTree():BroPearlTree
   {
      return _focusTree;
   }
   
   override public function get selectedUser():User
   {
      return _selectedUser;
   }
   
   override public function get selectedTree():BroPearlTree
   {
      return _selectedTree;
   }
}
class SearchNavigation extends NavigationLocation {
   private var _searchWord:String= null;
   private var _userId:int =0;
   private var _userOnly:Boolean = false;
   
   public function SearchNavigation(navKey:Number, searchWord:String, userId:int, isUserSearch:Boolean) {
      super(navKey, NavigationDescription.goToSearch(searchWord, userId, isUserSearch));
   }
   
}

class DiscoverNavigation extends NavigationLocation {
   private var _associationId:int;
   private var  _userId:int;
   private var _treeId:int;
   
   public function DiscoverNavigation(navKey:Number, assoctionId:int, userId:int, treeId:int) {
      super(navKey, null);
      _associationId  =assoctionId;
      _treeId = treeId;
      _userId = userId;
   }
   
   override public function  navigatateToLocation(navModel:INavigationManager):void {
      navModel.goToPearlTreesWorld(_associationId, _userId, _treeId);      
   }
}