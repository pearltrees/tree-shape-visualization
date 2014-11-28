package com.broceliand.pearlTree.model.event
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.events.Event;
   
   public class ChangeTreeEvent extends Event
   {
      public static const CHANGE_TREE_EVENT:String ="model.changeTreeEvent";
      private var _node:BroPTNode;
      private var _originTree:BroPearlTree;
      private var _destinationTree:BroPearlTree;
      public function ChangeTreeEvent(node:BroPTNode, originTree:BroPearlTree, destinationTree:BroPearlTree)
      {
         super(CHANGE_TREE_EVENT);
         _node = node;
         _originTree = originTree;
         _destinationTree = destinationTree;
      }
      
      public function get destinationTree():BroPearlTree
      {
         return _destinationTree;
      }
      
      public function get originTree():BroPearlTree
      {
         return _originTree;
      }
      
      public function get node():BroPTNode
      {
         return _node;
      }
      
   }
}