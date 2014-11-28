package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.IPearlLoader;
   import com.broceliand.pearlTree.io.loader.IPearlTreeHierarchyLoaderCallback;
   import com.broceliand.pearlTree.io.loader.PearlLocationLoaderEvent;
   import com.broceliand.pearlTree.io.loader.PearlTreeAmfLoader;
   import com.broceliand.pearlTree.model.BroComment;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.TreeHierarchy;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.INoteToPearlNavigator;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   
   import flash.utils.Dictionary;

   public class NoteToPearlNavigator implements INoteToPearlNavigator {
      
      private var _pearlLoader:IPearlLoader;
      
      private var _isNavigationLoading:Boolean;

      private var _nodeToUser:Dictionary;
      private var _nodeToTree:Dictionary;
      
      public function NoteToPearlNavigator() {
         _isNavigationLoading = false;
         
         _nodeToUser = new Dictionary();
         _nodeToTree = new Dictionary();
         
         _pearlLoader = new PearlTreeAmfLoader(null); 
         _pearlLoader.addEventListener(PearlLocationLoaderEvent.PEARL_LOCATION_LOADED, onPearlLocationLoaded);
         _pearlLoader.addEventListener(PearlLocationLoaderEvent.PEARL_LOCATION_NOT_LOADED, onPearlLocationNotLoaded);
      }
      
      public function goToPearl(note:BroComment):void {
         if(_isNavigationLoading) {
            trace("NoteToPearlNavigator ignored a request. Navigation is already loading.");
            return;
         }

         var noteNode:BroPTNode = new BroPTNode();
         noteNode.setPersistentId(note.pearlDb, note.pearlId, false);
         var noteNodeKey:String = noteNode.getKey();
         
         if(_nodeToUser[noteNodeKey] && _nodeToTree[noteNodeKey]) {
            goTo(_nodeToUser[noteNodeKey], _nodeToTree[noteNodeKey], noteNode);
         }
         else {
            _pearlLoader.getTreeAndAssoFromPearl(noteNode);
            _isNavigationLoading = true;
         }
      }
      
      private function onPearlLocationLoaded(event:PearlLocationLoaderEvent):void{
         _isNavigationLoading = false;
         
         var nodeKey:String = event.node.getKey();
         _nodeToUser[nodeKey] = event.user;
         _nodeToTree[nodeKey] = event.tree;
         
         goTo(event.user, event.tree, event.node);
      }
      
      private function onPearlLocationNotLoaded(_navigationModel:PearlLocationLoaderEvent):void{
         _isNavigationLoading = false;
      }
      
      private function goTo(user:User, tree:BroPearlTree, node:BroPTNode):void{
         var navigationModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;

         navigationModel.goTo(tree.getMyAssociation().associationId, 
            user.persistentId,  
            tree.id, 
            tree.id, 
            node.persistentID, 
            -1, -1, -1);         
      }
      public function goToUser(userkey:String):void {
         var uk:Array = User.parseUserKey(userkey);
         if (uk) {
            var user:User = ApplicationManager.getInstance().userFactory.getOrMakeUser(uk[0], uk[1]);
            ApplicationManager.getInstance().visualModel.navigationModel.goTo(-1, user.persistentId, -1, -1, -1, -1, -1, 0, false, NavigationEvent.ADD_ON_RESET_GRAPH);
         }
      }   
   }
}