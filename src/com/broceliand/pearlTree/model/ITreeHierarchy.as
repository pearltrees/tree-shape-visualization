package com.broceliand.pearlTree.model
{
   public interface ITreeHierarchy
   {
      function getTreePath(tree:BroPearlTree):Array;
      function getDescendantTree(tree:BroPearlTree):Array;
   }
}