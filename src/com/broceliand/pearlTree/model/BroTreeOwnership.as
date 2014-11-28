package com.broceliand.pearlTree.model
{
   import com.broceliand.util.logging.Log;
   
   internal class BroTreeOwnership
   {
      
      private var _tree:BroPearlTree;
      private var _association:BroAssociation;
      
      public function BroTreeOwnership(tree:BroPearlTree, association:BroAssociation) {
         _tree = tree;
         _association = association;         
      }
      public function set association (value:BroAssociation):void
      {
         if (_association && _association != value) {
            Log.getLogger("com.broceliand.util.logging.Log.BroTreeOwnership").info("Change tree tree {0} ({1} ({2})) from asso {3} to asso {4}", tree.traceId(), tree.title, tree.id, _association.associationId,value.associationId);
            _association = value;
         }
         _association = value;
      }
      public function get tree ():BroPearlTree
      {
         return _tree;
      }
      public function get association ():BroAssociation
      {
         return _association;
      }
      
   }
}