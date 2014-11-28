package com.broceliand.ui.interactors.drag
{
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EditedGraphVisualModification;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.SavedPearlReference;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.interactors.InteractorManager;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   
   public class RemovePearlInteractor
   {

      private  var _temporarilyDetachedChildren:Array = null;
      private  var _temporarilyDetachedChildrenSourceNode:SavedPearlReference= null;
      protected var _interactorManager:InteractorManager = null;
      private   var _temporaryLinksData:Array= null;
      protected var _isTempLinkVisible:Boolean=true;
      protected var _currentInsertionIndex:int;
      protected var _currentTargetNode:SavedPearlReference;
      
      public function RemovePearlInteractor(interactorManager:InteractorManager){
         _interactorManager = interactorManager;
         
      }
      
      private function moveDescendantsOfNodeToAnother(sourceNode:IPTNode, targetNode:IPTNode, insertionIndex:int = 0):void{
         if (targetNode) {
            _temporarilyDetachedChildren = new Array();
            _temporarilyDetachedChildrenSourceNode = new SavedPearlReference(sourceNode);
            var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
            var sourceBNode:BroPTNode = sourceNode.getBusinessNode();
            
            for(var i:int = sourceBNode.getChildCount(); i-->0;){
               
               _temporarilyDetachedChildren.push(sourceBNode.getChildAt(i));
               
            }
            _currentInsertionIndex = insertionIndex;
            _interactorManager.pearlTreeViewer.vgraph.getEditedGraphVisualModification().onDetachedTemporaryPearl(targetNode.getBusinessNode(), _temporarilyDetachedChildren, insertionIndex);
            for each(var bnode:BroPTNode in _temporarilyDetachedChildren){
               var successor:IPTNode = bnode.graphNode;
               if (successor) {
                  editionController.tempUnlinkNodes(sourceNode.vnode, successor.vnode); 
                  editionController.tempLinkNodes(targetNode.vnode, successor.vnode, insertionIndex, _isTempLinkVisible);

                  editionController.confirmNodeParentLink(successor.vnode, false, insertionIndex);
               }
            }
         }
         
      }
      
      public function setTemporaryLinksVisible(value:Boolean):Boolean {
         
         value = true;
         if (_isTempLinkVisible != value) {
            _isTempLinkVisible = value;
            if (_temporarilyDetachedChildren) {
               for each(var bnode:BroPTNode in _temporarilyDetachedChildren){
                  var node:IPTNode = bnode.graphNode;
                  if (node && node.edgeToParent) { 
                     var edgeData:EdgeData= node.edgeToParent.data as EdgeData;
                     edgeData.visible = _isTempLinkVisible;
                     edgeData.temporary = false;
                  }
               }
               return true;
            }
         }
         return false;
      }
      private function onRemovingRoot(rootNode:PTRootNode):void{
         var endNode:EndNode = rootNode.containedPearlTreeModel.endNode as EndNode;
         if(endNode && _interactorManager.getDraggedPearlOriginParentNodeRef()){
            _currentTargetNode = _interactorManager.getDraggedPearlOriginParentNodeRef();
            
            moveDescendantsOfNodeToAnother(endNode, _currentTargetNode.getNode(true), _interactorManager.draggedPearlOriginalParentIndex);
         }
      }
      private  function onRemovingNormalNode(node:IPTNode):void{
         if (_interactorManager.getDraggedPearlOriginParentNodeRef()) {
            _currentTargetNode = _interactorManager.getDraggedPearlOriginParentNodeRef();
            moveDescendantsOfNodeToAnother(node, _currentTargetNode.getNode(true), _interactorManager.draggedPearlOriginalParentIndex);
         }
      }

      protected function tempRemoveNode(node:IPTNode):void {
         if(node.parent){
            
            var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
            editionController.tempUnlinkNodes(node.parent.vnode, node.vnode);
         }
         if(node is PTRootNode &&  ((node as PTRootNode).isOpen() || (node as PTRootNode).containedPearlTreeModel.openingState== OpeningState.CLOSING)){
            onRemovingRoot(node as PTRootNode);
         }else{
            onRemovingNormalNode(node);
         }
      }
      
      protected function restoreTemporaryRemoveNode(node:IPTNode, definitively:Boolean =true):void {
         if(_interactorManager.getDraggedPearlOriginParentNodeRef() && _temporarilyDetachedChildren){
            
            var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
            var newParentNode:IPTNode = _temporarilyDetachedChildrenSourceNode.getNode(true);
            var newParentBNode:BroPTNode= _temporarilyDetachedChildrenSourceNode.getBusinessNode();
            for each(var bchild:BroPTNode in _temporarilyDetachedChildren){
               var child:IPTNode = bchild.graphNode;
               if (child) {
                  if (child.parent) {
                     editionController.tempUnlinkNodes(child.parent.vnode, child.vnode);
                  }
                  editionController.tempLinkNodes(newParentNode.vnode, child.vnode);
                  if (definitively) {
                     editionController.confirmNodeParentLink(child.vnode, true);
                  }
               } else {
                  editionController.linkBusinessNode(newParentBNode, bchild);
               }
            }
         }
         var editedGraphModification:EditedGraphVisualModification = _interactorManager.pearlTreeViewer.vgraph.getEditedGraphVisualModification();
         editedGraphModification.onRestoreTemporaryPearl();
         _temporarilyDetachedChildren = null;
         _temporarilyDetachedChildrenSourceNode = null;
         _currentTargetNode = null;
      }
      
      protected function getTemporarilyDetachedBChildren():Array {
         return _temporarilyDetachedChildren;
      }
      
   }

}