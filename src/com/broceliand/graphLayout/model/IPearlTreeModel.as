package com.broceliand.graphLayout.model
{
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   public interface IPearlTreeModel
   {
      function get businessTree():BroPearlTree;
      function get rootNode():PTRootNode;
      function get endNode():IPTNode; 
      function set endNode(value:IPTNode):void;
      
      function get openingState():String;
      function set openingState(o:String):void;
      function get openingTargetState():String;
      function set openingTargetState(o:String):void;
   }
}