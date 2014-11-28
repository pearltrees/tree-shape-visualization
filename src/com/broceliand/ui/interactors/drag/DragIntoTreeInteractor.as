package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   import com.broceliand.ui.model.INodeTitleModel;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.view.IUIPearlView;
   import com.broceliand.ui.pearlTree.UnfocusButton;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.GenericAction;
   
   import flash.geom.Point;
   
   public class DragIntoTreeInteractor implements ITreeOpenerRequestor
   {
      private var _isOpeningAsap:Boolean = false;
      private var _closeTreeRef:IPTNode;
      private var _isClosestRefOpened:Boolean;
      private var _isDraggedPearlInDragIntoTreeZone:Boolean;
      private var _testDragIntoTreeAllowed:int;  
      private var _interactorManager:InteractorManager;
      private var _excitePearlManager:ExcitePearlManager
      private var _draggedPearl:IPTNode;
      private var _draggedPearlBusinessNode:BroPTNode;
      private var _treeOpener:InteractiveTreeOpener;
      private var _interactionEnded:Boolean = false;
      private var _unfocusButton:UnfocusButton;
      private var _highlightUnfocusButton:Boolean = false;
      public function DragIntoTreeInteractor(draggedPearl:IPTNode, interactorManager:InteractorManager, treeOpener:InteractiveTreeOpener, excitePearlManager:ExcitePearlManager, unfocusButton:UnfocusButton)
      {
         _excitePearlManager = excitePearlManager;
         _draggedPearl = draggedPearl;
         _interactorManager = interactorManager;
         _treeOpener = treeOpener;
         _unfocusButton = unfocusButton;
         
      }
      public function onClosestNodeChange(newClosestNode:IPTNode):void  {
         
         if (isNodeClosedRootTree(newClosestNode)) {
            _testDragIntoTreeAllowed = _interactorManager.interactorRightsManager.testDragIntoTreeAllowed(_draggedPearl, newClosestNode, _interactorManager.manipulatedNodesModel);
         } else if (isNodeFocusSubTree(newClosestNode))  {
            _testDragIntoTreeAllowed = _interactorManager.interactorRightsManager.testDragIntoParentTreeAllowed(_draggedPearl, newClosestNode, _interactorManager.manipulatedNodesModel);
         } else {
            newClosestNode = null;
         }
         changeClosestNode(_closeTreeRef, newClosestNode);
      } 

      private function isNodeFocusSubTree(node:IPTNode):Boolean {
         if (node != null && node.getBusinessNode() is BroPTRootNode && node.vnode.vgraph.currentRootVNode ==node.vnode) {
            return node.getBusinessNode().owner.treeHierarchyNode.parentTree != null;
         }
         return false;
      }
      private function isNodeClosedRootTree(node:IPTNode):Boolean {
         if (node is PTRootNode && node.getBusinessNode() is BroLocalTreeRefNode) {
            return true;
         } else {
            return false;
         }
         
      }
      public function resetOnScrolling():void {
         if (_closeTreeRef) {
            endExitation(_closeTreeRef);
            changeClosestNode(_closeTreeRef, null);
         }
      }
      public function resetOnEndOfIteraction(endExcitation:Boolean=true):void {
         highlightUnfocusButton(false);
         if (_closeTreeRef && endExcitation) {
            endExitation(_closeTreeRef);
         }
         _interactionEnded = true;
      }
      public function openTreeAsap():void {
         if (shouldImportBranchIntoParentNode()) {
            _isOpeningAsap = true;
            _draggedPearlBusinessNode = _draggedPearl.getBusinessNode();
            _treeOpener.openTreeWithDelay(_closeTreeRef, this, 0);

         }
         
      }
      public function openEmptyTreeAsap():void {
         
         if (shouldImportBranchIntoParentNode()) {
            _isOpeningAsap = true;
            if (_closeTreeRef.getBusinessNode().childLinks.length==0) {
               _treeOpener.openEmptyTreeAsap(_closeTreeRef, this);
            }
            else openTreeAsap();

         }
      }
      
      public function onDraggedPearlMoved():void {
         if (_closeTreeRef && !_closeTreeRef.vnode ) {
            
            _closeTreeRef = null;
         }
         
         if ((isDraggedPearlInDragIntoTreeZone() &&  !isDraggedPearlTooFarToOpenNode())!=_isDraggedPearlInDragIntoTreeZone) {
            _isDraggedPearlInDragIntoTreeZone = !_isDraggedPearlInDragIntoTreeZone;
            
            var allowed:Boolean = (_testDragIntoTreeAllowed == InteractorRightsManager.CODE_OK) || (_testDragIntoTreeAllowed == InteractorRightsManager.CODE_TOO_MANY_IMMEDIATE_DESCENDANTS);
            var nodeTitleModel:INodeTitleModel = _interactorManager.nodeTitleModel;
            if (!allowed) {
               nodeTitleModel.setNodeMessageType(_draggedPearl, _interactorManager.interactorRightsManager.convertCodeToTitleMessageCode(_testDragIntoTreeAllowed, true));
            }
            if (_isDraggedPearlInDragIntoTreeZone) {
               if(allowed){
                  startExitation(_closeTreeRef);
               }
            } else {
               endExitation(_closeTreeRef);
               nodeTitleModel.setNodeMessageType(_draggedPearl, NodeTitleModel.NO_MESSAGE);
            }
         }
      }
      public function isDraggedPearlTooFarToOpenNode():Boolean {
         var rootNode:BroPTRootNode = _closeTreeRef.getBusinessNode() as BroPTRootNode;
         if (rootNode && rootNode.owner.treeHierarchyNode.parentTree !=null) {
            return false;
         }
         var pearl:IUIPearl = _closeTreeRef.pearlVnode.pearlView;
         var dist:Number = BroceliandMath.getSquareDistanceBetweenPoints(_closeTreeRef.vnode.viewCenter, _draggedPearl.vnode.viewCenter);
         var distanceThreshold:Number =  pearl.pearlWidth*.96* pearl.getScale();
         distanceThreshold *= distanceThreshold;
         return (dist >= distanceThreshold);
      }
      
      public function isDraggedPearlInDragIntoTreeZone():Boolean{
         var isUnfocusNode:Boolean = isNodeFocusSubTree(_closeTreeRef);
         if (!isNodeClosedRootTree(_closeTreeRef) && !isUnfocusNode) {
            return false;
         }
         var draggedPearlView:IUIPearl = _draggedPearl.pearlVnode.pearlView;
         var pointToFocusOn:Point;
         if (isUnfocusNode) {
            pointToFocusOn = _unfocusButton.getCenterButton();
         } else {
            pointToFocusOn = _closeTreeRef.vnode.viewCenter;
         }

         var dist:Number = BroceliandMath.getSquareDistanceBetweenPoints(pointToFocusOn, draggedPearlView.pearlCenter);
         
         var distanceThreshold:Number = 0;
         if (isUnfocusNode) {
            
            distanceThreshold = _draggedPearl.pearlVnode.pearlView.pearlWidth * 0.6 * draggedPearlView.getScale();
         } else if ( _closeTreeRef.getBusinessNode().childLinks.length==0 && !(_draggedPearl is PTRootNode)) {
            distanceThreshold = GeometricalConstants.DISTANCE_CREATE_LINK;
         } else {
            distanceThreshold = _closeTreeRef.pearlVnode.pearlView.pearlWidth*.96;
         }
         
         distanceThreshold *= distanceThreshold ;

         return (dist < distanceThreshold);
      }

      private function changeClosestNode(oldRef:IPTNode, newRef:IPTNode):void {
         if (oldRef != null && _isClosestRefOpened) {
            endExitation(oldRef);
         } 
         _closeTreeRef = newRef;

         _isDraggedPearlInDragIntoTreeZone=false;
         onDraggedPearlMoved();
      }
      
      private function startExitation(node:IPTNode):void {
         
         _isClosestRefOpened = true;
         openTreeWithDelay(node);
      }
      
      public function endExitation(node:IPTNode):void {
         if (!node.isEnded()) {
            highlightUnfocusButton(false);
            _excitePearlManager.relaxPearl(node.pearlVnode.pearlView);
         }
         _treeOpener.reset();
         _isClosestRefOpened = false;
      }
      
      public function shouldImportBranchIntoParentNode():Boolean
      {
         return _isClosestRefOpened && _closeTreeRef.getBusinessNode() is BroLocalTreeRefNode;
      }
      public function getClosestRefOpened():IPTNode {
         return _closeTreeRef;
      }
      public function isEmptyLoadedTree():Boolean {
         var tree:BroPearlTree = (_closeTreeRef.getBusinessNode() as BroLocalTreeRefNode).refTree;
         if (tree.isEmpty() && tree.pearlsLoaded) {
            
            if (ApplicationManager.getInstance().visualModel.selectionModel.openingTree != tree) {
               return true;
            }
         }
         return false; 
      }
      
      public function openTreeWithDelay(node:IPTNode):void {
         if (node.renderer) {
            if (isNodeFocusSubTree(_closeTreeRef)) {
               highlightUnfocusButton(true);
            }
            _excitePearlManager.excitePearl(node.renderer, false);
         }
         _treeOpener.openTreeWithDelay(node, this, 500);
      }
      public function isOpeningANewTree():Boolean {
         return _treeOpener.isOpeningANewTree();         
      }
      public function isOpeningTreeNeeded(nodeToOpen:IPTNode):Boolean {
         return !_interactionEnded || _isOpeningAsap;
      }
      public function onOpeningTree(nodeToOpen:IPTNode):void {
         var bnode:BroPTNode = nodeToOpen.getBusinessNode();
         var treeToOpen:BroPearlTree = bnode.owner;
         if (bnode is BroLocalTreeRefNode) {
            treeToOpen = BroLocalTreeRefNode(bnode).refTree;
         }
         if (_isOpeningAsap) {
            var animProcessor:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
            if (animProcessor.isBusy) {
               animProcessor.postActionRequest(new GenericAction(animProcessor, this, selectDraggedNodeAfterTreeIsOpen, nodeToOpen));
            } else {
               selectDraggedNodeAfterTreeIsOpen(nodeToOpen);
            }
            
         } 
         var highlightChanged:Boolean = ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(treeToOpen);
         if (highlightChanged) {
            _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
            IPTVisualGraph(nodeToOpen.vnode.vgraph).refreshNodes();
         }

      }
      
      private function selectDraggedNodeAfterTreeIsOpen(nodeRoot:IPTNode):void {
         var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         var nodes:Array = nodeRoot.getDescendantsAndSelf();
         for each (var n:IPTNode in nodes) {
            if (n.getBusinessNode() == _draggedPearlBusinessNode) {
               _draggedPearl = n;
               break;      
            }
         }
         selectionModel.selectNode(_draggedPearl, -1, true);
      }
      private function highlightUnfocusButton(highlighted:Boolean):void{
         if (_highlightUnfocusButton != highlighted) {
            _highlightUnfocusButton = highlighted;
            if (_highlightUnfocusButton) {
               _unfocusButton.excite();
            } else {
               _unfocusButton.relax();
            }
         }
      }

   }
}

