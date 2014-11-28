package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.DistantTreeRefNode;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NavigationManagerImpl;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UICenterPTWPearl;
   import com.broceliand.ui.pearl.UIPTWPearl;
   import com.broceliand.ui.pearlTree.EmptyMapText;
   import com.broceliand.ui.window.WindowController;
   
   public class OpenCloseTreeInteractor
   {
      
      private var _interactorManager:InteractorManager = null;
      
      private var _previousNodeSelected:IPTNode;
      
      public function OpenCloseTreeInteractor(interactorManager:InteractorManager){
         _interactorManager = interactorManager;
         
      }
      public function saveCurrentSelectionOnMouseDown():void {
         _previousNodeSelected  = ApplicationManager.getInstance().visualModel.selectionModel.getSelectedNode();
      }
      public function get previousNodeSelected():IPTNode {
         return _previousNodeSelected;
      }		
      
      private function handleClickOnRootNode(renderer:IUIPearl, clickOnEndNode:Boolean=false):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var windowController:IWindowController = am.components.windowController;
         if(renderer.node.isTopRoot){
            
            return;
         }
         
         var rootNode :PTRootNode =  renderer.node as PTRootNode;

         var wc:IWindowController = am.components.windowController;
         var isAnonymous:Boolean = am.currentUser.isAnonymous();

         var model:IPearlTreeModel = rootNode.containedPearlTreeModel;

         if((model.openingState == OpeningState.CLOSED) || (model.openingState == OpeningState.CLOSING)){
            openTree(rootNode);
         }
         else if(((wc.getNodeDisplayed() || wc.isPearlWindowDocked() || isAnonymous || clickOnEndNode) && (_previousNodeSelected == rootNode || clickOnEndNode)) 
            || (!clickOnEndNode && model.openingState == OpeningState.OPENING)) {
            
            if(clickOnEndNode) {               
               closeTree(rootNode);               
            } else { 

               var navmodel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
               var selectedTree:BroPearlTree = model.businessTree;
               if (!selectedTree.isEmpty()) {
                  navmodel.goTo(selectedTree.getMyAssociation().associationId,
                     navmodel.getSelectedUser().persistentId,
                     selectedTree.id,
                     selectedTree.id,
                     selectedTree.getRootNode().persistentID);
               } else {
                  showEmptyText(rootNode); 
                  var currentUser:User = ApplicationManager.getInstance().currentUser;
                  if (!navmodel.isShowingPearlTreesWorld() && selectedTree.isCurrentUserAuthor()) {
                     ApplicationManager.getInstance().components.windowController.displayNodeEmptyContent(rootNode);
                  }
               }

               _previousNodeSelected = null;
            }
            _interactorManager.selectInteractor.clearPendingSelection();
         } else if (_previousNodeSelected != rootNode) {
            if (rootNode.isOpen()) {
               var tree:BroPearlTree = rootNode.containedPearlTreeModel.businessTree;
               if (tree.isEmpty()) {
                  showEmptyText(rootNode, true);
               }
            }
         }
         
      }
      
      private function showEmptyText(rootNode:IPTNode, ignoreNextNavigation:Boolean= false):void {
         var emptyMapText:EmptyMapText = _interactorManager.pearlTreeViewer.vgraph.controls.emptyMapText;
         if (!emptyMapText.visible) {
            emptyMapText.bindToNode(rootNode);
            emptyMapText.visible=true;
            emptyMapText.ignoreNextNavigationEvent = ignoreNextNavigation;
         }
      }
      public function openTree(node:IPTNode):void{
         if (OpenCloseTreeInteractor.focusOnTreeNode(node)) {
            _interactorManager.selectInteractor.clearPendingSelection();  
         }
      }
      public static function focusOnTreeNode(node:IPTNode):Boolean {
         var rootNode:PTRootNode = node as PTRootNode;
         if(!rootNode) return false;
         var model:IPearlTreeModel = rootNode.containedPearlTreeModel;
         var navmodel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         var selectedTree:BroPearlTree = model.businessTree;

         if(((model.openingState == OpeningState.CLOSED) || (model.openingState == OpeningState.CLOSING)) && !rootNode.isDocked) {
            var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
            selectionModel.saveCrossingBusinessNode(node);
            
            navmodel.goTo(selectedTree.getMyAssociation().associationId, 
               navmodel.getSelectedUser().persistentId, 
               selectedTree.id,
               selectedTree.id, 
               selectedTree.getRootNode().persistentID, -1 ,-1, 0, true, NavigationEvent.ADD_ON_CROSS_ANIMATION);
            return true;
            
         }
         return false;
      }
      
      public function closeTree(node:IPTNode):void {
         if(node.isTopRoot) return;
         if (_interactorManager.draggedPearl == node.pearlVnode.view) {
            return;
         }
         var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
         var businessNode:BroPTNode = node.getBusinessNode();
         var selectedTree:BroPearlTree = businessNode.owner;
         if(businessNode is BroTreeRefNode) {
            selectedTree = BroTreeRefNode(businessNode).refTree;
         }
         editionController.closeTreeNode(node.vnode);

         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;         
         var focusedTree:BroPearlTree = navModel.getFocusedTree();
         var parentTree:BroPearlTree = selectedTree.treeHierarchyNode.parentTree;
         var user:User = navModel.getSelectedUser();
         
         navModel.goTo(focusedTree.getMyAssociation().associationId, 
            user.persistentId,
            focusedTree.id, 
            parentTree.id,
            selectedTree.refInParent.persistentID);         
      }
      
      private function handleClickOnEndNode(renderer:IUIPearl):void{
         var rootNode :PTRootNode =  (renderer.node as IPTNode).rootNodeOfMyTree as PTRootNode;
         if(rootNode){
            
            handleClickOnRootNode(rootNode.renderer, true);               
         }
         
      }
      
      private function handleClickOnDistantTreeRefNode(renderer:IUIPearl):void{
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         if((wc.getNodeDisplayed() && renderer.node  == _previousNodeSelected) || wc.isPearlWindowDocked()) {
            var distantTreeRefNode:BroDistantTreeRefNode = renderer.node.getBusinessNode() as BroDistantTreeRefNode;
            var navigationModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
            var ptwNode:IBroPTWNode = renderer.node.getBusinessNode() as IBroPTWNode
            if (ptwNode) {
               ptwNode.navigateToPearl(renderer.node);
            } else {
               navigationModel.getAliasNavigationModel().navigateThroughAlias(distantTreeRefNode, renderer.node);
               _interactorManager.selectInteractor.clearPendingSelection();
            }
         }
      }
      
      private function handleClickOnPTWNode(renderer:IUIPearl):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var selectionModel:SelectionModel = am.visualModel.selectionModel;
         var wc:IWindowController = am.components.windowController;
         var selectedNode:IPTNode = selectionModel.getSelectedNode();

         if(selectedNode == renderer.node || wc.isPearlWindowDocked()) {
            var node:IPTNode = renderer.node;   
            var bnode:BroPTNode = node.getBusinessNode();
            var focusNeighbourTree:BroPearlTree = navModel.getFocusNeighbourTree();
            if (bnode is BroNeighbourRootPearl) {
               bnode = BroNeighbourRootPearl(bnode).delegateNode;
               if (bnode is BroDistantTreeRefNode) {
                  visitPTWDistantNode(bnode as BroDistantTreeRefNode);
               }
            } else if(focusNeighbourTree) {
               selectionModel.saveCrossingBusinessNode(node);
               visitPTWDistantNode(bnode as BroDistantTreeRefNode);
            }
         }
      }
      private function visitPTWDistantNode(dnode:BroDistantTreeRefNode):void {
         
         if (!dnode) return;         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager= am.visualModel.navigationModel; 
         var tree:BroPearlTree = dnode.refTree;
         var user:User = tree.getMyAssociation().preferredUser;
         navModel.getAliasNavigationModel().declareNavigationFromPTW(tree.id);
         navModel.goTo(tree.getMyAssociation().associationId,
            dnode.user.persistentId,
            tree.id,
            tree.id,
            tree.getRootNode().persistentID,
            -1, -1, -1, true);
      }
      
      public function onPearlClick(renderer:IUIPearl, clickDuration:Number):void {
         if(renderer is UIPTWPearl || renderer is UICenterPTWPearl) {
            handleClickOnPTWNode(renderer);
         }else if(renderer.node is PTRootNode) {
            handleClickOnRootNode(renderer);   
         }else if(renderer.node is EndNode) {
            handleClickOnEndNode(renderer);   
         } else if(renderer.node is DistantTreeRefNode) {
            handleClickOnDistantTreeRefNode(renderer);
         }     			
      }
   }
}