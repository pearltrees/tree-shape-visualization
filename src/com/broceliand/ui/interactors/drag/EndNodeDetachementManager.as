package com.broceliand.ui.interactors.drag
{
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.EditedGraphVisualModification;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.PearlTreeModel;
   import com.broceliand.graphLayout.model.SavedPearlReference;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.interactors.InteractorUtils;
   
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class EndNodeDetachementManager
   {
      private  const DEBUG:Boolean = true;
      private var _treeToCheckEndNodes:Dictionary;

      private var _isDraggingLastBranchOnArc:Boolean= false;
      private var _lastPearlLink:IVisualNode = null;
      private var _detachedEndVNodeForDraggedPearl:IVisualNode = null;
      private var _detachedEndVNodeForDraggingOnArc:IVisualNode = null;
      private var _detachedEndVNodeForLinkCandidate:IVisualNode = null;
      private var _isCurrentParentOnLastBranch:Boolean =false;
      private var _editionController:IPearlTreeEditionController;
      private var _hasStartedDragged:Boolean=false;
      private var _hasStartedDraggedOnArc:Boolean = false;
      private var _vgraphModification :EditedGraphVisualModification;
      private var _tmpNewLastPearl:SavedPearlReference;
      
      public function EndNodeDetachementManager(editionController:IPearlTreeEditionController, vgraphModification:EditedGraphVisualModification)
      { 
         _editionController = editionController;
         _vgraphModification = vgraphModification;
         _treeToCheckEndNodes = new Dictionary();
      }
      private function detachEndNode(tree:IPearlTreeModel):IVisualNode {
         if (tree == null) return null; 
         var endNode:IPTNode = tree.endNode;
         if(endNode is EndNode && endNode.parent){
            _vgraphModification.onEndNodeDetach(endNode.vnode,endNode.parent.vnode);
         }
         return _editionController.detachEndNode(tree);
      }
      private function reattachEndNode(endVNode:IVisualNode):void {
         if (endVNode && endVNode.node) {
            _editionController.reattachEndNode(endVNode);
         }
         
      }
      
      public function startDraggingPearl(vnode:IVisualNode):void {
         
         if (_hasStartedDragged) {
            return ;
         }
         _hasStartedDragged = true;
         var draggedNode:IPTNode = IPTNode(vnode.node);

         resetDraggedNode();
         if (draggedNode.isOnLastBranch()) {
            var isLastItem:Boolean= draggedNode.successors[0] is EndNode;
            if (!isLastItem) {
               if (draggedNode is PTRootNode && PTRootNode(draggedNode).isOpen()) {
                  isLastItem = PTRootNode(draggedNode).containedPearlTreeModel.endNode.successors[0] is EndNode;
               }
            }
            var startingTree:IPearlTreeModel = draggedNode.containingPearlTreeModel;
            
            if (isLastItem) {
               _tmpNewLastPearl = new SavedPearlReference(draggedNode.parent, true);
            } else {
               
               if (startingTree && startingTree.endNode is EndNode && startingTree.endNode.parent) {
                  _tmpNewLastPearl = new SavedPearlReference(startingTree.endNode.parent, false);
               }
            }
            _detachedEndVNodeForDraggedPearl = detachEndNode(startingTree);
            addTreeToCheck(startingTree);
            
         } 
      }
      private function startDraggingOnArcPearl(vnode:IVisualNode):void {
         if (!_hasStartedDraggedOnArc) {
            _hasStartedDraggedOnArc = true;
            var draggedNode:IPTNode = IPTNode(vnode.node);
            _isDraggingLastBranchOnArc = draggedNode.isOnLastBranch();
            if (_isDraggingLastBranchOnArc) {
               var startingTree:IPearlTreeModel = draggedNode.containingPearlTreeModel;
               addTreeToCheck(startingTree);
            }
         }
      }
      
      public function onChangeNodePositionByDraggingOnArc(vnode:IVisualNode, isLast:Boolean):void {
         startDraggingOnArcPearl(vnode);
         
         if (_detachedEndVNodeForDraggedPearl ==null) {
            
            if (isLast != _isDraggingLastBranchOnArc) {
               var ptNode:IPTNode = vnode.node as IPTNode;
               if ((ptNode.parent is PTRootNode || ptNode.parent.isOnLastBranch()) && _detachedEndVNodeForDraggingOnArc == null) {
                  addTreeToCheck(ptNode.containingPearlTreeModel);
                  if (_isDraggingLastBranchOnArc) {
                     _detachedEndVNodeForDraggingOnArc = detachEndNode(ptNode.containingPearlTreeModel);
                  }
               }
            }

         }
      }
      
      public function onChangingTarget(linkCandidateVNode:IVisualNode, draggedNode:IVisualNode):void {
         resetLinkCandidate();
         if(linkCandidateVNode){
            var candidateNode:IPTNode = linkCandidateVNode.node as IPTNode;
            if (candidateNode  is PTRootNode && (candidateNode as PTRootNode).isOpen()) {
               _isCurrentParentOnLastBranch = true;
               
            } else {
               _isCurrentParentOnLastBranch = candidateNode.isOnLastBranch();
            }
         } else {
            _isCurrentParentOnLastBranch = false;
         }
         updateLinkToLastPearl(linkCandidateVNode, draggedNode);
      } 

      private function updateLinkToLastPearl(linkCandidateVNode:IVisualNode, draggedNode:IVisualNode):void {
         var endNode:EndNode = null;
         if (linkCandidateVNode&& linkCandidateVNode.node) {
            var parentNode:IPTNode = linkCandidateVNode.node as IPTNode;
            for each (var child:IPTNode in parentNode.successors) {
               endNode = child as EndNode;
               if (endNode) {
                  break;
               }
            }
         }
         if (_lastPearlLink != linkCandidateVNode) {
            restoreEndPearlLink(draggedNode);
         } 
         if (endNode) {
            _vgraphModification.onLinkToLastNode(linkCandidateVNode.node as IPTNode);
            _lastPearlLink =  linkCandidateVNode;
            _editionController.tempUnlinkNodes(linkCandidateVNode, endNode.vnode);
            _editionController.tempLinkNodes(draggedNode, endNode.vnode);
         } 
      }
      private function restoreEndPearlLink(draggedNode:IVisualNode):void {
         if (_lastPearlLink) {
            var parentNode:IPTNode = draggedNode.node as IPTNode;
            var endNode:EndNode = null;
            for each (var child:IPTNode in parentNode.successors) {
               endNode = child as EndNode;
               if (endNode) {
                  break;
                  
               }
            }
            if (endNode) {
               _editionController.tempUnlinkNodes(draggedNode, endNode.vnode);
               _editionController.tempLinkNodes(_lastPearlLink, endNode.vnode);
               if (!_tmpNewLastPearl || !_tmpNewLastPearl.isParentTemporaryLink || _lastPearlLink != _tmpNewLastPearl.getVnode(true)) {
                  _editionController.confirmNodeParentLink(endNode.vnode, false);
               }
               
            }
            _lastPearlLink = null;
            _vgraphModification.onUnlinkLastNode();
         }

      }
      
      public function onMovingOnNewParent(currentParentVNode:IVisualNode, draggedNode:IVisualNode):void {
         if (_isCurrentParentOnLastBranch) {
            if (_detachedEndVNodeForLinkCandidate) {
               if (!isDraggedNodeLowestNode(currentParentVNode, draggedNode)) {
                  resetLinkCandidate();
               }
               return;
            } else if (!isDraggedNodeLowestNode(currentParentVNode, draggedNode)) {
               return;
            }
            var candidateNode:IPTNode = currentParentVNode.node as IPTNode;
            if (candidateNode  is PTRootNode ) {
               var rootNode:PTRootNode= currentParentVNode.node as PTRootNode;
               
               if (rootNode.isOpen()) {
                  addTreeToCheck(rootNode.containedPearlTreeModel);
               } else {
                  addTreeToCheck(candidateNode.containingPearlTreeModel);                    	
               }
            } else {
               addTreeToCheck(candidateNode.containingPearlTreeModel);          
            }
            if (_detachedEndVNodeForLinkCandidate == _detachedEndVNodeForDraggedPearl) {
               _detachedEndVNodeForLinkCandidate = null;
            }
         }
      }
      private function addTreeToCheck(tree:IPearlTreeModel):void {
         if (tree) {
            _treeToCheckEndNodes[tree] = tree;
         }
      }  
      public function restoreEndNodesAtEndOfEdition(draggedNode:IPTNode):void {
         resetMovingOnArc();
         if (!draggedNode) {
            return;
         }
         addTreeToCheck(draggedNode.containingPearlTreeModel);
         resetLinkCandidate();
         resetDraggedNode();
         _hasStartedDragged=false;
         recomputeEndNodePositionsForAllTrees();
         _tmpNewLastPearl  = null;

      }

      internal function detachAllEndNodesOfTemporaryTrees():void {
         recomputeEndNodePositionsForAllTrees();
      }
      private function recomputeEndNodePositionsForAllTrees():void {
         for each (var tree:PearlTreeModel in _treeToCheckEndNodes) {
            if (tree.rootNode.getBusinessNode() && tree.rootNode.isOpen()) {
               var endNode:IVisualNode = _editionController.detachEndNode(tree); 
               if (endNode){
                  reattachEndNode(endNode);
               } else {
               }
            }
         }
      }

      private function resetMovingOnArc() :void{
         if (_detachedEndVNodeForDraggingOnArc) {
            reattachEndNode(_detachedEndVNodeForDraggingOnArc);
            _detachedEndVNodeForDraggingOnArc =null;
         }
      }
      private function resetLinkCandidate() :void{
         if (_detachedEndVNodeForLinkCandidate) {
            reattachEndNode(_detachedEndVNodeForLinkCandidate);
            _detachedEndVNodeForLinkCandidate =null;
         }
      }
      private function resetDraggedNode() :void{
         if (_detachedEndVNodeForDraggedPearl && !IPTNode(_detachedEndVNodeForDraggedPearl.node).parent) {
            reattachEndNode(_detachedEndVNodeForDraggedPearl);
            _detachedEndVNodeForDraggedPearl =null;
         }
      }
      
      private function isDraggedNodeLowestNode(parentVn:IVisualNode, draggedNode:IVisualNode):Boolean {
         draggedNode.refresh();
         var lastChild:INode = parentVn.node.successors[parentVn.node.successors.length-1];
         if (lastChild == draggedNode.node || lastChild is EndNode)
            return true;
         var draggedAngle:Number = InteractorUtils.getParentAngle(draggedNode, parentVn);
         var lastChildAngle:Number =InteractorUtils.getParentAngle(lastChild.vnode);;
         return draggedAngle<lastChildAngle;
      }

      public function onDetachDraggedPearlFromTree():void {
         if (_tmpNewLastPearl && _detachedEndVNodeForDraggedPearl) {
            _editionController.tempLinkNodes(_tmpNewLastPearl.getVnode(true), _detachedEndVNodeForDraggedPearl);
            if (!_tmpNewLastPearl.isParentTemporaryLink) {
               _editionController.confirmNodeParentLink(_detachedEndVNodeForDraggedPearl, false);
            }
            _vgraphModification.onTempReattachEndNode(_tmpNewLastPearl, _detachedEndVNodeForDraggedPearl);
         }
         
      }
   }
}