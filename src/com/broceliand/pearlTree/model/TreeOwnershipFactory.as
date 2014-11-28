package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.Assert;
   
   import flash.utils.Dictionary;
   
   public class TreeOwnershipFactory
   {
      private static var _singleton:TreeOwnershipFactory = new TreeOwnershipFactory(); 
      private var _treekey2owner:Dictionary;
      
      public function TreeOwnershipFactory()
      {
         _treekey2owner = new Dictionary();
      }
      public static function getInstance():TreeOwnershipFactory{
         return _singleton;
      }
      public function setTreeOwnership(tree:BroPearlTree, association:BroAssociation):BroTreeOwnership {
         var key:String = BroPearlTree.getTreeKey(tree.dbId, tree.id);
         var owner:BroTreeOwnership = _treekey2owner[key];
         if (!owner) {
            owner = new BroTreeOwnership(tree, association);
            _treekey2owner[key]= owner; 
         } else {
            owner.association = association;
         }
         return owner;  

      }
   }
}