package com.broceliand.ui.model {
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.notification.NewsListFromNovelty;
   import com.broceliand.pearlTree.model.notification.NewsListFromTeamHistoryItem;
   import com.broceliand.pearlTree.model.notification.novelty.Novelty;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.NavigationDisplaySynchronizer;
   import com.broceliand.util.Assert;
   
   import flash.events.Event;
   
   import mx.formatters.SwitchSymbolFormatter;
   
   public class NewsLabelModel {
      
      public static const MODE_INACTIVE:int = 0;
      public static const MODE_NOVELTY:int = 1;
      public static const MODE_TEAM_HISTORY:int = 2;
      
      private var _currentMode:int = 0;
      private var _specificNewPearlList:NewsListFromTeamHistoryItem;
      private var _noveltyNavigation:NewsListFromNovelty;
      
      public function NewsLabelModel() {
         _currentMode = 0;
         _specificNewPearlList = new NewsListFromTeamHistoryItem();
         _noveltyNavigation = new NewsListFromNovelty();
      }
      
      public function hasNewLabel(node:BroPTNode):Boolean {
         switch (_currentMode) {
            case MODE_NOVELTY : return _noveltyNavigation.hasNew(node);
            case MODE_TEAM_HISTORY : return _specificNewPearlList.hasNew(node);
            default : return false;
         }
      }
      
      public function launchTeamHistoryNewsLabelMode(pearls:Array, assoId:int): void {
         _specificNewPearlList.setNewsListFromTeamHistoryItem(pearls, assoId);
         currentMode = MODE_TEAM_HISTORY;
      }
      
      public function launchNoveltyNewsLabelMode(novelty:Novelty): void {
         _noveltyNavigation.setNewsListFromNovelty(novelty);
         currentMode = MODE_NOVELTY;
      }
      
      public function cancelSpecificListModeOnClickInTeamHistory():void {
         currentMode = MODE_INACTIVE;
      }
      
      private function set currentMode(value:int):void {
         if (value != _currentMode) {
            removeOldListeners();
            _currentMode = value;
            addNewListeners();
         }
      }
      
      private function removeOldListeners():void {
         var nm:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         switch (_currentMode) {
            case MODE_NOVELTY : nm.removeEventListener(NavigationEvent.NAVIGATION_EVENT, cancelNoveltyMode);
               break;
            case MODE_TEAM_HISTORY : nm.removeEventListener(NavigationEvent.NAVIGATION_EVENT, cancelSpecificListMode);
               break;
         } 
      }
      
      private function addNewListeners():void {         
         var nm:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         switch (_currentMode) {
            case MODE_NOVELTY : nm.addEventListener(NavigationEvent.NAVIGATION_EVENT, cancelNoveltyMode);
               break;
            case MODE_TEAM_HISTORY : nm.addEventListener(NavigationEvent.NAVIGATION_EVENT, cancelSpecificListMode);
               break;
         } 
      }
      
      private function cancelNoveltyMode(event:NavigationEvent):void {
         if (event.isNewFocus) {
            currentMode = MODE_INACTIVE;
         }
      }
      
      private function cancelSpecificListMode(event:NavigationEvent):void {
         if (event.newFocusAssoId != _specificNewPearlList.assoId) {
            currentMode = MODE_INACTIVE;
         }
      }

   }
}