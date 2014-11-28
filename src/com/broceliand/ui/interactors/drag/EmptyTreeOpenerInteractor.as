package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.interactors.InteractorManager;

   public class EmptyTreeOpenerInteractor implements ITreeOpenerRequestor 
   {
      private var _treeOpener:InteractiveTreeOpener;
      private var _draggedPearl:IPTNode;
      private var _interactorManager:InteractorManager;
      public function EmptyTreeOpenerInteractor(draggedPearl:IPTNode, interactorManager:InteractorManager, treeOpener:InteractiveTreeOpener)
      {
         _treeOpener = treeOpener;
         _draggedPearl= draggedPearl;
         _interactorManager = interactorManager;
      }
      public function openTree(node:IPTNode):void {
         _treeOpener.openTreeWithDelay(node, this, 500);
      }
      public function isOpeningTreeNeeded(nodeToOpen:IPTNode):Boolean {
         if (_draggedPearl.parent == nodeToOpen) {
            return true;
         }
         return false;
      }
      public  function onOpeningTree(nodeToOpen:IPTNode):void {
         var bnode:BroPTNode = nodeToOpen.getBusinessNode();
         var treeToOpen:BroPearlTree = bnode.owner;
         if (bnode is BroLocalTreeRefNode) {
            treeToOpen = BroLocalTreeRefNode(bnode).refTree;
         }
         var highlightChanged:Boolean = ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(treeToOpen);
         if (highlightChanged) {
            _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
            IPTVisualGraph(nodeToOpen.vnode.vgraph).refreshNodes();
         }
      }
      
   }
}