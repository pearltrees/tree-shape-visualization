package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetIntegerCallback;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.CurrentUser;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   
   import flash.utils.Dictionary;
   
   import mx.rpc.events.FaultEvent;
   
   public class FacebookNavigationMonitor implements IAmfRetIntegerCallback
   {
      private static const DISCOVER_INTERVAL:uint = 2000; 
      
      private var _sentTreesId:Dictionary;
      private var _treeCurrentlyDiscovered:BroPearlTree;
      private var _treeCurrentlyDiscoveredSince:Date;
      private var _isFirst:Boolean;
      private var _numberOfPearlsDiscoveredInTree:Number;
      
      public function FacebookNavigationMonitor() {
         _sentTreesId = new Dictionary();
         _treeCurrentlyDiscoveredSince = null;
         _treeCurrentlyDiscovered = null;
         _isFirst = true;
         _numberOfPearlsDiscoveredInTree = 0;
      }
      
      public function start():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (am.currentUser.shareDiscoveries()) {
            am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         }
      }
      
      public function stop():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (!am.currentUser.shareDiscoveries()) {
            am.visualModel.navigationModel.removeEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         }
      }
      
      private function onNavigationChange(event:NavigationEvent):void {
         if(event.newFocusTree != event.oldFocusTree) {
            var tree:BroPearlTree = event.newFocusTree;
            if(!tree) return;
            treeCurrentlyRead = tree;
            _numberOfPearlsDiscoveredInTree = 0;
         } else {
            _numberOfPearlsDiscoveredInTree++;
         } 
      }
      
      private function set treeCurrentlyRead(value:BroPearlTree):void {
         if (_treeCurrentlyDiscovered != value) {
            sendCurrentTreeIfPossible();
            _treeCurrentlyDiscovered = value;
            _treeCurrentlyDiscoveredSince = new Date();
         }
      }
      
      private function sendCurrentTreeIfPossible():void {
         if (_treeCurrentlyDiscovered != null) {
            if (hasBeenRead()) {
               if (!hasAlreadyBeenSent()) {
                  sendCurrentTree();                
               }
            }
         }
      }
      
      public function sendCurrentTree():void {
         _sentTreesId[_treeCurrentlyDiscovered.id] = true;
         var treeIdToSend:String = _treeCurrentlyDiscovered.id.toString();
         var user:CurrentUser = ApplicationManager.getInstance().currentUser;
         var service:AmfUserService = ApplicationManager.getInstance().distantServices.amfUserService;
         if (_isFirst) {
            _isFirst = false;
         }
         if (user.shareDiscoveries()) {
            service.sendOGActionDiscover(user.facebookAccount.facebookId, null, treeIdToSend, this);
         }
      }
      
      public function hasBeenRead():Boolean {
         var now:Date = new Date();
         
         return (_isFirst || (now.time - _treeCurrentlyDiscoveredSince.time) > DISCOVER_INTERVAL) && _numberOfPearlsDiscoveredInTree >= 3;
      }
      
      public function hasAlreadyBeenSent():Boolean {
         var alreadySent: Boolean = _sentTreesId[_treeCurrentlyDiscovered.id] as Boolean;
         if (!alreadySent) {
            return false;
         }
         return true;
      }
      
      public function onReturnValue(value:int):void {
         
      }
      
      public function onError(message:FaultEvent):void {
         
      }
      
   }
}