package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.io.IPearlTreeLoaderManager;
   import com.broceliand.pearlTree.io.exporter.IPearlTreeQueue;
   import com.broceliand.pearlTree.io.sync.ClientGraphicalSynchronizer;
   import com.broceliand.pearlTree.io.sync.SynchronizationRequest;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLink;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.TreeHierarchy;
   import com.broceliand.pearlTree.model.discover.DiscoverModel;
   import com.broceliand.ui.controller.startPolicy.DropZoneLoader;
   import com.broceliand.ui.effects.TrashPearlEffect;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.InteractorUtils;
   import com.broceliand.ui.interactors.ThrownPearlPositionner;
   import com.broceliand.ui.model.NoteModel;
   import com.broceliand.util.Assert;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   import com.broceliand.util.resources.IRemoteResourceManager;
   import com.broceliand.util.resources.ImageFactory;
   
   import flash.events.Event;
   import flash.utils.getTimer;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.Edge;
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class PearlTreeEditionController implements IPearlTreeEditionController, ILoadTreeRequestor
   {
      private var _vgraph:IPTVisualGraph = null;
      private var _pearlTreeLoaderManager:IPearlTreeLoaderManager = null;
      private var _graphicalAnimationController:GraphicalNavigationController;
      
      public function PearlTreeEditionController(vgraph:IPTVisualGraph, pearlTreeLoaderManager:IPearlTreeLoaderManager, animationRequestProcessor:GraphicalAnimationRequestProcessor, interactionManager:InteractorManager)
      {
         _vgraph = vgraph;
         _graphicalAnimationController = new GraphicalNavigationController(this, vgraph, animationRequestProcessor, interactionManager);
         _pearlTreeLoaderManager = pearlTreeLoaderManager;
         _pearlTreeLoaderManager = ApplicationManager.getInstance().pearlTreeLoader;
      }
      
      public function isPerformingAnimation():Boolean {
         return _graphicalAnimationController.isPerformingRequest();
      }
      
      private function findParentForEndNodeOnUnEndedTree(vn:IVisualNode):IVisualNode{
         var lastNode:IPTNode = (vn.node as IPTNode).rootNodeOfMyTree;
         var threshold:int =1000;
         while(lastNode.successors.length > 0){
            threshold -=1;
            if (threshold <0) {
               Assert.assert(threshold>0, "Loop in a graph while looking for end node of "+IPTNode(vn.node).name);
            }
            lastNode = lastNode.successors[lastNode.successors.length - 1];
            
            if (lastNode is PTRootNode) {
               lastNode = (lastNode as PTRootNode).containedPearlTreeModel.endNode;
            }
         }
         
         return lastNode.vnode;
      }
      
      public function addEndNode(rootNode:PTRootNode):EndNode{
         var parentVNode:IVisualNode = findParentForEndNodeOnUnEndedTree(rootNode.vnode);
         var vendNode:IVisualNode = _vgraph.createNode("end node"+getTimer(), rootNode.treeOwner);
         var endNode:EndNode = vendNode.node as EndNode;
         endNode.containingPearlTreeModel = rootNode.containedPearlTreeModel;
         rootNode.containedPearlTreeModel.endNode = endNode;
         endNode.rootNodeOfMyTree = rootNode;
         _vgraph.linkNodes(parentVNode, vendNode);
         _vgraph.endNodeVisibilityManager.updateEndNodeVisibility(vendNode.node as EndNode, true);
         return endNode;
      }

      public function detachEndNode(treeModel:IPearlTreeModel):IVisualNode{
         if(!treeModel){
            return null;
         }
         var endNode:IPTNode = treeModel.endNode;
         if(endNode is EndNode){
            var endVNode:IVisualNode = endNode.vnode;
            if (endNode.parent) {
               var detachedEndVNodeParent:IVisualNode = endNode.parent.vnode;
               tempUnlinkNodes(detachedEndVNodeParent, endVNode);
               return endVNode;
            }
         }
         return null;
      }

      public function reattachEndNode(endVNode:IVisualNode):void{
         if (endVNode == null || endVNode.node == null || endVNode.node.vnode == null) {
            trace("Error: can't reattach a null node");
            return;
         }
         var endVNodeParent:IVisualNode = findParentForEndNodeOnUnEndedTree(endVNode);
         tempLinkNodes(endVNodeParent, endVNode);
         confirmNodeParentLink(endVNode, false);
         
         if(!endVNode.isVisible || !endVNode.view.visible) {
            EdgeData(IEdge(endVNode.node.inEdges[0]).vedge.data).visible=false;
         }
         
      }
      
      public function onNodeTreeLoaded(tree:BroPearlTree, loadedNode:IPTNode):void{
         openLoadedTree(loadedNode);
      }
      
      public function onErrorLoadingTree(nodeError:IPTNode, error:Object):void {
         if (nodeError is PTRootNode) {
            PTRootNode(nodeError).containedPearlTreeModel.openingState = OpeningState.CLOSED;
         }
      }
      
      private function openLoadedTree(loadedNode:IPTNode, animationType:int = 0, dontShowEmptySign:Boolean= false):void{
         _graphicalAnimationController.openLoadedTree(loadedNode, animationType, dontShowEmptySign);
      }
      public function openTreeNode(vnToOpen:IVisualNode, animationType:int = 0, dontShowEmptySign:Boolean= false):void{
         var containedPearlTreeModel:IPearlTreeModel = (vnToOpen.node as PTRootNode).containedPearlTreeModel;
         containedPearlTreeModel.openingTargetState= OpeningState.OPEN;
         if(containedPearlTreeModel.openingState == OpeningState.CLOSED){
            containedPearlTreeModel.openingState = OpeningState.OPENING;
         } else {
            return;
         }
         var nToOpen:IPTNode= vnToOpen.node as IPTNode;
         var refNode:BroLocalTreeRefNode = nToOpen.getBusinessNode() as BroLocalTreeRefNode;
         if(!refNode) {
            trace("trying to open a pearl that doesn't refer to a tree");
            return;
         }
         
         if(!refNode.isRefTreeLoaded()){
            var loaderCallback:PearlTreeLoaderCallback = new PearlTreeLoaderCallback(vnToOpen.node as IPTNode, this);
            var associationId:Number = refNode.refTree.getMyAssociation().associationId;
            _pearlTreeLoaderManager.loadTree(associationId, refNode.treeId, loaderCallback, true);
         }else{
            openLoadedTree(nToOpen , animationType, dontShowEmptySign);
         }
      }
      
      public function openTreeNodeAndCloseAllOthers(vnToOpen:IVisualNode, animationType:int=0):void {
         var treeToOpen:BroPearlTree = (vnToOpen.node as PTRootNode).containedPearlTreeModel.businessTree;
         var focusedTree:BroPearlTree = ApplicationManager.getInstance().visualModel.navigationModel.getFocusedTree();
         _graphicalAnimationController.closeAllSubtrees(focusedTree, treeToOpen);
         openTreeNode(vnToOpen, animationType);
      }
      public function closeTreeNode(visualRootOfTheClosedTree:IVisualNode, withAnimation:int = 1, withLayout:Boolean = true):void{
         var ptRootNodeOfClosingTree:PTRootNode = visualRootOfTheClosedTree.node as PTRootNode;
         if (ptRootNodeOfClosingTree) {
            ptRootNodeOfClosingTree.containedPearlTreeModel.openingTargetState=OpeningState.CLOSED;
         }
         _graphicalAnimationController.closeTreeNode(visualRootOfTheClosedTree,withAnimation, withLayout);
      }
      
      internal function refreshEdgeWeights(vn:IVisualNode):void{
         if(!vn || !(vn.node is IPTNode)){
            trace("couldn't calculate edge weight on a node that isn't an IPTNode");
            return;
         }
         
         var upNode:IPTNode = vn.node as IPTNode;
         while(upNode.predecessors[0]!=null ){
            if (!upNode.predecessors[0].vnode.isVisible) {
               break;
            }
            upNode = upNode.predecessors[0];
         }
         
         upNode.updatingNumberOfDescendant();
         
         _vgraph.refreshEdges();
         
      }
      
      public function createTree(pearlTree:BroPearlTree, resetGraph:Boolean, resetScroll:Boolean=true,  withAnimation:Boolean = true):IVisualNode{
         return _graphicalAnimationController.createTree(pearlTree, resetGraph, resetScroll, withAnimation?1:0);
      }
      
      public function createNode(businessNode:BroPTNode):IPTNode{
         
         var newVn:IVisualNode = _vgraph.createNode("[.-1]:" + businessNode.title, businessNode);
         if(newVn.node is PTRootNode){
            _graphicalAnimationController.displayModel.onTreeGraphBuilt(newVn.node as PTRootNode);
         }
         return newVn.node as IPTNode;
      }
      public function deleteBranchGraphicalOnly(node:IPTNode):void {
         var businessNode:BroPTNode = node.getBusinessNode();
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var nodesToDelete:Array ;
         if (businessNode is BroPTRootNode) {
            
         } else if (businessNode) {
            nodesToDelete = businessNode.getDescendants();
            nodesToDelete.splice(0,0, businessNode);
         }
         
         var vnodes:Array = InteractorUtils.getDescendantsAndVNode(node.vnode);
         _vgraph.effectForItemRemoval = new TrashPearlEffect();
         for each(var descendant:IVisualNode in vnodes){
            _vgraph.removeNode(descendant);
         }
         refreshEdgeWeights(_vgraph.currentRootVNode);
         _vgraph.effectForItemRemoval = null;
         
         _vgraph.layouter.layoutPass();
      }
      
      public function deleteBusinessBranch(businessNode:BroPTNode):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var tree:BroPearlTree = businessNode==null?null:businessNode.owner;
         var pqueue:IPearlTreeQueue = am.persistencyQueue;
         var nodesToDelete:Array ;
         if (businessNode is BroPTRootNode) {
            tree = businessNode.owner.refInParent.owner;
            nodesToDelete = new Array();
            nodesToDelete.push(businessNode.owner.refInParent);
         } else if (businessNode) {
            nodesToDelete = businessNode.getDescendants();
            nodesToDelete.splice(0,0, businessNode);
         }
         
         if(tree){
            tree.removeBranch(businessNode);
            pqueue.registerInQueue(tree);
            
         }
         if (businessNode) {
            addPearlToDelete(nodesToDelete, pqueue);
         }
         var noteModel:NoteModel = am.visualModel.noteModel;
         for each(var nodeToRemove:BroPTNode in nodesToDelete) {
            noteModel.removeNotesOfDeletedNode(nodeToRemove);
            nodeToRemove.deletedByUser = true;
            
            if(nodeToRemove is BroPageNode) {
               am.getExternalInterface().notifyPearlDeleted(nodeToRemove as BroPageNode);
            }
         }
      }
      
      public function deleteBranch(node:IPTNode):void{
         var businessNode:BroPTNode = node.getBusinessNode();
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         deleteBusinessBranch(businessNode);

         var vnodes:Array = InteractorUtils.getDescendantsAndVNode(node.vnode);
         _vgraph.effectForItemRemoval = new TrashPearlEffect();
         for each(var descendant:IVisualNode in vnodes){
            _vgraph.removeNode(descendant);
         }
         refreshEdgeWeights(_vgraph.currentRootVNode);
         _vgraph.effectForItemRemoval = null;
         
         _vgraph.layouter.layoutPass();

         if(node.isDocked && !node.getDock().isClearing) {
            node.getDock().undockNode(node, !am.components.footer.isPearlDraggedOverTrashBox);
         }
      }
      public function deleteTree(tree:IPearlTreeModel): void {
         var nodesToDelete:Array= new Array();
         var pqueue:IPearlTreeQueue =ApplicationManager.getInstance().persistencyQueue;
         
         var refNode:BroPTNode = tree.businessTree.refInParent;
         nodesToDelete.push(refNode);
         var parentBNode:BroPTNode = refNode.parent;
         var treeToModify:BroPearlTree = parentBNode.owner;
         var indexToInsertNewNodes:int = parentBNode.getChildIndex(refNode);
         nodesToDelete.push(refNode);
         treeToModify.removeBranch(refNode);
         
         var endNode:IPTNode = tree.endNode;
         var parentNode:IPTNode = tree.rootNode.parent;
         var childToMove:IPTNode;
         var endNodeToReattach:EndNode =null;
         if (endNode.outEdges.length>0) {
            for (var i:int =endNode.successors.length;i-->0;) {
               childToMove = endNode.successors[i] as IPTNode;
               _vgraph.unlinkNodes(endNode.vnode, childToMove.vnode);
               if (childToMove is EndNode) {
                  endNodeToReattach = childToMove as EndNode;
               } else {
                  _vgraph.linkNodesAtIndex(parentNode.vnode, childToMove.vnode, indexToInsertNewNodes);
                  confirmNodeParentLink(childToMove.vnode, true, indexToInsertNewNodes);
               }
            }
         }
         
         _vgraph.effectForItemRemoval = new TrashPearlEffect();
         pqueue.registerInQueue(treeToModify);
         pqueue.registerPearlsToDelete(nodesToDelete);
         
         _vgraph.removeNode(tree.rootNode.vnode);
         _vgraph.removeNode(tree.endNode.vnode);
         if (endNodeToReattach) {
            reattachEndNode(endNodeToReattach.vnode);
         }
         _vgraph.effectForItemRemoval = null;
         refreshEdgeWeights(_vgraph.currentRootVNode);
         
      }
      
      private function addPearlToDelete(nodesToBeDeleted:Array, pqueue:IPearlTreeQueue):void {
         for each(var n:BroPTNode in nodesToBeDeleted) {
            if(n is BroLocalTreeRefNode) {
               
               ApplicationManager.getInstance().visualModel.dataRepository.removeInstanceTreeFromHierarchyAndRepository(BroLocalTreeRefNode(n).refTree, true);
            } else if (n is BroDistantTreeRefNode) {
               var t:BroPearlTree = BroDistantTreeRefNode(n).refTree;
               t.treeHierarchyNode.removeFromParent();
               if (t.hierarchyOwner) {
                  var th:TreeHierarchy = t.hierarchyOwner.treeHierarchy;
                  if (th.getTree(t.id) == t) {
                     th.removeTreeFromHierarchy(t);    
                  }
                  
               }
            }
         }
         pqueue.registerPearlsToDelete(nodesToBeDeleted);
         
      }
      public function closeAllSubtrees(tree:BroPearlTree, focusTreeOnly:Boolean=true, treeToRemainOpen:BroPearlTree=null):void {
         _graphicalAnimationController.closeAllSubtrees(tree, treeToRemainOpen, focusTreeOnly );
      }
      public function tempUnlinkNodes(v1:IVisualNode, v2:IVisualNode):void{
         _vgraph.unlinkNodes(v1, v2);
      }
      
      public function tempLinkNodes(v1:IVisualNode, v2:IVisualNode, index:Number = 0, visible:Boolean =true):IVisualEdge{
         
         if (v2.node.predecessors.length>0) {
            trace("Link node that had already one parent");
            tempUnlinkNodes(IPTNode(v2.node).parent.vnode, v2);
         }
         var tempVEdge:IVisualEdge =_vgraph.linkNodesAtIndex(v1, v2, index);
         var tempEdgeData:EdgeData = tempVEdge.data as EdgeData;
         tempEdgeData.temporary = true;
         tempEdgeData.visible = visible;
         refreshEdgeWeights(_vgraph.currentRootVNode);
         return tempVEdge;
      }
      
      public function confirmNodeParentLink(childVNode:IVisualNode, updateBusinessModel:Boolean = true, index:int=-1):void{
         var inEdge:IEdge = childVNode.node.inEdges[0] as Edge;
         (inEdge.data as EdgeData).temporary = false;
         (inEdge.data as EdgeData).visible = true;
         var newParentVNode:IVisualNode = inEdge.fromNode.vnode;
         
         var node:IPTNode = childVNode.node as IPTNode;
         node.undock();
         
         if(updateBusinessModel){
            var newParentNode:IPTNode = IPTNode(newParentVNode.node);
            var newParentBusinessNode:BroPTNode = newParentNode.getBusinessNode();
            var childBusinessNode:BroPTNode = node.getBusinessNode();
            linkBusinessNode(newParentBusinessNode, childBusinessNode, index);
         }
         refreshEdgeWeights(_vgraph.currentRootVNode);
      }
      
      public function linkBusinessNode(newParentBusinessNode:BroPTNode, childBusinessNode:BroPTNode, index:int = -1):void  {
         var oldOwnerOfTheMovingNode:BroPearlTree = null;
         if (childBusinessNode != null) {
            if(childBusinessNode is BroPTRootNode){
               oldOwnerOfTheMovingNode = childBusinessNode.owner.refInParent.owner;
            }else{
               oldOwnerOfTheMovingNode = childBusinessNode.owner;
            }
         }
         if(newParentBusinessNode){
            if(oldOwnerOfTheMovingNode){
               ApplicationManager.getInstance().persistencyQueue.registerInQueue(oldOwnerOfTheMovingNode);
            }
            if(newParentBusinessNode.owner == oldOwnerOfTheMovingNode){
               
               if (childBusinessNode is BroPTRootNode) {
                  if ((childBusinessNode as BroPTRootNode).owner.refInParent) {
                     newParentBusinessNode.owner.addToNode(newParentBusinessNode, (childBusinessNode as BroPTRootNode).owner.refInParent, index);
                  }
               }else {
                  newParentBusinessNode.owner.addToNode(newParentBusinessNode, childBusinessNode, index);
               }
            } else{
               
               if (childBusinessNode) { 
                  newParentBusinessNode.owner.importBranch(newParentBusinessNode, childBusinessNode, index);
                  ApplicationManager.getInstance().persistencyQueue.registerInQueue(newParentBusinessNode.owner);
               }
            }
         }
         
      }
      public function addNodeToDropZone(node:IPTNode, updateBusinessModel:Boolean = true, index:int=-1, dropZoneLoader:DropZoneLoader=null):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var pqueue:IPearlTreeQueue = ApplicationManager.getInstance().persistencyQueue
         var bnode:BroPTNode = node.getBusinessNode();
         if (updateBusinessModel) {
            if (bnode is BroPTRootNode) {
               bnode = bnode.owner.refInParent;
            }
            if (bnode.owner != null) {
               
               pqueue.registerInQueue(bnode.owner);
            }
            var dropZoneTree:BroPearlTree = am.currentUser.dropZoneTreeRef.refTree;
            if (dropZoneTree) {
               dropZoneTree.addToRoot(bnode,index);
               pqueue.registerInQueue(dropZoneTree);
            } else if (dropZoneLoader) {
               dropZoneLoader.addNodeToDockBeforeLoad(bnode);
            }
         }
      }

      public function focusOnTree(tree:BroPearlTree, fromPTW:Boolean =false, resetGraphOption:int= 0):void {
         _graphicalAnimationController.focusOnTree(tree, fromPTW, resetGraphOption);
      }
      public function showAndSelectPearl(nodeOwner:BroPearlTree, node:BroPTNode=null, intersection:int=-1, closeOtherTrees:Boolean=false):void {
         if (closeOtherTrees) {
            _graphicalAnimationController.closeAllSubtrees(ApplicationManager.getInstance().visualModel.navigationModel.getFocusedTree(), nodeOwner, true);
         }
         _graphicalAnimationController.showAndSelectPearl(nodeOwner, node, intersection);
      }
      
      internal function loadAllLogosAndDraw(tree:BroPearlTree):void {
         var node2Process:Array = new Array() ;
         node2Process.push(tree.getRootNode());
         var remoteImageManager:IRemoteResourceManager = ApplicationManager.getInstance().remoteResourceManagers.remoteImageManager;
         while (node2Process.length>0) {
            var n:BroPTNode = node2Process.pop();
            for each (var childLink:BroLink  in n.childLinks) {
               node2Process.push(childLink.toPTNode);
            }
            if (n is BroPageNode) {
               var logoUrl:String = (n  as BroPageNode).refPage.logoUrl;
               if (logoUrl)
                  remoteImageManager.getRemoteResource(ImageFactory.newRemoteImage(), logoUrl);
            }
         }
         if (remoteImageManager.isSourceLoadingComplete()) {
            allLogoLoaded();
         } else {
            remoteImageManager.addEventListener(Event.COMPLETE, allLogoLoaded);
         }
      }
      
      private function allLogoLoaded(e:Event=null):void {
         if (e!=null)
            e.target.removeEventListener(Event.COMPLETE, allLogoLoaded);
      }
      
      public function swapNodeWithParent(stringVNode:IVisualNode, parentVNode:IVisualNode):Boolean {
         if (stringVNode == parentVNode || parentVNode==null) {
            trace("Problem parent is myself in swapNodeWithParent");
            return false;
         }
         var stringNodeChild:IVisualNode = null;
         if (stringVNode.node.successors.length>0) {
            stringNodeChild = stringVNode.node.successors[0].vnode;
         }
         var grandParentNode:IPTNode = IPTNode(parentVNode.node).parent;
         var parentVNodeIndex:int  = InteractorUtils.getChildIndex(grandParentNode, parentVNode.node);
         if (parentVNodeIndex==-1) {
            return false;
         }
         if (stringNodeChild) {
            var stringNodeIndex:int = InteractorUtils.getChildIndex(parentVNode.node, stringVNode.node);
            if (stringNodeIndex<0) return false;
            _vgraph.unlinkNodes(stringVNode,stringNodeChild);
            linkNodesAtIndexWithBusinessUpdate(parentVNode, stringNodeChild, stringNodeIndex);
         }
         _vgraph.unlinkNodes(grandParentNode.vnode,parentVNode);
         _vgraph.unlinkNodes(parentVNode, stringVNode);
         linkNodesAtIndexWithBusinessUpdate(grandParentNode.vnode, stringVNode, parentVNodeIndex);
         linkNodesAtIndexWithBusinessUpdate(stringVNode, parentVNode);
         
         refreshEdgeWeights(_vgraph.currentRootVNode);
         return true;
         
      }
      
      public function swapNodeWithChild(stringVNode:IVisualNode):Boolean {
         var stringVNodeChild:IVisualNode = null;
         var parent:IPTNode = IPTNode(stringVNode.node).parent;
         if (stringVNode.node.successors.length>0) {
            stringVNodeChild = stringVNode.node.successors[0].vnode;
         }
         if (stringVNodeChild ==null || !stringVNode.view.visible) {
            return false;
         }
         
         var childIndex:Number = InteractorUtils.getChildIndex(parent, stringVNode.node);
         _vgraph.unlinkNodes(parent.vnode, stringVNode);
         _vgraph.unlinkNodes(stringVNode, stringVNodeChild);
         
         linkNodesAtIndexWithBusinessUpdate(parent.vnode, stringVNodeChild, childIndex);
         
         var grandChild:IVisualNode = null;
         if (stringVNodeChild.node.successors.length>0) {
            grandChild = stringVNodeChild.node.successors[0].vnode;
            _vgraph.unlinkNodes(stringVNodeChild, grandChild);
         }
         if (grandChild) {
            linkNodesAtIndexWithBusinessUpdate(stringVNode, grandChild);
         }
         linkNodesAtIndexWithBusinessUpdate(stringVNodeChild, stringVNode);
         refreshEdgeWeights(_vgraph.currentRootVNode);
         return true;
      }
      
      public function swapStringNodeChildIndex(stringVNode:IVisualNode, newIndex:int):Boolean {
         trace("Swap Vnode to Index " + IPTNode(stringVNode.node).getBusinessNode().title+ " : " + newIndex);
         var parent:IPTNode = IPTNode(stringVNode.node).parent;
         var childIndex:Number = InteractorUtils.getChildIndex(parent, stringVNode.node);
         
         if (newIndex >= parent.successors.length) {
            return false;
         }
         
         _vgraph.unlinkNodes(parent.vnode, stringVNode);
         var stringVNodeChild:IVisualNode = null;
         if (stringVNode.node.successors.length>0) {
            stringVNodeChild = stringVNode.node.successors[0].vnode;
         }

         if (stringVNodeChild !=null) {
            
            _vgraph.unlinkNodes(stringVNode, stringVNodeChild);
            linkNodesAtIndexWithBusinessUpdate(parent.vnode, stringVNodeChild, childIndex);
         }
         var newStringChild:IPTNode = parent.successors[newIndex];
         
         _vgraph.unlinkNodes(parent.vnode, newStringChild.vnode);
         linkNodesAtIndexWithBusinessUpdate(parent.vnode, stringVNode, newIndex);
         linkNodesAtIndexWithBusinessUpdate(stringVNode, newStringChild.vnode);
         
         refreshEdgeWeights(_vgraph.currentRootVNode);
         return true;
      }

      private function linkNodesAtIndexWithBusinessUpdate(parent:IVisualNode, child:IVisualNode, index:int=0):void {
         _vgraph.linkNodesAtIndex(parent, child, index);
         var parentNode:IPTNode = IPTNode(parent.node);
         var childNode:IPTNode = IPTNode(child.node);
         var parentBusinessNode:BroPTNode = parentNode.getBusinessNode();
         var childBusinessNode:BroPTNode = childNode.getBusinessNode();
         if (childNode is PTRootNode) {
            if ((childNode as PTRootNode).isOpen()) {
               
               childBusinessNode = childBusinessNode.owner.refInParent;
            }
            
         } else if (childNode is EndNode) {
            return;
         }
         if (parentNode is EndNode) {
            parentBusinessNode= parentNode.treeOwner.refInParent;
         }
         Log.getLogger("com.broceliand.ui.interactors.drag").info("Link node {0} to {1} at {2}",parentBusinessNode.title,childBusinessNode.title,index);
         parentBusinessNode.owner.addToNode(parentBusinessNode, childBusinessNode, index);
         
      }

      public  function importBranchIntoTree(localRefTreeVnode:IVisualNode, branchToImport:IVisualNode, nextNodeToSelect:IPTNode, onAnimationEnd:Function):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var parentNode:IPTNode = localRefTreeVnode.node as IPTNode;
         var saveQueue:IPearlTreeQueue = am.persistencyQueue
         var refNode:BroLocalTreeRefNode = BroLocalTreeRefNode(parentNode.getBusinessNode());
         
         var refTree:BroPearlTree = refNode.refTree;
         
         var nodeMove:BroPTNode = IPTNode(branchToImport.node).getBusinessNode();
         if (nodeMove) {
            var treeToSave:BroPearlTree = nodeMove.owner;
            if (nodeMove is BroPTRootNode) {
               treeToSave = treeToSave.treeHierarchyNode.parentTree;
            }
            if (treeToSave) {
               saveQueue.registerInQueue(treeToSave);
            }
         }
         
         if (nextNodeToSelect) {
            saveQueue.registerInQueue(nextNodeToSelect.getBusinessNode().owner);
         }

         refTree.importBranch(refTree.getRootNode(),IPTNode(branchToImport.node).getBusinessNode(), 0);
         
         var nodes2Process:Array = new Array();
         nodes2Process.push(branchToImport.node);
         var node2RemoveFromTheGraph:Array = new Array();
         while(nodes2Process.length>0) {
            var node:IPTNode = nodes2Process.pop();

            for each (var n:IPTNode in node.successors) {
               nodes2Process.push(n);
            }
            if (node.isDocked) {
               node.undock(false);
            }
            var bnode:BroPTNode = node.getBusinessNode();
            if (bnode) {
               bnode.setCollectedStatus();  
            }
            node2RemoveFromTheGraph.push(node);
            
         }
         var action:IAction =  new ImportIntoTreeAnimation(_vgraph, localRefTreeVnode.node as IPTNode, node2RemoveFromTheGraph, _graphicalAnimationController.displayModel, onAnimationEnd);
         am.visualModel.animationRequestProcessor.postActionRequest(action);   
         
         if (!refTree.pearlsLoaded) {

            am.pearlTreeLoader.loadTree(refTree.getMyAssociation().associationId, refTree.id,new PearlTreeLoaderCallback(null,null));
         }
         saveQueue.registerInQueue(refTree);
      }
      
      public function clearGraph(removeNodes:Boolean=true):Array {
         return _graphicalAnimationController.clearGraph(removeNodes);
      }
      
      public function focusOnPTWTree(tree:BroPearlTree):void {
         _graphicalAnimationController.focusOnPTWTree(tree);
      }
      public function moveInPTWTree(tree:BroPearlTree):void {
         _graphicalAnimationController.moveInPTW(tree);
      }

      public function synchronizeTrees(request:SynchronizationRequest, invoker:ClientGraphicalSynchronizer, isOutsideMyAccount:Boolean):void {
         _graphicalAnimationController.synchronizeTrees(request, invoker, isOutsideMyAccount);
      }

      public function visualLinkNodeToParentNode(bnode:BroPTNode, bparentNode:BroPTNode, index:int, updateBusinessModel:Boolean):Boolean {     
         var displayModel:GraphicalDisplayedModel = _graphicalAnimationController.displayModel;
         var rootNode:PTRootNode= displayModel.getNode(bparentNode.owner) as PTRootNode;
         if (rootNode) {
            if (rootNode.isOpen()) {
               if (bnode.graphNode) {
                  var endVNode:IVisualNode = detachEndNode(rootNode.containedPearlTreeModel);               
                  tempLinkNodes(bparentNode.graphNode.vnode, bnode.graphNode.vnode, index);
                  confirmNodeParentLink(bnode.graphNode.vnode, updateBusinessModel, index);
                  reattachEndNode(endVNode);
                  return true;
               }            
            }
         }
         return false;
      }

      public function visualLinkNodeToBusinessTreeAtLegalPosition(bnode:BroPTNode, targetTree:BroPearlTree, updateBusinessModel:Boolean = true ):Boolean {
         var displayModel:GraphicalDisplayedModel = _graphicalAnimationController.displayModel;
         var rootNode:PTRootNode= displayModel.getNode(targetTree) as PTRootNode;
         if (rootNode) {
            if (rootNode.isOpen()) {
               if (bnode.graphNode) {
                  var bparentNode:BroPTNode = ThrownPearlPositionner.findBestPositionInTree(targetTree, bnode);
                  if (!bparentNode || !bparentNode.graphNode) {
                     bparentNode = rootNode.getBusinessNode();
                  }                              
                  visualLinkNodeToParentNode(bnode, bparentNode, 0, updateBusinessModel);           
               } 
               return true;
            }
         }
         return false;
      }
      
      public function getDiscoverModel():DiscoverModel {
         return _graphicalAnimationController.discoverModel;
      }
      
      public function getDisplayModel():GraphicalDisplayedModel {
         return _graphicalAnimationController.displayModel;
      }
      
      public function createCopyOfNode(businessNode:BroPTNode):IPTNode {
         if (businessNode == null) {
            return null;
         }
         var newBusinessNode:BroPTNode = businessNode.makeCopy();
         newBusinessNode.originId = businessNode.persistentID;
         if (businessNode.owner && businessNode.owner.getMyAssociation().isMyAssociation()) {
            newBusinessNode.skipNotificationOnPersist = true;
         }
         return createNode(newBusinessNode);
      }
      
      public function get vgraph():IPTVisualGraph
      {
         return _vgraph;
      }
   }
}
