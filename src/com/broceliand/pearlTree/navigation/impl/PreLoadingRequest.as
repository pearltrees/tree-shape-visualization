package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.IPearlTreeLoaderCallback;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   
   public class PreLoadingRequest implements IPearlTreeLoaderCallback {
      
      private var _treeId:Number;
      private var _assoId:Number;
      
      public function PreLoadingRequest(treeId:Number, assoId:Number) {
         _treeId = treeId;
         _assoId = assoId;
      }
      
      public function load():void{
         ApplicationManager.getInstance().pearlTreeLoader.loadTree(_assoId, _treeId, this, false);
      }
      
      public function onTreeLoaded(tree:BroPearlTree):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.visualModel.navigationModel.goTo(_assoId, am.currentUser.persistentId, _treeId, _treeId, tree.getLastCreatedPearlPageId(), -1, -1, 0, false, NavigationEvent.ADD_ON_NAVIGATION_TYPE);
      }
      
      public function onErrorLoadingTree(error:Object):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.visualModel.navigationModel.goTo(_assoId, am.currentUser.persistentId, _treeId, _treeId, _treeId, -1, -1, 0, false, NavigationEvent.ADD_ON_NAVIGATION_TYPE);
      }
   }
}