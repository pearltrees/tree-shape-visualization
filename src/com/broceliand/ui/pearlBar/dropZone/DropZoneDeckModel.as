package com.broceliand.ui.pearlBar.dropZone {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.io.exporter.UserExporter;
   import com.broceliand.pearlTree.io.loader.AccountManager;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearlBar.deck.DeckModel;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.geom.Point;

   public class DropZoneDeckModel extends DeckModel {
      public static const HOLDING_NO_MSG:int =0;
      public static const HOLDING_MY_ASSO_DRAGGED:int=1;
      public static const HOLDING_MY_ASSO_EMPTY:int=2;
      public static const HOLDING_OTHER_ASSO_DRAGGED:int=3;
      public static const HOLDING_OTHER_ASSO_EMPTY:int=4;
      public static const HOLDING_PTW_EMPTY:int=5;
      
      private var _cleanDropZoneOnLogin:Boolean = false;
      
      public function DropZoneDeckModel() {
         super();
         deckType = DeckModel.TYPE_DROPZONE;
         title = BroLocale.getInstance().getText('deck.dropzone.title');
         emptyText = BroLocale.getText('pearlBar.pickup.title');
         isVisible = true;
         var accountManager:AccountManager = ApplicationManager.getInstance().accountManager;
         accountManager.addEventListener(AccountManager.USER_LOGGED_IN_EVENT, onUserLogin);
         accountManager.addEventListener(UserExporter.ACCOUNT_CREATED_EVENT, onUserLogin);
      }
      
      override protected function dockCopyOfNode(node:IPTNode, effectSource:Point=null):IPTNode {
         var copynode:IPTNode = super.dockCopyOfNode(node, effectSource);
         if (copynode) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            if(am.currentUser.isAnonymous()) {
               _cleanDropZoneOnLogin = true;
               DropZoneAnonymousStorage.getInstance().addNode(node.getBusinessNode());
            }else{
               var editionController:IPearlTreeEditionController = am.components.pearlTreeViewer.pearlTreeEditionController;
               editionController.addNodeToDropZone(copynode);
            }
         }
         return copynode;
      }
      
      private function onUserLogin(event:Event):void {
         if(_cleanDropZoneOnLogin) {
            _cleanDropZoneOnLogin = false;
            removeAll();
         }
      }
      
      override public function get isHighlighted():Boolean {
         if(ApplicationManager.getInstance().currentUser.isAnonymous()) {
            return false;
         }else{
            return super.isHighlighted;
         }
      }
      
      override public function get isNavButtonVisible():Boolean {
         if(ApplicationManager.getInstance().currentUser.isAnonymous()) {
            return false;
         }else{
            return true;
         }
      }
      
      public function get holdingMsgType():int{
         var type:int = HOLDING_NO_MSG;
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         var interactorManager:InteractorManager = am.components.pearlTreeViewer.interactorManager;
         if (am.currentUser.isAnonymous()){
            return HOLDING_NO_MSG;
         }
         
         if (am.visualModel.navigationModel.isShowingPearlTreesWorld()){
            if (getItemsCount()==0){
               return HOLDING_PTW_EMPTY;
            }else{
               return HOLDING_NO_MSG;
            }
         }
         
         if (interactorManager.draggedPearl) {
            if (getItemsCount()==0){
               if (am.visualModel.navigationModel.isInMyWorld()){
                  return HOLDING_MY_ASSO_DRAGGED;
               }else{
                  return HOLDING_OTHER_ASSO_DRAGGED;
               }
            }else{
               return HOLDING_NO_MSG;
            }
         }else if (getItemsCount()==0){
            if (am.visualModel.navigationModel.isInMyWorld()){
               return HOLDING_MY_ASSO_EMPTY;
            }else{
               return HOLDING_OTHER_ASSO_EMPTY;
            }     
         }else{
            return HOLDING_NO_MSG;
         }
      }

   }
}