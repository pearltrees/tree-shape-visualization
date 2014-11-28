package com.broceliand.ui.controller
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   public interface IEditionController
   {
      function deleteSelection(cutNode:IPTNode=null, skipConfirmation:Boolean = false):void;
      function moveSelection(cutNode:IPTNode, destination:BroPearlTree, stayInScreenWindow:Boolean = false):IPTNode; 
      function pasteFromClipboard():void;
      function playSelection(onScreenLine:Boolean, skipRootNode:Boolean = false):void;
      function copySelectionTo(selectedNode:IPTNode, destination:BroPearlTree):BroPTNode; 
      function copyBusinessNodeTo(selectedBNode:BroPTNode, destination:BroPearlTree):BroPTNode 
   }
}