package com.broceliand.ui.interactors.drag.action
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.PearlTreeLoaderCallback;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   
   public class MoveAction extends CutBNodeAction
   {
      private var _destination:BroPearlTree;
      private var _bnode:BroPTNode;
      private var _nextSelectedNode:IPTNode;
      private var _shouldLayout:Boolean=false;
      
      public function MoveAction(pearltreeViewer:IPearlTreeViewer, node:IPTNode, destination:BroPearlTree, stayInScreenWindow:Boolean = false)
      {  
         super(pearltreeViewer, node);
         _destination = destination;
         _bnode = node.getBusinessNode();
         if (_bnode is BroPTRootNode) {
            _bnode = _bnode.owner.refInParent;
         }
         _nextSelectedNode = computeNextSelection(node);
         if (!_nextSelectedNode) {
            _nextSelectedNode = _pearltreeViewer.vgraph.currentRootVNode.node as IPTNode;
         }
         _stayInScreenWindow = stayInScreenWindow;
      }
      
      public function getNextSelectedNode():IPTNode {
         return _nextSelectedNode;
      }
      
      private function computeNextSelection(moveNode:IPTNode):IPTNode{
         var nodeToSelect:IPTNode = getParentNode();
         var childBNodes:Array = super.getOriginChildNodes();
         if (childBNodes && childBNodes.length>0) {
            return BroPTNode(childBNodes[0]).graphNode;
         } else if (_fromDock) {
            
            var dockSize:int = _fromDock.getItemsCount();
            if (_originalIndex >0 ) {
               nodeToSelect = _fromDock.getNodeAt(_originalIndex-1);
            } else if (dockSize>1) {
               nodeToSelect = _fromDock.getNodeAt(_originalIndex +1);
            }  
         } else {
            var parentNode:IPTNode = getParentNode();
            if (parentNode != null && parentNode.successors.length > 1) {
               if (_originalIndex<parentNode.successors.length-1) {
                  nodeToSelect = parentNode.successors[_originalIndex+1];
               } else {
                  nodeToSelect = parentNode.successors[_originalIndex-1];
               }
            } else {
               nodeToSelect = _cutNode;
            }
         }
         return nodeToSelect;
      }
      
      override protected function updateSelection(node:IPTNode):void {

      }
      
      override protected function sendNodeToDestination(node:IPTNode):void {
         if (!_waitingForAnimationEnds) {
            if (_destination.isDropZone()) {
               node.dock(_pearltreeViewer.vgraph.controls.dropZoneDeckModel);
            }  else {
               if (!_pearltreeViewer.pearlTreeEditionController.visualLinkNodeToBusinessTreeAtLegalPosition(node.getBusinessNode(), _destination)) {
                  if (_fromDock) {
                     node.undock();
                  }
                  _pearltreeViewer.vgraph.removeNode(node.vnode);   
               }  else {
                  if (_shouldLayout) {
                     _pearltreeViewer.vgraph.layouter.layoutPass();
                  }
               }
            }
         }  else {
            _shouldLayout = true;
         }
      }
      
      override protected function changePearlInBusinessModel(node:IPTNode):void {
         if (_bnode.owner != _destination && _bnode.owner) {
            if (_destination.isPrivate() && _bnode is BroLocalTreeRefNode) {
               (_bnode as BroLocalTreeRefNode).refTree.changePrivacyState(true);
            }
            ApplicationManager.getInstance().persistencyQueue.registerInQueue(_bnode.owner);
         }
         var index:int = 0;
         if (_destination.isDropZone()) {
            index = -1;
         }
         _bnode.setCollectedStatus();
         _destination.importBranch(_destination.getRootNode(),_bnode, index);
         if (!_destination.pearlsLoaded) {

            ApplicationManager.getInstance().pearlTreeLoader.loadTree(_destination.getMyAssociation().associationId, _destination.id,new PearlTreeLoaderCallback(null,null));
         } 
         ApplicationManager.getInstance().persistencyQueue.registerInQueue(_destination);
      }
   }
}