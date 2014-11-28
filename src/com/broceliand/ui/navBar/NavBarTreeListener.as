package com.broceliand.ui.navBar {
   import com.broceliand.pearlTree.model.BroPTDataEvent;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class NavBarTreeListener extends EventDispatcher {
      
      public static const TREE_MODEL_CHANGED:String = "treeModelChanged";
      
      private var _treeFollowed:Dictionary = new Dictionary();
      
      public function NavBarTreeListener() {
         
      }  
      
      public function updateFollowedTrees(treeArray:Array):void {
         var tree:Object;
         for(tree in _treeFollowed) {
            if (treeArray.lastIndexOf(tree) == -1) {
               stopFollowingTree(tree as BroPearlTree);
            }
         } 
         for each(tree in treeArray) {
            if(_treeFollowed[tree] == null) {
               followTree(tree as BroPearlTree);
            }
         }
      }
      
      private function followTree(tree:BroPearlTree):void {
         if (_treeFollowed[tree] == null) {
            _treeFollowed[tree] = this;
            tree.addEventListener(BroPearlTree.TITLE_CHANGED, requestUpdate);
            tree.addEventListener(BroPearlTree.HIERARCHY_CHANGED, requestUpdate);
         }
      }
      
      public function stopFollowingTree(tree:BroPearlTree):void {
         tree.removeEventListener(BroPearlTree.TITLE_CHANGED, requestUpdate);
         tree.removeEventListener(BroPearlTree.HIERARCHY_CHANGED, requestUpdate);
         delete _treeFollowed[tree];
      }
      
      public function requestUpdate(event:BroPTDataEvent):void{
         if (event.type == BroPearlTree.TITLE_CHANGED) {
            
            dispatchEvent(new Event(TREE_MODEL_CHANGED));
         } else {
            dispatchEvent(new Event(TREE_MODEL_CHANGED));
         }
      }
   }
}