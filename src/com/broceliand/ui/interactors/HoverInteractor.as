package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIEndPearl;
   
   import flash.utils.setTimeout;
   
   public class HoverInteractor {
      
      protected var _interactorManager:InteractorManager = null;
      protected var _nodeToSelect:IPTNode = null;
      private var _isFirstHover:Boolean = true;
      
      private static const UPDATE_SELECTION_DELAY:Number = 35;
      
      public function HoverInteractor(interactorManager:InteractorManager){
         _interactorManager = interactorManager;
      }
      
      public function onMouseOverWithUpdateSelection(renderer:IUIPearl, updateSelection:Boolean):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var highlightedTree:BroPearlTree = null
         if(renderer){
            _interactorManager.pearlTreeViewer.pearlRendererStateManager.excitePearlRenderer(renderer, true);
            if (renderer.node is EndNode) {
               highlightedTree = renderer.node.rootNodeOfMyTree.getBusinessNode().owner;      
            } else {
               highlightedTree = renderer.node.getBusinessNode().owner;
            }
            
            if(am.isEmbed() && renderer.node.isDocked) {
               updateSelection = false;
            } else {
               
               var navModel:INavigationManager = am.visualModel.navigationModel;
               var windowController:IWindowController = am.components.windowController;
               if (navModel.isFirstSelectionPerformed && windowController.isPearlWindowDocked() && am.currentUser.shouldOpenPWOnNextOver(_isFirstHover) && updateSelection) {
                  var withAnimation:Boolean = true;
                  if (!windowController.isAllWindowClosed()) {
                     withAnimation = false;
                  }
                  windowController.isFirstOpenEffect = true;
                  windowController.setPearlWindowDocked(false, renderer.node, !withAnimation);
                  am.currentUser.openPWOnNextOver = false;
               }
               _isFirstHover = false;
            }
         }
         var currentSelectedTree:BroPearlTree = ApplicationManager.getInstance().visualModel.navigationModel.getSelectedTree();
         if (currentSelectedTree == highlightedTree) {
            highlightedTree = null;
         }
         if (ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(highlightedTree)) {
            _interactorManager.pearlTreeViewer.vgraph.refreshNodes();
         }
         if (updateSelection) {
            if(renderer && !(renderer is UIEndPearl) && renderer.node) {
               am.components.windowController.displayNodeInfo(renderer.node);
               if (am.visualModel.selectionModel.getSelectedNode() != renderer.node) {
                  _nodeToSelect = renderer.node;
                  
                  setTimeout(updateSelectionWithDelay, UPDATE_SELECTION_DELAY, renderer.node);
               }
            }
         }     
      }
      
      public function onMouseOver(renderer:IUIPearl):void{
         
         if (_interactorManager.updateSelectionOnOver) {
            onMouseOverWithUpdateSelection(renderer, true);   
         } else {
            onMouseOverWithUpdateSelection(renderer, false);
         }
      }

      private function updateSelectionWithDelay(node:IPTNode):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var pearlUnderCursor:IUIPearl = _interactorManager.pearlRendererUnderCursor;
         if(_nodeToSelect == node && am.visualModel.selectionModel.getSelectedNode() != node) {
            _nodeToSelect = null;
            am.visualModel.selectionModel.selectNode(node);
         }
      }
      
      public function onMouseOut(renderer:IUIPearl):void {
         if(!renderer || !renderer.vnode || !renderer.vnode.view) {
            return;
         }

         _interactorManager.pearlTreeViewer.pearlRendererStateManager.relaxPearlRenderer(renderer, true);
         renderer.pearl.moveRingOutPearl();
      }			
   }
}