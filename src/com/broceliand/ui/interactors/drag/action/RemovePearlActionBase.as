package com.broceliand.ui.interactors.drag.action
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.io.object.tree.OwnerData;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   
   public class RemovePearlActionBase
   {
      protected var _cutNode:IPTNode;
      protected var _parentNode:IPTNode;
      protected var _originalIndex:int;
      protected var _originChildNodes:Array;
      protected var _pearltreeViewer:IPearlTreeViewer;      
      protected var _isValidAction:Boolean=true;

      public function RemovePearlActionBase(pearltreeViewer:IPearlTreeViewer, node:IPTNode, parentNode:IPTNode = null, originalIndex:int = -1, originChildNodes:Array = null)
      {
         if (node==null  ||  node.getBusinessNode() == null) {
            _isValidAction = false;
            return;
         } 
         var bnode:BroPTNode = node.getBusinessNode();
         
         var ownerTree:BroPearlTree = bnode.owner;
         if (bnode is BroPTRootNode && bnode.owner.refInParent) {
            ownerTree= bnode.owner.refInParent.owner;
         }
         if (ownerTree && !ownerTree.isCurrentUserAuthor()) {
            _isValidAction = false;
         } else {
            var rootNode:BroPTRootNode = node.getBusinessNode() as BroPTRootNode;
            if (rootNode) {
               if(rootNode.isAssociationHierarchyRoot()) {
                  _isValidAction = false;
               }
            }
            
         }
         if (!_isValidAction) {
            return;
         }
         
         _cutNode = node;
         if (parentNode == null) {
            parentNode = node.parent;
         }
         _parentNode = parentNode;
         if (originalIndex < 0) {
            if (_parentNode) {
               originalIndex = _parentNode.successors.lastIndexOf(_cutNode);  
            } else {
               if (node.getDock() != null) {
                  originalIndex = node.getDock().findItemIndexFromNode(node);
               } 
            }
         }
         _originalIndex = originalIndex;
         if (originChildNodes == null) {
            _originChildNodes= computeChildNodesToMove();
         } else {
            _originChildNodes = originChildNodes;
         }
         _pearltreeViewer= pearltreeViewer;
      }
      
      private function computeChildNodesToMove():Array {
         var originChildNodes:Array = new Array();
         var parentChildNode:IPTNode = _cutNode;
         var rootNode:PTRootNode = _cutNode as PTRootNode;
         if(rootNode && (rootNode as PTRootNode).isOpen()){
            var endNode:EndNode = rootNode.containedPearlTreeModel.endNode as EndNode;
            parentChildNode = endNode;
         }
         if (parentChildNode) {
            
            for(var i:int = parentChildNode.successors.length; i-->0;){
               originChildNodes.push(parentChildNode.successors[i]);
            }
         }
         return originChildNodes;
      }
      
      private function moveChildNodeeToAnotherParent(newParentNode:IPTNode, insertionIndex:int = 0):void{
         var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;
         var endNodeToReposition:EndNode = null;        
         var excludeClosingNode:Boolean = false;
         if (_cutNode is PTRootNode ){ 
            excludeClosingNode = PTRootNode(_cutNode).containedPearlTreeModel.openingState == OpeningState.CLOSING;
         }
         var firstChild:IPTNode = null;
         for each(var successor:IPTNode in _originChildNodes){
            if (excludeClosingNode && successor.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
               continue;
            }
            if (successor.parent) {
               editionController.tempUnlinkNodes(successor.parent.vnode, successor.vnode);
            } 
            if (successor is EndNode) {
               endNodeToReposition = successor as EndNode;
            } else {
               editionController.tempLinkNodes(newParentNode.vnode, successor.vnode, insertionIndex);
               editionController.confirmNodeParentLink(successor.vnode, true, insertionIndex);
            }
         }        
         if (endNodeToReposition) {
            editionController.reattachEndNode(endNodeToReposition.vnode);
         }
      }
      
      protected function unlinkRemoveNode(removedNode:IPTNode):void {
         if(removedNode.parent){
            
            var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;
            editionController.tempUnlinkNodes(removedNode.parent.vnode, removedNode.vnode);
         }
      }
      
      protected function updateGraphWhenRemovingNode(removedNode:IPTNode):void {
         if (_parentNode) {
            
            moveFirstChildrenOneUp(removedNode, _parentNode, _originalIndex);
         }
      }
      private function moveFirstChildrenOneUp(removedNode:IPTNode, newParentNode:IPTNode, insertionIndex:int):void {
         var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;
         var endNodeToReposition:EndNode = null;        
         var excludeClosingNode:Boolean = false;
         if (removedNode is PTRootNode ){ 
            excludeClosingNode = PTRootNode(removedNode).containedPearlTreeModel.openingState == OpeningState.CLOSING;
         }
         var currentParent:IPTNode = newParentNode;
         for each(var successor:IPTNode in _originChildNodes){
            if (excludeClosingNode && successor.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
               continue;
            }
            if (successor.parent) {
               editionController.tempUnlinkNodes(successor.parent.vnode, successor.vnode);
            } 
            if (successor is EndNode) {
               endNodeToReposition = successor as EndNode;
            } else {
               editionController.tempLinkNodes(newParentNode.vnode, successor.vnode, insertionIndex);
               editionController.confirmNodeParentLink(successor.vnode, true, insertionIndex);
               if (!currentParent == newParentNode) {
                  currentParent = successor;
                  insertionIndex = 0;
               }
               
            }
         }        
         if (endNodeToReposition) {
            editionController.reattachEndNode(endNodeToReposition.vnode);
         }
      }
      
   }
}