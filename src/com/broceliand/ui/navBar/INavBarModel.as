package com.broceliand.ui.navBar {
   
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.events.IEventDispatcher;
   
   public interface INavBarModel extends IEventDispatcher {
      
      function get items():Vector.<NavBarModelItem>;
      function performItemAction(item:NavBarModelItem):void;
      function performIconAction():void;
      function get iconActionOnFirstItem():Boolean;
      function get useLargeGap():Boolean;
      function get isHomeButtonDisplayed():Boolean;
      function get isSimpleButtonDisplayed():Boolean;
      function get isWhatsHotButtonDisplayed():Boolean;
      function get isMostConnectedButtonDisplayed():Boolean;
      function get isVisible():Boolean;
      function set isVisible(value:Boolean):void;
      function get avatarTree():BroPearlTree;
      function refreshModel():void;
      function get iconType():uint;
      function navigateToMostConnectedTrees():void;
      function getPuzzleColor():uint;
      function get compactMode():uint;
      function get withPremiumSymbol():Boolean;
      function get isTeamNameOrSearchResult():Boolean;
      
      function forceViewRefresh():void; 
      
   }
}