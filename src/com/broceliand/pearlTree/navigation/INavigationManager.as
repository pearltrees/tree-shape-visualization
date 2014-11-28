package com.broceliand.pearlTree.navigation
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.impl.ApplicationDisplayedPageModel;
   import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
   import com.broceliand.pearlTree.navigation.impl.NavigationHistoryModel;
   import com.broceliand.pearlTree.navigation.impl.Url2NavigationSynchronizer;
   import com.broceliand.ui.controller.AliasNavigationModel;
   import com.broceliand.ui.welcome.tunnel.TunnelNavigationModel;
   
   import flash.events.IEventDispatcher;
   
   import mx.managers.HistoryManager;
   
   public interface INavigationManager extends IEventDispatcher
   {  
      
      function navigate(desc:NavigationDescription):void;
      function get urlSynchro():Url2NavigationSynchronizer;

      function goTo(associationId:int=-1, userId:int=-1, focusTreeId:int=-1, selectedTreeId:int=-1, pearlId:int=-1, onIntersection:int= -1, showPlayer:int= -1, pearlWindowPreferredState:int=0, navigateFromNode:Boolean=false, revealState:int=-1, followMoved:Boolean = false, resultCallback:INavigationResultCallback = null):void;  
      function goToUser(user:User, pearlWindowPreferredState:int=-1):void;
      function goToPearlTreesWorld(associationId:int, userId:int, treeId:int, isHomePage:Boolean =false):void;
      function getAliasNavigationModel():AliasNavigationModel;
      
      function getNavigationHistoryModel():NavigationHistoryModel;
      
      function goToAssociationParentPearl(assoId:int):void;  
      
      function goToWhatsHot(isHomePage:Boolean):void;
      
      function setPlayState(playState:int):void; 
      function getSelectedUser():User;
      function getFocusedTree():BroPearlTree;
      function getSelectedTree():BroPearlTree;
      function getSelectedPearl():BroPTNode;
      function getFocusNeighbourTree():BroPearlTree;
      function getSelectionIntersectionIndex():int;  
      function getPearlWindowPreferredState():int; 
      function getPlayState():int;  
      function isInPlayer():Boolean;
      function isInScreenLine():Boolean;
      function isShowingPearlTreesWorld():Boolean;
      function isShowingSearchResult():Boolean;
      function isShowingSearchPeopleResult():Boolean;
      function isShowingDiscover():Boolean;
      function getSearchKeyword():String;
      function getTunnelModel():TunnelNavigationModel;
      function getApplicationDisplayedPageModel():ApplicationDisplayedPageModel;
      function isInMyWorld():Boolean; 
      function isHomePage():Boolean;  
      function isAddOnNavigation():Boolean;
      function toCenterOnPearlForAnonymousArriving():Boolean;
      function set hasDisplayedABTestingEffectForAnonymous(value:Boolean):void;
      function isTreeInCurrentUserDropZone(tree:BroPearlTree):Boolean;
      function isWhatsHot():Boolean;
      function get focusAssoId():int;
      function get isFirstSelectionPerformed():Boolean;
      function set isFirstSelectionPerformed(value:Boolean):void;
      function cancelCurrentLoadingEvent():void;
      function get willShowPlayer():Boolean;
      function getSearchUserId():Number;
      function isAbTestingUser():Boolean;
   }
}
