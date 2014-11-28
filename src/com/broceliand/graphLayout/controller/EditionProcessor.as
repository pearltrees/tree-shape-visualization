package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.layout.PTLayouterBase;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.io.sync.editions.ChangeNodeType;
   import com.broceliand.pearlTree.io.sync.editions.CreateNodeInTree;
   import com.broceliand.pearlTree.io.sync.editions.IEdition;
   import com.broceliand.pearlTree.io.sync.editions.MoveNodeBetweenTrees;
   import com.broceliand.pearlTree.io.sync.editions.MoveNodeInTree;
   import com.broceliand.pearlTree.io.sync.editions.TreeEdition;
   import com.broceliand.pearlTree.io.sync.editions.UserEdition;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.model.OpenTreesStateModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearlBar.deck.DeckItem;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   import com.broceliand.util.BroUtilFunction;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   import mx.effects.Effect;
   import mx.effects.Fade;
   import mx.effects.Parallel;
   import mx.events.EffectEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class EditionProcessor extends EventDispatcher
   {
      public static const ANIMATION_ENDED_EVENT:String = "EditionAnimationEnds";
      
      private var _inPTW:Boolean;
      private var _graphRootNode:PTRootNode;
      private var _displayModel:GraphicalDisplayedModel;
      private var _vgraph:IPTVisualGraph;
      private var _userEdition:UserEdition;
      private var _editionController:IPearlTreeEditionController;
      private var _nodesToRemoveFromGraph:Array;
      private var _graphicaNavController:GraphicalNavigationController;
      private var _startTreePath:Array;
      private var _dockingTreeNode:Array;
      private var _creatingPearlEffect:Effect;
      
      public function EditionProcessor(vgraph:IPTVisualGraph,
                                       editionController:IPearlTreeEditionController,
                                       displayModel:GraphicalDisplayedModel, graphicalNavigation:GraphicalNavigationController, userEdition:UserEdition )
      {
         _displayModel = displayModel;
         _userEdition = userEdition;
         _vgraph = vgraph;
         _editionController = editionController;
         _graphicaNavController = graphicalNavigation;
         if (_vgraph.currentRootVNode) {
            _graphRootNode = _vgraph.currentRootVNode.node as PTRootNode;
         }
         _inPTW = ApplicationManager.getInstance().visualModel.navigationModel.isShowingPearlTreesWorld();
         if (!_inPTW && _graphRootNode) {
            _startTreePath = _graphRootNode.containedPearlTreeModel.businessTree.treeHierarchyNode.getTreePath();
         }
      }
      
      public function getGraphicalNode(id2IptNodes:Dictionary, id:Number):IPTNode{
         var node:Object = id2IptNodes[id];
         if (node is IPTNode) {
            return node as IPTNode;
         } else  if (node is DeckItem) 
         {
            var di:DeckItem = node as DeckItem;
            if (!di.node) {
               var dropZone:IDeckModel = _vgraph.controls.dropZoneDeckModel;
               dropZone.createItemNode(di);
            }
            return di.node;
         }
         return null;
      }
      
      public function performEdition():void {
         
         var treeWithGraphicalEdition:Dictionary = findGraphicalTreesToUpdate();
         var id2IptNodes:Dictionary  = indexGraphNodes(treeWithGraphicalEdition);
         var createdIptNode:Array =null;
         var detachedEndVNode:Array =null;
         var am:ApplicationManager = ApplicationManager.getInstance();
         var hasReorganizeTreeEdition:TreeEdition = null;
         var t:TreeEdition;
         
         for each (t in _userEdition.getTreesEdition()) {
            if (treeWithGraphicalEdition[t.tree] || (t.isDropzone && t.tree.isCurrentUserAuthor())) {
               createdIptNode = createGraphicalNodes(t, id2IptNodes);
            }
            if (t.getNewOrganizeValue() == BroPearlTree.ORGANIZE_STATE_NOTIFY_FORCED || t.getNewOrganizeValue() == BroPearlTree.ORGANIZE_STATE_NOTIFY_SIMPLE) {
               if (treeWithGraphicalEdition[t.tree]) {
                  hasReorganizeTreeEdition = t;
               }
               
            }
            if (t.hasPrivateStateChanged()){ 
               performPrivateStateChange(t);
            }
            detachedEndVNode= BroUtilFunction.addToArray(detachedEndVNode,unlinkAllMovedNodesAndComputeNodeToDelete(t, treeWithGraphicalEdition, id2IptNodes));
         }
         var shouldUpdateVisibility:Boolean = false;
         for each (t in _userEdition.getTreesEdition()) {
            shouldUpdateVisibility =  linkAllNodes(t, id2IptNodes, treeWithGraphicalEdition[t.tree]!=null) ||shouldUpdateVisibility ;
            t.updateTreeVersion();
         }
         
         reattachEndNodes(detachedEndVNode);
         if (_userEdition.hierarchyUpdate) {
            _userEdition.hierarchyUpdate.updateTreeHierarchy(am.visualModel.dataRepository);
         }

         for each (t in _userEdition.getTreesEdition()) {
            shouldUpdateVisibility = changeNodesType(t.getChangeNodeTypes(), id2IptNodes) || shouldUpdateVisibility;
            t.performTreeHierarchyUpdates();
         }

         if (_userEdition.hierarchyUpdate) {
            _userEdition.hierarchyUpdate.updateSubTreeAssociationConsistency();
         }
         if (!removeDockedNodesAndTryLostNodes()) {
            
            removeAllInvisibleNodesFromGraph();
         }
         
         var selectionModel:SelectionModel= am.visualModel.selectionModel
         var selectedNode:IPTNode = selectionModel.getSelectedNode();
         if (selectedNode != null) {
            if (selectedNode.vnode == null || !selectedNode.vnode.isVisible) {
               
               selectionModel.selectNode(_graphRootNode);
               am.components.pearlTreeViewer.interactorManager.updatePearlUnderCursorAfterCross();
            }
         }

         _vgraph.endNodeVisibilityManager.updateAllNodes();
         if (_inPTW) {
            endAnimation(null);
         } else {
            _creatingPearlEffect = makeNewNodeAnimation(createdIptNode);
            if (_dockingTreeNode==null || _dockingTreeNode.length==0) {
               layoutUpdatedTree();
            }
         }        
      }
      public function performPrivateStateChange(treeEdition:TreeEdition):void {

         var tree:BroPearlTree = treeEdition.tree;
         tree.changePrivacyState(!tree.isPrivate(), false, false);
         var node:IPTNode = tree.getRootNode().graphNode;
         if (node) {
            node.pearlVnode.refresh();
         }
      }
      public function makeNewNodeAnimation(newNodes:Array):Effect{
         var parallel:Parallel = new Parallel();
         for each (var n:IPTNode in newNodes) {
            if (n.vnode && n.vnode.isVisible && n.vnode.view) {
               var f:Fade = new Fade(n.vnode.view);
               f.alphaFrom =0;
               f.alphaTo =1;
               f.duration =300;
               n.vnode.view.alpha =0;
               parallel.addChild(f);
               
            }
         }
         if (parallel.children.length >0 ) {
            return parallel;
         }
         return null;
         
      }
      public function layoutUpdatedTree():void {
         
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         
         if (!navModel.isInMyWorld()){
            if (_userEdition.association.isMyAssociation() || navModel.focusAssoId != _userEdition.association.associationId) {
               endAnimation(null);
               return;
            }
         } else if (!_userEdition.association.isMyAssociation()) {
            endAnimation(null);
            return;
         } else if (!_graphRootNode) {
            endAnimation(null);
            return;
         }

         var goToTree:BroPearlTree = getFirstVisibleTree();
         if (goToTree &&  goToTree != _graphRootNode.containedPearlTreeModel.businessTree) {

            var navManager:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
            navManager.goTo(goToTree.getMyAssociation().associationId,
               navManager.getSelectedUser().persistentId,
               goToTree.id);
         }
         _vgraph.layouter.addEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, endAnimation);
         updateEdgeWeights();

         performSlowLayout();
      }
      public function performSlowLayout():void {
         _vgraph.PTLayouter.performSlowLayout();
         
      }
      private function clearGraphAndGoToTheSamePlace(newAssociation:BroAssociation,focusTree:BroPearlTree):void {
         var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         garp.postActionRequest(new ChangeFocusTeamAnimation(garp, _editionController, _vgraph));
         Log.getLogger("com.broceliand.graphLayout.controller.EditionProcessor").info("CLear graph new association tree :{0}", newAssociation.associationId);
         
         var navManager:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         var user:User = newAssociation.preferredUser;
         if (!user) {
            user = navManager.getSelectedUser();
         }
         
         navManager.goTo(newAssociation.associationId,
            user.persistentId,
            focusTree.id, -1,-1,-1,-1,0,false, 2);
      }
      
      private function getFirstVisibleTree():BroPearlTree {
         var goToTree:BroPearlTree = _graphRootNode.containedPearlTreeModel.businessTree;
         var path:Array = goToTree.treeHierarchyNode.getTreePath();
         if (_userEdition.lostTreesId) {
            for (var i:int=path.length; i-->0; ) {
               for each (var tid:int in _userEdition.lostTreesId){
                  if (tid == BroPearlTree(path[i]).id) {
                     
                     if (BroPearlTree(path[i]).getMyAssociation().associationId != ApplicationManager.getInstance().visualModel.navigationModel.focusAssoId) {
                        clearGraphAndGoToTheSamePlace(BroPearlTree(path[i]).getMyAssociation(), goToTree);
                        return goToTree;
                     } else {
                        if (i>0) {
                           goToTree = path[i-1];
                        }
                     }
                  }
               }
            }
         }
         var rootTree:BroPearlTree = _startTreePath[0];
         if (rootTree) {
            while (path[0] != rootTree) {
               goToTree = _startTreePath.pop();
               if (!goToTree || !goToTree.treeHierarchyNode)  {
                  break;
               }
               path = goToTree.treeHierarchyNode.getTreePath();
            }
         }
         return goToTree;
      }
      private function updateEdgeWeights():void {
         _graphRootNode.updatingNumberOfDescendant();
         
      }
      private function endAnimation(event:Event):void {
         if (event) {
            var eventDispatcher:IEventDispatcher = event.target as IEventDispatcher;
            eventDispatcher.removeEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, endAnimation);
         }
         if (_creatingPearlEffect) {
            _creatingPearlEffect.addEventListener(EffectEvent.EFFECT_END, endAnimation);
            _creatingPearlEffect.play();
            _creatingPearlEffect = null;
            return;
         }
         dispatchEvent(new Event(ANIMATION_ENDED_EVENT));
      }

      private function createGraphicalNodes(t:TreeEdition, id2IptNodes:Dictionary):Array{
         var newNodes:Array;
         var newNodeEditions:Array = t.createdNodesEdition;
         var gnode:IPTNode;
         if (newNodeEditions){
            for each (var newNodeEdition:CreateNodeInTree in newNodeEditions) {
               gnode= _editionController.createNode(newNodeEdition.moveNode);
               newNodes = BroUtilFunction.addToArray(newNodes, gnode);
               id2IptNodes[newNodeEdition.newNodeId] = gnode;
            }
         }
         var nodeMoveFromOtherTrees:Array = t.moveNodesFromOtherTrees;
         if (nodeMoveFromOtherTrees) {
            for each (var moveIntoTree:MoveNodeBetweenTrees in nodeMoveFromOtherTrees) {
               if (!id2IptNodes[moveIntoTree.movePearlId]) {
                  gnode = _editionController.createNode(moveIntoTree.moveNode);
                  newNodes = BroUtilFunction.addToArray(newNodes, gnode);
                  id2IptNodes[moveIntoTree.movePearlId]= gnode;
               }
            }
         }
         return newNodes;
      }
      
      private function unlinkAllMovedNodesAndComputeNodeToDelete(t:TreeEdition, treeWithGraphicalEdition:Dictionary, id2IptNodes:Dictionary):IVisualNode{
         
         var endNode:IVisualNode = null;
         var nodesToRemove:Array;
         var nodeMoveToOtherTrees:Array = t.moveNodesToOtherTrees;
         var rootNode:PTRootNode = treeWithGraphicalEdition[t.tree];
         if (rootNode) {
            endNode = _editionController.detachEndNode(rootNode.containedPearlTreeModel);
         }
         
         if (nodeMoveToOtherTrees) {
            for each (var moveOut:MoveNodeBetweenTrees in nodeMoveToOtherTrees) {
               nodesToRemove = BroUtilFunction.addToArray(nodesToRemove, unlinkNode(moveOut.moveNode, moveOut.oldParentNode, treeWithGraphicalEdition[moveOut.newTree] == null && !moveOut.newTree.isDropZone(), id2IptNodes));
            }
         }
         var deletedNodes:Array = t.lostNodes;
         if (deletedNodes) {
            for each (var n:BroPTNode  in deletedNodes) {
               nodesToRemove = BroUtilFunction.addToArray(nodesToRemove, unlinkNode(n , n.parent, true, id2IptNodes));
               n.deletedByUser = true;
            }
         }
         var nodeMoveFromOtherTrees:Array = t.moveNodesFromOtherTrees;
         if (nodeMoveFromOtherTrees) {
            for each (var moveIntoTree:MoveNodeBetweenTrees in nodeMoveFromOtherTrees) {
               unlinkNode(moveIntoTree.moveNode, moveIntoTree.oldParentNode, false, id2IptNodes);
            }
         }
         
         var nodeMoveInTree:Array = t.moveNodesInTrees;
         if (nodeMoveInTree && !t.isDropzone) {
            for each (var moveInTree:MoveNodeInTree in nodeMoveInTree) {
               unlinkNode(moveInTree.moveNode, moveInTree.oldParent, false, id2IptNodes);
            }
         }
         if (nodesToRemove) {
            if(!_nodesToRemoveFromGraph) {
               _nodesToRemoveFromGraph = nodesToRemove;
            } else {
               _nodesToRemoveFromGraph = _nodesToRemoveFromGraph.concat(nodesToRemove);
            }
         }
         return endNode;
      }

      private function linkAllNodes(t:TreeEdition, id2IptNodes:Dictionary, withGraphicUpdates:Boolean):Boolean {
         var nodeToHide:Array=null;
         var editions:Array = t.getOrderedEditions();
         if (!editions) {
            return false;
         }
         var dropZone:IDeckModel;
         if (t.isDropzone) {
            dropZone =  _vgraph.controls.dropZoneDeckModel;
         }
         for each (var e:IEdition in editions) {
            if (withGraphicUpdates) {
               var moveNode:IPTNode = getGraphicalNode(id2IptNodes,e.moveNode.persistentID);
               
               if (moveNode is EndNode) {
                  moveNode = moveNode.rootNodeOfMyTree;
               }
               if (e.newParent == null) {
                  Log.getLogger("com.broceliand.graphLayout.controller.EditionProcessor").error("unpextected null e.newParent value for move node : {0} edition {1} ",moveNode, e);
                  continue;
               }
               
               var parentNode:IPTNode = getGraphicalNode(id2IptNodes, e.newParent.persistentID);
               
               if (moveNode && moveNode.vnode  && parentNode && parentNode.vnode) {
                  _editionController.tempLinkNodes(parentNode.vnode, moveNode.vnode, e.newIndex);
                  _editionController.confirmNodeParentLink(moveNode.vnode, false, e.newIndex);
                  if (!parentNode.vnode.isVisible) {
                     nodeToHide = BroUtilFunction.addToArray(nodeToHide, moveNode);
                  }
               }
               
               e.newParent.owner = t.tree;
               t.tree.addToNode(e.newParent, e.moveNode, e.newIndex);
               Log.getLogger("com.broceliand.graphLayout.controller.EditionProcessor").info("Link node in bmodel {0}({1}) to {2}({3}) at {4}", e.moveNode.title, e.moveNode.persistentID, e.newParent.title, e.newParent.persistentID, e.newIndex);
               
            } else {
               if (t.isDropzone) {
                  
                  var dockNode:IPTNode= getGraphicalNode(id2IptNodes, e.moveNode.persistentID);
                  if (dockNode is EndNode) {
                     dockNode = dockNode.rootNodeOfMyTree;
                  }
                  if (dockNode is PTRootNode && PTRootNode(dockNode).isOpen()) {
                     dockOpenTree(dockNode as PTRootNode, dropZone);
                  } else if (dockNode && dockNode.vnode ) {
                     dockNode.dock(dropZone);
                  }
                  
               }
               e.newParent.owner = t.tree;
               t.tree.addToNode(e.newParent, e.moveNode, e.newIndex);
               Log.getLogger("com.broceliand.graphLayout.controller.EditionProcessor").info("Link node in bmodel {0}({1}) to {2}({3}) at {4}", e.moveNode.title, e.moveNode.persistentID, e.newParent.title, e.newParent.persistentID, e.newIndex);
            }
            
         }
         if (nodeToHide) {
            
            return true;
         }
         return false;
      }
      private function dockOpenTree(dockNode:PTRootNode, dropZone:IDeckModel):void {
         
         var animation:QuickCloseAnimationWithNoLayout= new QuickCloseAnimationWithNoLayout(null, ApplicationManager.getInstance().visualModel.animationRequestProcessor);
         if (dockNode.vnode) {
            _graphicaNavController.internalCloseTreeNode(dockNode.vnode, animation);
         }
         if (dockNode.vnode.isVisible) {
            _dockingTreeNode = BroUtilFunction.addToArray(_dockingTreeNode, dockNode);
            var action:GenericAction = new GenericAction(null, this, dockOnEndAnimation, dockNode, dropZone);
            animation.addEventListener(OpenTreeAnimationControllerBase.ANIMATION_ENDED_EVENT, action.performActionOnFirstEvent);
            animation.startClosingAnimation(_displayModel, dockNode.vnode);
         } else {
            
            _nodesToRemoveFromGraph = BroUtilFunction.addToArray(_nodesToRemoveFromGraph, _graphRootNode);
            dockNode = _editionController.createNode(dockNode.getBusinessNode()) as PTRootNode;
            dockNode.containedPearlTreeModel.openingState = OpeningState.CLOSED;
            dockNode.dock(dropZone);
            
         }
      }
      public function dockOnEndAnimation(ptRootNode:PTRootNode, dropZone:IDeckModel):void {
         ptRootNode.dock(dropZone);
         _dockingTreeNode.splice(_dockingTreeNode.lastIndexOf(ptRootNode));
         if (_dockingTreeNode.length ==0) {
            layoutUpdatedTree();
         }
      }

      private function unlinkNode(node:BroPTNode, oldParentNode:BroPTNode, shouldRemove:Boolean, id2IptNodes:Dictionary):IPTNode {
         if (oldParentNode){
            unlinkBusinessNodeFromParent(node,oldParentNode);
         }
         var gnode:IPTNode = getGraphicalNode(id2IptNodes, node.persistentID);
         if (gnode is EndNode) {
            gnode = gnode.rootNodeOfMyTree;
         }
         unlinkGraphNodeFromParent(gnode);
         if (shouldRemove && gnode && gnode.vnode) {
            return gnode;
         }
         return null;
         
      }

      private function removeDockedNodesAndTryLostNodes():Boolean{
         var treeToDelete:Array;
         if (_nodesToRemoveFromGraph) {
            for each (var  n:IPTNode in _nodesToRemoveFromGraph) {
               if (n is PTRootNode && PTRootNode(n).isOpen()) {
                  treeToDelete = BroUtilFunction.addToArray(treeToDelete, n);
               }
            }
         }
         
         if (treeToDelete) {
            var openTreesModel:OpenTreesStateModel = ApplicationManager.getInstance().visualModel.openTreesModel;
            for each (var r:PTRootNode in treeToDelete) {
               _nodesToRemoveFromGraph =  _nodesToRemoveFromGraph.concat(r.getDescendantsAndSelf());
            }
         }
         
         if (_nodesToRemoveFromGraph != null) {
            
            var shouldRemoveRoot:Boolean = (_nodesToRemoveFromGraph.lastIndexOf(_graphRootNode)>=0);
            if (!shouldRemoveRoot) {
               for each (r in treeToDelete) {
                  openTreesModel.closeTree(1, r.treeOwner.id);
               }
               
            }
            
            for each (n in _nodesToRemoveFromGraph) {
               if (shouldRemoveRoot) {
                  if (n.isDocked) {
                     removeNode(n);
                  }
               } else {
                  removeNode(n);
               }
            }
            return !shouldRemoveRoot;
         }
         return true;
         
      }
      private function removeNode(gnode:IPTNode):void {
         if (gnode && gnode.vnode ) { 
            if (gnode is PTRootNode  && PTRootNode(gnode).isOpen()) {
               var openTreesModel:OpenTreesStateModel = ApplicationManager.getInstance().visualModel.openTreesModel;
               openTreesModel.closeTree(1,  PTRootNode(gnode).containedPearlTreeModel.businessTree.id);
            }
            _vgraph.removeNode(gnode.vnode);
         }
      }
      private function unlinkBusinessNodeFromParent(node:BroPTNode, oldParentNode:BroPTNode):void {
         var linkIndex:int = oldParentNode.getChildIndex(node);
         if (linkIndex>=0) {
            oldParentNode.removeChildLink(oldParentNode.childLinks[linkIndex]);
         }
      }
      private function unlinkGraphNodeFromParent(gnode:IPTNode):void {
         if (gnode) {
            if (gnode.isDocked) {

               gnode.undock();
               
            }
            if ( gnode.parent) {
               var parentVnode:IVisualNode = gnode.parent.vnode;
               if (parentVnode && gnode.vnode) {
                  _editionController.tempUnlinkNodes(parentVnode,gnode.vnode);
               }
            }
         }
      }
      
      private function indexGraphNodes(graphRootNodes:Dictionary):Dictionary {
         var result:Dictionary = new Dictionary();
         for each (var rootNodes:IPTNode in graphRootNodes) {
            var nodes:Array = rootNodes.getDescendantsAndSelf();
            for each (var n:IPTNode  in nodes) {
               var bnode:BroPTNode = n.getBusinessNode();
               if(bnode){
                  result[bnode.persistentID] = n;
                  if (bnode is BroPTRootNode && bnode.owner.refInParent) {
                     result[bnode.owner.refInParent.persistentID] = n;
                  }
               }
            }
         }
         
         var dropZone:IDeckModel = _vgraph.controls.dropZoneDeckModel;
         for (var i:int=0; i<dropZone.getItemsCount(); i++) {
            var dropNode:DeckItem= dropZone.getItemAt(i);
            bnode = dropNode.dataSource as BroPTNode;
            if (!bnode) {
               bnode = dropNode.node.getBusinessNode();
            }
            var itemId:Number = bnode.persistentID;
            result[itemId] = dropNode;
         }
         return result;
      }
      
      public function findGraphicalTreesToUpdate():Dictionary{
         var graphicalTrees:Dictionary = new Dictionary();
         if (!_inPTW) {
            for each (var t:TreeEdition in _userEdition.getTreesEdition()) {
               var node:PTRootNode = _displayModel.getNode(t.tree) as PTRootNode;
               if (node && node.containedPearlTreeModel.openingState == OpeningState.OPEN) {
                  graphicalTrees[t.tree] = node;
               }
            }
         }
         return graphicalTrees;
      }
      public function reattachEndNodes(endVNodes:Array):void {
         if (endVNodes) {
            for each (var endNode:IVisualNode in endVNodes) {
               _editionController.reattachEndNode(endNode);
            }
         }
      }
      public function removeAllInvisibleNodesFromGraph():void {
         var nodesToKeep:Dictionary = new Dictionary();
         var nodes2Remove:Array = new Array();
         
         for each (var n:IPTNode in _graphRootNode.getDescendantsAndSelf()) {
            nodesToKeep[n] =n;
         }
         if (_dockingTreeNode) {
            for each (n in _dockingTreeNode) {
               nodesToKeep[n] =n;
            }
         }

         for each (var node:IPTNode in _vgraph.graph.nodes) {
            if(!node.getDock() && nodesToKeep[node] == null) {
               nodes2Remove.push(node);
            }
         }
         
         for each (node in nodes2Remove) {
            removeNode(node);
         }
      }

      private function changeNodesType(changeTypesNode:Array, id2IptNodes:Dictionary ):Boolean{
         var updateVisibility:Boolean = false;
         var displayedNode:IPTNode = ApplicationManager.getInstance().components.windowController.getNodeDisplayed();
         if (changeTypesNode) {
            for each (var edition:ChangeNodeType in changeTypesNode) {
               var oldNode:BroTreeRefNode = edition.oldNode;
               var endNodeToClose:IPTNode = null;
               if (edition.newNode.isContentTypeMatch(AmfTreeService.CONTENT_TYPE_TREE) && edition.oldNode.refTree.isAssociationRoot()) {
                  oldNode.refTree.getMyAssociation().isDissolvedAssociation = true;
               }
               
               oldNode.changeNodeType(edition.newNode);
               oldNode.refTree.getMyAssociation().isDissolvedAssociation = false;
               
               var oldIPTNode:IPTNode = getGraphicalNode(id2IptNodes, oldNode.persistentID);
               Log.getLogger("com.broceliand.graphLayout.controller.EditionProcessor").info("Change visible type node {0}",oldNode.title);
               if (oldIPTNode) {
                  if (oldNode is BroLocalTreeRefNode && !(edition.newNode is BroLocalTreeRefNode)) {
                     if (oldIPTNode is EndNode) {
                        oldIPTNode = oldIPTNode.rootNodeOfMyTree;
                     }
                     if (PTRootNode(oldIPTNode).isOpen()) { 
                        var focusTree:BroPearlTree =ApplicationManager.getInstance().visualModel.navigationModel.getFocusedTree();
                        var focusTreePath:Array = focusTree.treeHierarchyNode.getTreePath();
                        if (focusTreePath.lastIndexOf(oldNode.refTree) != -1 || focusTreePath.lastIndexOf(edition.newNode.refTree) != -1) {
                           continue;
                        } else {
                           
                           if (!oldIPTNode.vnode.isVisible) {
                              continue;
                           } else {

                              endNodeToClose = PTRootNode(oldIPTNode).containedPearlTreeModel.endNode;
                           }
                           
                        }
                     }
                  }
                  
                  var changeAction:ChangeNodeTypeAction= new ChangeNodeTypeAction(_editionController, _graphicaNavController, oldIPTNode, oldNode, edition.newNode);
                  if (endNodeToClose) {
                     _editionController.closeTreeNode(oldIPTNode.vnode);
                     var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
                     garp.postActionRequest(new GenericAction(garp, changeAction, changeAction.replaceGraphicalNode));
                  } else {
                     var newIPTNode:IPTNode = changeAction.replaceGraphicalNode();
                     if (newIPTNode.parent && !newIPTNode.parent.vnode.isVisible) {
                        
                        updateVisibility =true;
                     }
                     if (displayedNode == oldNode) {
                        ApplicationManager.getInstance().components.windowController.displayNodeInfo(newIPTNode);
                     }
                  }
               }
            }
            ApplicationManager.getInstance().components.mainPanel.navigationBar.model.refreshModel();
         }
         return updateVisibility;
      }
   }
}
