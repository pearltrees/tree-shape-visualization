package com.broceliand.ui.pearlBar.dropZone {
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.AccountManager;
   import com.broceliand.pearlTree.io.object.user.UserData;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetVoidCallback;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   
   import flash.events.Event;
   import flash.net.SharedObject;
   
   import mx.rpc.events.FaultEvent;

   public class DropZoneAnonymousStorage implements IAmfRetVoidCallback {
      
      private static var _instance:DropZoneAnonymousStorage;
      
      private var _nodeIdsCollection:Array;
      private var _so:SharedObject;
      
      public static function getInstance():DropZoneAnonymousStorage {
         if(!_instance) {
            _instance = new DropZoneAnonymousStorage();
            _instance.init();
         }
         return _instance;
      }
      
      private function init():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.addEventListener(ApplicationManager.FOCUS_CHANGE_EVENT, onApplicationFocusChange);
         am.accountManager.addEventListener(AccountManager.USER_LOGGED_IN_EVENT, onUserLogin);
         loadNodeIdsCollectionFromSharedObjects();
      }
      
      private function onApplicationFocusChange(event:Event):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(!am.currentUser.isAnonymous() && am.isApplicationFocused) {
            persistAnonymousCollectionToUserDropzone();
         }
      }
      
      private function onUserLogin(event:Event):void {
         persistAnonymousCollectionToUserDropzone();
      }
      
      public function addNode(value:BroPTNode):void {
         var nodeID:int = -1;
         if(value is BroTreeRefNode) {
            nodeID = BroTreeRefNode(value).refTree.getRootNode().persistentID;
         }else{
            nodeID = value.persistentID;
         }
         
         loadNodeIdsCollectionFromSharedObjects();
         _nodeIdsCollection.push(nodeID);
         saveNodeIdsCollectionToSharedObjects();
      }
      
      public function resetAll():void {
         _nodeIdsCollection = new Array();
         saveNodeIdsCollectionToSharedObjects();
      }
      
      public function persistAnonymousCollectionToUserDropzone():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         loadNodeIdsCollectionFromSharedObjects();
         if(!am.currentUser.isAnonymous() && _nodeIdsCollection.length > 0) {
            var service:AmfTreeService = am.distantServices.amfTreeService;
            var user:UserData = AmfUserService.makeDataFromBUser(am.currentUser);
            service.copyPearlsInDropzone(user, _nodeIdsCollection, this);
            resetAll();
         }
      }
      
      public function onReturnValue():void {
         ApplicationManager.getInstance().persistencyQueue.processQueue();
      }
      public function onError(message:FaultEvent):void {}
      
      private function saveNodeIdsCollectionToSharedObjects():void {
         try {
            _so.data['nodeIdsCollection'] = null;
            _so.data['nodeIdsCollection'] = _nodeIdsCollection;
            _so.flush();
         } catch (e:Error) {
         }
      }   
      
      private function loadNodeIdsCollectionFromSharedObjects():void {
         try {
            _so = null;
            _nodeIdsCollection = null;
            _so = SharedObject.getLocal("PTDropZoneAnonymousStorage","/");
            _nodeIdsCollection = _so.data['nodeIdsCollection'];
         } catch (e:Error) {
         }
         if(!_nodeIdsCollection) {
            _nodeIdsCollection = new Array();
            
            saveNodeIdsCollectionToSharedObjects();
         }
      }
   }
}