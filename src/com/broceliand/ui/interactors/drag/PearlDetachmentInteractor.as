package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.util.BroceliandMath;
   
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class PearlDetachmentInteractor extends RemovePearlInteractor
   {
      public static const MIN_INACTIVE_TIME_1:Number = 1000;
      public static const MIN_INACTIVE_TIME_2:Number = 750;
      private var _time:Number;
      private var _pearlDetached:Boolean = false;
      private var _draggedNode:IPTNode;
      private var _mainInteractor:DistantDragEditInteractor;
      private var _hasMoved:Boolean = false;
      private var _nodesDetached:Boolean = false;
      private var _hasTemporaryRestore:Boolean = false;
      private var _isClosing:Boolean = false;
      private var _endNodeDetachmentManager:EndNodeDetachementManager;
      
      public function PearlDetachmentInteractor(draggedVnode:IVisualNode, interactorManager:InteractorManager,  mainInteractor:DistantDragEditInteractor, endNodeDetachmentManager:EndNodeDetachementManager)
      {
         super(interactorManager);
         _time = getTimer();
         _draggedNode = draggedVnode.node as IPTNode;
         _mainInteractor = mainInteractor;
         _endNodeDetachmentManager = endNodeDetachmentManager;
         
         if (_draggedNode.parent && _draggedNode.parent.vnode.isVisible) {
            var timer :Timer = new Timer(MIN_INACTIVE_TIME_1, 1);
            if (false || !isDraggedNodeIsOpenTree()) {

               timer.addEventListener(TimerEvent.TIMER_COMPLETE, tryDetachBranch);
            } else {
               
               timer.addEventListener(TimerEvent.TIMER_COMPLETE, tryDetachPearl);
            }

            timer.start();
         }
         _interactorManager = interactorManager;
         
      }

      public function onMove():void {
         
         if (!_hasMoved) {
            var p:Point = new Point(draggedVNode.view.x,draggedVNode.view.y);
            if (BroceliandMath.getDistanceBetweenPoints(_interactorManager.draggedPearlInitialPosition, p)>3) {
               
               _hasMoved = true;    
            }
         } 
      }
      private function get draggedVNode():IVisualNode {
         if (!_draggedNode.vnode) {
            _draggedNode = _interactorManager.draggedPearl.node;
         }
         return _draggedNode.vnode;
      }
      private function tryDetachBranch(event:TimerEvent=null):void {
         if (!_hasMoved) {
            detachBranch();
            IPTVisualGraph(draggedVNode.vgraph).endNodeVisibilityManager.editMode =true;

         }
      }
      private function tryDetachPearl(event:TimerEvent):void{
         if (!_hasMoved) {
            detachPearlFromTree();
            IPTVisualGraph(draggedVNode.vgraph).endNodeVisibilityManager.editMode =true;
         }
      } 
      public function isDraggedNodeIsOpenTree():Boolean {
         return (_draggedNode is PTRootNode && PTRootNode(_draggedNode).containedPearlTreeModel.openingState == OpeningState.OPEN);
      }
      public function detachPearlFromTree():void {
         _pearlDetached = true;
         _interactorManager.selectInteractor.commitPendingSelection();
         
         detachNodes(); 
         setTemporaryLinksVisible(false);
         if (isDraggedNodeIsOpenTree()) {
            var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
            editionController.closeTreeNode(draggedVNode, 1, false);
            var animationProcess:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
            setTemporaryLinksVisible(false);
            _hasMoved = true;

         }
         _endNodeDetachmentManager.onDetachDraggedPearlFromTree();
      }
      
      public function isClosing():Boolean {
         return _isClosing;
      } 
      public function afterTreeClosed():void{
         
         (_draggedNode as PTRootNode).containedPearlTreeModel.openingState = OpeningState.CLOSED;
         setTemporaryLinksVisible(true);
      }
      private function setTemporaryLinkBackVisible(event:Event):void {
         var animationProcess:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         if (event) {
            _isClosing = false;
            animationProcess.removeEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, setTemporaryLinkBackVisible);
         }
         afterTreeClosed();
         
      }

      public function detachBranch():void {
         
         _interactorManager.selectInteractor.commitPendingSelection();
         _mainInteractor.detachNodeFromParent(draggedVNode, true);
      }
      
      private function detachNodes():void {
         if (!_nodesDetached) {
            
            _nodesDetached = true;
            _mainInteractor.detachNodeFromParent(draggedVNode, false);
            tempRemoveNode(_draggedNode);
            
            _interactorManager.manipulatedNodesModel.updateManipulatedNodesFromDraggedNode(_draggedNode);
         }
      }

      public function onMovingOnNewParent(newParentVNode:IVisualNode) :void{
         if (!_nodesDetached) return;
         if (false && _interactorManager.draggedPearlLogicalOriginParentVNode == newParentVNode) {
            
            if (shouldTemporaryRestoreLink(newParentVNode)) {
               if (!_hasTemporaryRestore) {
                  restoreTemporaryRemoveNode(_draggedNode,false);
                  _hasTemporaryRestore = true;
               } 
            } else {
               if (_hasTemporaryRestore) {
                  tempRemoveNode(_draggedNode);
                  _hasTemporaryRestore = false;
               }
               
            }
         }
      }
      
      private function shouldTemporaryRestoreLink(newParentVNode:IVisualNode):Boolean {
         if (_hasTemporaryRestore) {
            
         }
         return (newParentVNode.viewX > draggedVNode.viewX);
      }
      
      public function onNewTempParent(newParentVNode:IVisualNode):void {
         if (!_nodesDetached) return;
         var shouldRefreshLinks:Boolean = false;
         if (newParentVNode) {
            
            if (false && _interactorManager.draggedPearlLogicalOriginParentVNode == newParentVNode) {
               restoreTemporaryRemoveNode(_draggedNode, false);
               _hasTemporaryRestore = true;
            } else {
               if (_hasTemporaryRestore) {
                  tempRemoveNode(_draggedNode);
                  _hasTemporaryRestore = false;
               }
            }
            
         } else {
            if (_hasTemporaryRestore) {
               tempRemoveNode(_draggedNode);
               _hasTemporaryRestore = false;
            }
            
         }
         if (shouldRefreshLinks) {
            draggedVNode.vgraph.refresh();
         }
      }
      public function isMovingPearl():Boolean {
         return _pearlDetached;
      }
      public function cancelDrag():void {
         _hasMoved = true;
         end();
         if (_nodesDetached) {
            restoreTemporaryRemoveNode(_draggedNode);
         }  
      }
      
      public function commitDrag():BroPearlTree{
         _hasMoved = true;
         end();
         if (_nodesDetached) {
            if (_hasTemporaryRestore) {
               var nextNode:IPTNode = _draggedNode;
               var excludeClosingNode:Boolean =false;
               if (_draggedNode is PTRootNode) {
                  excludeClosingNode = PTRootNode(_draggedNode).containedPearlTreeModel.openingState == OpeningState.CLOSING;
                  nextNode = PTRootNode(_draggedNode).containedPearlTreeModel.endNode;
               }
               var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;        
               for each(var child:IPTNode in nextNode.successors) {
                  if (excludeClosingNode && child.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
                     continue;
                  }
                  editionController.confirmNodeParentLink(child.vnode, true);
               }
               
            } else {
               return confirmRemoveNode();   
            }
         }
         return null;
      }
      
      protected function confirmRemoveNode():BroPearlTree{
         var modifiedTree:BroPearlTree;
         var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
         var detachedChildren:Array = getTemporarilyDetachedBChildren(); 
         if (detachedChildren) {
            var childBNode:BroPTNode;
            var child:IPTNode;

            for (var i:int= 0; i<detachedChildren.length ; i++){
               childBNode = detachedChildren[i];
               child = childBNode.graphNode;
               if (child && child.parent != null) { 
                  editionController.confirmNodeParentLink(child.vnode, true, _currentInsertionIndex);
                  if (modifiedTree ==null) {
                     modifiedTree = child.containingPearlTreeModel.businessTree;
                  }
               }
               else {
                  editionController.linkBusinessNode(_currentTargetNode.getBusinessNode(), childBNode, _currentInsertionIndex);
               }
            }
         }
         return modifiedTree;
      }
      
      public function hasMoved():Boolean {
         return _hasMoved;
      }
      public function end():void {
      }
   }
}