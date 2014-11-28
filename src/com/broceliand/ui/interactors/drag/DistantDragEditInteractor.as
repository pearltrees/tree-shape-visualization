package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.autoReorgarnisation.BusinessTree;
   import com.broceliand.graphLayout.autoReorgarnisation.BusinessTreeLayoutChecker;
   import com.broceliand.graphLayout.autoReorgarnisation.LayoutReorganizer;
   import com.broceliand.graphLayout.controller.CloseBranchAnimation;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.controller.LayoutAction;
   import com.broceliand.graphLayout.layout.UpdateTitleRendererLayout;
   import com.broceliand.graphLayout.model.EditedGraphVisualModification;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.SavedPearlReference;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.io.loader.SessionHelper;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.NeighbourPearlTree;
   import com.broceliand.pearlTree.model.team.TeamRightManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   import com.broceliand.ui.interactors.InteractorUtils;
   import com.broceliand.ui.interactors.ThrownPearlPositionner;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.model.ScrollModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.ui.pearlTree.UnfocusButton;
   import com.broceliand.ui.window.ui.signUpBanner.SignUpBanner;
   import com.broceliand.util.BroUtilFunction;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;
   
   public class DistantDragEditInteractor extends DragEditInteractorBase
   {
      
      private static const ZONE_BEYOND_LINKING_DISTANCE:int = 0;
      private static const ZONE_CAN_LINK_BUT_NOT_SHOW_FEEDBACK:int = 1;
      private static const ZONE_CAN_LINK_AND_SHOW_FEEDBACK:int = 2;
      private static const ZONE_CAN_DRAG_INTO_TREE:int = 3;
      private static const ZONE_TOO_FAR_TO_DRAG_IN_TREE:int = 4;
      
      public static var MARK_NODE_EDITED:Boolean = true;
      private var _vgraph:IPTVisualGraph;
      private var _excitePearlManager:ExcitePearlManager=null;

      private var _pearlDetachmentInteractor:PearlDetachmentInteractor=null;
      private var _draggingOnStringInteractor:DraggingOnStringInteractor=null;
      private var _dragIntoTreeInteractor:DragIntoTreeInteractor = null;
      private var _draggingOnArcState:DraggingOnArcState=null;
      private var _emptyTreeOpener:EmptyTreeOpenerInteractor=null
      private var _endNodeDetachementManager:EndNodeDetachementManager;
      private var _dropZoneInteractor:DropZoneInteractor = null;
      private var _detachedBranchManager:CloseBranchAnimation;
      private var _businessTreeChecker:BusinessTreeLayoutChecker;

      private var _startDistanceToRoot:Number;
      private var _nearestNode:IPTNode = null;
      private var _isHome:Boolean= true;
      private var _shouldDetachPearlOnDetachment:Boolean = false;
      private var _nodeZone:int = ZONE_BEYOND_LINKING_DISTANCE;
      private var _dragEnded:Boolean = false;
      private var _hasNodeMsg:Boolean = false;
      private var _isScrolling:Boolean = false;
      private var _loopCount:int = 10;
      private var _endAction:IAction = null;
      
      private var _isAnonymous:Boolean = false;

      static internal var Logger:BroLogger= Log.getLogger("com.broceliand.ui.interactors.drag.DistantDragEditInteractor");
      
      public function DistantDragEditInteractor(interactorManager:InteractorManager, isHome:Boolean, isAnoynmous:Boolean = false){
         super(interactorManager);
         _isHome = isHome;
         _dropZoneInteractor = new DropZoneInteractor(interactorManager);
         _excitePearlManager = new ExcitePearlManager(interactorManager.pearlTreeViewer.pearlRendererStateManager);
         _vgraph = interactorManager.pearlTreeViewer.vgraph;
         _isAnonymous = isAnoynmous;
      }

      internal function detachNodeFromParent(vn:IVisualNode, updateManipulatedNodes:Boolean = true):void {
         var shouldLayout:Boolean= false;

         var animProcessor:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         if (!_interactorManager.draggedPearlIsDetached) {
            _interactorManager.draggedPearlIsDetached = true;
            
            if (_draggingOnArcState) {
               _draggingOnArcState.restoreNodePositions();
               _draggingOnArcState = null;
            }
            if (_dragIntoTreeInteractor == null) {
               var draggedPearl:IPTNode=  _interactorManager.draggedPearl.node as IPTNode;
               
               var treeOpener:InteractiveTreeOpener = new InteractiveTreeOpener(draggedPearl, _interactorManager);
               var unfocusButton:UnfocusButton = ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.controls.unfocusButton;
               _dragIntoTreeInteractor = new DragIntoTreeInteractor(draggedPearl, _interactorManager, treeOpener, _excitePearlManager, unfocusButton);
               _emptyTreeOpener = new EmptyTreeOpenerInteractor(draggedPearl as IPTNode, _interactorManager, treeOpener);
            }
            endDraggingOnString();
            var vgraph:IPTVisualGraph = _interactorManager.pearlTreeViewer.vgraph;
            var vgraphModif:EditedGraphVisualModification=vgraph.getEditedGraphVisualModification(); 
            var parentNode:IPTNode= vn.node.predecessors[0] as IPTNode; 
            
            if(parentNode){
               _interactorManager.setDraggedPearlOriginalParentNode(parentNode);
               _interactorManager.draggedPearlOriginalParentIndex = parentNode.successors.lastIndexOf(_interactorManager.draggedPearl.node);
               if (shouldLayout) {
                  if( _interactorManager.draggedPearlOriginalParentVNode){
                     _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes( _interactorManager.draggedPearlOriginalParentVNode, vn);
                  }
                  animProcessor.postActionRequest(new LayoutAction(_interactorManager.pearlTreeViewer.vgraph, false), 400);
                  _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempLinkNodes( _interactorManager.draggedPearlOriginalParentVNode, vn);
               }
               vgraphModif.draggedNodeDetached(parentNode.vnode, _interactorManager.draggedPearl.vnode, _interactorManager.draggedPearlOriginalParentIndex);
            } else {
               _interactorManager.setDraggedPearlOriginalParentNode(null);
               vgraphModif.draggedNodeDetached(null, _interactorManager.draggedPearl.vnode, 0);
            }
            _endNodeDetachementManager.startDraggingPearl(vn);
            if(_interactorManager.draggedPearlOriginalParentVNode){
               _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes( _interactorManager.draggedPearlOriginalParentVNode, vn);
            }
            if(updateManipulatedNodes){
               var draggedNode:IPTNode = vn.node as IPTNode;
               _detachedBranchManager.startAnimation(vgraph, draggedNode, _interactorManager.depthInteractor);
               _interactorManager.manipulatedNodesModel.updateManipulatedNodesFromDraggedNode(draggedNode);
            }
            
         }
      }

      private function handleNodeDetachment(vn:IVisualNode):void{
         var distanceToRoot:Number = BroceliandMath.getDistanceBetweenPoints(vn.vgraph.currentRootVNode.viewCenter, vn.viewCenter);
         var shouldDetachPearl:Boolean = false;
         if(distanceToRoot > _startDistanceToRoot + GeometricalConstants.DISTANCE_BREAK_LINK ){
            shouldDetachPearl = true;
         } else {
            if (_draggingOnArcState) {
               shouldDetachPearl = _draggingOnArcState.shouldNodeBeDetached(vn);
            } 
         }
         if (shouldDetachPearl) {
            if (_pearlDetachmentInteractor.isMovingPearl()) {
               detachNodeFromParent(vn); 
            } else {
               if (_shouldDetachPearlOnDetachment) { 
                  _pearlDetachmentInteractor.detachPearlFromTree();
               } else if (!_dragEnded) {
                  _pearlDetachmentInteractor.detachBranch();
               }        
            }
         }
      }

      private function handleTrashWarning(ev:MouseEvent):Boolean{
         var renderer:IUIPearl = _interactorManager.draggedPearl;

         if (isPrivatePearlForExpiredPremium(renderer.node)) {
            return false;
         }
         var cursorOnTrash:Boolean = _interactorManager.pearlTreeViewer.vgraph.controls.isPointOverTrash(new Point(ev.stageX, ev.stageY));
         if(cursorOnTrash != _interactorManager.draggedPearlOverTrash){
            _interactorManager.draggedPearlOverTrash = cursorOnTrash;
            var vnodesToUpdate:Array = InteractorUtils.getDescendantsAndVNode(renderer.vnode);
            
            for each(var vn:IVisualNode in vnodesToUpdate){
               if(cursorOnTrash && vn.view){
                  (vn.view as IUIPearl).pearl.blacken();
               }else{
                  if (vn.view) {
                     (vn.view as IUIPearl).pearl.unblacken();
                  }
               }
            }
         }
         return cursorOnTrash;
      }
      private function unblackenPearlsDragged() :void {
         var renderer:IUIPearl = _interactorManager.draggedPearl;
         var vnodesToUpdate:Array = InteractorUtils.getDescendantsAndVNode(renderer.vnode);
         
         for each(var vn:IVisualNode in vnodesToUpdate){
            (vn.view as IUIPearl).pearl.unblacken();
         }
      }

      private function changeParentVisualNode(previousParentVNode:IVisualNode, newParentVNode:IVisualNode, targetVNode:IVisualNode, index:int = 0, exciteNewParent:Boolean = false):void{
         if(previousParentVNode){
            var previousParentRenderer:IUIPearl = previousParentVNode.view as IUIPearl;
            _excitePearlManager.relaxPearl(previousParentRenderer);
            _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes(previousParentVNode, targetVNode);
            if (!newParentVNode) {
               _pearlDetachmentInteractor.onNewTempParent(null);
               _pearlDetachmentInteractor.setTemporaryLinksVisible(false);
            }  
         }
         if(newParentVNode){
            var newParentRenderer:IUIPearl = newParentVNode.view as IUIPearl;
            if(exciteNewParent){
               
               if (!_dragEnded && !(newParentVNode.node is EndNode)){
                  _excitePearlManager.excitePearl(newParentRenderer, false);
               }
            }
            var newParentRootNode:PTRootNode= newParentVNode.node as PTRootNode; 
            var isLastNode:Boolean = newParentRootNode && (true || newParentRootNode.successors.length==0  || !IPTNode(newParentRootNode.successors[0]).vnode.isVisible); 

            var sm:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
            var highlightChange:Boolean = false;
            if (newParentRootNode && newParentRootNode.isOpen()) {
               highlightChange = sm.highlightTree(newParentRootNode.containedPearlTreeModel.businessTree);
            } else if(newParentRenderer.node.containingPearlTreeModel && newParentRenderer.node.containingPearlTreeModel.rootNode.getBusinessNode()) {
               highlightChange = sm.highlightTree(newParentRenderer.node.containingPearlTreeModel.businessTree);
            }
            _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempLinkNodes(newParentVNode, targetVNode, index);
            _pearlDetachmentInteractor.setTemporaryLinksVisible(true);
            _pearlDetachmentInteractor.onNewTempParent(newParentVNode);
            if (highlightChange) {
               IPTVisualGraph(newParentRenderer.vnode.vgraph).refreshNodes();
               _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
            }
         }
      }

      private function linkToOriginalParent(parentNodeRef:SavedPearlReference, n:IVisualNode):void{
         var parentNode:IPTNode = null;
         if (parentNodeRef) {
            parentNode = parentNodeRef.getNode(true);
         }
         if (!parentNode || parentNode.isDisappearing || parentNode.vnode.view.alpha<1 || !parentNode.vnode.isVisible) {
            Logger.debug("Link to original parent, with no parent node visible");
            var rootNode:IPTNode = _vgraph.currentRootVNode.node as IPTNode;
            if (_dragIntoTreeInteractor.shouldImportBranchIntoParentNode()) {
               rootNode = _dragIntoTreeInteractor.getClosestRefOpened();
               Logger.debug("ImporLink to original parent, with no parent node visible");
               
            }
            var  tree:BroPearlTree= (rootNode as PTRootNode).containedPearlTreeModel.businessTree;
            var parentBNode:BroPTNode = ThrownPearlPositionner.findBestPositionInTree(tree, (n.node as IPTNode).getBusinessNode());
            Logger.debug("Best position parent : {0}", parentBNode.title);
            
            if (parentBNode && parentBNode.graphNode) {
               parentNode = parentBNode.graphNode;
            } else {
               Logger.debug("No graph node -> parent null");
               parentNode = null;
            }
            _interactorManager.draggedPearlOriginalParentIndex =0;
         } 
         if (!parentNode || parentNode.isDisappearing || parentNode.vnode.view.alpha<1 || !parentNode.vnode.isVisible) {
            
            Logger.debug("New parent still not visible, wait for animation ends try count : {0}", _loopCount);
            
            if (_loopCount --< 0) {
               _interactorManager.manipulatedNodesModel.flush();
               _dropZoneInteractor.moveBranchToDropZone(n.node as IPTNode);
            }  else {
               
               var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
               var ga:GenericAction = new GenericAction(garp, this, linkToOriginalParent, null, n);
               ga.addInQueue();
            }
            return;
         }

         if (parentNode) {

            var draggedBNode:BroPTNode = IPTNode(n.node).getBusinessNode();
            if (draggedBNode is BroPTRootNode) {
               draggedBNode = draggedBNode.owner.refInParent; 
            }
            Logger.debug("will change parent {0} at index {1}", 
               parentNode.name, _interactorManager.draggedPearlOriginalParentIndex) ;
            
            changeParentVisualNode(null , parentNode.vnode, n, _interactorManager.draggedPearlOriginalParentIndex, false);
            _interactorManager.pearlTreeViewer.pearlTreeEditionController.confirmNodeParentLink(n, true, _interactorManager.draggedPearlOriginalParentIndex);
            
         }
      }

      private function computeLinkFinalIndex(parent:INode, child:INode):int {
         
         parent.vnode.refresh();
         
         var parentPoint:Point = new Point(-parent.vnode.x ,   parent.vnode.y);
         var index:int=0; 
         var childIndex:int= -1; 
         
         if (parent.successors.length>1) {
            var parentAngle:Number =0;
            if (parent.predecessors[0] != null && parent.predecessors[0].vnode.isVisible) {
               var gpVnode:IVisualNode = parent.predecessors[0].vnode;
               gpVnode.refresh(); 
               
               parentAngle = Geometry.polarAngle(new Point(parent.vnode.x- gpVnode.x, -parent.vnode.y + gpVnode.y));
               if (parentAngle > Math.PI) parentAngle-= 2*Math.PI;
            } 
            var childPoint:Point = parentPoint.clone();
            child.vnode.refresh();
            childPoint.offset(child.vnode.x, - child.vnode.y);

            var childAngle:Number = Geometry.polarAngle(childPoint);
            if (childAngle>Math.PI+parentAngle) childAngle -= 2 * Math.PI;
            var successors:Array = parent.successors;

            for each (var node:INode in successors) {
               if (node == child) { 
                  childIndex = index;
                  index++;
                  continue;  
               }
               childPoint = parentPoint.clone();
               node.vnode.refresh();
               
               childPoint.offset(node.vnode.x,  - node.vnode.y);

               var currentAngle :Number= Geometry.polarAngle(childPoint);

               if (currentAngle>Math.PI+parentAngle) {
                  currentAngle -= 2 * Math.PI;
                  
               }  
               
               if (currentAngle<childAngle) {
                  if (childIndex>=0) {
                     index--; 
                  }
                  break;
               }
               index++;
            }

            if (childIndex != -1 && index == successors.length) {
               index = successors.length -1;
            }
         }
         
         if (childIndex== index) return -childIndex;
         return index;
         
      }

      override public function dragBegin(ev:MouseEvent):void{
         ApplicationManager.getInstance().sessionHelper.notifyPearlCreationEvent(SessionHelper.DRAG_PEARL);
         suscribeToScrollModel(true);
         super.dragBegin(ev);
         
         _dragEnded=false;
         if(!_interactorManager.pearlRendererUnderCursor){
            return;
         }
         _vgraph.dragNodeBegin(_interactorManager.pearlRendererUnderCursor.uiComponent, ev);
         _businessTreeChecker = new BusinessTreeLayoutChecker();
         
         var vgraphModification:EditedGraphVisualModification = _interactorManager.pearlTreeViewer.vgraph.getEditedGraphVisualModification();
         vgraphModification.startEditingGraph();
         _endNodeDetachementManager = new EndNodeDetachementManager(_interactorManager.pearlTreeViewer.pearlTreeEditionController, vgraphModification);
         
         var renderer:IUIPearl = _interactorManager.draggedPearl;
         _interactorManager.trashInteractor.isPearlDragged = !_isAnonymous || renderer.node.isDocked; 
         _detachedBranchManager = new CloseBranchAnimation(renderer.node, _interactorManager.pearlTreeViewer.pearlTreeEditionController);
         
         renderer.pearl.moveRingInPearl();
         var parentNode:IPTNode = renderer.node.predecessors[0] as IPTNode;

         _interactorManager.manipulatedNodesModel.updateManipulatedNodesFromDraggedNode(renderer.node, false);
         
         _pearlDetachmentInteractor = new PearlDetachmentInteractor(renderer.vnode, _interactorManager, this, _endNodeDetachementManager);
         
         var rootCenter:Point = renderer.vnode.vgraph.currentRootVNode.viewCenter;
         _startDistanceToRoot = BroceliandMath.getDistanceBetweenPoints(rootCenter, renderer.vnode.viewCenter);
         if (IPTNode(renderer.vnode.node).isDocked) _startDistanceToRoot = 0;
         if(parentNode && parentNode.vnode.isVisible) {
            
            _interactorManager.draggedPearlOriginalParentIndex = parentNode.successors.lastIndexOf(renderer.vnode.node);
            _interactorManager.setDraggedPearlOriginalParentNode(parentNode);
            
            if (renderer.vnode.node.successors.length<2 ) {
               if (!(renderer.vnode.node is  PTRootNode && PTRootNode(renderer.vnode.node).isOpen())) {
                  _draggingOnStringInteractor = new DraggingOnStringInteractor(renderer.vnode, _interactorManager.pearlTreeViewer.pearlTreeEditionController , _interactorManager.interactorRightsManager);
               }
            }
         }
         if(renderer.node.parent && renderer.node.parent.vnode.isVisible){
            _draggingOnArcState = new DraggingOnArcState(renderer.vnode, _endNodeDetachementManager, _detachedBranchManager, _interactorManager.depthInteractor);
         }
         _interactorManager.draggedPearlInitialPosition = new Point(renderer.x, renderer.y);
         var bnode:BroPTNode = renderer.node.getBusinessNode();
         if (!ApplicationManager.getInstance().currentUser.isAnonymous() && bnode.owner.isInATeam()) {
            TeamRightManager.buildValidDestinationTrees(bnode);
         }
      }
      
      private function isPrivatePearlForExpiredPremium(node:IPTNode):Boolean {
         return node.getBusinessNode().owner && node.getBusinessNode().owner.isPrivatePearltreeOfCurrentUserNotPremium();
      } 
      
      private function manageNormalLinkOnDrag(ev:Event):void{

         var renderer:IUIPearl = _interactorManager.draggedPearl;
         var node:IPTNode = renderer.node;
         if (isPrivatePearlForExpiredPremium(node)) {
            _interactorManager.nodeTitleModel.setNodeMessageType(node, NodeTitleModel.MESSAGE_PRIVATE_EXPIRED_PREMIUM);
            return;
         }
         
         var vnode: IVisualNode = renderer.vnode;
         var newNearestNode:IPTNode = InteractorUtils.getNearestNode(renderer.node,-1);
         var zoomFactor:Number = vnode.vgraph.scale;
         if (zoomFactor < 1) {
            zoomFactor = 1;
         }
         var squareZoomFactor:Number  = zoomFactor * zoomFactor; 
         
         if (newNearestNode){
            var distanceToNode:Number =  BroceliandMath.getSquareDistanceBetweenPoints(newNearestNode.pearlVnode.viewCenter, renderer.pearlCenter);
            var currentRoot:IVisualNode = newNearestNode.vnode.vgraph.currentRootVNode;
            if (newNearestNode.parent) {

               var distanceToRoot:Number = BroceliandMath.getSquareDistanceBetweenPoints(currentRoot.viewCenter, node.vnode.viewCenter);
               var distanceofNearestToRoot:Number =  BroceliandMath.getSquareDistanceBetweenPoints(currentRoot.viewCenter, newNearestNode.vnode.viewCenter);
               if ((distanceToRoot + 100)< distanceofNearestToRoot) {
                  newNearestNode = newNearestNode.parent;
                  if (newNearestNode == node) {
                     newNearestNode = newNearestNode.parent;
                  }
               }
            }
            if (distanceToNode > GeometricalConstants.DISTANCE_CREATE_LINK * GeometricalConstants.DISTANCE_CREATE_LINK * squareZoomFactor) {
               if (newNearestNode != currentRoot.node ) {
                  newNearestNode = null;
               }else if (newNearestNode.getBusinessNode().getChildCount()<4) {
                  newNearestNode = null;
               } else {
                  var i:int =0;
                  while (newNearestNode.getBusinessNode().getChildAt(i++).graphNode == node);
                  var newNearestChildPTNode:IPTNode = newNearestNode.getBusinessNode().getChildAt(i-1).graphNode;
                  if (newNearestChildPTNode) {
                     var distanceChild:Number = BroceliandMath.getSquareDistanceBetweenPoints(currentRoot.viewCenter, newNearestChildPTNode.vnode.viewCenter);
                     if (distanceChild < distanceToNode) {
                        newNearestNode = null;
                     }
                  } else {
                     newNearestNode = null;                  
                  }
               }
            }
         }
         
         var newNodeZone:int = ZONE_BEYOND_LINKING_DISTANCE;
         
         var oldNearestVNode:IVisualNode = null;
         
         if(_nearestNode){
            oldNearestVNode = _nearestNode.vnode;
         }
         if (node.parent) {
            oldNearestVNode = node.parent.vnode;
         }
         var newNearestVNode:IVisualNode = null;
         if(newNearestNode){
            newNearestVNode = newNearestNode.vnode;
         }
         _dragIntoTreeInteractor.onDraggedPearlMoved();
         
         var rightsManager:InteractorRightsManager = _interactorManager.interactorRightsManager;
         var vgraphModif:EditedGraphVisualModification  = _interactorManager.pearlTreeViewer.vgraph.getEditedGraphVisualModification();
         if (newNearestNode is EndNode && !EndNode(newNearestNode).canBeVisible && newNearestNode.vnode.view.alpha == 0) {
            newNearestNode = null;
         }   
         if  (_dragIntoTreeInteractor && _dragIntoTreeInteractor.isOpeningANewTree() ) {
            if (_dragEnded) {
               
               if (newNearestNode) {   
                  if (newNearestNode.containingPearlTreeModel.openingState == OpeningState.CLOSING) {
                     return;
                  }
                  if (newNearestNode.containingPearlTreeModel.openingState == OpeningState.OPENING) {
                     
                     newNearestNode = newNearestNode.containingPearlTreeModel.rootNode;
                     var distance:Number = BroceliandMath.getSquareDistanceBetweenPoints(renderer.pearlCenter, newNearestNode.vnode.viewCenter);
                     if (distance > GeometricalConstants.DISTANCE_CREATE_LINK * GeometricalConstants.DISTANCE_CREATE_LINK * squareZoomFactor) {
                        return;
                     }
                  }  
               }
            } else {
               if (node.parent) {
                  distance = BroceliandMath.getSquareDistanceBetweenPoints(renderer.pearlCenter, oldNearestVNode.viewCenter);
                  if (distance > 2.25 * GeometricalConstants.DISTANCE_CREATE_LINK * GeometricalConstants.DISTANCE_CREATE_LINK * squareZoomFactor) {
                     changeParentVisualNode(node.parent.vnode, null, vnode);
                     vgraphModif.tempParentDraggedNodeChanged(null);
                     _endNodeDetachementManager.onChangingTarget(null, vnode);
                  }    
               }
               return;
            }               
         }
         if(newNearestNode != _nearestNode){

            _dragIntoTreeInteractor.onClosestNodeChange(newNearestNode);
         }

         if(newNearestNode){
            
            newNodeZone = ZONE_CAN_LINK_AND_SHOW_FEEDBACK;
            var squareDistanceBetweenDraggedAndNearest:Number = BroceliandMath.getSquareDistanceBetweenPoints(vnode.viewCenter, newNearestNode.vnode.viewCenter); 
            if(squareDistanceBetweenDraggedAndNearest < GeometricalConstants.SQUARE_DISTANCE_SHOW_FORDIBBEN_SIGN * squareZoomFactor){    
               newNodeZone = ZONE_CAN_LINK_AND_SHOW_FEEDBACK;              
            }
            if(_dragIntoTreeInteractor.isDraggedPearlInDragIntoTreeZone()){
               if (_dragIntoTreeInteractor.isDraggedPearlTooFarToOpenNode()) {
                  newNodeZone =  ZONE_TOO_FAR_TO_DRAG_IN_TREE;
               } else {
                  newNodeZone = ZONE_CAN_DRAG_INTO_TREE;
               }
            }
         }

         var shouldUpdate:Boolean = (newNearestNode != _nearestNode) || (newNodeZone != _nodeZone) || _dragEnded;
         if(shouldUpdate){
            var shouldBeLinkedWithNearest:Boolean = false;
            var testLinkValue:int = InteractorRightsManager.CODE_OK;
            if(newNodeZone == ZONE_BEYOND_LINKING_DISTANCE){
               _interactorManager.nodeTitleModel.setNodeMessageType(node, NodeTitleModel.NO_MESSAGE);
            }else if((newNodeZone == ZONE_CAN_LINK_BUT_NOT_SHOW_FEEDBACK) || (newNodeZone == ZONE_CAN_LINK_AND_SHOW_FEEDBACK)){
               testLinkValue = testLinkAllowed(node, newNearestNode);  
               shouldBeLinkedWithNearest = (testLinkValue == InteractorRightsManager.CODE_OK);
               if(!shouldBeLinkedWithNearest){
                  if(newNodeZone == ZONE_CAN_LINK_AND_SHOW_FEEDBACK){
                     
                     _interactorManager.nodeTitleModel.setNodeMessageType(node, rightsManager.convertCodeToTitleMessageCode(testLinkValue, false));
                  } 
               } else {
                  _interactorManager.nodeTitleModel.setNodeMessageType(node, NodeTitleModel.NO_MESSAGE);
               } 
            } else {
               testLinkValue = testLinkAllowed(node, newNearestNode);  
               if (testLinkValue == InteractorRightsManager.CODE_OK){
                  if (newNodeZone == ZONE_TOO_FAR_TO_DRAG_IN_TREE) {
                     shouldBeLinkedWithNearest = false;
                  } else {
                     shouldBeLinkedWithNearest = true;
                  }
               }
            }
            if(shouldBeLinkedWithNearest){
               
               if (newNearestNode && node.parent == null) {
                  oldNearestVNode = null;
               }
               if(oldNearestVNode != newNearestVNode ){   
                  changeParentVisualNode(oldNearestVNode, newNearestVNode, vnode, 0, true);
                  vgraphModif.tempParentDraggedNodeChanged(newNearestVNode);
                  _endNodeDetachementManager.onChangingTarget(newNearestVNode, vnode);
               } 
            } else {
               if(node.parent){
                  changeParentVisualNode(node.parent.vnode, null, vnode);
                  vgraphModif.tempParentDraggedNodeChanged(null);
                  _endNodeDetachementManager.onChangingTarget(null, vnode);
               }
            }
            _nearestNode = newNearestNode;
            _nodeZone = newNodeZone;   
         }
         if (newNearestNode && node.parent == newNearestNode) {
            _endNodeDetachementManager.onMovingOnNewParent(newNearestVNode, vnode);
            _pearlDetachmentInteractor.onMovingOnNewParent(newNearestVNode);
         }
      }

      private function endDraggingOnString():Boolean {
         if (_draggingOnStringInteractor !=null) {
            _shouldDetachPearlOnDetachment = _draggingOnStringInteractor.hasSwapped;
            _draggingOnStringInteractor=null;
            return _shouldDetachPearlOnDetachment;
         }
         return false
      }
      private function handleDetachedDrag(ev:MouseEvent):void{
         _dropZoneInteractor.handleDragForDropZone(ev);
         
         if (_hasNodeMsg) {
            _hasNodeMsg = false;
            _interactorManager.nodeTitleModel.setNodeMessageType(_interactorManager.draggedPearl.node, NodeTitleModel.NO_MESSAGE);
         }
         if (_dropZoneInteractor.isMouseOverDropZone(ev)) {
            var bnode:BroPTNode = _interactorManager.draggedPearl.node.getBusinessNode();
            if (_interactorManager.movePearlOutsideFromTeam()) {
               _interactorManager.nodeTitleModel.setNodeMessageType(_interactorManager.draggedPearl.node, NodeTitleModel.MESSAGE_NO_MOVE_PEARL_OUTSIDE_TEAM);
               _hasNodeMsg = true;
            }
            else if (_interactorManager.manipulatedNodesModel.containsSubAssociations && !(_interactorManager.draggedPearl.node.getBusinessNode() is BroDistantTreeRefNode)) {
               _interactorManager.nodeTitleModel.setNodeMessageType(_interactorManager.draggedPearl.node, NodeTitleModel.MESSAGE_NO_TEAM_IN_DROPZONE);
               _hasNodeMsg = true;
            } else {
               _interactorManager.pearlTreeViewer.vgraph.controls.dropZoneDeckModel.highlight();
            }
         }
         else {
            if (_isHome || _isAnonymous) {
               manageNormalLinkOnDrag(ev); 
            }
            if (_interactorManager.noFounderDeletePearlFromTeam() && _interactorManager.pearlTreeViewer.vgraph.controls.isPointOverTrash(new Point(ev.stageX, ev.stageY))) {
               _interactorManager.nodeTitleModel.setNodeMessageType(_interactorManager.draggedPearl.node, NodeTitleModel.MESSAGE_NO_ALLOW_DELETE_PEARL);
               _hasNodeMsg = true;
            }
            handleTrashWarning(ev);  
            _interactorManager.pearlTreeViewer.vgraph.controls.dropZoneDeckModel.unhighlight();
         }

      }
      override public function handleDrag(ev:MouseEvent):void{
         _vgraph.handleDragPearl(ev);
         super.handleDrag(ev);
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         if (!_dragEnded) {
            wc.setAllWindowBackward(wc.isPointOverWindow(ev.stageX, ev.stageY));
            wc.setNotificationWindowBackward(wc.isPointOverNotificationWindow(ev.stageX, ev.stageY));
         }
         
         var renderer:IUIPearl = _interactorManager.draggedPearl;
         if(!renderer || !renderer.vnode){
            return;
         }
         if (_pearlDetachmentInteractor) {
            _pearlDetachmentInteractor.onMove();
         }
         var hasSwapped:Boolean = false; 
         if (_draggingOnStringInteractor) {
            if (!_draggingOnStringInteractor.isDraggingOnString(renderer.vnode)) {
               
               hasSwapped = _draggingOnStringInteractor.hasSwapped;
               endDraggingOnString();
            } else {
               _draggingOnStringInteractor.swapPearlIfNeeded(renderer.vnode);
               hasSwapped = _draggingOnStringInteractor.hasSwapped;   
            }
         }
         if (hasSwapped) {
            _detachedBranchManager.cancelBranchDetachmentAfterSwap();
         }
         if(_draggingOnStringInteractor == null && _interactorManager.draggedPearlIsDetached){
            if (!_isScrolling)
               handleDetachedDrag(ev);
         } else {
            if (_draggingOnArcState && !hasSwapped ) {
               _draggingOnArcState.exciteSurroundingNodes(renderer.vnode);
            }
            if (_draggingOnStringInteractor==null){
               handleNodeDetachment(renderer.vnode);
            }
         }
         
         if (_interactorManager.hasMouseDragged()) {
            IPTVisualGraph(renderer.vnode.vgraph).endNodeVisibilityManager.editMode = true;
         }
      }
      public function canDragBeEnded():Boolean {

         if (_dragIntoTreeInteractor) { 
            if (_dragIntoTreeInteractor.shouldImportBranchIntoParentNode()) {
               
               return false;
            }
         }
         var renderer:IUIPearl = _interactorManager.draggedPearl;
         if (renderer) {
            var parentNode:IPTNode = renderer.vnode.node.predecessors[0];
            if (parentNode && parentNode is PTRootNode) {
               if (PTRootNode(parentNode).containedPearlTreeModel.openingState == OpeningState.OPENING) {
                  return false;
               }
               
            }
         }
         
         return true;
         
      }
      private function scheduleDragEndCleanUp():void {
         var animProcessor:GraphicalAnimationRequestProcessor =ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         if (animProcessor.isBusy) {
            animProcessor.postActionRequest(new GenericAction(animProcessor, this, cleanUpAtDragEnd));
         }  else {
            setTimeout(cleanUpAtDragEnd, 200);
         }
      }
      
      private function suscribeToScrollModel(isSuscribing:Boolean):void {
         var sm:ScrollModel = ApplicationManager.getInstance().visualModel.scrollModel;
         _isScrolling = false;
         if (isSuscribing) {
            sm.addEventListener(ScrollModel.SCROLL_STARTED, onScrollStarted);
            sm.addEventListener(ScrollModel.SCROLL_STOPPED, onScrollStopped);
         } else {
            sm.removeEventListener(ScrollModel.SCROLL_STARTED, onScrollStarted);
            sm.removeEventListener(ScrollModel.SCROLL_STOPPED, onScrollStopped);
         }
      }
      
      private function onScrollStopped(event:Event):void {
         _isScrolling = false;  
         
      }
      private function onScrollStarted(event:Event):void {
         _isScrolling = true;
         if(_draggingOnStringInteractor == null && _interactorManager.draggedPearlIsDetached){
            var dp:IUIPearl= _interactorManager.draggedPearl;
            if (dp && dp.node.parent) {
               changeParentVisualNode(dp.node.parent.vnode, null, dp.vnode);
            }
            _dragIntoTreeInteractor.resetOnScrolling();
         }      
      }
      override public function dragEnd(ev:MouseEvent):void {
         _vgraph.dragEndEventSafe(ev);
         
         dragEndInternal(ev);

      }
      
      private function dragEndInternal(ev:MouseEvent):void {
         var refreshDropzone:Boolean = false;
         var garp:GraphicalAnimationRequestProcessor= ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         var isDraggedPearlOrganinzed:Boolean = false;
         _dragEnded = true;
         
         suscribeToScrollModel(false);
         var animProcessor:GraphicalAnimationRequestProcessor =ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         var canDragBeEnded:Boolean = canDragBeEnded();
         var shouldLayout:Boolean = _interactorManager.hasMouseDragged() || _pearlDetachmentInteractor.hasMoved();
         var targetZone:String = "";
         var shouldResetOpenRefTree:Boolean = true;
         var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         var point:Point = new Point(ev.stageX, ev.stageY);
         var treeToCheck:Array = null;

         _excitePearlManager.relaxAllPearls();
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.components.windowController.setAllWindowBackward(false);
         am.components.windowController.setNotificationWindowBackward(false);
         
         _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.editMode = false;  
         _interactorManager.pearlTreeViewer.vgraph.getEditedGraphVisualModification().endEditingGraph();
         if(!_interactorManager.draggedPearl){
            return;
         }
         if (endDraggingOnString()) {
            isDraggedPearlOrganinzed = true;
         }
         var renderer:IUIPearl = _interactorManager.draggedPearl;
         if (renderer.pearl) {
            renderer.pearl.moveRingOutPearl();
         }

         if (renderer.vnode ==null) {
            super.dragEnd(ev);
            return;
         }
         var currentNode:IPTNode = IPTNode(renderer.vnode.node);
         var oldDock:IDeckModel = currentNode.getDock();
         if (_nearestNode != null && _nearestNode.isEnded()) {
            _nearestNode = null;
         }
         var isAnonymous:Boolean = _isAnonymous;
         _interactorManager.nodeTitleModel.setNodeMessageType(renderer.node, NodeTitleModel.NO_MESSAGE);
         if (currentNode.getBusinessNode().owner && currentNode.getBusinessNode().owner.isPrivatePearltreeOfCurrentUserNotPremium()) {
            targetZone = "Cancelled";          
         }  else if (_interactorManager.pearlTreeViewer.vgraph.controls.isPointOverTrash(point) && _interactorManager.draggedPearlIsDetached && !_interactorManager.noFounderDeletePearlFromTeam()) {
            targetZone = "Trash";
         } else if (_interactorManager.pearlTreeViewer.vgraph.controls.isPointOverDropZoneDeck(point) &&  _interactorManager.draggedPearlIsDetached  && !_interactorManager.manipulatedNodesModel.containsSubAssociations && !_interactorManager.movePearlOutsideFromTeam()) {
            targetZone = "DropZone";
         } else if (!renderer.node.parent && (!_dragIntoTreeInteractor || !_dragIntoTreeInteractor.shouldImportBranchIntoParentNode())
            && !_interactorManager.pearlTreeViewer.vgraph.controls.isPointOverDropZoneDeck(point)
            && renderer.node.isDocked) {
            targetZone = "LeaveDropZone";         
         } else if (!renderer.node.parent && (!_dragIntoTreeInteractor || !_dragIntoTreeInteractor.shouldImportBranchIntoParentNode())) {
            if (_interactorManager.draggedPearlIsDetached) {
               var testLinkValue:int = this.testLinkAllowed(currentNode, _nearestNode);
               if (testLinkValue == InteractorRightsManager.CODE_OK || testLinkValue == InteractorRightsManager.CODE_TOO_MANY_NODES_IN_MAP) {            
                  if (!isAnonymous && (!_interactorManager.manipulatedNodesModel.containsSubAssociations || (currentNode.getBusinessNode() is BroDistantTreeRefNode)) && !_interactorManager.movePearlOutsideFromTeam()) {
                     targetZone = "DropZone";
                  } else {
                     isDraggedPearlOrganinzed = true;

                     targetZone = "Cancelled";
                  }
               }
               else {
                  targetZone = "Cancelled";
               }
            }  
         }
         
         updateEditionStatus(renderer.node, targetZone, _interactorManager.hasMouseDragged());
         var restoreDepthAction:IAction = null;
         if (_detachedBranchManager.isBranchClosed()) {
            shouldLayout = true;
            restoreDepthAction = _detachedBranchManager.restoreBranch(_interactorManager.depthInteractor, targetZone != "DropZone");
         }
         var isDraggedPearlOpenTree:Boolean = _detachedBranchManager.isDraggedNodeOpenTree();
         if (_interactorManager.draggedPearlIsDetached) {
            
            _dropZoneInteractor.handleDragForDropZone(ev);
         }
         var targetZoneHandled:Boolean = false;
         
         if(targetZone == "Trash") {
            treeToCheck = BroUtilFunction.addToArray(treeToCheck, _pearlDetachmentInteractor.commitDrag());
            
            var toDeleteGraphicalOnly:Boolean = !oldDock && _isAnonymous;
            var draggedPearlOriginalParentNode:IPTNode = null;
            var shouldClosePW:Boolean = true;
            if(_interactorManager.draggedPearlOriginalParentVNode){
               draggedPearlOriginalParentNode = _interactorManager.draggedPearlOriginalParentVNode.node as IPTNode;
               shouldClosePW = false;
               am.visualModel.selectionModel.selectNode(draggedPearlOriginalParentNode,-1);
            }
            if (shouldClosePW) {
               am.components.windowController.closeAllWindows();
            }
            targetZoneHandled = true;
            if (toDeleteGraphicalOnly) {
               _interactorManager.pearlTreeViewer.pearlTreeEditionController.deleteBranchGraphicalOnly(renderer.node);
            } else {
               _interactorManager.pearlTreeViewer.pearlTreeEditionController.deleteBranch(renderer.node);
            }
         } else {
            unblackenPearlsDragged();
         }
         if (targetZone == "LeaveDropZone") {
            if (!isAnonymous && _interactorManager.nodePositioningInteractor.sendNodeToDefaultPosition(renderer.node)) {
               targetZoneHandled = true;
            } else {
               targetZone = "Cancelled";
            }
         }
         if(targetZone == "DropZone"){
            if (_isAnonymous) {
               
               if (currentNode.getBusinessNode().owner) {
                  var controls:IGraphControls =_interactorManager.pearlTreeViewer.vgraph.controls;
                  controls.dropZoneDeckModel.dockNode(currentNode, true, _interactorManager.mousePosition);
               }
            } else {
               var dock:IDeckModel = _interactorManager.draggedPearl.node.getDock();
               if (!dock) { 
                  if (restoreDepthAction) {
                     restoreDepthAction.performAction();
                  }
                  
                  treeToCheck = BroUtilFunction.addToArray(treeToCheck, _pearlDetachmentInteractor.commitDrag());
                  
                  _interactorManager.manipulatedNodesModel.flush();
                  
                  _dropZoneInteractor.moveBranchToDropZone(renderer.node);
               } else {
                  if (renderer.node.parent) {
                     _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes(renderer.node.parent.vnode, renderer.vnode);
                  }
                  dock.repositionNodes();
               }
               refreshDropzone = true;
               targetZoneHandled = true;
            }
         } 
         if (!targetZoneHandled) {
            
            _endNodeDetachementManager.detachAllEndNodesOfTemporaryTrees();
            
            var parentNode:IPTNode = renderer.vnode.node.predecessors[0]; 

            if (parentNode) {
               var parentBnode:BroPTNode = parentNode.getBusinessNode();
               if (parentBnode && parentBnode.owner is NeighbourPearlTree) {
                  parentNode = null;
               }
            }

            if(parentNode){
               treeToCheck = BroUtilFunction.addToArray(treeToCheck, _pearlDetachmentInteractor.commitDrag());
               var shouldLinkToParent:Boolean = true;

               if (_dragIntoTreeInteractor && _dragIntoTreeInteractor.shouldImportBranchIntoParentNode()) {
                  
                  var openingNode:IPTNode = _dragIntoTreeInteractor.getClosestRefOpened();
                  var bnodeToOpen:BroPTNode = openingNode.getBusinessNode();
                  var targetTree:BroPearlTree = bnodeToOpen.owner;
                  var testlinkIsOk:Boolean = true;
                  
                  if (bnodeToOpen is BroTreeRefNode) {
                     targetTree = BroTreeRefNode(bnodeToOpen).refTree;
                     if (targetTree.pearlsLoaded) {

                        testlinkIsOk =_businessTreeChecker.isBNodeMoveAllowed(currentNode.getBusinessNode(), targetTree.getRootNode(),0);
                        
                        if (!testlinkIsOk && !garp.isBusy) {
                           testlinkIsOk = true;
                        } 
                        
                     }
                  }
                  if (!testlinkIsOk) {
                     shouldLinkToParent = false;
                     
                     _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes(parentNode.vnode, renderer.vnode);
                     parentNode = null;
                  } else {
                     
                     testLinkValue = _interactorManager.interactorRightsManager.testMovingTeamIntoSubTeam(_interactorManager.manipulatedNodesModel, targetTree);
                     if (testLinkValue == InteractorRightsManager.CODE_OK && bnodeToOpen is BroTreeRefNode ) {
                        
                        _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes(parentNode.vnode, renderer.vnode);

                        var nextSelectedNode:IPTNode = parentNode;
                        if (_interactorManager.draggedPearlOriginalParentVNode!=null) {
                           nextSelectedNode= _interactorManager.draggedPearlOriginalParentVNode.node as IPTNode;
                           while (nextSelectedNode!=null && !(nextSelectedNode is PTRootNode) ) {
                              nextSelectedNode = nextSelectedNode.parent;
                           }
                        }
                        
                        shouldResetOpenRefTree = false; 

                        var endNode:IVisualNode = _interactorManager.pearlTreeViewer.pearlTreeEditionController.detachEndNode(renderer.node.containingPearlTreeModel);
                        
                        var wasDocked:Boolean = renderer.node.isDocked;
                        
                        _interactorManager.pearlTreeViewer.pearlTreeEditionController.importBranchIntoTree(_dragIntoTreeInteractor.getClosestRefOpened().vnode,
                           renderer.vnode, nextSelectedNode, _dragIntoTreeInteractor.resetOnEndOfIteraction );
                        
                        if (wasDocked) {
                           
                           _interactorManager.depthInteractor.movePearlAboveAllElse(renderer);
                        }
                        
                        treeToCheck = BroUtilFunction.addToArray(treeToCheck, PTRootNode(_dragIntoTreeInteractor.getClosestRefOpened()).containedPearlTreeModel.businessTree);                                                                                                          
                        if (endNode) {
                           _interactorManager.pearlTreeViewer.pearlTreeEditionController.reattachEndNode(endNode);
                           _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
                        }                                              
                        shouldLinkToParent =false;
                        shouldLayout= false;                                                                                    
                        
                        _dragIntoTreeInteractor.resetOnEndOfIteraction();
                        _endAction = restoreDepthAction;
                        restoreDepthAction = null;            
                     }
                  }
               }
               
               if (shouldLinkToParent) {
                  shouldLinkToParent = InteractorRightsManager.CODE_OK == testLinkAllowed(currentNode, parentNode);
                  if (!shouldLinkToParent) {
                     
                     _interactorManager.pearlTreeViewer.pearlTreeEditionController.tempUnlinkNodes(parentNode.vnode, renderer.vnode);
                     parentNode = null;
                  }
               }
               if (shouldLinkToParent) {
                  var index:int = computeLinkFinalIndex(parentNode,currentNode );

                  var updateBusinessModel:Boolean = true;
                  var parentBNode:BroPTNode= parentNode.getBusinessNode();
                  
                  var originalIndex:int= _interactorManager.draggedPearlOriginalParentIndex;
                  if (_pearlDetachmentInteractor && _pearlDetachmentInteractor.isMovingPearl()) {
                     
                     var indexInBusinessNode:int = parentBNode.getChildIndex(currentNode.getBusinessNode());
                     if (indexInBusinessNode >= 0) {
                        originalIndex = indexInBusinessNode;
                     }
                  }
                  
                  var indexSame:Boolean = (index == originalIndex )|| (index < 0);
                  var bnode:BroPTNode = currentNode.getBusinessNode();
                  if (bnode is BroPTRootNode) { 
                     bnode = bnode.owner.refInParent;
                  }
                  if(indexSame 
                     && (bnode.parent== parentBNode)){
                     updateBusinessModel = false;
                  } 
                  if (!indexSame || index>0) {

                     changeParentVisualNode(parentNode.vnode, parentNode.vnode,renderer.vnode, index, false);
                     
                  } 
                  
                  var originTree:BroPearlTree = IPTNode(renderer.vnode.node).getBusinessNode().owner;
                  if (updateBusinessModel) {
                     treeToCheck = BroUtilFunction.addToArray(treeToCheck, parentNode.getBusinessNode().owner);
                  }     
                  _interactorManager.pearlTreeViewer.pearlTreeEditionController.confirmNodeParentLink(renderer.vnode, updateBusinessModel, index);
                  isDraggedPearlOrganinzed = true;
                  
                  if (true || IPTNode(renderer.vnode.node).getBusinessNode().owner != originTree) {
                     if (animProcessor.isBusy) {
                        animProcessor.postActionRequest(new GenericAction(animProcessor, selectionModel, selectionModel.selectNode, renderer.node, -1, true));
                     } else {
                        selectionModel.selectNode(renderer.node, -1, true);
                     }  
                  }
               }
            } 
            if (isDraggedPearlOrganinzed) {
               var node:BroPTNode = renderer.node.getBusinessNode();
               if (node is BroPTRootNode) {
                  node = node.owner.refInParent;
               }
            }
            
            if (!parentNode) {
               if(!renderer.node.getDock()){
                  _pearlDetachmentInteractor.cancelDrag();
                  linkToOriginalParent(_interactorManager.getDraggedPearlOriginParentNodeRef(), renderer.vnode);
               }
            }
            
            if(oldDock){
               oldDock.repositionNodes();
            }
         }

         cleanInteractorManager(ev);
         
         var stillnode:BroPTNode = _interactorManager.draggedPearl.node.getBusinessNode();
         
         var slowLayout:Boolean = false
         if (checkTreeReorganisation(treeToCheck,  stillnode)) {
            slowLayout = true;
         } 
         
         if (canDragBeEnded) {
            cleanUpAtDragEnd();         
         } else {
            _interactorManager.setActive(false);
            scheduleDragEndCleanUp();
         }
         if (_dragIntoTreeInteractor != null) {
            _dragIntoTreeInteractor.resetOnEndOfIteraction(shouldResetOpenRefTree);
         }
         if (restoreDepthAction) {
            garp.postActionRequest(new GenericAction(garp, restoreDepthAction, restoreDepthAction.performAction));
         } else {
            garp.postActionRequest(new GenericAction(garp, _interactorManager.depthInteractor, _interactorManager.depthInteractor.returnPearlAboveAllElseToNormalPosition));         
         }
         
         if (shouldLayout) {
            animProcessor.postActionRequest(new LayoutAction(_interactorManager.pearlTreeViewer.vgraph, slowLayout), 400);
         }
         if (refreshDropzone || oldDock != null) {
            _vgraph.controls.dropZoneDeckModel.refreshAtAnimationEnds();
            
         }
         super.dragEnd(ev);

         if (shouldLayout) {
            if (_isAnonymous) {
               if ( targetZone != "Cancelled") {
                  if (targetZone == "DropZone") {
                     _interactorManager.showExplanationForAnonymousUser(SignUpBanner.DRAG_TO_DROP_ZONE);
                  }
                  else {
                     _interactorManager.showExplanationForAnonymousUser(SignUpBanner.DRAG_PEARL_MOVE);
                  }
               }
            }
            _interactorManager.pearlTreeViewer.vgraph.endNodeVisibilityManager.updateAllNodes();
            var sm:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
            if (sm.highlightTree(null)) {
               _interactorManager.pearlTreeViewer.vgraph.refreshNodes();
            }
         }
         UpdateTitleRendererLayout.scheduleTitleRendererLayout(_vgraph);
         am.components.mainPanel.navigationBar.model.refreshModel();
      }
      
      private function testLinkAllowed(node:IPTNode, nearestNode :IPTNode):int {
         if (!node) 
            return InteractorRightsManager.CODE_OK;
         if (!nearestNode) {
            if (node.getBusinessNode().owner && node.getBusinessNode().owner.isPrivatePearltreeOfCurrentUserNotPremium()) {
               return InteractorRightsManager.CODE_PRIVATE_EXPIRED_PREMIUM;
            }
            return InteractorRightsManager.CODE_OK;
         }
         var testLinkValue:int = _interactorManager.interactorRightsManager.testLinkAllowed(node, nearestNode, _interactorManager.manipulatedNodesModel, _isAnonymous); 
         if (testLinkValue == InteractorRightsManager.CODE_OK) {
            testLinkValue = _interactorManager.interactorRightsManager.testLayoutWillBeOk(_businessTreeChecker, node, nearestNode, -1);
         }
         return testLinkValue;      
      }
      private function cleanInteractorManager(ev:MouseEvent):void {
         _interactorManager.setDraggedPearlOriginalParentNode(null);
         _endNodeDetachementManager.restoreEndNodesAtEndOfEdition(_interactorManager.draggedPearl.node);
         _endNodeDetachementManager = null;
         _interactorManager.pearlTreeViewer.vgraph.layouter.dropEvent(ev,  _interactorManager.draggedPearl.vnode);
         _interactorManager.draggedPearlIsDetached = false;
      }
      private function checkTreeReorganisation(treeToCheck:Array, stillNode:BroPTNode):Boolean{
         var isReorganizing:Boolean = false;
         
         if (treeToCheck) {
            while (treeToCheck.length >0) {
               var tree:BroPearlTree = treeToCheck.pop();
               if (treeToCheck.lastIndexOf(tree) <0) {
                  var btree:BusinessTree = new BusinessTree(tree);
                  if (stillNode && stillNode.owner == tree) {
                     btree.forbidMove(stillNode);
                  }
                  isReorganizing = new LayoutReorganizer().checkCurrentLayout(btree) || isReorganizing;  
               }
            }
         }
         return isReorganizing;
      }
      private function updateEditionStatus(node:IPTNode, targetZone:String, hasMouseDragged:Boolean):void {
         if (hasMouseDragged && targetZone != "DropZone") {
            var bnode:BroPTNode = node.getBusinessNode();
            if (bnode is BroPTRootNode) {
               bnode = bnode.owner.refInParent;
            }
            if (bnode) {
               if (MARK_NODE_EDITED) {
                  bnode.setEditedStatus();
               } else {
                  bnode.setCollectedStatus();
               }
            }
         }
         
      }
      private function cleanUpAtDragEnd():void {
         if (_endAction) {
            var garp:GraphicalAnimationRequestProcessor= ApplicationManager.getInstance().visualModel.animationRequestProcessor;
            garp.postActionRequest(new GenericAction(garp, _endAction, _endAction.performAction));
            _endAction = null;
         }
         _interactorManager.setActive(true);
         _interactorManager.manipulatedNodesModel.flush();
         _interactorManager.draggedPearl = null;
         _draggingOnArcState = null;
         _detachedBranchManager = null;
      }
      
      private function handleAnonymousNotAllowDeleting():void {
         
      } 
   }
}

