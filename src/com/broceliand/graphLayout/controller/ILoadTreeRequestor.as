package com.broceliand.graphLayout.controller
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   public interface ILoadTreeRequestor
   {
      function onNodeTreeLoaded(tree:BroPearlTree, loadedNode:IPTNode):void;
      function onErrorLoadingTree(nodeError:IPTNode, error:Object):void;
   }
}