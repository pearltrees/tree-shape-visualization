package com.broceliand.ui.controller
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.User;

   public interface IPearlTreeLoaderInteractor
   {
      function loadPearlTreesWorld():void;
      function loadPearltreesWorldAroundTree(nodeToGoTo:BroDistantTreeRefNode):void;
   }
}