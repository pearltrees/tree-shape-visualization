package com.broceliand.pearlTree.model{
   import flash.events.Event;
   
   public class BroPTDataEvent extends Event{
      
      public static const PT_DATA_LOADED:String = "PtDataLoaded";    
      public static const PT_DATA_NOT_LOADED:String = "PtDataNotLoaded";
      public static const PT_DATA_UPDATED:String = "PtDataUpdated"; 
      public static const PT_DATA_NOT_UPDATED:String = "PtDataNotUpdated";
      public static const PT_AUTHORS_UPDATED:String = "PtAuthorsUpdated"; 
      public static const PT_AUTHORS_NOT_UPDATED:String = "PtAuthorsNotUpdated";        
      public static const PT_CURRENT_TREE_LOADED:String = "currentTreeAvailable";
      public static const DROP_ZONE_TREE_LOADED:String ="dropZoneAvailable"; 
      public static const PT_NO_CURRENT_TREE:String = "currentTreeNotAvailable";
      /*declare our additional instance field
      that this event can track */

      private var _tree:BroPearlTree;
      
      private var _node:BroPTNode;

      private var _treeID:int;
      private var _treeDB:int;
      private var _isErrorReported:Boolean; 
      
      public function get isErrorAlreadyReported():Boolean
      {
         return _isErrorReported;
      }
      
      public function set isErrorAlreadyReported(value:Boolean):void
      {
         _isErrorReported = value;
      }
      
      public function get treeID ():int
      {
         return _treeID;
      }

      public function get treeDB ():int
      {
         return _treeDB;
      }

      public function set tree (value:BroPearlTree):void
      {
         _tree = value;
         
      }
      
      public function get tree ():BroPearlTree
      {
         return _tree;
      }

      public function BroPTDataEvent(broceliandData:BroPearlTree, type:String, treeDb:int=-1, treeId:int=-1, node:BroPTNode=null) {
         super(type);
         this._tree= broceliandData;
         if (treeDb>=0) {
            _treeID = treeId;
            _treeDB = treeDb;
         }
         _isErrorReported = false;
         _node = node;
         
      }
      public function set node (value:BroPTNode):void
      {
         _node = value;
      }
      
      public function get node ():BroPTNode
      {
         return _node;
      }

      override public function clone():Event {
         return new BroPTDataEvent(_tree, type, _treeDB, _treeID, _node);
      }
      
   }
}