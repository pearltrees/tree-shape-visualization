package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.model.INodeTitleModel;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IPearlWithButton;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIRootPearl;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlNotificationState;
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.display.Stage;
   import flash.geom.Point;

   public class PearlRendererStateManager
   {
      private static const STATE_SELECTED_OVER_NODE:int = -1;
      private static const STATE_SELECTED_NODE:int = 0;
      private static const STATE_EXCITED:int = 1;
      private static const STATE_FOCUS_PATH:int = 2;
      private static const STATE_SELECTED_TREE:int = 3;
      private static const STATE_OPENING_TREE:int = 5;
      private static const STATE_ANYTHING_ELSE:int = 6;
      private static const STATE_PEARLTREE_WORLD:int = 7;
      private static const STATE_PEARLTREE_WORLD_ROOT:int = 8; 
      private static const STATE_IS_MOVING:int = 9;
      
      private static const TITLE_COLOR_SELECTED_NODE:int = 0x000000;
      private static const TITLE_COLOR_EXCITED:int = 0x000000;
      private static const TITLE_COLOR_FOCUS_PATH:int = 0x4b4c4c;
      private static const TITLE_COLOR_SELECTED_TREE:int = 0x000000;
      private static const TITLE_COLOR_DEFAULT:int = 0xa8a8a8;
      private static const TITLE_COLOR_DEFAULT_DOCKED:int = 0x888888;
      private static const TITLE_COLOR_INVISIBLE:int = ColorPalette.getInstance().backgroundColor;
      
      private var _navigationManager:INavigationManager = null;
      private var _selectionModel:SelectionModel = null;

      private var _vgraph:IPTVisualGraph;
      private var _nodeTitleModel:INodeTitleModel;
      private var _interactorManager:InteractorManager
      private var _windowController:IWindowController;
      private var _highlightAllPearl:Boolean;
      private var _utilPoint:Point = new Point(); 
      
      public function PearlRendererStateManager(vgraph:IPTVisualGraph, nodeTitleModel:INodeTitleModel, interactorManager:InteractorManager, navigationManager:INavigationManager, selectionModel:SelectionModel,
                                                windowController:IWindowController)
      {
         _navigationManager = navigationManager;
         _interactorManager = interactorManager;
         _nodeTitleModel = nodeTitleModel;
         _selectionModel = selectionModel;
         _vgraph = vgraph;
         _windowController = windowController;
      }

      private function isNodeSelectedNode(renderer:IUIPearl):Boolean{
         
         var node:BroPTNode = renderer.node.getBusinessNode();        
         if(!node){
            return false;
         }
         var selectedNode:IPTNode = _selectionModel.getSelectedNode();
         if(!selectedNode){
            return false;
         }

         var selectedBusinessNode:BroPTNode = _navigationManager.getSelectedPearl();
         
         if (selectedNode != null && selectedNode.isDocked) {
            selectedBusinessNode = selectedNode.getBusinessNode();
         }
         if (node == selectedBusinessNode) {
            return true;
         }

         if(node is IBroPTWNode && selectedNode == renderer.node) {
            return true;
         }

         if(node is BroLocalTreeRefNode && isMouseOverNode(renderer)) {
            return true;
         }
         return false;
         
      }

      private function isNodeInSelectedTree(node:BroPTNode, withRootException:Boolean= true):Boolean{
         var selectedTree:BroPearlTree = _selectionModel.getHighlightedTree(); 
         
         var isDragging:Boolean = _interactorManager.draggedPearl != null;
         if (isDragging && !selectedTree) {
            selectedTree = _navigationManager.getSelectedTree();
         }
         if (selectedTree && selectedTree.isEmpty() && node.owner != selectedTree) {
            selectedTree = selectedTree.treeHierarchyNode.parentTree;
         }
         var inSelectedTree:Boolean = isNodeInTree(node, selectedTree, withRootException);
         if (!inSelectedTree && !isDragging) {
            selectedTree = _navigationManager.getSelectedTree();
            if (selectedTree && selectedTree.isEmpty() && node.owner != selectedTree) {
               selectedTree = selectedTree.treeHierarchyNode.parentTree;
            }
            inSelectedTree = isNodeInTree( node, selectedTree, withRootException);
         }
         return inSelectedTree;
      }
      
      private function isNodeInTree(node:BroPTNode, selectedTree:BroPearlTree, withRootException:Boolean):Boolean {
         var inSelectedTree:Boolean =false;
         if (node) {
            inSelectedTree = (selectedTree && node.owner && selectedTree == node.owner);
            if (!inSelectedTree  && withRootException) {
               if (node is BroPTRootNode) {
                  if (node.owner  && node.owner.refInParent  && node.owner.refInParent.owner){
                     inSelectedTree = node.owner.refInParent.owner == selectedTree;
                  }
               }  else if (node is BroLocalTreeRefNode && BroLocalTreeRefNode(node).refTree == selectedTree) {
                  inSelectedTree = true;
               }
            } 
         }
         return inSelectedTree;
      }
      private function isNodeInOpeningTree(node:BroPTNode):Boolean{
         return  node && node.owner && (node.owner== _selectionModel.openingTree);
      }
      
      private function isNodeInExcitedDeck(node:IPTNode):Boolean {
         return (node && node.isDocked && node.getDock().isHighlighted && node.getDock().isEnabled);
      }

      public static function getStartRendererForEndRenderer(renderer:IUIPearl):UIRootPearl{
         var endRenderer:EndPearlRenderer = renderer as EndPearlRenderer;
         if(endRenderer && endRenderer.node && endRenderer.node.rootNodeOfMyTree){
            return endRenderer.node.rootNodeOfMyTree.renderer as UIRootPearl;
         }else{
            return null;
         }
      }
      
      public static function getEndRendererForStartRenderer(startRenderer:IUIPearl):EndPearlRenderer{
         if(startRenderer && startRenderer.node && startRenderer.node && (startRenderer.node is PTRootNode)){
            var startNode:PTRootNode = startRenderer.node as PTRootNode;
            if(startNode.containedPearlTreeModel && startNode.containedPearlTreeModel && startNode.containedPearlTreeModel.endNode){
               return startNode.containedPearlTreeModel.endNode.renderer as EndPearlRenderer;
            }
         }
         return null;
      }
      
      private function isMouseOverNode(renderer:IUIPearl):Boolean {
         return (_interactorManager.pearlRendererUnderCursor == renderer);
      }

      private function getState(renderer:IUIPearl, excited:Boolean = false):int{
         if (_highlightAllPearl) {
            return STATE_EXCITED;
         }
         var state:int = STATE_ANYTHING_ELSE;
         if (renderer.isMoving) {
            state = STATE_IS_MOVING; 
         } else 
            if (renderer is PTCenterPTWPearlRenderer || isSearchCenter(renderer.node)) {
               state = STATE_PEARLTREE_WORLD_ROOT;
            } else if(renderer.node){
               var businessNode:BroPTNode; 
               if (renderer is EndPearlRenderer) {
                  businessNode = (renderer as EndPearlRenderer).businessNode;           
               }
               else {
                  businessNode = renderer.node.getBusinessNode(); 
               }
               if (businessNode is BroNeighbourRootPearl|| businessNode is IBroPTWNode) {
                  state= STATE_PEARLTREE_WORLD;
               } 
               if(isNodeSelectedNode(renderer)){
                  if(isMouseOverNode(renderer)) {
                     state = STATE_SELECTED_OVER_NODE;
                  }else {
                     state = STATE_SELECTED_NODE;
                  }
               }else if(excited){
                  state = STATE_EXCITED;

               }else if(isNodeInSelectedTree(businessNode)){
                  state = STATE_SELECTED_TREE;
               } else if (isNodeInOpeningTree(businessNode)) {
                  state = STATE_OPENING_TREE;
               }else if(isNodeInExcitedDeck(renderer.node)) {
                  state = STATE_SELECTED_TREE;
               }
            }
         return state; 
      }

      private function isRootOfSelectedPearlTree(inode:IPTNode):Boolean {
         if (inode is EndNode) {
            inode = inode.rootNodeOfMyTree;   
         }
         var node:BroPTNode = inode.getBusinessNode();
         var selectedTree:BroPearlTree = _selectionModel.getHighlightedTree();
         if (!selectedTree) {
            selectedTree = _navigationManager.getSelectedTree();
         }
         if (node  is BroPTRootNode && node.owner && node.owner == selectedTree) {
            return true;
         }
         if (node is BroLocalTreeRefNode && BroLocalTreeRefNode(node).refTree == selectedTree) {
            return true;
         }
         return false;
      }
      
      private function isSearchNode(inode:IPTNode):Boolean {
         var businessNode:BroPTNode = inode.getBusinessNode();
         return businessNode is IBroPTWNode && IBroPTWNode(businessNode).isSearchNode;
      }
      
      private function isSearchCenter(inode:IPTNode):Boolean {
         var businessNode:BroPTNode = inode.getBusinessNode();
         return businessNode is IBroPTWNode && IBroPTWNode(businessNode).isSearchCenter;
      }
      
      private function updateEndNodeVisualState(node:EndNode, excited:Boolean = false, isExciteSource:Boolean = true):void{
         if (!node.canBeVisible) {
            return;
         }
         var isInSelectedTree:Boolean = false;
         var refNode:BroLocalTreeRefNode = node.getBusinessNode() as BroLocalTreeRefNode;

         if (isNodeInSelectedTree(refNode, false)) {
            isInSelectedTree = true; 
         } 
         if (isNodeInSelectedTree(refNode.refTree.getRootNode(), false)) {
            isInSelectedTree = true;
         }
         var pearl:EndPearlRenderer = node.vnode.view as EndPearlRenderer;
         pearl.setInSelection(isInSelectedTree);
         if (excited ) {
            if (isExciteSource) {
               pearl.excite();
            } 
         } else {
            pearl.relax();
         }
         
      } 
      public function updateVisualState(renderer:IUIPearl, excited:Boolean = false, isExciteSource:Boolean = true):void{
         if(!renderer || renderer.isEnded() || !renderer.node || !renderer.node.getBusinessNode() || ! renderer.node.vnode){
            return;
         }      
         
         var node:IPTNode = renderer.node;
         if (!excited ) {
            excited = node.pearlVnode.isExcited;
            isExciteSource = false;
         }
         if (node is EndNode) {
            updateEndNodeVisualState(node as EndNode, excited, isExciteSource);
            return;
         }
         var businessNode:BroPTNode = node.getBusinessNode();        
         var deleted:Boolean = businessNode.deletedByUser;
         var state:int = getState(renderer, excited);
         var color:int = TITLE_COLOR_DEFAULT;
         var showRings:Boolean = true;
         var isRootOfSelectedNode:Boolean = isRootOfSelectedPearlTree(node);       
         var isSearchNode:Boolean = isSearchNode(node);
         var isSearchCenter:Boolean = isSearchCenter(node);
         var excitePearl:Boolean = (state <= STATE_EXCITED) || (state == STATE_PEARLTREE_WORLD_ROOT) || isRootOfSelectedNode || isSearchCenter;
         var titleAbove:Boolean = (state <= STATE_EXCITED);
         var showTitleTextInBold:Boolean = (isNodeSelectedNode(renderer) || (state == STATE_EXCITED)) && !isSearchCenter;
         var showHalo:Boolean = false;
         var isManipulated:Boolean = _interactorManager.draggedPearl != null && renderer.node && _interactorManager.manipulatedNodesModel.isNodeManipulated(renderer.node);
         var am:ApplicationManager = ApplicationManager.getInstance();

         if(businessNode is BroNeighbourRootPearl /*|| isSearchCenter */ ){
            showHalo = true;
            titleAbove = true;
         }                 
         if(!node.isDocked){
            switch(state){
               case STATE_SELECTED_OVER_NODE:
                  color = TITLE_COLOR_SELECTED_NODE;
                  break;           
               case STATE_SELECTED_NODE:
                  color = TITLE_COLOR_SELECTED_NODE;
                  break;
               case STATE_EXCITED:
                  color = TITLE_COLOR_EXCITED;
                  break;
               case STATE_IS_MOVING:
                  color = TITLE_COLOR_INVISIBLE;
                  break; 
               case STATE_FOCUS_PATH:
                  color = TITLE_COLOR_FOCUS_PATH;
                  break;
               case STATE_SELECTED_TREE:
                  color = TITLE_COLOR_SELECTED_TREE;
                  break;
               case STATE_OPENING_TREE:
                  color = TITLE_COLOR_SELECTED_TREE;
                  break;  
               case STATE_PEARLTREE_WORLD:
                  color= TITLE_COLOR_EXCITED;
                  break;
               case STATE_PEARLTREE_WORLD_ROOT:
                  color= TITLE_COLOR_EXCITED;
                  titleAbove= true;
                  break; 
            }
         }else{
            
            switch(state){
               case STATE_SELECTED_OVER_NODE:
                  color = TITLE_COLOR_SELECTED_NODE;
                  break;
               case STATE_SELECTED_NODE:
                  color = TITLE_COLOR_SELECTED_NODE;
                  break;
               case STATE_EXCITED:
                  color = TITLE_COLOR_EXCITED;
                  break;
               case STATE_SELECTED_TREE:
                  color = TITLE_COLOR_EXCITED;
                  break;
               default:
                  color = TITLE_COLOR_DEFAULT_DOCKED;
            }
            showRings = false;
         }

         if(node == _interactorManager.nodeWhoseTitleIsBeingEdited ){
            color = TITLE_COLOR_INVISIBLE;
         }
         if (node.pearlVnode && node.pearlVnode.pearlView && node.pearlVnode.pearlView.pearl.markAsDisappearing) {
            color = TITLE_COLOR_INVISIBLE;
         }
         
         if(node.isDocked && ApplicationManager.getInstance().isEmbed()) {
            color = TITLE_COLOR_INVISIBLE;
         }
         if(!deleted) {
            if(titleAbove){
               var onTop:Boolean = _interactorManager.draggedPearl && _interactorManager.draggedPearl.node == node;
               _vgraph.showNodeTitle(renderer, true, onTop, node.isDocked);
            }else{
               _vgraph.showNodeTitle(renderer, false, false, node.isDocked);
            }
         }
         if (isManipulated && color == TITLE_COLOR_DEFAULT) {
            color = TITLE_COLOR_SELECTED_TREE;
         }
         var titleRenderer:TitleRenderer = renderer.titleRenderer;
         var nodeMessageCode:int = _nodeTitleModel.getMessageType(node);
         var overrideNodeTitle:Boolean = (nodeMessageCode != NodeTitleModel.NO_MESSAGE);
         if (titleRenderer) {
            titleRenderer.messageOnTrashBoxMode = false;
            if (renderer.visible == false || renderer.isTitleHiddenToDisplayInfo()) {
               color = TITLE_COLOR_INVISIBLE;
            }
            if(color == TITLE_COLOR_INVISIBLE) {
               titleRenderer.visible = titleRenderer.includeInLayout = false;
            }else{
               if(!deleted) {
                  titleRenderer.visible = titleRenderer.includeInLayout = true;
               }
               if(overrideNodeTitle){
                  titleRenderer.setColor(0x009EE9);
                  var message:String = _nodeTitleModel.getNodeTitle(node);
                  titleRenderer.setText(message, null);
                  titleRenderer.showTextInBold = showTitleTextInBold;
                  if (nodeMessageCode == NodeTitleModel.MESSAGE_NO_ALLOW_DELETE_PEARL) {
                     titleRenderer.messageOnTrashBoxMode = true;
                  }
               }else{
                  titleRenderer.setText(businessNode.title, renderer.senderInfo);
                  titleRenderer.setColor(color);
                  titleRenderer.showTextInBold = showTitleTextInBold;
               }
            }
            
            if (state == STATE_EXCITED || state == STATE_SELECTED_NODE || state == STATE_SELECTED_OVER_NODE) {
               if(overrideNodeTitle){
                  titleRenderer.titleMegaExpanded = true;
                  titleRenderer.titleExpanded = false;
               } else { 
                  titleRenderer.titleMegaExpanded = false;
                  titleRenderer.titleExpanded = true;
               }
            }
            else {
               titleRenderer.titleExpanded = false;
               titleRenderer.titleMegaExpanded = false;
            }
         }
         var isBig:Boolean =  isMouseOverNode(renderer) || isRootOfSelectedNode || isSearchCenter;
         if (!isBig && _interactorManager.draggedPearl != null) {
            isBig = _interactorManager.manipulatedNodesModel.isNodeManipulated(node);
         }
         if (node.vnode == node.vnode.vgraph.currentRootVNode && businessNode.owner) {
            isBig = true;
         } else if (isBig) {
            if (renderer.isNewLabelVisible()) {
               var stage:Stage = renderer.stage;
               _utilPoint.x = stage.mouseX;
               _utilPoint.y = stage.mouseY;
               isBig = renderer.isPointOnPearl(_utilPoint);
            }
         }
         renderer.setBigger(isBig);
         if (isManipulated && state >  STATE_SELECTED_TREE) {
            state =  STATE_SELECTED_TREE;
         }
         
         renderer.setInSelection(true);
         if(excitePearl){
            renderer.excite();
         }else{
            renderer.relax();
         }    

         renderer.pearl.showRings = showRings;
         renderer.setShowHalo(showHalo);   
         
         var isTreeNode:Boolean = (businessNode is BroTreeRefNode || businessNode is BroLocalTreeRefNode || businessNode is BroPTRootNode);
         var isATeam:Boolean = false;
         if (isTreeNode) {
            if (businessNode is BroTreeRefNode && BroTreeRefNode(businessNode).refTree.isAssociationRoot()) {
               isATeam = true;
            } else if (businessNode is BroLocalTreeRefNode && BroLocalTreeRefNode(businessNode).refTree.isAssociationRoot()) {
               isATeam = true;
            } else if (businessNode is BroPTRootNode && BroPTRootNode(businessNode).isAssociationHierarchyRoot()) {
               isATeam = true;
            }
         }
         if (isTreeNode && businessNode.isRefTreePrivate()) {
            renderer.showPadlock(!(state == STATE_ANYTHING_ELSE), isATeam);
         } else {
            renderer.hidePadlock();
         }
      }

      private function excitePearlRendererInternal(renderer:IUIPearl, isExciteSource:Boolean = true):void{
         if (renderer && renderer.vnode as IPTVisualNode) {
            IPTVisualNode(renderer.vnode).isExcited = true;
         }
         updateVisualState(renderer, true, isExciteSource);
      } 
      
      private function relaxPearlRendererInternal(renderer:IUIPearl, isExciteSource:Boolean = true):void{
         if (renderer && renderer.vnode as IPTVisualNode) {
            IPTVisualNode(renderer.vnode).isExcited = false;
         }
         updateVisualState(renderer, false, isExciteSource);
      } 

      public function excitePearlRenderer(renderer:IUIPearl, isPearlUnderCursor:Boolean = false, showButtons:Boolean= true):void{
         excitePearlRendererInternal(renderer);
         if(showButtons && renderer is UIRootPearl){
            UIRootPearl(renderer).setButtonVisible(true);
            var correspondingEndRenderer:IUIPearl = getEndRendererForStartRenderer(renderer);
            excitePearlRendererInternal(correspondingEndRenderer, false);             
         }else if(renderer is EndPearlRenderer){
            var correspondingStartRenderer:UIRootPearl = getStartRendererForEndRenderer(renderer);
            if (correspondingStartRenderer){
               correspondingStartRenderer.exciteCloseButton(); 
            } 
            excitePearlRendererInternal(correspondingStartRenderer, false);
            
         } else if (renderer is IPearlWithButton) {
            IPearlWithButton(renderer).exciteButtons();
         }
      }
      
      public function relaxPearlRenderer(renderer:IUIPearl, wasPearlUnderCursor:Boolean = false):void{
         relaxPearlRendererInternal(renderer); 
         if(renderer is UIRootPearl){
            UIRootPearl(renderer).setButtonVisible(false);
            var correspondingEndRenderer:IUIPearl = getEndRendererForStartRenderer(renderer);
            relaxPearlRendererInternal(correspondingEndRenderer, false);             
         }else if(renderer is EndPearlRenderer){
            var correspondingStartRenderer:UIRootPearl= getStartRendererForEndRenderer(renderer);
            if (correspondingStartRenderer) correspondingStartRenderer.relaxCloseButton();
            relaxPearlRendererInternal(correspondingStartRenderer, false);             
         } else if (renderer is IPearlWithButton) {
            IPearlWithButton(renderer).relaxButtons();
         } 
      }
      public function set highlightAllPearl (value:Boolean):void
      {
         _highlightAllPearl = value;
      }
      
      public function get highlightAllPearl ():Boolean
      {
         return _highlightAllPearl;
      }

   }
}