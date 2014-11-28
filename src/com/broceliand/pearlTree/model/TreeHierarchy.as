package com.broceliand.pearlTree.model
{
   import com.broceliand.util.logging.Log;
   
   import flash.utils.Dictionary;

   public class TreeHierarchy
   {
      static private var UID:int = 0;
      private var _debugId:int = UID ++;
      
      private static var _isDebug:Boolean = true;      
      private var _owner:BroAssociation;
      private var _key2Trees:Dictionary = new Dictionary();
      
      public function TreeHierarchy(association:BroAssociation) 
      {
         _owner = association;
      }
      
      public function get owner():BroAssociation
      {
         return _owner;
      }
      
      public function getTree(treeId:int):BroPearlTree{
         return _key2Trees[treeId];
      }
      public function registerTree(tree:BroPearlTree):void{
         
         Log.getLogger("com.broceliand.pearlTree.model.TreeHierarchy").info("Register tree {0} ({1} ({2})) isOwner: {3} in tree hierarchhy {4} ({5})",tree.traceId(), tree.title, tree.id, tree.isOwner, this.traceId(), this.owner.associationId);
         
         if (_isDebug && tree.treeHierarchyNode.isAlias && _key2Trees[tree.id] != null) {
            if (getTree(tree.id).treeHierarchyNode.isAlias) {
               Log.getLogger("com.broceliand.pearlTree.model.TreeHierarchy").error("replacing the tree {0} ({1}) in a tree hierarchy {2} by an alias tree", tree.title, tree.id, owner?owner.info.title:"");
            }
         }
         _key2Trees[tree.id] = tree;
         
         if (_owner) {
            
            if (tree.isOwner && !_owner.isMyAssociation()) {
               tree.owner = _owner;
               tree.authorsLoaded=true;
            }
            tree.hierarchyOwner= _owner;
         }
      }
      public function removeTreeFromHierarchy(tree:BroPearlTree, targetHierarchy:TreeHierarchy =null):Boolean{
         if (targetHierarchy != this) {
            Log.getLogger("com.broceliand.pearlTree.model.TreeHierarchy").info("Remove tree {0} ({1} ({2})) isOwner: {3} in tree hierarchhy {4} ({5})",tree.traceId(), tree.title, tree.id, tree.isOwner, this._debugId, this.owner.associationId);
            delete _key2Trees[tree.id];
            return true;
         } else {
            return false;
         }
      }
      
      public function get orderedTreeHieararchy ():Boolean
      {
         return true;
      }
      
      public function addSubHierarchy(treeHierarchy:TreeHierarchy):void {
         for each (var tree:BroPearlTree in treeHierarchy._key2Trees) {
            if (getTree(tree.id) == null) {
               registerTree(tree);
            } else if (tree.isOwner) {
               registerTree(tree);
            }
         }
      }
      public function releaseAllTrees(dataRepository:BroDataRepository):void {
         Log.getLogger("com.broceliand.pearlTree.model.TreeHierarchy").info("Release ALL trees from  hierarchhy {0} ({1})",this._debugId, this.owner.associationId);
         for each (var t:BroPearlTree in _key2Trees) {
            if (t.isOwner) {
               dataRepository.releaseTree(t);  
            }
         } 
      }
      internal function moveTreeToHierarchy(tree:BroPearlTree, targetHierarchy:TreeHierarchy):void {
         if (targetHierarchy != this) {
            removeTreeFromHierarchy(tree, targetHierarchy);
            targetHierarchy.registerTree(tree);
         }
      }
      
      public function getMyWorldHierarchy():TreeHierarchy {
         if (_owner && _owner.myWorldAssociations) {
            return _owner.myWorldAssociations.treeHierarchy;
         }
         return null;
      }
      public function traceId():String {
         return "0x"+_debugId;
      }
   }
}