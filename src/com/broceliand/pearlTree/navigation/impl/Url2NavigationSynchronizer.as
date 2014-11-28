package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.util.StringHelper;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.UrlNavigationController;
   
   import flash.events.Event;
   
   import mx.managers.IHistoryManagerClient;
   
   public class Url2NavigationSynchronizer implements IHistoryManagerClient
   {
      public static const  HISTORY_CLIENT_NAME:String="N"; 
      public static const  USER_FIELD:String="u"; 
      public static const  FOCUS_FIELD:String="f"; 
      public static const  FOCUS_ASSOCIATION_FIELD:String="fa"; 
      public static const  SELECT_FIELD:String="s"; 
      public static const  PEARL_FIELD:String="p"; 
      public static const  INTERSECTION_FIELD:String="i"; 
      public static const  PTW_FIELD:String="w"; 
      public static const  PEARL_WINDOW_FIELD:String="pw";
      public static const  PLAY_FIELD:String="play";
      public static const  PLAY_URL_FIELD:String="play-url";
      public static const  PLAY_ID_FIELD:String="play-id";
      public static const  PLAY_STATE_FIELD:String="play-state";
      public static const  PLAY_TITLE_FIELD:String="play-title";
      public static const  REVEAL_FIELD:String="reveal";
      public static const  SEARCH_FIELD:String="q"; 
      public static const  SEARCH_IN_USER_ACCOUNT_FIELD:String="su"; 
      public static const  SEARCH_USER_ONLY_FIELD:String="people"; 
      
      private static var _updateWithDelay:Boolean= false;
      
      private var _nbOfEventToIgnore:int=0;
      private var _previousState:Object;
      private var _currentState:Object;
      private var _navigator:INavigationManager;
      private var _abModel:Number;

      private var _updateStateWhenFocusChangeOnly:Boolean = false;
      public function Url2NavigationSynchronizer(navBar:INavigationManager) {
         _navigator = navBar;
         _navigator.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         _navigator.addEventListener(NavigationEvent.PLAY_EVENT, onNavigationChange);
         UrlNavigationController.registerHistory(HISTORY_CLIENT_NAME, this);
         new Url2Error();
         new Url2Pearlbar();
         new Url2Overlay();
         new Url2DisplayedPage();
         new Url2EmbedWindow();
         new Url2TeamRequest();
      }
      
      private function onNavigationChange(workaroundEvent:Event):void {
         var e:NavigationEvent = NavigationEvent (workaroundEvent);
         
         var association:BroAssociation = (e.newFocusTree)?e.newFocusTree.getMyAssociation():null;
         var state:Object = makeState(association, e.newUser, e.newFocusTree,e.newSelectedTree, e.newSelectedPearl, e.selectionOnIntersection, e.isShowingPTW, e.newPearlWindowPreferredState, e.playState, e.revealState, e.searchKeyword, e.isHome, e.searchUserId, e.searchUserOnly);
         if ( _currentState !=null &&  !areStateTheSame(_currentState, state)) {
            _previousState  = _currentState;
            _nbOfEventToIgnore ++;
            _currentState  =state;
            UrlNavigationController.save();
         } else {
            _currentState = state;
         }          
         
         updateBrowserTitle(e);
      }
      
      private function updateBrowserTitle(e:NavigationEvent):void {
         
         var title:String = null;
         var separator:String = " • ";
         
         var am:ApplicationManager = ApplicationManager.getInstance();  
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         var selectedTree:BroPearlTree = navigationModel.getSelectedTree();
         var focusedTree:BroPearlTree = navigationModel.getFocusedTree();
         
         if(e.isShowingPTW) {
            if(navigationModel.isWhatsHot()) {
               title = separator + BroLocale.getInstance().getText('navBar.whatsHot');
            } else if (e.searchKeyword != null) {
               title = separator + BroLocale.getInstance().getText('navBar.searchTitle');
            } else {
               title = separator + BroLocale.getInstance().getText('navBar.mostConnected');
            }
         } else{
            
            var rootTree:BroPearlTree = null;
            if(focusedTree && focusedTree.getMyAssociation()) {
               var focusAssociation:BroAssociation = focusedTree.getMyAssociation();
               if(selectedTree && selectedTree.getMyAssociation() != focusAssociation) {
                  rootTree = selectedTree;
               }
               else {
                  rootTree = am.visualModel.dataRepository.getTree(focusAssociation.associationId);
               }
            }
            
            if(rootTree) {
               title = separator + rootTree.title;
            }else{
               UrlNavigationController.setBrowserTitle(title);
               return;
            }
            
            if(selectedTree && selectedTree != rootTree) {
               title += separator + selectedTree.title;
            }  
            
            var selectedNode:BroPTNode = navigationModel.getSelectedPearl();
            var excitedTree:BroPearlTree = null;
            if(selectedNode is BroTreeRefNode) {
               excitedTree = BroTreeRefNode(selectedNode).refTree;
            }else if(selectedNode is BroPTRootNode) {
               excitedTree = selectedNode.owner;
            }
            
            if(excitedTree && excitedTree != selectedTree && excitedTree != rootTree) {
               title += separator + excitedTree.title;
            }
            
            if(e.playState == 1 && selectedNode is BroPageNode) {
               title += separator + selectedNode.title;
            }
         }          
         UrlNavigationController.setBrowserTitle(title); 
         
      }
      
      private function areStateTheSame(currentState:Object, state:Object):Boolean {
         if (currentState==null) { return state==null; }
         if (_updateStateWhenFocusChangeOnly) {
            return _currentState[USER_FIELD]=state[USER_FIELD] && _currentState[FOCUS_FIELD] == state[FOCUS_FIELD] && _currentState[FOCUS_ASSOCIATION_FIELD] == state[FOCUS_ASSOCIATION_FIELD] && _currentState[PTW_FIELD] == state[PTW_FIELD];
         }
         for (var name:String in currentState) {
            if (!state.hasOwnProperty(name) || state[name] != currentState[name]) {
               return false;
            }
         }
         for (name in state) {
            if (!currentState.hasOwnProperty(name)) {
               return false;
            }
         } 
         return true;
      }
      public function saveState():Object {
         return _currentState;
      }
      
      public function loadState(state:Object):void {
         if (state) {
            if (_updateWithDelay && _nbOfEventToIgnore>0 ) { 
               _nbOfEventToIgnore --;
               _previousState = null;
            } else if (!areStateTheSame(_currentState, state)) {
               var focusAssociationId:int = -1;
               var userId:int=-1;
               var focustTreeId:int=-1;
               var selectedTreeId:int=-1;
               var pearlId:int=-1;
               var onIntersection:int=-1;
               var pearlWindowState:int=0;
               var play:int = -1;
               var playState:int = -1;
               var playUrl:String = null;
               var playTitle:String = null;
               var playId:int = -1;
               var revealState:int = -1;
               var isPTW:Boolean=false;
               var isHome:Boolean=false;
               var searchKeyword:String=null;
               var searchUserId:Number=0;
               var searchUserOnly:Boolean=false;
               
               _currentState = state;
               if (_currentState[SEARCH_FIELD]) {
                  searchKeyword = _currentState[SEARCH_FIELD] as String;
               }
               if (_currentState[SEARCH_IN_USER_ACCOUNT_FIELD] != null) {
                  searchUserId = parseInt(_currentState[SEARCH_IN_USER_ACCOUNT_FIELD]);
                  if (isNaN(searchUserId)) {
                     searchUserId = 0;
                  }
               }
               if (_currentState[SEARCH_USER_ONLY_FIELD] != null) {
                  searchUserOnly = true;
               }
               if (_currentState[SEARCH_IN_USER_ACCOUNT_FIELD] != null) {
                  searchUserId = parseInt(_currentState[SEARCH_IN_USER_ACCOUNT_FIELD]);
                  if (isNaN(searchUserId)) {
                     searchUserId = 0;
                  }
               }
               var uKey:Array = User.parseUserKey(_currentState[USER_FIELD]);
               if (uKey) {
                  userId = uKey[1];
               }
               var fKey:Array = BroPearlTree.parseTreerKey(_currentState[FOCUS_FIELD]);
               if (fKey) {
                  focustTreeId = fKey[1];
               }
               
               if (_currentState[FOCUS_ASSOCIATION_FIELD]) {
                  focusAssociationId = _currentState[FOCUS_ASSOCIATION_FIELD];
               }            
               
               var sKey:Array = BroPearlTree.parseTreerKey(_currentState[SELECT_FIELD]);
               if (sKey) {
                  selectedTreeId = sKey[1];
               }
               if (_currentState[PEARL_FIELD]!=null) {
                  pearlId = parseInt(_currentState[PEARL_FIELD]);
                  if (isNaN(pearlId)){ 
                     pearlId = -1;
                  }
               }
               if (_currentState[INTERSECTION_FIELD]!=null) {
                  onIntersection = parseInt(_currentState[INTERSECTION_FIELD]);
                  if (isNaN(onIntersection)) {
                     onIntersection = -1;
                  }
               }
               
               if (_currentState[PEARL_WINDOW_FIELD]!=null) {
                  pearlWindowState = parseInt(_currentState[PEARL_WINDOW_FIELD]);
                  if (isNaN(pearlWindowState)) {
                     pearlWindowState = 0;
                  }
               }
               if (_currentState[PLAY_FIELD]!=null) {
                  play= parseInt(_currentState[PLAY_FIELD]);
                  if (isNaN(play)) {
                     play = -1;
                  }
               }
               if (_currentState[PLAY_ID_FIELD]!=null) {
                  playId= parseInt(_currentState[PLAY_ID_FIELD]);
                  if (isNaN(playId)) {
                     playId = -1;
                  }
               }
               if (_currentState[PLAY_STATE_FIELD]!=null) {
                  playState= parseInt(_currentState[PLAY_STATE_FIELD]);
                  if (isNaN(playState)) {
                     playState = -1;
                  }
               }
               
               if (_currentState[PLAY_URL_FIELD]!=null) {
                  playUrl= _currentState[PLAY_URL_FIELD] as String;
               }
               
               if (_currentState[PLAY_TITLE_FIELD]!=null) {
                  playTitle= _currentState[PLAY_TITLE_FIELD] as String;
                  if (playTitle) {
                     playTitle = StringHelper.unescapeWithPlus(playTitle);
                  }
               }
               
               if (_currentState[REVEAL_FIELD]!=null) {
                  revealState = parseInt(_currentState[REVEAL_FIELD]);
                  if (isNaN(revealState)) {
                     revealState = -1;
                  }
                  if (revealState > 0) {
                     play = -1;
                  }
                  if (revealState < -1) {
                     var model:String = "";
                     if (revealState == -2) {
                        model = "A";
                        _abModel = 1;
                     }
                     else if (revealState == -3) {
                        model = "B";
                        _abModel = 2;
                        StartPolicyLogger.getInstance().setStartLocation(StartPolicyLogger.START_LOCATION_SEO_URL);
                     }
                     else if (revealState == -4) {
                        model = "C";
                        _abModel = 3;
                     }
                  }
               }
               
               if (_currentState[PTW_FIELD] != null) {
                  if ("h" == _currentState[PTW_FIELD] ) {
                     isHome = true;   
                  }
                  isPTW = true;
               }
               if (searchKeyword) {
                  _navigator.navigate(NavigationDescription.goToSearch(searchKeyword, searchUserId, searchUserOnly));
               } 
               else if (isPTW) {
                  _navigator.goToPearlTreesWorld(focusAssociationId, 
                     userId, 
                     focustTreeId, 
                     isHome);
               } 
               else if(Url2TeamRequest.hasTeamRequestNavigationUrl() && !ApplicationManager.getInstance().currentUser.isAnonymous()) {
                  
               }
               else {
                  if (  true &&
                     pearlWindowState>0 &&
                     !(ApplicationManager.getInstance().currentUser.isAdminAccount() && pearlWindowState == PWModel.LIST_PRIVATE_MSG_PANEL)
                     && true) {
                     ApplicationManager.getInstance().components.windowController.setPearlWindowDocked(false);
                  }
                  if (revealState == NavigationEvent.ADD_ON_NAVIGATION_TYPE && pearlId == -1 && focusAssociationId > 0) {
                     new PreLoadingRequest(focustTreeId, focusAssociationId).load();
                     return;
                  }

                  _navigator.goTo(focusAssociationId, 
                     userId,
                     focustTreeId,
                     selectedTreeId, 
                     pearlId, 
                     onIntersection, 
                     play,  
                     pearlWindowState, 
                     false, 
                     revealState);
               }
               if (playId != -1 && playUrl != null && play == 1) {
                  ApplicationManager.getInstance().components.pearlTreePlayer.showPlayerOnUrl(playUrl, playId, playState, playTitle);
               }
            }
         }
      }
      
      private function makeState(focusAssociation:BroAssociation, user:User, focusTreeKey:BroPearlTree, selectedTree:BroPearlTree, pearl:BroPTNode, onIntersection:int, isOnPTW:Boolean, pearlWindowPreferredState:int, play:int, revealState:int, searchKeywod:String, isHome:Boolean, searchUserId:Number, searchUserOnly:Boolean):Object {
         var state:Object= new Object();
         if (searchKeywod) {
            state[SEARCH_FIELD] = searchKeywod;
            if (searchUserId != 0) {
               state[SEARCH_IN_USER_ACCOUNT_FIELD] = searchUserId;
            }           
            if (searchUserOnly) {
               state[SEARCH_USER_ONLY_FIELD] = "y";
            }
         } else {
            if (user) {
               state[USER_FIELD] = User.getUserKey(user.persistentDbId, user.persistentId);
            } else {
               state[USER_FIELD] = "-1_-1"; 
            }
            if (focusTreeKey) {
               state[FOCUS_FIELD] = BroPearlTree.getTreeKey(focusTreeKey.dbId, focusTreeKey.id); 
            }
            if (focusAssociation) {
               state[FOCUS_ASSOCIATION_FIELD] = focusAssociation.associationId; 
            }            
            if (selectedTree) {
               state[SELECT_FIELD] = BroPearlTree.getTreeKey(selectedTree.dbId, selectedTree.id); 
            }
            if (pearl) {
               state[PEARL_FIELD] = ""+pearl.persistentID;
            }
            if (onIntersection>=0) {
               state[INTERSECTION_FIELD]=""+onIntersection; 
            }
            if (isOnPTW) {
               if (isHome) {
                  state[PTW_FIELD]="h";    
               } else {
                  state[PTW_FIELD]="y";
               }
            }
            if (pearlWindowPreferredState != 0) {
               state[PEARL_WINDOW_FIELD]= pearlWindowPreferredState;
            }
            if (play != -1) {
               state[PLAY_FIELD]= play;
            }
            if (revealState != -1) {
               state[REVEAL_FIELD]= revealState;
            }
         }
         return state;
      }    
      
      public  function toString():String {
         return "N";
      }
      
      public function get abModel():Number {
         return _abModel;
      }
   }
}