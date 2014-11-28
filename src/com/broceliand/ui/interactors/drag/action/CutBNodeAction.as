package com.broceliand.ui.interactors.drag.action
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.autoReorgarnisation.BusinessTree;
   import com.broceliand.graphLayout.autoReorgarnisation.LayoutReorganizer;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.navBar.NavBarModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.undo.IUndoableAction;
   
   import flash.events.Event;
   
   import mx.effects.Move;
   import mx.effects.Zoom;
   import mx.events.EffectEvent;

   public class CutBNodeAction extends RemoveBNodeActionBase implements IUndoableAction   {
      
      private var _openRootBeingDocked:PTRootNode = null;
      protected var _waitingForAnimationEnds:Boolean = false;
      private var _shouldUpdateSelection:Boolean;
      private var _shouldLayout:Boolean;
      protected var _fromDock:IDeckModel;
      protected var _stayInScreenWindow:Boolean = false;
      
      public function CutBNodeAction(pearltreeViewer:IPearlTreeViewer, ptnode:IPTNode, parentBNode:BroPTNode= null, originalIndex:int = -1, originChildNodes:Array = null) {
         super(pearltreeViewer, ptnode, parentBNode, originalIndex, originChildNodes);
         if (_isValidAction) {
            _shouldLayout = true;
            _shouldUpdateSelection= true;
            _fromDock = _cutNode.getDock();
         }
      }
      
      public function doIt():void  {
         if (_isValidAction) {
            cutNode(_cutNode);
         }   
      }
      
      public function cutNode(node:IPTNode):void  {
         if (_pearltreeViewer.vgraph.currentRootVNode == node.vnode) {
            unfocusAndCutLater(_cutNode)
         } else {
            moveNodeToTargetZone(_cutNode);
         }
      }
      
      public function unfocusAndCutLater(rootNode:IPTNode):void {
         var navModel:INavigationManager= ApplicationManager.getInstance().visualModel.navigationModel;
         var treeToClose:BroPearlTree = rootNode.getBusinessNode().owner;
         var treeToFocusOn:BroPearlTree = treeToClose.treeHierarchyNode.parentTree;
         var user:User= navModel.getSelectedUser();
         var window:int = _stayInScreenWindow ? 2 : -1;
         navModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onFocusingToParent);
         navModel.goTo(treeToFocusOn.getMyAssociation().associationId, 
            user.persistentId,
            treeToFocusOn.id,
            treeToFocusOn.id, 
            treeToFocusOn.getRootNode().persistentID,
            -1,
            window);
      }
      
      private function onFocusingToParent(event:Event):void {
         var navModel:INavigationManager= ApplicationManager.getInstance().visualModel.navigationModel;
         navModel.removeEventListener(NavigationEvent.NAVIGATION_EVENT, onFocusingToParent);
         ApplicationManager.getInstance().visualModel.animationRequestProcessor.addEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, onEndAnimation);
      }
      private function onEndAnimation(event:Event):void {
         ApplicationManager.getInstance().visualModel.animationRequestProcessor.removeEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, onEndAnimation);
         moveNodeToTargetZone(_cutNode);
      }
      private function moveNodeToTargetZone(node:IPTNode):void{
         var bnode:BroPTNode = node.getBusinessNode();
         var btreeToCheck:BroPearlTree = bnode? bnode.owner:null; 
         unlinkRemoveNode(node);                  
         if((node is PTRootNode) && ((node as PTRootNode).isOpen())){
            launchOpenTreeAnimationDisparition(node as PTRootNode);              
         }else{
            moveNotOpenRootToTargetZone(node);
         }
         attachChildNodesToParent();
         
         sendNodeToDestination(node);
         
         changePearlInBusinessModel(node);
         if (shouldUpdateSelection) {
            updateSelection(_cutNode);
         }
         _pearltreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
         if (btreeToCheck) {
            new LayoutReorganizer().checkCurrentLayout(new BusinessTree(btreeToCheck));
         }
         
         if (shouldLayout) {
            _pearltreeViewer.vgraph.layouter.layoutPass();
         }
         NavBarModel.refreshNavbar();
         
      }     
      public function getOpposite():IUndoableAction {
         return null;
      }
      public function canUndo():Boolean {
         return false;
      }
      protected function closeTreeOnDescendantNodesDisappeared(event:EffectEvent = null):void{
         _pearltreeViewer.pearlTreeEditionController.closeTreeNode(_openRootBeingDocked.vnode, -1);
         if (_waitingForAnimationEnds) {
            onActionCompleted();  
         }
      }
      protected function changePearlInBusinessModel(node:IPTNode):void {
         _pearltreeViewer.pearlTreeEditionController.addNodeToDropZone(node);
      }
      
      protected function sendNodeToDestination(node:IPTNode):void {
         if (!_waitingForAnimationEnds) {
            node.dock(_pearltreeViewer.vgraph.controls.dropZoneDeckModel);
         } 
      } 
      
      protected function attachChildNodesToParent():void {
         
         super.updateGraphWhenRemovingNode(_cutNode);
         
      }
      
      protected function moveEffect(renderer:IUIPearl, x:Number, y:Number, duration:int):Move {
         var move:Move = new Move(renderer);
         move.xTo = x;
         move.yTo = y;
         move.duration = duration;
         return move;
      }
      
      protected function disappearEffect(renderer:IUIPearl, duration:int):Zoom {
         var zoom:Zoom = new Zoom(renderer.uiComponent);
         zoom.zoomHeightFrom = 1;
         zoom.zoomHeightTo = 0;
         zoom.zoomWidthFrom = 1;
         zoom.zoomWidthTo = 0;
         zoom.duration = duration;
         return zoom;
         
      }
      
      private function launchOpenTreeAnimationDisparition(rootNode:PTRootNode):void{
         
         _openRootBeingDocked = rootNode;
         const DISAPPEAR_DURATION:int = 450; 
         var move:Move = null;
         var zoom:Zoom = null;
         
         for each(var descendantNode:IPTNode in rootNode.getDescendantsAndSelf()){
            if(descendantNode == rootNode){
               continue;
            }
            
            (descendantNode.edgeToParent.data as EdgeData).visible = false;
            
            if (descendantNode.renderer) { 
               if (!descendantNode.renderer.isEnded()) {
                  
                  descendantNode.renderer.pearl.showRings = false;
                  descendantNode.renderer.pearl.markAsDisappearing = true;
               }
               move = moveEffect(descendantNode.renderer, rootNode.renderer.x, rootNode.renderer.y, DISAPPEAR_DURATION);
               if (move) {
                  move.play();
               }
               zoom= disappearEffect(descendantNode.renderer,DISAPPEAR_DURATION);
               if (zoom) {
                  
                  zoom.play();
                  
               }
            }
         }
         _pearltreeViewer.vgraph.refresh();
         if(zoom){
            _waitingForAnimationEnds = true;
            zoom.addEventListener(EffectEvent.EFFECT_END, closeTreeOnDescendantNodesDisappeared);
         }else{
            closeTreeOnDescendantNodesDisappeared();
         }
      }
      
      private function moveNotOpenRootToTargetZone(node:IPTNode):void{
         var editionController:IPearlTreeEditionController = _pearltreeViewer.pearlTreeEditionController;   
         var excludeClosingNode:Boolean = false;
         if (_cutNode is PTRootNode ){ 
            excludeClosingNode = PTRootNode(_cutNode).containedPearlTreeModel.openingState == OpeningState.CLOSING;
         }
         for each(var child:BroPTNode in getOriginChildNodes()){
            if (child.graphNode) {
               if (excludeClosingNode && child.graphNode.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
                  continue;
               }   
               editionController.confirmNodeParentLink(child.graphNode.vnode, true);
            } else {
               editionController.linkBusinessNode(_parentBNode, child);
            }
         }
         if(node.parent && node.parent.vnode){
            editionController.tempUnlinkNodes(node.parent.vnode, node.vnode);
         }
      }
      protected function updateSelection(node:IPTNode):void {
         ApplicationManager.getInstance().components.windowController.displayNodeInfo(node);
         var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         if (selectionModel.getSelectedNode() != node) {
            selectionModel.selectNode(node);
         }
      }
      public function set shouldUpdateSelection (value:Boolean):void
      {
         _shouldUpdateSelection = value;
      }
      
      public function get shouldUpdateSelection ():Boolean
      {
         return _shouldUpdateSelection;
      }
      
      public function set shouldLayout (value:Boolean):void
      {
         _shouldLayout = value;
      }
      
      public function get shouldLayout ():Boolean
      {
         return _shouldLayout;
      }
      
      protected function onActionCompleted():void {
         _waitingForAnimationEnds = false;
         sendNodeToDestination(_cutNode);
      }
      
   }
}