package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.window.ui.error.ErrorWindowModel;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class NodePositioningInteractor
   {
      private var _interactorManager:InteractorManager = null;
      public function NodePositioningInteractor(interactorManager:InteractorManager)
      {
         _interactorManager = interactorManager;
      }
      private function isInOverLimitException(parent:IPTNode, child:IPTNode):Boolean {
         return _interactorManager.interactorRightsManager.testBigTreeLimitation(parent.getBusinessNode(), child.getBusinessNode()) == InteractorRightsManager.CODE_TOO_MANY_NODES_IN_MAP;
      }
      private function findDefaultPosition():IVisualNode{
         var rootOfSelectedTree:IVisualNode = findRootOfSelectedTree();
         if (rootOfSelectedTree.node.successors.length +1 > InteractorRightsManager.MAX_NUM_IMMEDIATE_DESCENDANTS_ROOT && InteractorRightsManager.PREVENT_TOO_MANY_DESCENDANT) {
            while (rootOfSelectedTree.node.successors.length >0) {
               rootOfSelectedTree =  rootOfSelectedTree = rootOfSelectedTree.node.successors[0].vnode;
            }
         }
         return rootOfSelectedTree;
      }
      
      private function findRootOfSelectedTree():IVisualNode{
         var currentRootVNode:IVisualNode = _interactorManager.pearlTreeViewer.vgraph.currentRootVNode;
         var currentRootNode:IPTNode = currentRootVNode.node as IPTNode;
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         var selectedTree:BroPearlTree = navModel.getSelectedTree();
         var focusedTree:BroPearlTree = navModel.getFocusedTree();
         if (selectedTree != null && focusedTree != selectedTree) {
            
            var nodes:Array = currentRootNode.getDescendantsAndSelf();
            for each (var n:IPTNode in nodes) {
               if (n is PTRootNode && PTRootNode(n).containedPearlTreeModel.businessTree == selectedTree && PTRootNode(n).isOpen()) {
                  return n.vnode;
               }
            }
         }
         return currentRootVNode;
         
      }
      public function sendNodeToDefaultPosition(node:IPTNode):Boolean{
         if(node){
            
            var manipulatedNodesModel:ManipulatedNodesModel = new ManipulatedNodesModel();
            manipulatedNodesModel.updateManipulatedNodesFromDraggedNode(node,true);
            
            var parentVNode:IVisualNode= findDefaultPosition(); 
            var rightsManager:InteractorRightsManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.interactorRightsManager;
            
            var testLinkAllowed:Boolean = rightsManager.testLinkAllowed(node, parentVNode.node as IPTNode, manipulatedNodesModel, false) == InteractorRightsManager.CODE_OK;
            
            if(rightsManager.userHasRightToAddChildrenToNode(IPTNode(parentVNode.node)) && testLinkAllowed) {
               if (!isInOverLimitException(parentVNode.node as IPTNode, node)) {
                  new UndockNodeAndSelectAfterLayoutAction(_interactorManager, node, parentVNode.node as IPTNode).performAction();
               } else {
                  
                  var tree:BroPearlTree = IPTNode(parentVNode.node).getBusinessNode().owner;
                  var action:IAction = null;
                  if (tree.pearlCount == InteractorRightsManager.MAX_NUM_NODES_IN_MAP) {
                     action = new CreateEmptyTreeUndockNodeAndSelectAfterLayoutAction(_interactorManager, node, parentVNode.node as IPTNode);
                  } else {
                     action = new CreateEmptyTreeReplaceLastNodeAndSelectAfterLayoutAction (_interactorManager, node, parentVNode.node as IPTNode);
                  }
                  var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
                  wc.openErrorWindow(ErrorWindowModel.WARNING_LIMIT_MAX_TREE_SIZE_FROM_DROP_ZONE, false, null, action);
               }
               return true;
            } 
         }
         return false;
      }

   }
}
import com.broceliand.ApplicationManager;
import com.broceliand.graphLayout.autoReorgarnisation.BusinessTree;
import com.broceliand.graphLayout.autoReorgarnisation.LayoutReorganizer;
import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
import com.broceliand.graphLayout.controller.LayoutAction;
import com.broceliand.graphLayout.layout.UpdateTitleRendererLayout;
import com.broceliand.graphLayout.model.EdgeData;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.graphLayout.model.IPearlTreeModel;
import com.broceliand.graphLayout.model.PTRootNode;
import com.broceliand.graphLayout.visual.IPTVisualGraph;
import com.broceliand.pearlTree.io.object.tree.OwnerData;
import com.broceliand.pearlTree.model.BroPTNode;
import com.broceliand.pearlTree.model.BroPTRootNode;
import com.broceliand.pearlTree.model.BroPearlTree;
import com.broceliand.pearlTree.model.User;
import com.broceliand.pearlTree.navigation.INavigationManager;
import com.broceliand.ui.interactors.InteractorManager;
import com.broceliand.ui.interactors.ThrownPearlPositionner;
import com.broceliand.ui.interactors.drag.action.MoveAction;
import com.broceliand.util.GenericAction;
import com.broceliand.util.IAction;

import flash.events.Event;

import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

class UndockNodeAndSelectAfterLayoutAction implements IAction{
   protected var _interactorManager:InteractorManager;
   protected var _node:IPTNode;
   protected var _parentNode:IPTNode;
   protected var _hasReorganized:Boolean = false;
   protected var _newEdgeData:EdgeData= null;
   
   public function UndockNodeAndSelectAfterLayoutAction(interactorManager:InteractorManager, node:IPTNode, parentNode:IPTNode) {
      _interactorManager = interactorManager;
      _node = node;
      _parentNode = parentNode; 
   }
   public function performAction():void {
      _hasReorganized = undockNodeAndAddItToParent(_node, _parentNode);
      internalLayoutAndNavigateAfter();
   }
   
   public function internalLayoutAndNavigateAfter(event:Event=null):void {
      var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
      var vgraph:IPTVisualGraph = _interactorManager.pearlTreeViewer.vgraph; 
      garp.postActionRequest(new LayoutAction(vgraph, _hasReorganized));
      garp.postActionRequest(new GenericAction(garp, this, navigateToNode, _node));
   }
   
   public function navigateToNode(node:IPTNode):void {
      _newEdgeData.visible = true;
      var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
      var selectedUser:User = navModel.getSelectedUser();
      var focusTree:BroPearlTree = navModel.getFocusedTree();
      var selectTree:BroPearlTree = navModel.getSelectedTree();
      
      var id:Number = node.getBusinessNode().persistentID;
      if (node is PTRootNode ) {
         selectTree = PTRootNode(node).containedPearlTreeModel.businessTree;
         if (!selectTree.isEmpty()) {
            selectTree = navModel.getFocusedTree();
         } else {
            id = selectTree.getRootNode().persistentID;
         }
      } else {
         selectTree = node.treeOwner;
      }
      
      if (navModel.getSelectedPearl() != node) {
         navModel.goTo(focusTree.getMyAssociation().associationId, 
            selectedUser.persistentId, 
            focusTree.id,  
            selectTree.id, 
            id);
      }
   }
   protected function undockNodeAndAddItToParent(nodeToUndock:IPTNode, parentNode:IPTNode):Boolean {
      var editionController:IPearlTreeEditionController =  _interactorManager.pearlTreeViewer.pearlTreeEditionController;
      var treeModel:IPearlTreeModel = parentNode.containingPearlTreeModel;
      if (parentNode is PTRootNode) {
         treeModel = PTRootNode(parentNode).containedPearlTreeModel;
      }
      var parentBNode:BroPTNode = ThrownPearlPositionner.findBestPositionInTree(parentNode.getBusinessNode().owner, nodeToUndock.getBusinessNode());
      if (parentBNode && parentBNode.graphNode) {
         parentNode = parentBNode.graphNode;
      }
      var indexToPutDockedNodeAt:int = 0 ; 
      
      var endNode:IVisualNode = editionController.detachEndNode(treeModel); 
      var vedge:IVisualEdge = editionController.tempLinkNodes(parentNode.vnode, nodeToUndock.vnode, indexToPutDockedNodeAt);
      _newEdgeData = vedge.data as EdgeData;
      editionController.confirmNodeParentLink(nodeToUndock.vnode, true, indexToPutDockedNodeAt);
      
      nodeToUndock.getBusinessNode().setCollectedStatus();
      _newEdgeData.visible = false;
      editionController.reattachEndNode(endNode);
      var hasReorganized:Boolean = new LayoutReorganizer().checkCurrentLayout(new BusinessTree(treeModel.businessTree));
      nodeToUndock.undock();
      _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
      UpdateTitleRendererLayout.updateTitleRendererNow(_interactorManager.pearlTreeViewer.vgraph);
      return hasReorganized;
   }
   
}

class CreateEmptyTreeUndockNodeAndSelectAfterLayoutAction extends UndockNodeAndSelectAfterLayoutAction implements IAction {
   private var _mustCreateEmptyTree:Boolean;
   public function CreateEmptyTreeUndockNodeAndSelectAfterLayoutAction(interactorManager:InteractorManager, node:IPTNode, parentNode:IPTNode) {
      super(interactorManager, node, parentNode);
      _mustCreateEmptyTree = true;
      if (_node is PTRootNode) {
         if (PTRootNode(_node).containedPearlTreeModel.businessTree.isEmpty()) {
            _mustCreateEmptyTree = false;
         }
      }
   }
   public function onErrorLoadingTree(error:Object):void {
      
   }
   
   override public function performAction():void {
      if (!_mustCreateEmptyTree) {
         super.performAction();
      } else {
         ApplicationManager.getInstance().components.windowController.openNewPearltreeWindow();
         
      }
   }

}

class CreateEmptyTreeReplaceLastNodeAndSelectAfterLayoutAction extends CreateEmptyTreeUndockNodeAndSelectAfterLayoutAction implements IAction {
   
   public function CreateEmptyTreeReplaceLastNodeAndSelectAfterLayoutAction (interactorManager:InteractorManager, node:IPTNode, parentNode:IPTNode) {
      super(interactorManager, node, parentNode);
      
   }
   override public function performAction():void {
      dockLastNodeOfTree(_parentNode);
      super.performAction();
   }
   private function dockLastNodeOfTree(parentNode:IPTNode):void {
      var bnode:BroPTNode = ThrownPearlPositionner.findBestPositionInTree(parentNode.getBusinessNode().owner, _node.getBusinessNode());
      var nodeToReplace:IPTNode = bnode.graphNode; 
      
      if (nodeToReplace) {
         _parentNode = nodeToReplace.parent;
         var cutAction:MoveAction = new MoveAction(_interactorManager.pearlTreeViewer, nodeToReplace, ApplicationManager.getInstance().currentUser.dropZoneTreeRef.refTree); 
         cutAction.shouldLayout =false;
         cutAction.shouldUpdateSelection = false;
         cutAction.doIt();
      }  
   }

}