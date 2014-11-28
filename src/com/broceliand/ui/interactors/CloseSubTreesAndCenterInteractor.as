package com.broceliand.ui.interactors 
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   
   public class CloseSubTreesAndCenterInteractor
   {
      private var _interactorManager:InteractorManager;
      private var _selectionModel:SelectionModel;
      
      public function CloseSubTreesAndCenterInteractor(interactorManager:InteractorManager, selectionModel:SelectionModel)
      {
         _interactorManager = interactorManager;
         _selectionModel = selectionModel; 
         
      }

      public function closeFocusSubTrees():Boolean {
         var bnode:BroPTNode =_selectionModel.getSelectedNode().getBusinessNode();
         var  openSubTree:Boolean = hasSubTreeToClose();
         if (openSubTree) {
            _interactorManager.pearlTreeViewer.pearlTreeEditionController.closeAllSubtrees(bnode.owner,true);
         }
         return openSubTree;
         
      }
      public function hasSubTreeToClose():Boolean {
         var selectedNode:IPTNode = _selectionModel.getSelectedNode();
         if (!selectedNode)  {
            return false;
         }
         var bnode:BroPTNode =selectedNode.getBusinessNode();
         var  openSubTree:Boolean =false;
         var selectedPearl:IUIPearl = _interactorManager.selectedPearl;
         if(bnode is BroPTRootNode && selectedPearl && selectedPearl.node) {
            var  descendants:Array = selectedPearl.node.getDescendantsAndSelf();
            var focusTree:BroPearlTree = bnode.owner;
            for each (var node:IPTNode in descendants) {
               if (node is PTRootNode && PTRootNode(node).containingPearlTreeModel && PTRootNode(node).containingPearlTreeModel.openingState == OpeningState.OPEN) {
                  if (node.getBusinessNode().owner != focusTree) {
                     openSubTree = true;
                     break; 
                  } 
               }
            }  
         }
         return openSubTree;
      }
      
   }
}