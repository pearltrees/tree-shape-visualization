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
   
   import flash.net.getClassByAlias;
   
   public class RemoveBNodeActionBase
   {
      protected var _cutNode:IPTNode;
      protected var _cutBNode:BroPTNode;
      protected var _parentBNode:BroPTNode;
      protected var _originalIndex:int;
      private   var _originChildNodes:Array;
      protected var _pearltreeViewer:IPearlTreeViewer;      
      protected var _isValidAction:Boolean=true;

      public function RemoveBNodeActionBase(pearltreeViewer:IPearlTreeViewer, ptNode:IPTNode, parentNode:BroPTNode= null, originalIndex:int = -1, originChildNodes:Array = null)
      {
         if (ptNode==null || !ptNode.getBusinessNode()) {
            _isValidAction = false;
            return;
         } 
         var bnode:BroPTNode = ptNode.getBusinessNode();
         var ownerTree:BroPearlTree = bnode.owner;
         if (bnode is BroPTRootNode && bnode.owner.refInParent) {
            ownerTree= bnode.owner.refInParent.owner;
         }
         if (ownerTree && !ownerTree.isCurrentUserAuthor()) {
            _isValidAction = false;
         } else {
            var rootNode:BroPTRootNode = bnode as BroPTRootNode;
            if (rootNode) {
               if(rootNode.isAssociationHierarchyRoot() && rootNode.owner.getMyAssociation().isUserRootAssociation()) {
                  _isValidAction = false;
               }
            }
            
         }
         if (!_isValidAction) {
            return;
         }
         
         _cutNode = ptNode;
         if (bnode is BroPTRootNode) {
            bnode = bnode.owner.refInParent;
         }
         _cutBNode = bnode;
         if (parentNode == null) {
            if (bnode is BroPTRootNode) {
               bnode = bnode.owner.refInParent;
            }
            parentNode = bnode.parent;
         }
         _parentBNode = parentNode;
         if (originalIndex < 0) {
            if (ptNode.getDock() != null) {
               originalIndex = ptNode.getDock().findItemIndexFromNode(ptNode);
            }  else if (_parentBNode) {
               originalIndex = _parentBNode.getChildIndex(_cutBNode);
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
         var parentChildNode:BroPTNode= _cutBNode;
         var rootNode:BroPTRootNode= _cutBNode as BroPTRootNode;
         if(rootNode && (rootNode.owner.refInParent)){
            parentChildNode = rootNode.owner.refInParent; 
         }
         if (parentChildNode) {
            
            for(var i:int = parentChildNode.getChildCount(); i-->0;){
               originChildNodes.push(parentChildNode.getChildAt(i));
            }
         }
         return originChildNodes;
      }

      protected function unlinkRemoveNode(removedNode:IPTNode):void {
         if(removedNode.parent && removedNode.parent.vnode){
            
            var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;
            editionController.tempUnlinkNodes(removedNode.parent.vnode, removedNode.vnode);
         }
      }
      
      protected function updateGraphWhenRemovingNode(removedNode:IPTNode):void {
         if (_parentBNode) {
            
            moveFirstChildrenOneUp(removedNode, _parentBNode, _originalIndex);
         }
         
      }

      private function moveFirstChildrenOneUp(removedNode:IPTNode, newParentBNode:BroPTNode, insertionIndex:int):void {
         var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;
         var endNodeToReposition:EndNode = null;        
         var excludeClosingNode:Boolean = false;
         var cutNode:IPTNode = _cutBNode.graphNode;
         if (cutNode is PTRootNode ){ 
            excludeClosingNode = PTRootNode(cutNode).containedPearlTreeModel.openingState == OpeningState.CLOSING;
         }
         var currentParentBNode:BroPTNode= newParentBNode;
         var newParentNode:IPTNode = currentParentBNode.graphNode;
         for (var i:int = _originChildNodes.length; i --> 0 ; ){
            var bsuccessor:BroPTNode = _originChildNodes[i];
            var successor:IPTNode = bsuccessor.graphNode;
            if (successor) {
               if (excludeClosingNode && successor.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
                  continue;
               }
               if (successor.parent) {
                  editionController.tempUnlinkNodes(successor.parent.vnode, successor.vnode);
               } 
               if (successor is EndNode) {
                  endNodeToReposition = successor as EndNode;
               }
               else {
                  editionController.tempLinkNodes(newParentNode.vnode, successor.vnode,  insertionIndex);
                  editionController.confirmNodeParentLink(successor.vnode, true, insertionIndex);
               }
            } 
            else {
               editionController.linkBusinessNode(currentParentBNode, bsuccessor,  insertionIndex);
            }
            if (currentParentBNode == newParentBNode) {
               currentParentBNode = bsuccessor;
               newParentNode = currentParentBNode.graphNode;
               if (newParentNode is PTRootNode && PTRootNode(newParentNode).isOpen()) {
                  newParentNode = PTRootNode(newParentNode).containedPearlTreeModel.endNode;
               }
               insertionIndex = 1;
               if (currentParentBNode.getChildCount() > 1) {
                  moveChildrenDown(currentParentBNode);               
               }
               else if (currentParentBNode.getChildCount() == 0) {
                  insertionIndex = 0;
               }            
            } else {
               insertionIndex ++;
            }
            
         }        
         if (endNodeToReposition) {
            editionController.reattachEndNode(endNodeToReposition.vnode);
         } 
      }
      
      private function moveChildrenDown(parentNode:BroPTNode):void {
         var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;
         if (parentNode.getChildCount() > 0) {
            var firstChild:BroPTNode = parentNode.getChildAt(0);
            moveChildrenDown(firstChild);
            var newParentNode:IPTNode = firstChild.graphNode;
            if ((newParentNode is PTRootNode) && PTRootNode(newParentNode).isOpen()) {
               newParentNode = PTRootNode(newParentNode).containedPearlTreeModel.endNode;
            }
            var insertionIndex:int =0;
            var childCount:int = parentNode.getChildCount();
            for (var i:int = 1; i < childCount; ++i) {

               var childToMove:BroPTNode = parentNode.getChildAt(1);
               var successor:IPTNode = childToMove.graphNode;
               if (successor) {
                  if (successor.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
                     continue;
                  }
                  if (successor.parent) {
                     editionController.tempUnlinkNodes(successor.parent.vnode, successor.vnode);
                  } 
                  
                  editionController.tempLinkNodes(newParentNode.vnode, successor.vnode, ++ insertionIndex);
                  editionController.confirmNodeParentLink(successor.vnode, true, insertionIndex);
                  
               } 
               else {
                  editionController.linkBusinessNode(firstChild, childToMove, ++ insertionIndex);
               }
               
            }
            
         }

      }
      public function getOriginChildNodes():Array {
         return _originChildNodes;
      }
      protected function getParentNode():IPTNode {
         if (_parentBNode) {
            return _parentBNode.graphNode;
         } else {
            return null;
         }
      }
   }
}