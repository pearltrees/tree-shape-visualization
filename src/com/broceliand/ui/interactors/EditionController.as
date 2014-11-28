package com.broceliand.ui.interactors{
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.InfoPanelAssets;
   import com.broceliand.graphLayout.autoReorgarnisation.BusinessTree;
   import com.broceliand.graphLayout.autoReorgarnisation.LayoutReorganizer;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.controller.PearlTreeLoaderCallback;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.controller.IEditionController;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.interactors.drag.action.DeleteAction;
   import com.broceliand.ui.interactors.drag.action.MoveAction;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.navBar.NavBarModel;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.pearlWindow.ui.share.ShareHelper;
   import com.broceliand.ui.window.PTWindowModel;
   import com.broceliand.ui.window.ui.infoWindow.InfoWindowModel;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.PTKeyboardListener;
   
   import flash.events.Event;
   
   public class EditionController implements IEditionController {
      
      private var _selectionModel:SelectionModel;
      private var _controls:IGraphControls;
      private var _currentNodeToDelete:IPTNode;
      
      public function EditionController(sm:SelectionModel, keyboardListener:PTKeyboardListener) {
         _selectionModel= sm;

      }
      
      private function getControls():IGraphControls {
         if (!_controls) {
            _controls = ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.controls;
         }
         return _controls;
      }
      private function areKeyboardShortcutsDisabled():Boolean {
         return ApplicationManager.getInstance().visualModel.navigationModel.getPlayState() == 1;
      }
      
      public function copySelectionTo(selectedNode:IPTNode, destination:BroPearlTree):BroPTNode {
         if (!selectedNode) {
            selectedNode = _selectionModel.getSelectedNode();
            if(!selectedNode || selectedNode.isEnded()) return null;
         }
         return copyBusinessNodeTo(selectedNode.getBusinessNode(), destination);
      }
      
      public function copyBusinessNodeTo(selectedBNode:BroPTNode, destination:BroPearlTree):BroPTNode {
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         var copyNode:IPTNode;
         var bnode:BroPTNode;
         var editionController:IPearlTreeEditionController = am.components.pearlTreeViewer.pearlTreeEditionController;
         if (destination.isDropZone()) {
            if (selectedBNode.graphNode) {
               copyNode = getControls().dropZoneDeckModel.dockNode(selectedBNode.graphNode, true);
            } else {
               
               copyNode = getControls().dropZoneDeckModel.dockCopyBroPTNode(selectedBNode, null, selectedBNode.graphNode);
               editionController.addNodeToDropZone(copyNode);
            }
         }
         else {
            bnode = selectedBNode;
            if (bnode) {
               ApplicationManager.getInstance().currentUser.userGaugeModel().onCopyPearl(bnode);
               var copy:BroPTNode  = bnode.makeCopy();
               copy.originId = bnode.persistentID;
               if (bnode.owner && bnode.owner.getMyAssociation().isMyAssociation()) {
                  copy.skipNotificationOnPersist = true;
               }
               bnode = copy;
            }
            var shouldLayout:Boolean = false;
            var parentBNode:BroPTNode = destination.getRootNode();
            var selectedNode:IPTNode = selectedBNode.graphNode;
            
            if (editionController.visualLinkNodeToBusinessTreeAtLegalPosition(bnode, destination)) {
               copyNode = editionController.createNode(bnode);
               editionController.visualLinkNodeToBusinessTreeAtLegalPosition(bnode, destination);
               parentBNode = bnode.graphNode.parent.getBusinessNode();
               if (selectedNode && selectedNode.vnode.view) {
                  copyNode.vnode.view.x = selectedNode.vnode.viewX;
                  copyNode.vnode.view.y = selectedNode.vnode.viewY;
               }
               
               shouldLayout = true;
            }
            
            destination.importBranch(parentBNode,bnode,0);
            bnode.setCollectedStatus();
            var hasReorganized:Boolean = false;
            if (!destination.pearlsLoaded) {

               am.pearlTreeLoader.loadTree(destination.getMyAssociation().associationId, destination.id,new PearlTreeLoaderCallback(null,null), false);
            } else {
               if (copyNode && copyNode.rootNodeOfMyTree) {
                  hasReorganized = new LayoutReorganizer().checkCurrentLayout(new BusinessTree(destination));
               } else {
                  hasReorganized = new LayoutReorganizer().checkCurrentLayout(new BusinessTree(destination));
               }
               
            }
            if (shouldLayout) {
               if (hasReorganized) {
                  am.components.pearlTreeViewer.vgraph.PTLayouter.performSlowLayout();
               } else {
                  am.components.pearlTreeViewer.vgraph.layouter.layoutPass();
               }
            }
            am.persistencyQueue.registerInQueue(destination);
            am.components.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
            am.visualModel.neighbourModel.declareClientNeighbour(selectedBNode, destination, bnode);
            if (selectedNode && selectedNode.vnode.view) {
               selectedNode.vnode.view.invalidateProperties()
            }
         }
         NavBarModel.refreshNavbar();
         return bnode;
      }
      
      public function deleteSelection(cutNode:IPTNode=null, skipConfirmation:Boolean = false):void{
         if (areKeyboardShortcutsDisabled()) {
            return;
         }
         if (!cutNode) {
            cutNode = _selectionModel.getSelectedNode();
         }
         
         if (!cutNode) {
            return;
         }
         else if (!skipConfirmation) {
            var bnode:BroPTNode = cutNode.getBusinessNode();
            
            var tree:BroPearlTree = null;
            if (bnode is BroPTRootNode) {
               tree = bnode.owner;
            }  else if (bnode is BroLocalTreeRefNode) {
               tree = BroLocalTreeRefNode(bnode).refTree;
            }
            if (tree && tree.pearlCount>0) {
               _currentNodeToDelete = cutNode;
               showConfirmationWindow(tree);
               return;
            }
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         new DeleteAction(am.components.pearlTreeViewer, cutNode).doIt();
         
      }
      
      private function showConfirmationWindow(tree:BroPearlTree):void {
         var pearlCount:Number = tree.totalDescendantPearlCount;
         var pearlCountStr:String;
         if (pearlCount == 1) {
            pearlCountStr = BroLocale.getInstance().getText("information.panel.deleteConfirm.pearl.single");
         }
         else {
            pearlCountStr = BroLocale.getInstance().getText("information.panel.deleteConfirm.pearl.plural", [pearlCount.toString()]);
         }
         var textKey:String;
         var links:Array;
         var params:Array;
         
         if (tree.isTeamRoot()) {
            var memberCount:Number = 2;
            if (tree.getMyAssociation() && tree.getMyAssociation().info) {
               memberCount = tree.getMyAssociation().info.ownerCount;
               if (memberCount < 2) {
                  memberCount = 2;
               }
            }
            textKey = "deleteConfirm.team";
            links = null;
            params = [memberCount.toString(), pearlCountStr];
            
         }
         else {
            textKey = "deleteConfirm.tree";
            links = null;
            params = [pearlCountStr];
         }
         
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         var infoWindowModel:InfoWindowModel = wc.openInfoWindow(
            textKey,
            InfoPanelAssets.DELETE_PEARLS,
            InfoWindowModel.BUTTON_TYPE_LEAVE,
            links,
            params,
            InfoWindowModel.USE_SYSTEM_FONT_ON_TITLE);
         if (infoWindowModel) {
            infoWindowModel.addEventListener(PTWindowModel.WINDOW_CLOSE, onClickCancelDelete);
            infoWindowModel.addEventListener(InfoWindowModel.CLICK_BUTTON, onOkDelete);
            infoWindowModel.addEventListener(InfoWindowModel.LINK + 0, onClickCancelDelete);
         }
      }
      
      private function onOkDelete(event:Event):void {
         removeListeners(event)
         deleteSelection(_currentNodeToDelete, true);
      }
      
      private function onClickCancelDelete(event:Event):void {
         removeListeners(event);
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         wc.closeInfoWindow();
      }
      
      private function removeListeners(event:Event):void {
         if (event && event.target && event.target is InfoWindowModel) {
            var infoWindowModel:InfoWindowModel = InfoWindowModel(event.target);
            infoWindowModel.removeEventListener(PTWindowModel.WINDOW_CLOSE, onClickCancelDelete);
            infoWindowModel.removeEventListener(InfoWindowModel.CLICK_BUTTON, onOkDelete);
            infoWindowModel.removeEventListener(InfoWindowModel.LINK + 0, onClickCancelDelete);
         }
      }

      public function moveSelection(cutNode:IPTNode, destination:BroPearlTree, stayInScreenWindow:Boolean = false):IPTNode{
         if (!cutNode)
            cutNode = _selectionModel.getSelectedNode();
         var moveAction:MoveAction = new MoveAction(ApplicationManager.getInstance().components.pearlTreeViewer, cutNode, destination, stayInScreenWindow);
         moveAction.doIt();
         NavBarModel.refreshNavbar();
         return moveAction.getNextSelectedNode();
      }
      public function pasteFromClipboard():void {
         
      }
      
      private function playNode(onScreenLine:Boolean, node:IPTNode, skipRootNode:Boolean = false):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed()) {
            var selectedNode:BroPTNode = node.getBusinessNode();
            ShareHelper.openNodeUrlInNewTab(selectedNode);
            am.isApplicationFocused = false;
         }
         else {
            if (onScreenLine) {
               am.components.screenLine.showScreenLineOnCurrentSelection(PWModel.CONTENT_PANEL);
            } else {
               if (node && node.isDocked) {
                  am.components.pearlTreePlayer.showPlayerOnDockedNode(node);
               } else {
                  am.components.pearlTreePlayer.showPlayerOnCurrentSelection(skipRootNode);
               }
            }
         }
      }
      
      public function playSelection(onScreenLine:Boolean, skipRootNode:Boolean = false):void {
         var am:ApplicationManager=ApplicationManager.getInstance();
         var node:IPTNode = am.visualModel.selectionModel.getSelectedNode();
         playNode(onScreenLine, node, skipRootNode);
      }
   }
}