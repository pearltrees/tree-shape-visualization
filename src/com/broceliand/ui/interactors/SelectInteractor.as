package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PageNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPTWPageNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NavigationManagerImpl;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPTWPearl;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.pearlWindow.ui.share.ShareHelper;
   import com.broceliand.ui.renderers.pageRenderers.PagePearlRenderer;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   import mx.core.Application;
   import mx.core.UIComponent;
   
   public class SelectInteractor
   {
      private static const HIDE_NOTIFICATION_DELAY:Number = 700;
      private static const WAIT_FOR_DOUBLE_CLICK:Boolean = true;
      
      protected var _interactorManager:InteractorManager = null;
      protected var _selectionModel:SelectionModel;
      private var _selectTwiceOnMouseUp:Boolean= false;
      private var _currentSelectionOnMouseDown:IUIPearl;
      private var _isFirstSelection:Boolean = true;
      private var _pendingPlaySelection:uint;
      
      public function SelectInteractor(interactorManager:InteractorManager){
         _interactorManager = interactorManager;
         _selectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         _selectionModel.addEventListener(SelectionModel.NEW_NODE_SELECTED_EVENT, onSelectionChanges);
         _selectionModel.addEventListener(SelectionModel.NODE_SELECTED_TWICE_EVENT, onSelectedTwice);
      }
      
      private function onSelectionChanges(event:Event):void {
         var selectedNode:IPTNode = _selectionModel.getSelectedNode();
         if (selectedNode) {
            unselectInternal(false);
            selectInternal(selectedNode);
            if (_selectionModel.selectedFromNavBar) {
               centerOnSelection();
            }
         } else {
            unselectInternal(true);
         }
         
         clearPendingPlay();
         _isFirstSelection = false;
      }
      
      protected function getPearlRenderer(ev:Event):IUIPearl{
         return ev.target.parent as IUIPearl;
      }
      
      public function selectOnMouseDown(renderer:IUIPearl):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var wc:IWindowController = am.components.windowController;
         var isPWUndockedButNodeInfoNotVisible:Boolean = !wc.isPearlWindowDocked() && (wc.visibleWindowId != 1 || wc.pearlWindow.model.selectedPanel != PWModel.CONTENT_PANEL);

         if (true && 
            (!am.visualModel.navigationModel.isShowingDiscover()  || renderer.node.getBusinessNode() is BroPTWPageNode ) &&
            _selectionModel.getSelectedNode() == renderer.node && 
            !isPWUndockedButNodeInfoNotVisible &&
            true){
            _selectTwiceOnMouseUp = true;
         }
         else {
            _currentSelectionOnMouseDown = renderer;
         }
         
         am.components.windowController.displayNodeInfo(renderer.node, true);

         if (am.currentUser.openPWOnNextOver) {
            am.components.windowController.setPearlWindowDocked(false, null, true);
            am.currentUser.openPWOnNextOver = false;
            _selectTwiceOnMouseUp = false;
         }
         
         if(am.isEmbed()) {
            am.embedManager.pearlClicked = true;
         }
      }
      
      public function commitPendingSelection():void {
         if (_currentSelectionOnMouseDown && _selectionModel.getSelectedNode() != _currentSelectionOnMouseDown.node) {
            _selectionModel.selectNode(_currentSelectionOnMouseDown.node);
         }
         clearPendingSelection();
      }
      
      public function clearPendingSelection():void {
         _currentSelectionOnMouseDown =null;
         _selectTwiceOnMouseUp = false;
      }

      private function selectInternal(node:IPTNode):void {
         if (!node.vnode) return;
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var renderer:IUIPearl = IUIPearl(node.vnode.view);
         _interactorManager.selectedPearl = renderer;
         if (renderer && am.visualModel.navigationModel.getPlayState() != 1) {
            renderer.refresh();
         }
         
         var windowController:IWindowController =  am.components.windowController;
         
         if(renderer && windowController.getNodeDisplayed() != renderer.node) {
            if(am.isEmbed() && _isFirstSelection) {
               
            } else {
               var navModel:INavigationManager = am.visualModel.navigationModel;
               if (!_selectionModel.turnOffDisplayInfo && !navModel.willShowPlayer) {
                  windowController.displayNodeInfo(renderer.node, true);
               }
            }
         }
      }
      
      private function onSelectedTwice(event:Event):void {
         var selectedNode:IPTNode=_selectionModel.getSelectedNode();
         
         if (selectedNode.pearlVnode.pearlView is UIPTWPearl || !selectedNode.getBusinessNode().owner) {
            
         }
         else if (selectedNode.isDocked ) {
            var playOnScreenLine:Boolean = true;
            if (_interactorManager.hasDoubleClicked && selectedNode is PageNode) {
               openPlayerOnNewTab(selectedNode.getBusinessNode());
            }  else {
               playSelectionAfterWaitForDoubleClick();
            }
         }
         else {
            var isAnimating:Boolean = IPTVisualGraph(selectedNode.vnode.vgraph).isAnimating();
            
            if (selectedNode is PageNode  && _interactorManager.hasDoubleClicked) {
               if (!isAnimating) {
                  openPlayerOnNewTab(selectedNode.getBusinessNode());
               }
            } else {
               if (!_selectionModel.selectedFromNavBar) {
                  if(!isAnimating) {
                     playSelectionAfterWaitForDoubleClick();       
                  }
               } else {
                  closeAllSubFocusTreesAndCenterAfter();
               }
            }
         }
      }
      
      private function playSelectionAfterWaitForDoubleClick():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (WAIT_FOR_DOUBLE_CLICK && !am.isEmbed()) {
            _pendingPlaySelection = setTimeout(playSelectionOnDelayEnds, InteractorManager.DOUBLE_CLICK_LENGTH);
         } else {
            playSelection(true);
         }
      } 
      
      private function clearPendingPlay():void {
         if (_pendingPlaySelection > 0) {
            clearTimeout(_pendingPlaySelection);
            _pendingPlaySelection = 0;
         }
      }
      private function playSelectionOnDelayEnds():void {
         if (_interactorManager.hasDoubleClicked) {
            return;
         }
         else {
            playSelection(true);
            _pendingPlaySelection = 0;
         }
      } 
      public function unselect():void{
         _selectionModel.selectNode(null);
      }
      private function unselectInternal(hidePearlWindow:Boolean):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var refresh:Boolean = true;
         if(am.visualModel.navigationModel.getPlayState() ==1) {
            refresh =false;
         }
         if(_interactorManager.selectedPearl){
            if (refresh) _interactorManager.selectedPearl.refresh();
            _interactorManager.selectedPearl = null;
         }
      }
      
      private function playSelection(onScreenLine:Boolean):void {
         clearPendingPlay();
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (am.isEmbed()) {
            onScreenLine = false;
         }
         var nm:INavigationManager = am.visualModel.navigationModel;
         var showScreenLine:Boolean = onScreenLine
         var selectedNode:IPTNode = am.visualModel.selectionModel.getSelectedNode();
         if (selectedNode) {
            var ptwNode:IBroPTWNode = selectedNode.getBusinessNode() as IBroPTWNode;
            if (ptwNode) {
               ptwNode.navigateToPearl(selectedNode);
               return;
            }
         }
         
         if (nm.getFocusedTree().getRootNode() != nm.getSelectedPearl() || am.isEmbed() || showScreenLine) {
            Log.getLogger("com.broceliand.ui.screenwindow.SelectInteractor").info("SelectInteractor showScreenLine");
            am.visualModel.editionController.playSelection(onScreenLine && !am.isEmbed());
         }
      }
      
      public function closeAllSubFocusTreesAndCenterAfter():void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         am.components.pearlTreeViewer.pearlTreeEditionController.closeAllSubtrees(navigationModel.getFocusedTree(), true);
         if (am.visualModel.animationRequestProcessor.isBusy) {
            am.visualModel.animationRequestProcessor.addEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerOnSelection);
         } else {
            centerOnSelection();
         }
      }
      
      public function center():void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         if (am.visualModel.animationRequestProcessor.isBusy) {
            am.visualModel.animationRequestProcessor.addEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerOnSelection);
         } else {
            centerOnSelection();
         }
      }
      
      private function centerOnSelection(event:Event=null):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if (event) {
            am.visualModel.animationRequestProcessor.removeEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerOnSelection);
         }
         _selectionModel.centerGraphOnCurrentSelectionWithPWDisplayed(false, true);
      }

      public function closePlayOrDisplayContentPanel():void {
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var wc:IWindowController =  am.components.windowController;
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         var nodeDisplayed:IPTNode = wc.getNodeDisplayed();
         var isPearlWindowDocked:Boolean = am.components.windowController.isPearlWindowDocked();
         var shouldDisplayContent:Boolean = false;
         var shouldDisplayEmpty:Boolean = false;
         var isNodeAlreadyVisibleInPearlWindow:Boolean = (nodeDisplayed && nodeDisplayed.vnode && (nodeDisplayed.vnode.view == _interactorManager.selectedPearl));
         
         if(!nodeDisplayed && !isPearlWindowDocked && _interactorManager.selectedPearl) {
            shouldDisplayContent = true;
         }
         else if(isPearlWindowDocked || isNodeAlreadyVisibleInPearlWindow) {
            if (closeSubTrees()) {
               return;
            }
            var bnode:BroPTNode =_selectionModel.getSelectedNode().getBusinessNode();
            if (bnode is BroDistantTreeRefNode) {
               if (BroDistantTreeRefNode(bnode).refTree.isDeleted() || BroDistantTreeRefNode(bnode).refTree.isHidden()) {
                  shouldDisplayContent = true;
               }
            } else if (bnode is BroLocalTreeRefNode) {
               if (BroLocalTreeRefNode(bnode).refTree.isEmpty()) {
                  shouldDisplayContent = true;
               }
            } else if (bnode is BroPTRootNode && !(bnode is BroNeighbourRootPearl)) {
               if (bnode.owner.isEmpty()) {
                  if (bnode.owner.isCurrentUserAuthor()) {
                     shouldDisplayEmpty = true;
                  } else {
                     return;
                  }
                  
               } else if (bnode.owner != navigationModel.getFocusedTree()) {
                  
                  return;
               }
            }
         }
         
         if (shouldDisplayContent) {
            wc.displayNodeInfo();
         } else if (shouldDisplayEmpty) {
            wc.displayNodeEmptyContent();
         } else {
            
            if (_interactorManager.isInsideCreationCycle()) {
               return;
            }
            playSelection(true);
         }
         
      }
      
      private function closeSubTrees():Boolean {
         return new CloseSubTreesAndCenterInteractor(_interactorManager,_selectionModel).closeFocusSubTrees();
         
      }
      
      public function onMouseUp(hasDragged:Boolean, clickDuration:Number):void {
         Log.getLogger("com.broceliand.ui.screenwindow.SelectInteractor").info("SelectInteractor onMouseUp");
         var am:ApplicationManager = ApplicationManager.getInstance();
         var isPearlWindowDocked:Boolean = am.components.windowController.isPearlWindowDocked();
         var selectedNode:IPTNode = (_currentSelectionOnMouseDown && _currentSelectionOnMouseDown.node && _currentSelectionOnMouseDown.node.vnode)?_currentSelectionOnMouseDown.node:null;
         var isNodeAnimating:Boolean = (selectedNode)?IPTVisualGraph(selectedNode.vnode.vgraph).isAnimating():false;
         
         if (_selectTwiceOnMouseUp) {
            _selectTwiceOnMouseUp = false;
            if (!hasDragged) {
               var node:IPTNode = _selectionModel.getSelectedNode();
               _selectionModel.selectNode(node);
            }
         }
         else {
            if (!hasDragged) {
               if(!(selectedNode is EndNode)) {
                  commitPendingSelection();
               }
               if(!selectedNode is PageNode && !isNodeAnimating && !selectedNode.isInDropZone) {
                  playSelection(true);
               }
               if (isPearlWindowDocked && selectedNode && selectedNode.isInDropZone) {
                  playSelection(true);               
               }
               
            }
         }
         
         clearPendingSelection();
      }

      private function openPlayerOnNewTab(node:BroPTNode):void {
         if (ApplicationManager.getInstance().isEmbed()) {
            playSelection(false);   
         } 
         else {
            ShareHelper.openNodeUrlInNewTab(node);
         }
      }
   }
}