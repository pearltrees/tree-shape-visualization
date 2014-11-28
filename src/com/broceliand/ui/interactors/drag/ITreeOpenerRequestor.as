package com.broceliand.ui.interactors.drag
{
   import com.broceliand.graphLayout.model.IPTNode;
   
   public interface ITreeOpenerRequestor
   {
      function isOpeningTreeNeeded(nodeToOpen:IPTNode):Boolean;
      function onOpeningTree(nodeToOpen:IPTNode):void;
   }
}