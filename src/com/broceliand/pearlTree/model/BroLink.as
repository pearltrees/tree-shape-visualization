package com.broceliand.pearlTree.model{
   import com.broceliand.util.Assert;

   public class BroLink{
      private var _fromPTNode:BroPTNode;
      private var _toPTNode:BroPTNode;
      
      public function BroLink(fromP:BroPTNode, toP:BroPTNode) {
         Assert.assert(fromP!=null, "invalid from link");
         Assert.assert(toP!=null, "invalid to  link");
         Assert.assert(fromP!=toP, "invalid to  link");
         _fromPTNode=fromP;
         _toPTNode = toP;
      }
      public function get fromPTNode():BroPTNode
      {
         return _fromPTNode;
      }
      public function get toPTNode():BroPTNode
      {
         return _toPTNode;
      }
      internal function replaceNode(oldNode:BroPTNode, newNode:BroPTNode):Boolean{
         Assert.assert(oldNode.persistentID== newNode.persistentID, "Node should be the same");
         if (_fromPTNode == oldNode) {
            _fromPTNode = newNode;
            return true;
         } else if (_toPTNode == oldNode) {
            _toPTNode = newNode;
            return true; 
         }
         return false;
         
      }
   }
}