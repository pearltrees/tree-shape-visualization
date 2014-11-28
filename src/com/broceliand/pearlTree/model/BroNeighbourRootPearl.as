package com.broceliand.pearlTree.model
{
   import com.broceliand.ui.model.NoteModel;
   
   public class BroNeighbourRootPearl extends BroPTRootNode
   {
      
      private var _delegateNode:BroPTNode;

      public function BroNeighbourRootPearl(node:BroPTNode)
      {
         _delegateNode = node;
         
      }
      override public function get title ():String {
         return _delegateNode.title;
      }
      public function get delegateNode ():BroPTNode
      {
         return _delegateNode;
      }
      
      override public function get neighbourCount():Number {
         if (delegateNode is BroDistantTreeRefNode) {
            return BroDistantTreeRefNode(delegateNode).refTree.rootPearlNeighbourCount;
         }
         return _delegateNode.neighbourCount;
      }
      
      override public function get noteCount():int {
         if (delegateNode is BroDistantTreeRefNode) {
            return BroDistantTreeRefNode(delegateNode).refTree.rootPearlNoteCount;
         }else{
            return _delegateNode.noteCount;   
         }
      }  
      override public function isAssociationHierarchyRoot():Boolean {
         return false;
      }
      
   }
}