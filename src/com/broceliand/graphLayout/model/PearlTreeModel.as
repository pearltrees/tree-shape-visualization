package com.broceliand.graphLayout.model
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;

   public class PearlTreeModel implements IPearlTreeModel
   {
      
      private var _rootNode:PTRootNode;
      private var _endNode:IPTNode ;
      private var _openingState:String;
      private var _openingTargetState:String;
      
      public function get rootNode():PTRootNode {
         return _rootNode;
      }
      
      /* 		public function set rootNode(o:PTRootNode):void {
      _rootNode = o;
      }
      
      */		public function PearlTreeModel(rootNode:PTRootNode)
      {
         _rootNode = rootNode;
         _openingState = OpeningState.CLOSED;
      }
      
      public function get endNode():IPTNode {
         if (_endNode) 
            return _endNode;
         return rootNode; 
      }
      
      public function set endNode(value:IPTNode):void{
         _endNode = value; 
      }
      
      public function get openingState():String {
         return _openingState;
      }
      
      public function set openingState(o:String):void {
         _openingState = o;
      }
      
      public function get openingTargetState():String {
         return _openingTargetState;
      }
      
      public function set openingTargetState(o:String):void {
         _openingTargetState = o;
      }
      public function get businessTree():BroPearlTree {
         var bNode:BroPTNode = rootNode.getBusinessNode();
         if (bNode is BroLocalTreeRefNode) { 
            return BroLocalTreeRefNode(bNode).refTree;
         }
         return bNode.owner;
      }
      internal function replaceNode(targetNode:PTRootNode):void {
         _rootNode = targetNode;
      }
   }
}