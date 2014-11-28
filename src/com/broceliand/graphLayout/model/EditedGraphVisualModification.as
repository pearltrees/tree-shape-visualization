package com.broceliand.graphLayout.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.events.VNodeMouseEvent;
   
   public class EditedGraphVisualModification
   {
      private static const TRACE_DEBUG:Boolean = true;
      
      private var _originalParent:SavedPearlReference;
      private var _draggedVNode:IVisualNode;
      private var _tempParent:IVisualNode;
      private var _detachedEndVnodes:Array = new Array();
      private var _detachedEndVnodesParents:Array = new Array();
      private var _vgraph:IPTVisualGraph;
      private var _lastNode:IPTNode;
      private var _tmpNewLastNode:SavedPearlReference;
      private var _tmpNewLastNodeEndNode:IVisualNode;
      private var _tmpDetachChildren:Array;
      private var _tmpDetachedChildrenParent:BroPTNode;
      
      private var _insertionIndex:int;
      private var _originalNodeIndex:int=0;
      public function EditedGraphVisualModification(vgraph:IPTVisualGraph)
      {
         _vgraph= vgraph;
      }
      public function startEditingGraph():void {
         resetModification();
      }
      public function endEditingGraph():void {
         resetModification();
      }
      private function resetModification():void {
         
         if (_detachedEndVnodes.length>0) {
            _detachedEndVnodes = new Array();
            _detachedEndVnodesParents = new Array();
         }
         _draggedVNode = null;
         _originalParent =null;
         _tempParent =null;
         _lastNode = null;
         _tmpNewLastNode = null;
         _tmpNewLastNodeEndNode = null;
         _tmpDetachedChildrenParent = null;
         _tmpDetachChildren = null;
      }
      public function draggedNodeDetached(originalParent:IVisualNode, draggedNode:IVisualNode, originalIndex:int):void {
         _tempParent = null;
         _originalParent = originalParent == null? null : new SavedPearlReference(originalParent.node as IPTNode, true);
         _draggedVNode = draggedNode;
         _originalNodeIndex=originalIndex;
      } 
      public function tempParentDraggedNodeChanged(newParent:IVisualNode):void {
         _tempParent = newParent;
      }
      public function onEndNodeDetach(endNode:IVisualNode, parentEndNode:IVisualNode):void {
         var index:int = _detachedEndVnodes.lastIndexOf(endNode);
         if (index<0) {
            if(TRACE_DEBUG) trace("Detach end node of "+IPTNode(endNode.node).name+ " from "+IPTNode(parentEndNode.node).getBusinessNode().title);
            _detachedEndVnodesParents.push(parentEndNode)
            _detachedEndVnodes.push(endNode);
         }
      }
      public function onEndNodeReattach(endNode:IVisualNode):void {
         var index:int = _detachedEndVnodes.lastIndexOf(endNode);
         if (index>=0) {
            _detachedEndVnodes.splice(index,1);
            _detachedEndVnodesParents.splice(index,1);
         }
      }
      public function onTempReattachEndNode(tmpNewPearl:SavedPearlReference, endNode:IVisualNode ):void {
         _tmpNewLastNode = tmpNewPearl;
         _tmpNewLastNodeEndNode = endNode;
      }
      private function cancelTmpLastNode():void {
         if (_tmpNewLastNode) {
            
            if (IPTNode(_tmpNewLastNodeEndNode.node).parent != _tmpNewLastNode.getNode(true)) {
               detachEndNode(_tmpNewLastNodeEndNode);
            } else {
               var vnode:IVisualNode = _tmpNewLastNode.getVnode(true);
               if (vnode) {
                  detachEndNode(_tmpNewLastNodeEndNode);
               }
            }
         }
      }
      private function restoreTmpLastNode():void {
         if (_tmpNewLastNode && _tmpNewLastNodeEndNode.view) {
            var previousLastNode:IVisualNode = _tmpNewLastNode.getVnode(true);
            
            if (previousLastNode) {
               var tempVEdge:IVisualEdge = _vgraph.linkNodes(previousLastNode,_tmpNewLastNodeEndNode);
               if (_tmpNewLastNode.isParentTemporaryLink) {
                  var tempEdgeData:EdgeData = tempVEdge.data as EdgeData;
                  tempEdgeData.temporary = true;
               }
            }
         }
      }
      public function cancelVisualGraphModificationForLayout():void {
         cancelTmpLastNode();
         
         cancelLinkToLastNode();
         
         removeTemporaryLinks();

         tempAtachEndNodes();

      }
      public function restoreVisualGraphModificationAfterLayout():void {
         restoreLinkToLastNode();
         
         restoreTemporaryLinks();
         tempDetachEndNodes();
         restoreTmpLastNode();
         restoreDetachedChildren();

      }
      private function removeTemporaryLinks():void {
         if (_tempParent != null) {
            var parent:IPTNode = IPTNode(_draggedVNode.node).parent;
            if (parent) {
               _tempParent = parent.vnode;
            }
            _vgraph.unlinkNodes(_tempParent, _draggedVNode);
         }
         if (_draggedVNode && _draggedVNode.node.predecessors.length==0 && _originalParent) {

            var orignalParentVNode:IVisualNode = _originalParent.getVnode(true); 
            if (orignalParentVNode) {
               _vgraph.linkNodesAtIndex(orignalParentVNode , _draggedVNode, _originalNodeIndex);
            }

         }
      }
      private function restoreTemporaryLinks():void {
         if (_draggedVNode && _draggedVNode.node.predecessors.length>0) {
            _vgraph.unlinkNodes(_draggedVNode.node.predecessors[0].vnode, _draggedVNode);
         }
         
         if (_tempParent && _tempParent.view) {
            var tempVEdge:IVisualEdge = _vgraph.linkNodes(_tempParent, _draggedVNode);
            var tempEdgeData:EdgeData = tempVEdge.data as EdgeData;
            tempEdgeData.temporary = true;
         }
      }
      
      private function tempAtachEndNodes():void {
         var manipulatedModel:ManipulatedNodesModel=null;
         
         for (var i:int=0; i<_detachedEndVnodes.length; i++) {
            
            if (!manipulatedModel) {
               manipulatedModel = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.manipulatedNodesModel;
            }
            
            var parentEndNode:EndNode =_detachedEndVnodesParents[i].node as EndNode;

            var parentVnode :IVisualNode = checkDisappearedLeftNode(_detachedEndVnodesParents[i]); 
            if (parentVnode && !_detachedEndVnodes[i].node.isEnded()) {
               _vgraph.linkNodes(parentVnode,_detachedEndVnodes[i]);
               if (TRACE_DEBUG) { 
                  trace("temp relink "+IPTNode(parentVnode.node).name);
               }
            } else {
               if (TRACE_DEBUG) { 
                  trace("can't relink vnode is null");
               }
            }
         }  
      }
      
      public function getDetachedEndNodeSuccessorIndex(rootNode:IVisualNode):int{
         return _detachedEndVnodesParents.lastIndexOf(rootNode);
      }
      public function changeEndNodeParentOnOpeningNode(newParentOfDeachedEndNode:IVisualNode, index:int):void {
         if (index>=0 && _detachedEndVnodesParents.length> index) {
            _detachedEndVnodesParents[index] = newParentOfDeachedEndNode;
         }
      }

      private function tempDetachEndNodes():void {
         for (var i:int=0; i<_detachedEndVnodes.length; i++) {
            detachEndNode(_detachedEndVnodes[i]);
         } 
      }
      private function detachEndNode(endVNode:IVisualNode):void{
         var endNode:IPTNode = IPTVisualNode(endVNode).ptNode;
         if (endNode && !endNode.isEnded()) {
            var parentNode:IPTNode = endNode.parent;
            if (parentNode && !parentNode.isEnded()) {
               _vgraph.unlinkNodes(parentNode.vnode, endNode.vnode);   
            }
         }
      }
      public function onLinkToLastNode(lastNode:IPTNode):void {
         _lastNode = lastNode;
      } 
      public function onUnlinkLastNode():void {
         _lastNode = null;
      }
      private function cancelLinkToLastNode():void {
         if (_lastNode) {
            var parentNode:IPTNode = _draggedVNode.node as IPTNode;
            var endNode:EndNode = null;
            for each (var child:IPTNode in parentNode.successors) {
               endNode = child as EndNode;
               if (endNode) {
                  break;
               }
            }
            if (endNode) {
               detachEndNode(endNode.vnode);
               _vgraph.linkNodes(checkOpeningNodeAttachToEndNode(_lastNode.vnode, endNode), endNode.vnode);
            }
         }
      }
      private function restoreLinkToLastNode():void {
         if (_lastNode) {
            var endNode:EndNode = null;
            for each (var child:IPTNode in _lastNode.successors) {
               endNode = child as EndNode;
               if (endNode) {
                  break;
               }
            }
            if (endNode) {
               detachEndNode(endNode.vnode);
               var tempVEdge:IVisualEdge = _vgraph.linkNodes(_draggedVNode, endNode.vnode);
               var tempEdgeData:EdgeData = tempVEdge.data as EdgeData;
               tempEdgeData.temporary = true;
            }
         }
      }
      private function checkDisappearedLeftNode(vnode:IVisualNode):IVisualNode {
         if (IPTNode(vnode.node).isEnded()) {

            var endNode:EndNode = vnode.node as EndNode;
            if (endNode && !endNode.rootNodeOfMyTree.isEnded()) {
               return endNode.rootNodeOfMyTree.vnode;
            }   
         }
         if (!IPTNode(vnode.node).isEnded()) {
            return vnode;
         }
         return null;
      }
      private function checkOpeningNodeAttachToEndNode(vnode:IVisualNode, endNode:IPTNode):IVisualNode{
         var node:PTRootNode = vnode.node as PTRootNode;
         if(node && node.isOpen() && node.containedPearlTreeModel.endNode != endNode) {
            return node.containedPearlTreeModel.endNode.vnode;
         }
         return vnode;
      }
      
      public function onDetachedTemporaryPearl(newParent:BroPTNode, childNodes:Array, insertionIndex:int):void {
         _tmpDetachChildren  = childNodes;
         _tmpDetachedChildrenParent = newParent;
         
         _insertionIndex = insertionIndex;
      }
      public function onRestoreTemporaryPearl():void {
         _tmpDetachChildren = null;
      }
      
      private function cancelTmpDetachedChildren():void {
         if (_tmpDetachChildren && _tmpDetachChildren.length>0) {
            var targetNode:IPTNode = _draggedVNode.node as IPTNode;
            for each (var n:BroPTNode in _tmpDetachChildren) {
               var node:IPTNode = n.graphNode;
               if (!node) continue;
               if (node.parent) {
                  _vgraph.unlinkNodes(node.parent.vnode, node.vnode);
               }
               if (targetNode) {
                  _vgraph.linkNodes(targetNode.vnode, node.vnode);               
               }
            }
         }
      }
      private function restoreDetachedChildren():void {
         if (_tmpDetachChildren && _tmpDetachChildren.length>0) {
            if (_tmpDetachedChildrenParent && _tmpDetachedChildrenParent.graphNode && _tmpDetachedChildrenParent.graphNode.getBusinessNode() == _tmpDetachedChildrenParent) {
               var parentVNode:IVisualNode = _tmpDetachedChildrenParent.graphNode.vnode;
               for each (var n:BroPTNode in _tmpDetachChildren) {
                  var node:IPTNode = n.graphNode;
                  if (!node) {
                     continue;
                  }
                  var tmpParent:IPTNode = node.parent;
                  if (tmpParent) {
                     _vgraph.unlinkNodes(tmpParent.vnode, node.vnode);
                  }
                  var tempVEdge:IVisualEdge = _vgraph.linkNodesAtIndex(_tmpDetachedChildrenParent.graphNode.vnode, node.vnode, _insertionIndex);
                  var tempEdgeData:EdgeData = tempVEdge.data as EdgeData;
                  
                  tempEdgeData.temporary = false;
                  tempEdgeData.visible = true;
               }
               
            }
         }
      }     
      
   }
}