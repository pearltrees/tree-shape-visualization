package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class OpenTreesStateModel extends EventDispatcher
   {
      static public var OPEN_TREE_STATE_CHANGED_EVENT:String="openTreeStateChange";
      private var _openedTrees:Dictionary = new Dictionary();
      public function OpenTreesStateModel()
      {
      }
      public function openTree(treeDB:int, treeID:int):void{
         var key:String = BroPearlTree.getTreeKey(treeDB, treeID);
         if (_openedTrees[key] != true) {
            _openedTrees[key] = true;
            dispatchEvent(new Event(OPEN_TREE_STATE_CHANGED_EVENT));
         }
      }
      public function closeTree(treeDB:int, treeID:int):void{
         var key:String = BroPearlTree.getTreeKey(treeDB, treeID);
         if (_openedTrees[key] != null) {
            delete _openedTrees[key];
            dispatchEvent(new Event(OPEN_TREE_STATE_CHANGED_EVENT));
         }
      }
      public function closeAllTees():void {
         for (var key:String in _openedTrees) {
            delete _openedTrees[key];
         }
      }
      public function isTreeOpened(treeDB:int, treeId:int):Boolean {
         var key:String = BroPearlTree.getTreeKey(treeDB, treeId);
         return _openedTrees[key];
      }
      
   }
}