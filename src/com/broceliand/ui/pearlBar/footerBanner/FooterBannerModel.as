package com.broceliand.ui.pearlBar.footerBanner {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.AccountManager;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.pearlBar.deck.DeckModel;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class FooterBannerModel extends EventDispatcher {
      
      public static const MODEL_CHANGE:String = "modelChanged";
      
      public static const STATE_DEFAULT:uint = 0;
      public static const STATE_PICK:uint = 1;
      public static const STATE_ONE_PEARL:uint = 2;
      public static const STATE_FULL:uint = 3;
      
      private static const NUM_PEARL_TO_SET_FULL_STATE:uint = 2;
      
      private var _isVisible:Boolean;
      private var _state:uint;
      private var _selectedTree:BroPearlTree;
      private var _dropZoneModel:IDeckModel;
      private var _isShowingPTW:Boolean;
      
      public function FooterBannerModel() {
         super();
         var am:ApplicationManager = ApplicationManager.getInstance();
         _isVisible = true;
         _state = STATE_DEFAULT;
         _dropZoneModel = am.components.pearlTreeViewer.vgraph.controls.dropZoneDeckModel;
         isShowingPTW = am.visualModel.navigationModel.isShowingPearlTreesWorld();
         selectedTree = am.visualModel.navigationModel.getSelectedTree();

         am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         am.accountManager.addEventListener(AccountManager.USER_LOGGED_IN_EVENT, onUserLogin);
         _dropZoneModel.addEventListener(DeckModel.MODEL_CHANGE, onDeckModelChange);
      }
      
      private function onUserLogin(event:Event):void {
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.visualModel.navigationModel.removeEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         am.accountManager.removeEventListener(AccountManager.USER_LOGGED_IN_EVENT, onUserLogin);
         _dropZoneModel.removeEventListener(DeckModel.MODEL_CHANGE, onDeckModelChange);
      }
      
      private function onNavigationChange(event:NavigationEvent):void {
         selectedTree = event.newSelectedTree;
         isShowingPTW = event.isShowingPTW;
      }
      
      private function onDeckModelChange(event:Event):void {
         var itemCount:uint = _dropZoneModel.getItemsCount();
         if(itemCount >= NUM_PEARL_TO_SET_FULL_STATE && state != STATE_FULL) {
            _dropZoneModel.addEventListener(DeckModel.EFFECTS_END, onDropZoneEffectsEnd);
         }
         else if(itemCount == 1 && state != STATE_ONE_PEARL) {
            _dropZoneModel.addEventListener(DeckModel.EFFECTS_END, onDropZoneEffectsEnd);
         }
      }
      
      private function onDropZoneEffectsEnd(event:Event):void {
         if(!_dropZoneModel.isScollEffectPlaying) {
            var itemCount:uint = _dropZoneModel.getItemsCount();
            if(itemCount >= NUM_PEARL_TO_SET_FULL_STATE) {
               state = STATE_FULL;
            }
            else if(itemCount == 1) {
               state = STATE_ONE_PEARL;
            }
         }
         _dropZoneModel.removeEventListener(DeckModel.EFFECTS_END, onDropZoneEffectsEnd);
      }
      
      public function onClickPick():void {
         if(_state == STATE_DEFAULT) {
            state = STATE_ONE_PEARL;
         }
      }
      
      public function onDragBegin():void {
         if(_state == STATE_DEFAULT) {
            state = STATE_PICK;
         }
      }
      
      public function get isVisible():Boolean {
         return _isVisible;
      } 
      public function set isVisible(value:Boolean):void {
         if(value != _isVisible) {
            _isVisible = value;
            dispatchChangeEvent();
         }
      }
      
      public function get state():uint {
         return _state;
      }
      public function set state(value:uint):void {
         if(value != _state) {
            _state = value;
            dispatchChangeEvent();
         }
      }
      
      public function get selectedTree():BroPearlTree {
         return _selectedTree;
      }
      public function set selectedTree(value:BroPearlTree):void {
         if(value != _selectedTree) {
            _selectedTree = value;
            dispatchChangeEvent();
         }
      }
      
      public function get selectedAsso():BroAssociation {
         return (_selectedTree)?_selectedTree.getMyAssociation():null;
      }
      
      public function set isShowingPTW(value:Boolean):void {
         if(value != _isShowingPTW) {
            _isShowingPTW = value;
            dispatchChangeEvent();
         }
      }
      public function get isShowingPTW():Boolean {
         return _isShowingPTW;
      }
      
      protected function dispatchChangeEvent():void {
         dispatchEvent(new Event(MODEL_CHANGE));
      }
   }
}