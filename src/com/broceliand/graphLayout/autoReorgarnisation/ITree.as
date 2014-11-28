package com.broceliand.graphLayout.autoReorgarnisation
{
   public interface ITree
   {
      function get rootNode():Object;
      function getChildNodeCount(node:Object):int;
      function getChildAt(parentNode:Object, index:int):Object;
      function isDropZone():Boolean;
      function moveNode(nodeToMove:Object, newParent:Object):void;
   }
}