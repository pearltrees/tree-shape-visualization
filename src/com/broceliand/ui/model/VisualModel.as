package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ApplicationMessageBroadcaster;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.pearlTree.model.BroDataRepository;
   import com.broceliand.pearlTree.model.privateMsg.PrivateMsgContactsCache;
   import com.broceliand.pearlTree.model.team.ITeamRequestModel;
   import com.broceliand.pearlTree.model.team.TeamRequestModel;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.impl.FacebookNavigationMonitor;
   import com.broceliand.pearlTree.navigation.impl.NavigationManagerImpl;
   import com.broceliand.ui.renderers.PearlLogoUpdater;
   import com.broceliand.ui.controller.IEditionController;
   import com.broceliand.ui.highlight.HighlightManager;
   import com.broceliand.ui.interactors.EditionController;
   import com.broceliand.ui.mouse.MouseManager;
   import com.broceliand.ui.welcome.HomePageModel;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.PTKeyboardListener;
   
   public class VisualModel
   {
      
      private var _dataRepository:BroDataRepository;
      private var _selectionModel:SelectionModel;
      private var _openTreesModel:OpenTreesStateModel = new OpenTreesStateModel();
      private var _navigationModel:INavigationManager;
      private var _scrollModel:ScrollModel;
      
      private var _noteModel:NoteModel;
      private var _teamDiscussionModel:NoteModel;
      private var _neighbourModel:NeighbourModel;
      private var _highlightManager:HighlightManager;
      private var _mouseManager:MouseManager;
      private var _homePageModel:HomePageModel;
      private var _privateMsgContactsCache:PrivateMsgContactsCache;
      
      private var _pearlLogoUpdater:PearlLogoUpdater;
      private var _editionController:IEditionController;
      private var _applicationMessageBroadcaster:ApplicationMessageBroadcaster;
      private var _animationRequestProcessor:GraphicalAnimationRequestProcessor;
      
      public function VisualModel(keyboardListener:PTKeyboardListener, browserName:String, os:String, dataRepository:BroDataRepository) {
         _dataRepository = dataRepository;
         _applicationMessageBroadcaster = new ApplicationMessageBroadcaster();
         _navigationModel= new NavigationManagerImpl();
         _selectionModel= new SelectionModel(_navigationModel);
         _scrollModel = new ScrollModel();
         _noteModel = new NoteModel(this, NoteModel.TYPE_NOTE);
         _teamDiscussionModel = new NoteModel(this, NoteModel.TYPE_TEAM_DISCUSSION);
         _neighbourModel = new NeighbourModel(dataRepository);
         _highlightManager = new HighlightManager();
         _mouseManager = new MouseManager(browserName, os);
         _animationRequestProcessor= new GraphicalAnimationRequestProcessor();
         _editionController= new EditionController(_selectionModel, keyboardListener);
         _homePageModel  = new HomePageModel();
         _privateMsgContactsCache = new PrivateMsgContactsCache(_navigationModel);
         
         _pearlLogoUpdater = new PearlLogoUpdater;
      }
      
      public function get dataRepository():BroDataRepository {
         return _dataRepository;
      }
      public function get homePageModel():HomePageModel {
         return _homePageModel;
      }
      public function get selectionModel ():SelectionModel {
         return _selectionModel;
      }
      
      public function get privateMsgContactsCache():PrivateMsgContactsCache {
         return _privateMsgContactsCache;
      }
      public function get applicationMessageBroadcaster():ApplicationMessageBroadcaster {
         return _applicationMessageBroadcaster;
      }
      
      public function get openTreesModel ():OpenTreesStateModel
      {
         return _openTreesModel;
      }
      
      public function get navigationModel ():INavigationManager
      {
         return _navigationModel;
      }
      
      public function get scrollModel ():ScrollModel
      {
         return _scrollModel;
      }
      
      public function get noteModel():NoteModel {
         return _noteModel;
      }
      
      public function get teamDiscussionModel():NoteModel {
         return _teamDiscussionModel;
      }
      
      public function get neighbourModel():NeighbourModel {
         return _neighbourModel;
      }
      
      public function get highlightManager():HighlightManager {
         return _highlightManager;
      }
      
      public function get mouseManager():MouseManager{
         return _mouseManager;
      }
      
      public function get animationRequestProcessor ():GraphicalAnimationRequestProcessor
      {
         return _animationRequestProcessor;
      }
      
      public function get editionController ():IEditionController
      {
         return _editionController;
      }
      
      /*public function get fbNavigationMonitor ():FacebookNavigationMonitor
      {
      return _fbNavigationMonitor;
      }*/
      
      public function get pearlLogoUpdater():PearlLogoUpdater
      {
         return _pearlLogoUpdater;
      }
      
   }
}