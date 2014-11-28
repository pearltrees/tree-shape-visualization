package com.broceliand.graphLayout.controller
{
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTGraph;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.PearlTreeModel;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.io.sync.BusinessTreeMerger;
   import com.broceliand.pearlTree.io.sync.ClientGraphicalSynchronizer;
   import com.broceliand.pearlTree.io.sync.SynchronizationRequest;
   import com.broceliand.pearlTree.io.sync.editions.UserEdition;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroDataRepository;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.discover.DiscoverModel;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.model.OpenTreesStateModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class GraphicalNavigationController extends EventDispatcher 
   {
      private static const TRACE_DEBUG:Boolean = false;
      
      private var _focusController:FocusController;
      private var _editionController:PearlTreeEditionController;
      private var _vgraph:IPTVisualGraph;
      private var _timeOfLastPerformedRequest:Number=-1;
      private var _displayModel:GraphicalDisplayedModel;
      private var _discoverView:DiscoverView;
      private var _animationRequestProcessor:GraphicalAnimationRequestProcessor;
      private var _interactionManager:InteractorManager;
      private var _addNextInQueue:Boolean = false;
      private var _hasDisplayedABTestingForAnonymousUser:Boolean = false;
      
      private static const OPEN_TREE_REQUEST:int =1; 
      private static const CLOSE_TREE_REQUEST:int =2;
      private static const FOCUS_TREE_REQUEST:int =3;
      private static const SELECT_TREE_AND_PEARL_REQUEST:int =4;
      private static const FOCUS_PTW_TREE_REQUEST :int=5;
      private static const MOVE_IN_PTW_TREE_REQUEST :int=6;
      private static const CLOSE_ALL_SUB_TREES_REQUEST:int=7;
      private static const SYNCHRONIZE_TREES_REQUEST:int=8;
      
      public static const MAX_REQUEST_HANDLED:int =10;
      public static const TIME_OUT:int =10000;
      
      private static const DEBUG:Boolean = false;
      private function debug(msg:String): void {
         if (DEBUG) {
            Log.debug(msg);
         }
      }
      
      public function GraphicalNavigationController(editionController:PearlTreeEditionController, vgraph:IPTVisualGraph, animationRequestProcessor:GraphicalAnimationRequestProcessor, interactionManager:InteractorManager) {
         _focusController = new FocusController(editionController, vgraph, animationRequestProcessor);
         _editionController = editionController;
         _vgraph = vgraph;
         _displayModel = _vgraph.getDisplayModel(); 
         _animationRequestProcessor = animationRequestProcessor;
         _interactionManager = interactionManager;
         if(ApplicationManager.getInstance().useDiscover()) {
            _discoverView = new DiscoverView();
         }
         _addNextInQueue = false;
      }
      
      private function request(request:Request, timeOut:int = 5000):void {
         if (_addNextInQueue) {
            _animationRequestProcessor.insertFirstInQueue(request,timeOut );
         } else {
            _animationRequestProcessor.postActionRequest(request,timeOut );
         }
      }
      
      public function isPerformingRequest():Boolean{
         return (_animationRequestProcessor.isBusy && !_animationRequestProcessor.isPearlWindowOpening());
      }
      public function internalPerformRequest(request:Request):void {
         _timeOfLastPerformedRequest = getTimer();
         if (request.type==OPEN_TREE_REQUEST) {
            performOpenLoadedTree(request, request.node, request.animationType, request.withLayout);
         } else if (request.type == CLOSE_TREE_REQUEST) {
            performCloseTreeNode(request, request.node.vnode, request.animationType, request.withLayout);
         } else if (request.type == FOCUS_TREE_REQUEST) {
            performFocusOnNode(request, request.node, request.tree, request.crossingBusinessNode, request.fromPTW, request.addOnNavigation);
         } else if (request.type == SELECT_TREE_AND_PEARL_REQUEST) {
            performShowAndSelectPearl(request, request.tree, request.businessNode, request.intersection, request.animationType);
         } else if (request.type == FOCUS_PTW_TREE_REQUEST) {
            perfomFocusOnPTWTree(request, request.tree, request.crossingBusinessNode); 
         } else if (request.type == MOVE_IN_PTW_TREE_REQUEST) {
            perfomMoveInPTWTree(request, request.tree);
         } else if (request.type == CLOSE_ALL_SUB_TREES_REQUEST) {
            performCloseAllSubtrees(request, request.tree, request.secondaryTree);
         } else if (request.type == SYNCHRONIZE_TREES_REQUEST) {
            performSynchronizeRequest(request, InternalSynchronizeRequest(request).synchroRequest, InternalSynchronizeRequest(request).invoker, InternalSynchronizeRequest(request).updateOutsideMyAccount);
         }
      }
      private function notifyEndOfRequest(event:Event, request:IAction =null):void  {
         _animationRequestProcessor.notifyEndAction(request);
      }
      
      internal  function openLoadedTree(loadedNode:IPTNode, animationType:int, dontShowEmptySign:Boolean= false):void{
         request(new Request(this, OPEN_TREE_REQUEST, loadedNode,null, null, -1,null, animationType, dontShowEmptySign), 10000);
      }
      internal function showAndSelectPearl(nodeOwner:BroPearlTree, node:BroPTNode=null, intersection:int=-1):void {
         var r:Request = new Request(this,SELECT_TREE_AND_PEARL_REQUEST, null, nodeOwner, node,intersection);
         request(r); 
      }
      internal function closeTreeNode(visualRootOfTheClosedTree:IVisualNode, animationType:int , withLayout:Boolean):void{
         request(new Request(this,CLOSE_TREE_REQUEST, visualRootOfTheClosedTree.node as IPTNode,null,null,-1,null,animationType, withLayout));
      }
      
      public function focusOnTree(tree:BroPearlTree, fromPTW:Boolean =false, resetGraphOption:int= 0):void {
         var crossingBusinessNode:BroPTNode = ApplicationManager.getInstance().visualModel.selectionModel.getCrossingBusinessNode();
         var req:Request = new Request(this,FOCUS_TREE_REQUEST, null, tree, null, -1, crossingBusinessNode);
         req.fromPTW= fromPTW;
         req.addOnNavigation = resetGraphOption;
         request(req);
         ApplicationManager.getInstance().visualModel.selectionModel.resetCrossingBusinessNode();
      }
      
      public function closeAllSubtrees(rootTree:BroPearlTree, treeToOpen:BroPearlTree=null, focusTreeOnly:Boolean=true):void {
         
         if (!focusTreeOnly) {
            
         } 
         var req:Request = new Request(this,CLOSE_ALL_SUB_TREES_REQUEST, null, rootTree, null, -1, null);
         req.secondaryTree = treeToOpen;
         request(req);
         
      }
      public function synchronizeTrees(sr:SynchronizationRequest, invoker:ClientGraphicalSynchronizer, updateOutsideMyAccount:Boolean):void {
         var req:Request = new InternalSynchronizeRequest(this,SYNCHRONIZE_TREES_REQUEST, sr, invoker, updateOutsideMyAccount);
         request(req);
      }
      public function focusOnPTWTree(tree:BroPearlTree):void {
         var crossingBusinessNode:BroPTNode = ApplicationManager.getInstance().visualModel.selectionModel.getCrossingBusinessNode();
         request(new Request(this,FOCUS_PTW_TREE_REQUEST, null, tree, null, -1, crossingBusinessNode), 10000);
         ApplicationManager.getInstance().visualModel.selectionModel.resetCrossingBusinessNode();
      }
      public function moveInPTW(tree:BroPearlTree):void {
         request(new Request(this,MOVE_IN_PTW_TREE_REQUEST, null, tree, null, -1 ));
      }

      private function createTreeGraphNodes(loadedNode:IPTNode):Array {
         var newNodes : Array= new Array();
         var refNodeVisualNode:IVisualNode = loadedNode.vnode;
         var openedTree:IPearlTreeModel = null;
         if (refNodeVisualNode==null) {
            
            notifyEndOfRequest(null);
            return null;
         }
         var loadedNodeBusinessNode:BroPTNode = loadedNode.getBusinessNode(); 
         if(loadedNodeBusinessNode){
            
            if(loadedNodeBusinessNode is BroPTRootNode){
               loadedNodeBusinessNode = loadedNodeBusinessNode.owner.refInParent;
            }
            if(BroLocalTreeRefNode(loadedNodeBusinessNode).isRefTreeLoaded()){
               openedTree = modifyGraphOnTreeOpening(loadedNode,newNodes); 
            } else {
               throw new Error("type of node unexpected on opening node");
            }
         } else{
            throw new Error("visual node tree not available");
         }
         var openedTreeB:BroPearlTree = openedTree.rootNode.getBusinessNode().owner;
         var openTreesModel:OpenTreesStateModel = ApplicationManager.getInstance().visualModel.openTreesModel;
         
         openTreesModel.openTree(openedTreeB.dbId, openedTreeB.id);
         
         if (refNodeVisualNode.view)  {
            refNodeVisualNode.view.invalidateProperties();
         } 
         
         if(_vgraph.currentRootVNode == null){
            _vgraph.currentRootVNode = refNodeVisualNode;
         }
         
         _editionController.refreshEdgeWeights(refNodeVisualNode);
         return newNodes;
      }
      
      private function performOpenLoadedTree(request:IAction, loadedNode:IPTNode, animationType:int, dontShowEmptySign:Boolean= false):void{
         var ptrootNode:PTRootNode = loadedNode as PTRootNode;
         if (ptrootNode) {
            if (ptrootNode.containedPearlTreeModel.openingTargetState != OpeningState.OPEN) {
               if(TRACE_DEBUG) trace("Can;t opening state of "+loadedNode.getBusinessNode().title+" was "+ptrootNode.containedPearlTreeModel.openingTargetState);
               notifyEndOfRequest(null);
               return;                
            }
            ptrootNode.containedPearlTreeModel.openingState = OpeningState.OPENING;
         }
         if (!ptrootNode.vnode || !ptrootNode.vnode.view) {
            if(TRACE_DEBUG) trace("Invalid open node, loaded node has no view");
            notifyEndOfRequest(null);
            return;
         }
         if(TRACE_DEBUG) trace("Start opening tree "+loadedNode.getBusinessNode().title);          
         var newNodes:Array = createTreeGraphNodes(loadedNode);
         if (!newNodes) {
            notifyEndOfRequest(null);
            return ;
         }
         
         var animation:OpenTreeAnimation = new OpenTreeAnimation(request, _animationRequestProcessor, dontShowEmptySign);
         var containedPearlTreeModel:IPearlTreeModel = (loadedNode as PTRootNode).containedPearlTreeModel;
         animation.animateTreeOpening(containedPearlTreeModel, newNodes, animationType);
      }
      
      private function modifyGraphOnTreeOpening(loadedNode:IPTNode, nodesAddedToTheGraph :Array) : IPearlTreeModel {
         var refNodeVisualNode:IVisualNode = loadedNode.vnode;
         var ptRootNode:PTRootNode = refNodeVisualNode.node as PTRootNode;
         var openTreesModel:OpenTreesStateModel = ApplicationManager.getInstance().visualModel.openTreesModel;
         var rootNode:BroPTRootNode = loadedNode.getBusinessNode() as BroPTRootNode;
         if (!rootNode) {
            var treeRefNode:BroTreeRefNode = loadedNode.getBusinessNode() as BroTreeRefNode;
            rootNode = treeRefNode.refTree.getRootNode();
         }
         
         var containedPearlTreeModel:IPearlTreeModel = (ptRootNode).containedPearlTreeModel;
         
         var refPearlSuccessors:Array = new Array;
         var successorEdgeData:Array= new Array();
         for each ( var successor:INode in loadedNode.successors) {
            refPearlSuccessors.push(successor);
            var edgeData:EdgeData= IEdge(successor.inEdges[0]).data as EdgeData;
            successorEdgeData.push(edgeData);
         }
         var detachEndNodeIndex:int= _vgraph.getEditedGraphVisualModification().getDetachedEndNodeSuccessorIndex(refNodeVisualNode);
         for each ( successor in refPearlSuccessors) {
            _vgraph.unlinkNodes(refNodeVisualNode, successor.vnode);
         }
         
         var subTreeToOpen:Array= new Array();  
         var nodesToProcess:Array = new Array();
         var bnode2IPTNode:Dictionary = new Dictionary();
         
         var businessNode:BroPTNode  = rootNode;
         var openedTreeID:Number= rootNode.owner.id;
         
         nodesToProcess.push(businessNode);
         while (nodesToProcess.length > 0) {
            businessNode  = nodesToProcess.shift();
            var children:Array = businessNode.childLinks;
            if (children) {
               
               for(var j:Number = children.length; j-->0; ){
                  var nodeToProcess:BroPTNode = children[j].toPTNode;
                  nodesToProcess.push(nodeToProcess);
               }
            }
            if (businessNode.graphNode && !businessNode.graphNode.isEnded()) {
               bnode2IPTNode[businessNode] = businessNode.graphNode;
            }
            
            var newTreeRootNode:IVisualNode = refNodeVisualNode;
            if (businessNode is BroPTRootNode) {
               
               (refNodeVisualNode.node as PTRootNode).setBusinessNode(businessNode);
               bnode2IPTNode[businessNode] = ptRootNode;
            } else {
               var newVn:IVisualNode = null;
               var oldNode:IPTNode = bnode2IPTNode[businessNode];
               if (!oldNode && businessNode is BroLocalTreeRefNode) {
                  oldNode = _displayModel.getNode(BroLocalTreeRefNode(businessNode).refTree);
               }
               if (oldNode && oldNode.vnode && !oldNode.isDisappearing) {
                  newVn = oldNode.vnode;
               } else {
                  newVn = _vgraph.createNode("["+openedTreeID+"."+businessNode.persistentID+"]:" + businessNode.title, businessNode);
               }
               var newN:IPTNode = newVn.node as IPTNode;
               bnode2IPTNode[businessNode] = newVn.node;
               nodesAddedToTheGraph .push(newVn);
               var fromNode:IPTNode = bnode2IPTNode[businessNode.parent];
               if (businessNode.parent != fromNode.getBusinessNode()) {
                  
                  var fromRootNode:PTRootNode = fromNode as PTRootNode;
                  fromNode = fromRootNode.containedPearlTreeModel.endNode;
               }
               var vedge:IVisualEdge  = _vgraph.linkNodes(fromNode.vnode, newVn);
               newN.containingPearlTreeModel = containedPearlTreeModel;
               
               if (businessNode is BroLocalTreeRefNode) {
                  
                  var newRootN:PTRootNode = newN as PTRootNode;
                  var refNode:BroLocalTreeRefNode = businessNode as BroLocalTreeRefNode;
                  if (openTreesModel.isTreeOpened(refNode.treeDB, refNode.treeId )) {
                     if (refNode.isRefTreeLoaded()) { 
                        
                        if(newRootN.isOpen()) {
                           bnode2IPTNode[refNode] = PTRootNode(newVn.node).containedPearlTreeModel.endNode;
                        }   else {
                           subTreeToOpen.push(newRootN);
                        }
                     }   
                  }
               }
            }
         }
         
         var endNode:EndNode = null;
         endNode = _editionController.addEndNode(refNodeVisualNode.node as PTRootNode);
         nodesAddedToTheGraph.push(endNode.vnode);
         if(refNodeVisualNode.node.predecessors[0] == null || !refNodeVisualNode.node.predecessors[0].vnode.isVisible){
            endNode.canBeVisible = false;
         }
         
         if(refPearlSuccessors.length>0 && endNode) {
            for (var index:int = refPearlSuccessors.length ;  index --> 0; ) {
               var vnodeConnectedToEndNode:IVisualNode = refPearlSuccessors[index].vnode; 
               if (_interactionManager.draggedPearl && vnodeConnectedToEndNode.node == _interactionManager.draggedPearl.node) {
                  vedge  = _vgraph.linkNodes(ptRootNode.vnode, vnodeConnectedToEndNode);     
               } else {
                  vedge = _vgraph.linkNodes(endNode.vnode, vnodeConnectedToEndNode);
               }
               vedge.edge.data = vedge.data = EdgeData(successorEdgeData[index]);
               edgeData = vedge.data as EdgeData;
               edgeData.visible = vnodeConnectedToEndNode.isVisible && vnodeConnectedToEndNode.view.visible && EdgeData(successorEdgeData[index]).visible;
            }
         }
         _vgraph.getEditedGraphVisualModification().changeEndNodeParentOnOpeningNode(endNode.vnode, detachEndNodeIndex);

         if (refNodeVisualNode.view!=null) {
            refNodeVisualNode.view.invalidateProperties();   
         }
         for each (var nodeToOpen:IPTNode in subTreeToOpen) {
            modifyGraphOnTreeOpening(nodeToOpen,nodesAddedToTheGraph);
         }
         containedPearlTreeModel.openingState = OpeningState.OPEN;
         return containedPearlTreeModel;
      }
      
      private function performCloseAllSubtrees(request:IAction, tree:BroPearlTree, treeToRemainOpen:BroPearlTree, focusOnly:Boolean = true):void {
         if(_displayModel.getCurrentFocusedTree()!=tree  && focusOnly) {
            return;
         } 
         var animation:CloseTreeAnimation= new CloseTreeAnimation(request, _animationRequestProcessor);
         var topTreeToRemainOpen:BroPearlTree = treeToRemainOpen;
         var allSubTrees:Array = new Array();
         allSubTrees.push(tree);
         var treeToClose:Array = new Array();
         var openPath:Array = null;
         var interactorManager:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager; 
         var draggedTree:BroPearlTree = null;
         if (treeToRemainOpen) {
            openPath = treeToRemainOpen.treeHierarchyNode.getTreePath(tree)
         } else {
            openPath = tree.treeHierarchyNode.getTreePath(tree);
         }
         var draggedTreePath:Array = openPath;
         if (interactorManager.draggedPearl) {
            draggedTree= interactorManager.draggedPearl.node.getBusinessNode().owner;
            if (draggedTree) {
               draggedTreePath = draggedTree.treeHierarchyNode.getTreePath(tree);
            }
         }
         
         for (var i:int = 0 ; i<openPath.length; i ++) {
            var childTrees:Array = openPath[i].treeHierarchyNode.getChildTrees();
            for (var j:int = 0 ; j<childTrees.length; j ++) {
               if (i>=openPath.length ||childTrees[j] != openPath[i+1]) {
                  if (i+1>draggedTreePath.length || childTrees[j] != draggedTreePath[i+1]) {
                     treeToClose.push(childTrees[j]);
                  }
               }
            }
         }
         if (draggedTreePath != openPath) {
            for (i= 0 ; i<draggedTreePath.length; i ++) {
               childTrees= draggedTreePath[i].treeHierarchyNode.getChildTrees();
               for (j= 0 ; j<childTrees.length; j ++) {
                  if (childTrees[j] != draggedTreePath[i+1]) {
                     if (i+1>openPath.length || childTrees[j] != openPath[i+1]) {
                        if (treeToClose.lastIndexOf(childTrees[j])) {
                           treeToClose.push(childTrees[j]);   
                        }
                     }
                  }
               }
            }   
         }
         
         var rootNode:IPTNode = _displayModel.getNode(tree);
         
         var childNodes:Array = rootNode.getDescendantsAndSelf();
         var hasSubTreeToClose:Boolean = false;
         for each (var n:IPTNode  in childNodes) {
            if (n is PTRootNode && n.treeOwner != tree && n.treeOwner != topTreeToRemainOpen && treeToClose.lastIndexOf(n.getBusinessNode().owner) != -1) {
               if (PTRootNode(n).containedPearlTreeModel.openingState == OpeningState.OPENING || PTRootNode(n).containedPearlTreeModel.openingState == OpeningState.CLOSING  ) {
                  continue;
               } 
               if (n.getBusinessNode() is BroPTRootNode && !interactorManager.manipulatedNodesModel.isNodeManipulated(n)) { 
                  hasSubTreeToClose = true;
                  internalCloseTreeNode(n.vnode,animation);
               }
            }
         }
         if (hasSubTreeToClose) {
            var fixedNode:IVisualNode = null;
            if (treeToRemainOpen) {
               var iptnode:IPTNode = _displayModel.getNode(treeToRemainOpen);
               fixedNode = _displayModel.getNode(treeToRemainOpen).vnode;
            }
            animation.startClosingAnimation(_displayModel, fixedNode);
         } else {
            notifyEndOfRequest(null, request);
         }
      }
      
      private function performCloseTreeNode(request:IAction, visualRootOfTheClosedTree:IVisualNode, animationType:int, withLayout:Boolean):void{
         if (animationType >= 0) {   
            var animation:CloseTreeAnimation = withLayout ? new CloseTreeAnimation(request, _animationRequestProcessor): new QuickCloseAnimationWithNoLayout(request, _animationRequestProcessor);
            internalCloseTreeNode(visualRootOfTheClosedTree, animation);
            animation.addEventListener(OpenTreeAnimationControllerBase.ANIMATION_ENDED_EVENT, notifyEndOfRequest);
            animation.startClosingAnimation(_displayModel, visualRootOfTheClosedTree);
         } else {
            internalCloseTreeNode(visualRootOfTheClosedTree);
            notifyEndOfRequest(null, request);
         } 
      }
      
      internal function internalCloseTreeNode(visualRootOfTheClosedTree:IVisualNode, closeAnimation:CloseTreeAnimation=null):void {
         if (visualRootOfTheClosedTree == null) {
            notifyEndOfRequest(null);
            return;
         }
         var containedPearlTreeModel:IPearlTreeModel = (visualRootOfTheClosedTree.node as PTRootNode).containedPearlTreeModel;
         containedPearlTreeModel.openingState = OpeningState.CLOSING;
         var treeToclose:BroPearlTree = containedPearlTreeModel.rootNode.getBusinessNode().owner;
         var openTreeModel:OpenTreesStateModel =ApplicationManager.getInstance().visualModel.openTreesModel; 
         openTreeModel.closeTree(treeToclose.dbId, treeToclose.id);
         var node:IPTNode= visualRootOfTheClosedTree.node as IPTNode;
         var owner:BroPearlTree = node.treeOwner;
         if(!(node.getBusinessNode() is BroPTRootNode)){
            trace("trying to close a pearl that isn't a root");
            containedPearlTreeModel.openingState = OpeningState.CLOSED;
            containedPearlTreeModel.endNode = null;
            notifyEndOfRequest(null);
            return;
         }
         var rootNode:BroPTRootNode = node.getBusinessNode() as BroPTRootNode;
         if(!rootNode.owner.refInParent){
            trace("can't close top tree(no owner)");
            return;
         }
         
         var interactorManager:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager; 
         var manipulatedNodes:ManipulatedNodesModel = interactorManager.manipulatedNodesModel;
         var vnodesToDelete:Array = new Array();
         var nodesToProcess:Array = new Array();
         nodesToProcess.push(visualRootOfTheClosedTree);
         var endNode:EndNode = null;
         while(nodesToProcess.length > 0){
            var nextVNnode:IVisualNode  = nodesToProcess.shift();
            var children:Array = nextVNnode.node.successors;
            
            for each(var nChild:IPTNode in children){
               if (!manipulatedNodes.isNodeManipulated(nChild)) {
                  vnodesToDelete.push(nChild.vnode);
                  if (nChild is PTRootNode) {
                     
                     var tmodel:IPearlTreeModel = PTRootNode(nChild).containedPearlTreeModel;
                     var subTreeToClose:BroPearlTree= tmodel.businessTree;
                     tmodel.openingState= OpeningState.CLOSING;
                     tmodel.openingTargetState= OpeningState.CLOSED;
                     tmodel.endNode=null;
                     openTreeModel.closeTree(subTreeToClose.dbId, subTreeToClose.id);
                  }
               }
               if((nChild is EndNode) && (nChild.treeOwner == owner)){
                  endNode = nChild as EndNode;
               } else {
                  nodesToProcess.push(nChild.vnode);
               }
            }
         }
         
         PTRootNode(node).setBusinessNode(rootNode.owner.refInParent);
         if (visualRootOfTheClosedTree.view) {
            visualRootOfTheClosedTree.view.invalidateProperties();
         }
         
         _editionController.refreshEdgeWeights(visualRootOfTheClosedTree);
         containedPearlTreeModel.openingState = OpeningState.CLOSING;
         
         if (closeAnimation) {
            if (!endNode) {
               endNode = containedPearlTreeModel.endNode as EndNode;
            }
            closeAnimation.addTreeToClose(visualRootOfTheClosedTree, vnodesToDelete , endNode);
         } else {
            var ptroot:PTRootNode = visualRootOfTheClosedTree.node as PTRootNode;
            if (ptroot) {
               if (ptroot.containedPearlTreeModel.openingTargetState == OpeningState.CLOSED) {
                  ptroot.containedPearlTreeModel.openingTargetState= null;
               } 
               ptroot.containedPearlTreeModel.openingState = OpeningState.CLOSED;
               ptroot.containedPearlTreeModel.endNode =null;
            }
            for each (var vn:IVisualNode in vnodesToDelete) {
               vn.vgraph.removeNode(vn);
            }
         }
      }  
      
      public function clearGraph(removeNodes:Boolean):Array {
         
         var openTreeModel:OpenTreesStateModel =ApplicationManager.getInstance().visualModel.openTreesModel;
         var manipulatedModel:ManipulatedNodesModel = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.manipulatedNodesModel;
         openTreeModel.closeAllTees();     
         var nodes2Remove:Array = new Array();
         for each (var node:IPTNode in _vgraph.graph.nodes) {
            if(!node.getDock() && !manipulatedModel.isNodeManipulated(node)) {
               nodes2Remove.push(node);
               node.isDisappearing = true;
            }
         }    
         
         for each (node in nodes2Remove) {
            if (removeNodes) {
               _vgraph.removeNode(node.vnode);  
            } else {
               _displayModel.onNodeRemovedFromGraph(node);
            }
         }
         return nodes2Remove;
      } 
      
      public function createTree(pearlTree:BroPearlTree, resetGraph:Boolean, resetScroll:Boolean = true, withAnimation:int=1):IVisualNode{
         _editionController.loadAllLogosAndDraw(pearlTree);
         if(!_vgraph.graph ){
            _vgraph.graph = new PTGraph("pearltrees", true, null);
         } else if (resetGraph) {
            if (resetScroll) {
               _vgraph.origin.x=0;
               _vgraph.origin.y=0;
            }
            clearGraph(true);  
         }
         var topVNode:IVisualNode = createRootTreeNode(pearlTree).vnode;
         _focusController.focusedVNode = topVNode;
         if (resetGraph) {
            _vgraph.currentRootVNode = topVNode;
         }
         _displayModel.onTreeGraphBuilt(topVNode.node as IPTNode);
         if (pearlTree.pearlsLoaded && withAnimation==0) {
            createTreeGraphNodes(topVNode.node as IPTNode);
            
         } else {
            var animType:int = OpenTreeAnimation.GROWING_ANIMATION;
            if (withAnimation == 2) {
               animType = OpenTreeAnimation.QUICK_ANIMATION; 
            } else if (withAnimation == 3) {
               animType = OpenTreeAnimation.FADE_ANIMATION;
            }
            _editionController.openTreeNode(topVNode, animType);
         }
         return topVNode;            
      }
      
      private function createRootTreeNode(pearlTree:BroPearlTree):IPTNode {
         var topRefNode:BroLocalTreeRefNode = pearlTree.refInParent  ;
         if (topRefNode==null) {
            topRefNode = new BroLocalTreeRefNode(pearlTree.dbId, pearlTree.id);
            topRefNode.refTree = pearlTree;
            pearlTree.refInParent = topRefNode;
         }  
         var topVNode:IVisualNode = _vgraph.createNode("["+pearlTree.dbId+"."+pearlTree.id+"]:" + pearlTree.title, topRefNode);
         var topPearlTreeModel:IPearlTreeModel = new PearlTreeModel(topVNode.node as PTRootNode);
         (topVNode.node as IPTNode).containingPearlTreeModel = topPearlTreeModel;
         return topVNode.node as IPTNode;
      }       
      private function performFocusOnNode(request:IAction, node:IPTNode, tree:BroPearlTree, crossingBusinessNode:BroPTNode,isFromPTW:Boolean, resetGraphOption:int):void{
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navmodel:INavigationManager = am.visualModel.navigationModel;
         if (tree== null || navmodel.getFocusedTree()!= tree) {
            notifyEndOfRequest(null, request);
            return;
         } 

         if (isFromPTW) {
            allowMoveDockedPearl();  
         }
         var addOnNavigation:Boolean = resetGraphOption >0;

         if (!addOnNavigation) {
            
            var currentFocusTree:BroPearlTree = _displayModel.getCurrentFocusedTree();
            
            if (currentFocusTree) {
               var parentTrees:Array = currentFocusTree.treeHierarchyNode.getTreePath(tree);

               if (parentTrees[0] == tree) {
                  
                  if (parentTrees.length == 2) {
                     var closeAnimation:CloseTreeAnimation = new UnfocusCloseAnimation(request, _animationRequestProcessor, tree, this);
                     internalCloseTreeNode(_vgraph.currentRootVNode, closeAnimation);
                     closeAnimation.addEventListener(OpenTreeAnimationControllerBase.ANIMATION_ENDED_EVENT, notifyEndOfRequest);
                     closeAnimation.startClosingAnimation(_displayModel, _vgraph.currentRootVNode);
                     return;
                  } 
               }
                  
               else {
                  node = _displayModel.getNode(tree);
                  
                  if (node && tree.treeHierarchyNode.getTreePath(currentFocusTree).indexOf(currentFocusTree) != 0 ) { 
                     node = null;
                  } 
               }
            }
         } 
         if (!node || !node.vnode) {
            _addNextInQueue = true;
            var isCrossingAnimationPossible:Boolean = _vgraph.currentRootVNode &&_vgraph.graph.nodes.length>1 && (crossingBusinessNode || isFromPTW);
            
            if (resetGraphOption == NavigationEvent.ADD_ON_CLEAR_GRAPH_NO_SCROLL) {
               node = createTree(tree, true, false, 3).node as IPTNode;
            } 
            else if (isCrossingAnimationPossible) {
               var nodesToRemove:Array = null;
               if (!addOnNavigation || resetGraphOption == NavigationEvent.ADD_ON_CROSS_ANIMATION || resetGraphOption == NavigationEvent.ADD_ON_RESET_GRAPH_AND_CENTER) {
                  nodesToRemove = clearGraph(false);
                  node = createTree(tree, false,false,0).node as IPTNode;
                  var animation:OpenCrossingAnimationController= new OpenCrossingAnimationController(request, _animationRequestProcessor, _vgraph, _displayModel);
                  if (isFromPTW && !crossingBusinessNode) {
                     crossingBusinessNode =  IPTNode(_vgraph.currentRootVNode.node).getBusinessNode();
                  }
                  _addNextInQueue = false;
                  animation.performAnimation(node, nodesToRemove, crossingBusinessNode, false, isFromPTW || resetGraphOption == NavigationEvent.ADD_ON_RESET_GRAPH_AND_CENTER);
                  return; 
               } 
            }
            if (!node) {
               
               node = createTree(tree, true, true).node as IPTNode;
            }
            
         }
         _addNextInQueue = false;
         
         _focusController.focusOnNode(request, node.vnode, _displayModel, crossingBusinessNode);
      }                   
      
      private function allowMoveDockedPearl():void {
         var dropZoneModel:IDeckModel = _vgraph.controls.dropZoneDeckModel;
         var dropZoneItemsCount:int = dropZoneModel.getItemsCount();
         var dockedNode:IPTNode;
         var i:uint;
         for(i=0; i<dropZoneItemsCount; i++) {
            dockedNode = dropZoneModel.getNodeAt(i, false);
            if(dockedNode) {
               dockedNode.renderer.forbidMove(false);
            }
         }
      }
      
      public function get displayModel ():GraphicalDisplayedModel
      {
         return _displayModel;
      }
      public function get discoverModel():DiscoverModel {
         return _discoverView.model;
      }
      
      private function performShowAndSelectPearl(request:IAction, tree:BroPearlTree, node:BroPTNode, intersection:int, animationType:int):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         _vgraph.PTLayouter.setPearlTreesWorldLayout(false);
         var parentOfSelectedTree:Array = tree.treeHierarchyNode.getTreePath();
         var lastNodeToOpen:PTRootNode = null;
         var openTreesModel:OpenTreesStateModel  = am.visualModel.openTreesModel;
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var pwState:int  = navModel.getPearlWindowPreferredState();
         var toCenterOnPearlForAnonymous:Boolean = navModel.toCenterOnPearlForAnonymousArriving();
         for (var i:int=parentOfSelectedTree.length; i-->0;) {
            var ptNode:PTRootNode= _displayModel.getNode(parentOfSelectedTree[i]) as PTRootNode;
            if (ptNode && !ptNode.isOpen() && ptNode.containedPearlTreeModel.openingState!= OpeningState.OPENING) {
               lastNodeToOpen = ptNode;
            }
            openTreesModel.openTree((parentOfSelectedTree[i] as BroPearlTree).dbId,(parentOfSelectedTree[i] as BroPearlTree).id);
         }
         var isOpeningNode:Boolean = false;
         var parentNodeOfSelectNode:IPTNode = _displayModel.getNode(tree);
         if (parentNodeOfSelectNode == null) {
            parentNodeOfSelectNode = lastNodeToOpen;
         }
         
         if (lastNodeToOpen != null) {
            if (lastNodeToOpen.containedPearlTreeModel.openingTargetState == null) {
               lastNodeToOpen.containedPearlTreeModel.openingTargetState = OpeningState.OPEN;
               performOpenLoadedTree(request, lastNodeToOpen, animationType);
               isOpeningNode = true;
            }
         }

         var selectedNode:IPTNode = null;
         if (navModel.getSelectedTree() == tree && navModel.getSelectedPearl()==node && navModel.getSelectionIntersectionIndex()== intersection) {
            
            if (parentNodeOfSelectNode !=null && node !=null) {
               var iptnodes:Array= parentNodeOfSelectNode.getDescendantsAndSelf();
               for each (var iptnode:IPTNode in iptnodes) {
                  if (!(iptnode is EndNode) && iptnode.getBusinessNode() == node) {
                     selectedNode = iptnode;
                     break;
                  }
               }
            }  else if (node==null) { 
               if (parentNodeOfSelectNode is PTRootNode) {
                  selectedNode= PTRootNode(parentNodeOfSelectNode).containedPearlTreeModel.endNode;
               }
            }
         }   
         
         if (selectedNode && !selectedNode.vnode) {
            selectedNode = null;
         }
         if (selectedNode ) {
            var selectionModel:SelectionModel = am.visualModel.selectionModel;
            if (selectionModel.getSelectedNode() != selectedNode || selectionModel.getIntersection()!= intersection) {
               selectionModel.selectNode(selectedNode,intersection);               
            } 
            
            if (node && (toCenterOnPearlForAnonymous || pwState>0 || (!selectedNode.isRendererInScreen() && am.components.pearlTreePlayer.isHidden() && (!am.isEmbed())))) {
               
               var slowAnimation:Boolean = pwState > 0;
               var ga:GenericAction = new GenericAction(_animationRequestProcessor, selectionModel, selectionModel.centerGraphOnCurrentSelectionWithPWDisplayed, false, true, 1 ,false, null, slowAnimation);
               if (isOpeningNode) {
                  ga.addInQueue();
               } else {
                  ga.performAction();
               }
               navModel.hasDisplayedABTestingEffectForAnonymous = true;
            }
            else {
               ApplicationManager.getInstance().visualModel.navigationModel.isFirstSelectionPerformed = true;
            }
         }
         var windowController:IWindowController = am.components.windowController;

         if (pwState<0) {
            pwState =-pwState; 
         }
         if (pwState == PWModel.CROSS_PANEL && (!selectedNode || !selectedNode.getBusinessNode() || selectedNode.getBusinessNode().neighbourCount == 0)) {
            pwState = PWModel.CONTENT_PANEL;
         }
         if (pwState == PWModel.CONTENT_PANEL) {
            windowController.displayNodeInfo(selectedNode, true);
         } else if (pwState == PWModel.NOTE_PANEL) {
            windowController.displayNodeNotes(selectedNode, true, false, true);
         } else if (pwState == PWModel.CROSS_PANEL) {
            windowController.displayNodeCrosses(selectedNode, true);
         } else if(pwState == PWModel.SHARE_PANEL) {
            windowController.displayNodeShare(selectedNode, true);
         } else if( pwState == PWModel.TEAM_ACCEPT_CANDIDACY_PANEL) {
            windowController.displayTeamAcceptCandidacy(selectedNode, null, true, true);
         } else if (pwState == PWModel.TEAM_INFO_PANEL) {
            windowController.displayOrHideTeamInfo();
         } else if (pwState == PWModel.TEAM_FREEZE_MEMBER_PANEL) {
            windowController.displayOrHideTeamInfo();
         } else if (pwState == PWModel.AUTHOR_PANEL){
            windowController.displayOrHideAuthorInfo(selectedNode, false, true);
         } else if (pwState == PWModel.TEAM_LIST_PANEL){
            windowController.displayAuthorTeamList(selectedNode, null, -1, true, true);
         } else if (pwState == PWModel.TEAM_HISTORY_PANEL){
            windowController.displayOrHideTeamHistory(selectedNode, false, true, true);
         } else if (pwState == PWModel.TEAM_DISCUSSION_PANEL){
            windowController.displayTeamDiscussion(selectedNode, true, false, true);
         } else if (pwState == PWModel.LIST_PRIVATE_MSG_PANEL) {
            windowController.displayPrivateMessages(selectedNode);
         } else if (pwState == PWModel.TREE_EDITO_PANEL) {
            windowController.displayTreeEdito(selectedNode);
         } else if (pwState == PWModel.CUSTOMIZATION_AVATAR_PANEL) {
            windowController.displayCustomizeAvatar(selectedNode);
         } else if (pwState == PWModel.CUSTOMIZATION_LOGO_PANEL) {
            windowController.displayCustomizeLogo(selectedNode);
         } else if (pwState == PWModel.CUSTOMIZATION_BACKGROUND_PANEL) {
            windowController.displayCustomizeBackground(selectedNode);
         } else if (pwState == PWModel.IMAGES_BIBLI_PANEL) {
            windowController.displayImagesBibli(null, null,  selectedNode);
         } else if (pwState == PWModel.TEAM_NOTIFICATION_PANEL){

         } else if (pwState == PWModel.FACEBOOK_INVITATION_DEFAULT_PANEL){
            windowController.displayFacebookInvitationDefault(selectedNode);
         } else if (pwState == PWModel.FACEBOOK_INVITATION_TEAMUP_PANEL){
            windowController.displayFacebookInvitationTeamUp(selectedNode);
         }
         
         if (lastNodeToOpen == null) {
            notifyEndOfRequest(null, request);
         }
      }
      
      private function perfomFocusOnPTWTree(request:IAction, tree:BroPearlTree, crossingNode:BroPTNode):void {
         var openTreesModel:OpenTreesStateModel = ApplicationManager.getInstance().visualModel.openTreesModel;
         openTreesModel.closeAllTees();
         var ptwAnimationController:PTWAnimationController = new PTWAnimationController(_vgraph,_editionController, _animationRequestProcessor);
         ptwAnimationController.createPTW(tree, crossingNode, request);
      }
      
      private function perfomMoveInPTWTree(request:IAction, tree:BroPearlTree):void {
         var ptwAnimationController:PTWAnimationController = new PTWAnimationController(_vgraph,_editionController, _animationRequestProcessor);
         ptwAnimationController.moveInPTW(tree, request);
      }
      
      private function performSynchronizeRequest(request:IAction, synchroRequest:SynchronizationRequest, invoker:ClientGraphicalSynchronizer, updateOutsideMyAccount:Boolean):void {
         var associationToMerge:BroAssociation;
         if (!updateOutsideMyAccount) {
            var user:User = ApplicationManager.getInstance().currentUser;
            associationToMerge = user.getAssociation();
            synchroRequest.conflictManager.unsuscribeToChangeTreeEvent();
            synchroRequest.conflictManager.processMergeResults();
         } else {
            associationToMerge = synchroRequest.getExternalVisitedAssociation();    
         }
         if (updateOutsideMyAccount) {
            Log.getLogger("com.broceliand.graphLayout.controller.GraphicalNavigationController").info("Perform request {0} :Updating outside my account {0} version {1} -> {2} ",synchroRequest.debugRequestId(), synchroRequest.getExternalVisitedAssociation().info.title,synchroRequest.getExternalVisitedAssociation().info.versionId,synchroRequest.response.getExternallyUpdatedAssoOutputData().assoId  );
         } else {
            Log.getLogger("com.broceliand.graphLayout.controller.GraphicalNavigationController").info("Perform request {0} : Updating my account ", synchroRequest.debugRequestId());
         }
         var merger:BusinessTreeMerger = associationToMerge.getBusinessTreeMerger();
         if (!merger) {
            Log.getLogger("com.broceliand.graphLayout.controller.GraphicalNavigationController").error("No business tree merger for '{0}'",associationToMerge.info.title);
            invoker.onUserEditionProcessed(synchroRequest, updateOutsideMyAccount);
            return;
         }
         var userModification:UserEdition = merger.computeNodeEdition(synchroRequest, updateOutsideMyAccount);         
         var editionPerfomer:EditionProcessor = new EditionProcessor(_vgraph,_editionController, displayModel, this, userModification);
         editionPerfomer.addEventListener(EditionProcessor.ANIMATION_ENDED_EVENT, notifyEndOfRequest);
         editionPerfomer.performEdition();
         invoker.onUserEditionProcessed(synchroRequest, updateOutsideMyAccount);
         if (updateOutsideMyAccount) {
            synchroRequest.updateExternalAssociationVersion();
         } else {
            synchroRequest.updateTreeVersions();
            synchroRequest.notifySyncPerformed();
         }
         
         if (!updateOutsideMyAccount) {
            var lostTrees:Array = synchroRequest.response.getLostTreesIds();
            var dataRepository:BroDataRepository;
            for each (var id:Number in lostTrees) {
               if (!dataRepository) {
                  dataRepository = ApplicationManager.getInstance().visualModel.dataRepository;
               }
               var tree:BroPearlTree = dataRepository.getTree(id);
               if (tree) {
                  tree.unloadTree(dataRepository);
               }
            }
         } else {

         }
         
         invoker.onUserEditionProcessed(synchroRequest, updateOutsideMyAccount);
      }
   }
   
}

import com.broceliand.graphLayout.controller.GraphicalNavigationController;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.pearlTree.io.sync.ClientGraphicalSynchronizer;
import com.broceliand.pearlTree.io.sync.SynchronizationRequest;
import com.broceliand.pearlTree.io.sync.editions.UserEdition;
import com.broceliand.pearlTree.model.BroPTNode;
import com.broceliand.pearlTree.model.BroPearlTree;
import com.broceliand.util.IAction;

internal class Request implements IAction {
   public var type:int;
   public var node:IPTNode;
   public var businessNode:BroPTNode; 
   public var tree:BroPearlTree;
   public var intersection:int;
   public var animationType:int
   private var _gnc:GraphicalNavigationController;
   private var _fromPTW:Boolean;
   public var withLayout:Boolean;
   public var secondaryTree:BroPearlTree;
   private var _addOnNavigation:int;

   public var crossingBusinessNode:BroPTNode;
   public function Request(gnc:GraphicalNavigationController, requestType:int, node:IPTNode, tree:BroPearlTree, businessNode:BroPTNode=null, intersection:int=-1, crossingBusinessNode:BroPTNode=null, animationType:int=0, withLayout:Boolean= true) {
      _gnc = gnc;
      this.node = node;
      this.type = requestType;
      this.tree = tree;
      this.businessNode = businessNode;
      this.intersection = intersection;
      this.crossingBusinessNode = crossingBusinessNode;
      this.animationType= animationType;
      this.withLayout = withLayout;
      
   }
   public function performAction():void {
      _gnc.internalPerformRequest(this);
   }
   
   public function set fromPTW (value:Boolean):void   {
      _fromPTW = value;
   }
   
   public function get fromPTW ():Boolean {
      return _fromPTW;
   }
   public function set addOnNavigation (value:int):void {
      _addOnNavigation = value;
   }
   
   public function get addOnNavigation ():int{
      return _addOnNavigation;
   }
   
   public function toString():String {
      var msg:String;
      switch (type) {
         case 1:
            msg = "Request Opening tree";
            break;
         case 2:
            msg = "Request closing tree";
            break;
         case 3:
            msg = "Request closing tree";
            break;
         case 4:
            msg = "Request Select one pearl : ";
            break;
         case 5:
            msg  = "Request Focus PTW tree : ";
            break;
         case 6:
            msg  = "Request Move in PTW : ";
            break;
         case 7:
            msg  = "Request Close All SubTrees from : ";
            break;
         case 8: 
            msg  = "synchronizeRequest ";
            break;
         default:
            msg = "Unknown request type";
      }
      switch (type) {
         case 1:
         case 2:
            if (node && node.getBusinessNode()) {
               msg += node.getBusinessNode().title; 
            }
            break;
         case 3:
         case 5:
         case 6:
            if (tree) {
               msg += tree.title;
            }
            break;
         case 4: 
            if (businessNode && tree.title) {
               msg += businessNode.title+" from : "+tree.title;
            } else if (tree.title) {
               msg += tree.title;
            }
            break;
         case 7:
            if (tree) { 
               msg += tree.title;
               if (secondaryTree) {
                  msg +=  "except "+ secondaryTree.title;
               }
            }
            break;
      }
      return msg;
      
   }
}
internal class InternalSynchronizeRequest extends Request {
   public var synchroRequest:SynchronizationRequest;
   public var invoker:ClientGraphicalSynchronizer;
   public var updateOutsideMyAccount:Boolean;
   public function InternalSynchronizeRequest(gnc:GraphicalNavigationController, requestType:int, request:SynchronizationRequest, invoker:ClientGraphicalSynchronizer, updateOutsideMyAccount:Boolean) {
      super(gnc, requestType, null, null);
      this.synchroRequest = request;
      this.invoker = invoker;
      this.updateOutsideMyAccount = updateOutsideMyAccount;
   }
}
