package com.broceliand.graphLayout.controller
{
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.pearlTree.io.sync.ClientGraphicalSynchronizer;
   import com.broceliand.pearlTree.io.sync.SynchronizationRequest;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.discover.DiscoverModel;
   import com.broceliand.ui.controller.startPolicy.DropZoneLoader;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public interface IPearlTreeEditionController
   {
      
      function openTreeNode(n:IVisualNode, animationType:int=0, dontShowEmptySign:Boolean= false):void;
      function openTreeNodeAndCloseAllOthers(vnToOpen:IVisualNode, animationType:int = 0 ):void ; 
      function closeTreeNode(n:IVisualNode, animationType:int= 1, withLayout:Boolean = true):void;	
      
      function createTree(pearlTree:BroPearlTree, resetGraph:Boolean, resetScroll:Boolean=true, withAnimation:Boolean = true):IVisualNode;
      
      function clearGraph(removeNodes:Boolean=true):Array ;
      function deleteBranch(node:IPTNode):void;
      function deleteBranchGraphicalOnly(node:IPTNode):void;
      function deleteTree(tree:IPearlTreeModel):void;
      
      function tempUnlinkNodes(v1:IVisualNode, v2:IVisualNode):void;
      function tempLinkNodes(v1:IVisualNode, v2:IVisualNode, index:Number = 0, visible:Boolean=true):IVisualEdge;
      function confirmNodeParentLink(childVNode:IVisualNode, updateBusinessModel:Boolean = true, index:int=0):void;
      function linkBusinessNode(newParentBusinessNode:BroPTNode, childBusinessNode:BroPTNode, index:int = -1):void ;
      
      function createNode(businessNode:BroPTNode):IPTNode;
      function addNodeToDropZone(childVNode:IPTNode, updateBusinessModel:Boolean = true, index:int=-1, dropZoneLoader:DropZoneLoader=null):void;
      
      function detachEndNode(tree:IPearlTreeModel):IVisualNode;
      
      function reattachEndNode(endVNode:IVisualNode):void;
      
      function focusOnTree(tree:BroPearlTree, fromPTW:Boolean =false, clearGraphOption:int = 0):void;
      function focusOnPTWTree(tree:BroPearlTree):void;
      function moveInPTWTree(tree:BroPearlTree):void;
      function closeAllSubtrees(tree:BroPearlTree, focusTreeOnly:Boolean=true, treeToRemainOpen:BroPearlTree=null):void;

      function showAndSelectPearl(nodeOwner:BroPearlTree, node:BroPTNode=null, intersection:int=-1, closeOtherTrees:Boolean=false):void;

      function swapNodeWithParent(stringNode:IVisualNode, parentNode:IVisualNode):Boolean;
      function swapNodeWithChild(stringNode:IVisualNode):Boolean;
      function swapStringNodeChildIndex(stringNode:IVisualNode, newIndex:int):Boolean;

      function importBranchIntoTree(LocalRefTreeVnode:IVisualNode, branchToImport:IVisualNode, nextNodeToSelect:IPTNode, onEndAnimation:Function):void;
      
      function isPerformingAnimation():Boolean;
      
      function synchronizeTrees(request:SynchronizationRequest, invoker:ClientGraphicalSynchronizer, isOutsideMyAccount:Boolean):void;
      
      function visualLinkNodeToBusinessTreeAtLegalPosition(nodeToLink:BroPTNode,  targetTree:BroPearlTree, updateBusinessNode:Boolean = true):Boolean;
      
      function visualLinkNodeToParentNode(bnode:BroPTNode, bparentNode:BroPTNode, index:int, updateBusinessModel:Boolean):Boolean;
      function getDisplayModel():GraphicalDisplayedModel;
      function getDiscoverModel():DiscoverModel;
      
      function createCopyOfNode(bnode:BroPTNode):IPTNode;
      function deleteBusinessBranch(businessNode:BroPTNode):void;
   }
}