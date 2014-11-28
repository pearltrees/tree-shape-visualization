package com.broceliand.pearlTree.navigation
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.discover.SpatialTree;
   import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
   
   import flash.events.Event;
   
   public class NavigationEvent extends Event {
      
      public static const NAVIGATION_EVENT:String  = "navigationEvent";
      public static const NAVIGATION_PLAYSTATE_UPDATE_EVENT:String = "navigationPlayStateUpdateEvent";
      public static const PLAY_EVENT:String  = "playEvent";
      public static const FORBIDDEN_EVENT:String = "navigationForbiddenEvent";
      public static const ADD_ON_NAVIGATION_TYPE:int = 1;
      public static const ADD_ON_RESET_GRAPH:int = 2;
      public static const ADD_ON_CLEAR_GRAPH_NO_SCROLL:int = 3;
      public static const ADD_ON_FADE_ANIMATION:int = 4;
      public static const ADD_ON_CROSS_ANIMATION:int = 5;
      public static const ADD_ON_RESET_GRAPH_AND_CENTER:int = 6;
      
      public static const PLAY_STATE_PLAYER:int = 1;
      public static const PLAY_STATE_SCREEN:int = 2;

      private var _newNavigationDescription:NavigationDescription;
      private var _newUser:User;
      private var _oldUser:User;
      private var _newFocusTree:BroPearlTree;
      private var _oldFocusTree:BroPearlTree;      
      private var _newNeighbourTree:BroPearlTree;
      private var _oldNeighbourTree:BroPearlTree;
      private var _oldSelectedPearl:BroPTNode;     
      private var _newSelectedPearl:BroPTNode;		
      private var _selectionOnIntersection:int;
      private var _playState:int;
      private var _revealState:int;      
      private var _oldPlayState:int;      
      private var _oldRevealState:int;      
      private var _wasShowingPTW:Boolean;
      private var _isShowingPTW:Boolean;      
      private var _isHome:Boolean;
      private var _newSelectedTree:BroPearlTree;		
      private var _newPearlWindowPreferredState:Number;		
      private var _searchKeyword:String;
      private var _searchUserId:Number;		
      private var _searchUserOnly:Boolean;
      private var _isFirstNavigation:Boolean;
      private var _oldSearchKeyword:String;
      private var _oldSearchUserId:Number;		
      private var _oldSearchUserOnly:Boolean;
      private var _spatialTreeList:Vector.<SpatialTree>;
      
      private var _isEndPearl:Boolean;
      private var _oldFocusAssoId:int;
      private var _newFocusAssoId:int;
      
      public function get newNavigationDescription():NavigationDescription
      {
         return _newNavigationDescription;
      }
      
      public function set newNavigationDescription(value:NavigationDescription):void
      {
         _newNavigationDescription = value;
      }
      
      public function get newFocusAssoId():int
      {
         return _newFocusAssoId;
      }
      
      public function set newFocusAssoId(value:int):void
      {
         _newFocusAssoId = value;
      }
      
      public function get oldFocusAssoId():int
      {
         return _oldFocusAssoId;
      }
      
      public function set oldFocusAssoId(value:int):void
      {
         _oldFocusAssoId = value;
      }
      
      public function set isEndPearl (value:Boolean):void
      {
         _isEndPearl = value;
      }
      
      public function get isEndPearl ():Boolean
      {
         return _isEndPearl;
      }

      public function set newPearlWindowPreferredState (value:Number):void
      {
         _newPearlWindowPreferredState = value;
      }
      
      public function get newPearlWindowPreferredState ():Number
      {
         return _newPearlWindowPreferredState;
      }
      
      public function set oldFocusTree (value:BroPearlTree):void
      {
         _oldFocusTree = value;
      }
      
      public function get oldFocusTree ():BroPearlTree
      {
         return _oldFocusTree;
      }
      
      public function set newFocusTree (value:BroPearlTree):void
      {
         if (value && value.getMyAssociation()) {
            newFocusAssoId = value.getMyAssociation().associationId;
         }
         _newFocusTree = value;
      }
      
      public function get newFocusTree ():BroPearlTree
      {
         return _newFocusTree;
      }

      public function set oldUser (value:User):void
      {
         _oldUser = value;
      }
      
      public function get oldUser ():User
      {
         return _oldUser;
      }
      
      public function set newUser (value:User):void
      {
         _newUser = value;
      }
      
      public function get newUser ():User
      {
         return _newUser;
      }

      public function NavigationEvent(type:String= NAVIGATION_EVENT) {
         super(type);
      }
      
      public function get isNewFocus ():Boolean
      {
         return hasChangedWorld || _oldFocusTree != _newFocusTree || _oldFocusAssoId != _newFocusAssoId || _oldSearchKeyword != _searchKeyword;
      }
      public function get hasChangedWorld():Boolean { 
         return _wasShowingPTW != _isShowingPTW;
      }  
      
      public function get isNewTreeSelection ():Boolean
      {
         return _oldSelectedTree != _newSelectedTree;
      }
      
      public function get isNewUser ():Boolean
      {
         return _newUser != oldUser;
      }

      public function set newSelectedTree (value:BroPearlTree):void
      {
         _newSelectedTree = value;
      }
      
      public function get newSelectedTree ():BroPearlTree
      {
         return _newSelectedTree;
      }
      
      private var _oldSelectedTree:BroPearlTree;
      public function set oldSelectedTree (value:BroPearlTree):void
      {
         _oldSelectedTree = value;
      }
      
      public function get oldSelectedTree ():BroPearlTree
      {
         return _oldSelectedTree;
      }
      public function set oldSelectedPearl (value:BroPTNode):void
      {
         _oldSelectedPearl = value;
      }
      
      public function get oldSelectedPearl ():BroPTNode
      {
         return _oldSelectedPearl;
      }
      public function set newSelectedPearl (value:BroPTNode):void
      {
         _newSelectedPearl = value;
      }
      
      public function get newSelectedPearl ():BroPTNode
      {
         return _newSelectedPearl;
      }
      
      public function set selectionOnIntersection (value:int):void
      {
         _selectionOnIntersection = value;
      }
      
      public function get selectionOnIntersection ():int
      {
         return _selectionOnIntersection;
      }
      
      public function set isShowingPTW (value:Boolean):void
      {
         _isShowingPTW = value;
      }
      
      public function get isShowingPTW ():Boolean
      {
         return _isShowingPTW;
      }
      
      public function set wasShowingPTW (value:Boolean):void
      {
         _wasShowingPTW = value;
      }
      
      public function get wasShowingPTW ():Boolean
      {
         return _wasShowingPTW;
      }

      public function set oldNeighbourTree (value:BroPearlTree):void
      {
         _oldNeighbourTree = value;
      }
      
      public function get oldNeighbourTree ():BroPearlTree
      {
         return _oldNeighbourTree;
      }
      
      public function set newNeighbourTree (value:BroPearlTree):void
      {
         _newNeighbourTree = value;
      }
      
      public function get newNeighbourTree ():BroPearlTree
      {
         return _newNeighbourTree;
      }
      public function set playState (value:int):void
      {
         _playState = value;
      }
      
      public function get playState ():int
      {
         return _playState;
      }
      
      public function set revealState (value:int):void
      {
         _revealState = value;
      }
      
      public function get revealState ():int
      {
         return _revealState;
      }      
      
      public function set oldPlayState (value:int):void
      {
         _oldPlayState = value;
      }
      
      public function get oldPlayState ():int
      {
         return _oldPlayState;
      }
      
      public function set oldRevealState (value:int):void
      {
         _oldRevealState = value;
      }
      
      public function get oldRevealState ():int
      {
         return _oldRevealState;
      }
      
      public function set isHome (value:Boolean):void
      {
         _isHome = value;
      }
      
      public function get isHome ():Boolean
      {
         return _isHome;
      }
      public function isDisplayingSearchResult():Boolean {
         return _searchKeyword!= null;
         
      }
      public function set searchKeyword (value:String):void
      {
         _searchKeyword = value;
      }
      
      public function get searchKeyword ():String
      {
         return _searchKeyword;
      }
      public function set searchUserOnly (value:Boolean):void
      {
         _searchUserOnly = value;
      }
      
      public function get searchUserOnly ():Boolean
      {
         return _searchUserOnly;
      }

      public function set searchUserId (value:Number):void
      {
         _searchUserId = value;
      }
      
      public function get searchUserId ():Number
      {
         return _searchUserId;
      }
      
      public function get isFirstNavigation():Boolean {
         return _isFirstNavigation;
      }
      public function set isFirstNavigation(value:Boolean):void {
         _isFirstNavigation = value;
      }
      
      public function get oldSearchKeyword():String
      {
         return _oldSearchKeyword;
      }
      
      public function set oldSearchKeyword(value:String):void
      {
         _oldSearchKeyword = value;
      }
      
      public function get oldSearchUserId():Number
      {
         return _oldSearchUserId;
      }
      
      public function set oldSearchUserId(value:Number):void
      {
         _oldSearchUserId = value;
      }
      
      public function get oldSearchUserOnly():Boolean
      {
         return _oldSearchUserOnly;
      }
      
      public function set oldSearchUserOnly(value:Boolean):void
      {
         _oldSearchUserOnly = value;
      }
      
      public function get spatialTreeList():Vector.<SpatialTree>
      {
         return _spatialTreeList;
      }
      
      public function set spatialTreeList(value:Vector.<SpatialTree>):void
      {
         _spatialTreeList = value;
      }
      
      public function isHistoryNavigation():Boolean {
         if (_newNavigationDescription) {
            return _newNavigationDescription.isHistoryNavigation;
         }
         return false;
      }
   }
}
