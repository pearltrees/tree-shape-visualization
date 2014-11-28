package com.broceliand.graphLayout.controller
{
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.graphLayout.visual.PTVisualNodeBase;
   import com.broceliand.pearlTree.model.BroAnonymousTreeRefNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.model.NeighbourPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.effects.ChangePropertyEffect;
   import com.broceliand.ui.effects.MoveWithScroll;
   import com.broceliand.ui.effects.UnfocusPearlEffect;
   import com.broceliand.ui.interactors.DepthInteractor;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UICenterPTWPearl;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.ui.util.Profiler;
   import com.broceliand.util.Alert;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   import mx.effects.Effect;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.effects.Pause;
   import mx.effects.Sequence;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class PTWAnimationController 
   {
      private static const TRACE_DEBUG:Boolean = false;
      private static const RECYCLE_NODES:Boolean = false;
      
      private var _vgraph:IPTVisualGraph;
      private var _editionController:IPearlTreeEditionController;  
      private var _selectionModel:SelectionModel;
      private var _navModel:INavigationManager;
      private var _garp:GraphicalAnimationRequestProcessor;
      private var _actionsToPerform:Array = new Array();
      private var _currentRequest:IAction;
      
      public function PTWAnimationController(vgraph:IPTVisualGraph, editionController:IPearlTreeEditionController, garp:GraphicalAnimationRequestProcessor)
      {
         _vgraph = vgraph;
         _editionController = editionController;
         _selectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         _navModel = ApplicationManager.getInstance().visualModel.navigationModel;
         _garp = garp;
      }
      
      public function onAnimationEnd():void  {
         _garp.notifyEndAction(_currentRequest);
         _currentRequest = null;
      }
      
      public function createPTW(newPTW:BroPearlTree, crossingNode:BroPTNode, request:IAction):void {                
         var am:ApplicationManager = ApplicationManager.getInstance();
         _vgraph.controls.unfocusButton.visible=false;
         _currentRequest = request;
         
         if (crossingNode is BroDistantTreeRefNode && BroDistantTreeRefNode(crossingNode).treeId == newPTW.id) {
            
         } else { 
            
            crossingNode = null;
         }
         var nodesToRemove:Array = _editionController.clearGraph(false);
         var nodesToMoveToTheCenter:Array = new Array();

         var clearTreeEffect:Sequence;
         
         var vnodeToKeep:IVisualNode;
         var vgraphCurrentRootVnode:IPTVisualNode = _vgraph.currentRootVNode as IPTVisualNode;
         var vgraphCurrentRootBusinessNode:BroPTNode;
         var vgraphCurrentRootTree:BroPearlTree;
         if(vgraphCurrentRootVnode) {
            vgraphCurrentRootBusinessNode = vgraphCurrentRootVnode.ptNode.getBusinessNode();
         }
         if(vgraphCurrentRootBusinessNode) {
            vgraphCurrentRootTree = vgraphCurrentRootBusinessNode.owner;
         }
         
         if(_navModel.isShowingDiscover() && am.useDiscover() && !_navModel.isShowingSearchResult() && !_navModel.isWhatsHot() && newPTW && newPTW.equals(vgraphCurrentRootTree)) {
            vnodeToKeep = _vgraph.currentRootVNode;
         }
         var tree:BroPearlTree = findTreeInCurrentGraph(newPTW);
         if (tree) {
            _selectionModel.highlightTree(tree);
            var nodesToRemoveNotInTheTree:Array = new Array();
            var nodeToKeep:BroPTNode = tree.getRootNode();
            if (crossingNode) {
               nodeToKeep = crossingNode
            }
            var vnodeToKeepFound:Boolean = false;
            var subtrees:Array = tree.treeHierarchyNode.getDescendantTrees();
            for each (var n:IPTNode in nodesToRemove) {
               if (!vnodeToKeepFound && n.getBusinessNode() == nodeToKeep &&  !(n is EndNode)) { 
                  vnodeToKeep = n.vnode;
                  vnodeToKeepFound =true;
               } else if (!vnodeToKeepFound &&  n.getBusinessNode() is BroTreeRefNode && BroTreeRefNode(n.getBusinessNode()).refTree == tree && !(n is EndNode)) {
                  vnodeToKeep = n.vnode;
                  vnodeToKeepFound =true;
               } else {
                  if (subtrees.lastIndexOf(n.getBusinessNode().owner)==-1 || !n.vnode.isVisible) {
                     nodesToRemoveNotInTheTree.push(n);
                     continue;
                  } else if (n is EndNode) {
                     
                     if (n.getBusinessNode().owner == tree) {
                        nodesToRemoveNotInTheTree.push(n);
                        continue;
                     }
                  } 
                  
               }
               nodesToMoveToTheCenter.push(n);
            }  
            nodesToRemove = nodesToRemoveNotInTheTree;
         }        

         var effect:Effect= makeDisappearEffect(nodesToRemove, vnodeToKeep);
         if (effect) {
            clearTreeEffect = new Sequence();
            clearTreeEffect.addChild(effect);
            effect = new Pause();
            effect.duration = 300;
            clearTreeEffect.addChild(effect);
         }
         effect=null;
         var depthInteractor:DepthInteractor = am.components.pearlTreeViewer.interactorManager.depthInteractor;
         if (vnodeToKeep) {
            depthInteractor.movePearlAboveAllElse(vnodeToKeep.view as IUIPearl);   
         }

         var moveEffect:Parallel = new Parallel();
         nodesToRemove = new Array();
         var action:IAction = new RemoveVNodesAtAnimationEnd(nodesToRemove, null); 
         var remover :GraphicalActionSynchronizer = new GraphicalActionSynchronizer(action);
         
         effect = null;
         
         var move:Move;
         if (vnodeToKeep) {
            var vnodeToKeepView:IUIPearl = vnodeToKeep.view  as IUIPearl;
            var targetPoint:Point = vnodeToKeepView.positionWithoutZoom;  
            
            for each (n in nodesToMoveToTheCenter) {
               if (!n.vnode.view || n.vnode.viewX != targetPoint.x || n.vnode.viewY != targetPoint.y && n.vnode != vnodeToKeep) {
                  move =_vgraph.moveNodeTo(n.vnode, targetPoint.x, targetPoint.y, 300, false);
                  (n.vnode as PTVisualNodeBase).notifyInMove(move);
                  effect = move;
                  
                  remover.registerComponentToWaitForEvent(effect, EffectEvent.EFFECT_END);
                  moveEffect.addChild(effect);   
               }
               if (n.vnode != vnodeToKeep) {
                  nodesToRemove.push(n);
               }
            }
         }
         if (effect) {
            if (!clearTreeEffect) {
               clearTreeEffect = new Sequence();
            }
            clearTreeEffect.addChild(moveEffect);
         } 
         var vnodesFromOutsideScreen:Array = new Array();
         
         if (newPTW) {
            var oldVRoot:IPTVisualNode= _vgraph.currentRootVNode as IPTVisualNode;
            var bnode:BroPTNode = newPTW.getRootNode();
            var vnode:IPTVisualNode = _vgraph.createNode("[ptw."+bnode.persistentID+"]:" + bnode.title, bnode)  as IPTVisualNode;
            
            if (oldVRoot) {
               
               var vedge:IVisualEdge = _vgraph.linkNodes(vnode, oldVRoot);
               EdgeData(vedge.data).visible = false;
               
               if(vnodeToKeep) {
                  vnodeToKeep.refresh();
               }
               
               if(am.useDiscover() && _navModel.isShowingDiscover()) {
                  
                  if(vnodeToKeep) {
                     
                     effect = new Pause();
                     effect.duration = 100;
                     clearTreeEffect.addChild(effect);
                     
                     var moveWithScroll:MoveWithScroll = new MoveWithScroll(vnodeToKeep.view);
                     moveWithScroll.duration = 300;
                     moveWithScroll.xTo = _vgraph.center.x - PTRootPearl.PEARL_WIDTH_EXCITED * _vgraph.scale / 2.0;
                     moveWithScroll.yTo = _vgraph.center.y - PTRootPearl.PEARL_WIDTH_EXCITED * _vgraph.scale / 2.0;;
                     clearTreeEffect.addChild(moveWithScroll);
                  }
               }
               if(vnodeToKeep) {
                  vnode.pearlView.animationZoomFactor = oldVRoot.pearlView.animationZoomFactor;
                  vnode.pearlView.setBigger(true); 
                  vnode.pearlView.move(vnodeToKeep.viewX, vnodeToKeep.viewY);
               }
            }
            
            if(am.useDiscover() && _navModel.isShowingDiscover()) {
               _vgraph.origin.x = 0;
               _vgraph.origin.y = 0;            
            }
            
            _vgraph.currentRootVNode = vnode;
            
            var rootNode:IPTNode = vnode.node as IPTNode;
            if (!rootNode.getBusinessNode().owner.isWhatsHot()) {
               ApplicationManager.getInstance().components.windowController.displayNodeInfo(vnode.node as IPTNode);
            }
            var newNodes:Array = newPTW.getRootNode().getDescendants();
            if (oldVRoot){
               newNodes.splice(newNodes.lastIndexOf(oldVRoot.node), 1);
            }
            createNodes(vnode, newPTW.getRootNode().getDescendants(), vnodesFromOutsideScreen);         
            if (vnodesFromOutsideScreen.length || am.useDiscover()) {
               var gsynchro:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(new CreateNewPTWAction(this, _vgraph, vnodesFromOutsideScreen, null, clearTreeEffect, vnodeToKeep, _selectionModel));
               var view:IUIPearl = _vgraph.currentRootVNode.view as IUIPearl;
               if (!view.isCreationCompleted()) {
                  gsynchro.registerComponentToWaitForCreation(_vgraph.currentRootVNode.view);
               }
               _vgraph.currentRootVNode.view.visible =false;
               for each (vnode in vnodesFromOutsideScreen) {
                  view = vnode.view as IUIPearl;
                  if (view && !view.isCreationCompleted()) {
                     gsynchro.registerComponentToWaitForCreation(vnode.view);
                  }   
                  vnode.view.visible =false;
               }
               gsynchro.performActionAsap();
            }
         }
         else 
         {
            var rootVgraph:IVisualNode = _vgraph.currentRootVNode;
            if (rootVgraph) {
               rootVgraph.view.visible =false;
               applyPTWStyleToNodes(IPTNode(rootVgraph.node));
               if (clearTreeEffect) {        
                  clearTreeEffect.play();
               }      
               cleanPTWLayout(_vgraph,  vnodesFromOutsideScreen, null);
            }
         }
         remover.performActionAsap();
      }
      
      private function makeDisappearEffect(nodesToRemove:Array, vnodeToSkip:IVisualNode ):Effect{
         
         var disappearEffect:Parallel = new Parallel();
         var effect:UnfocusPearlEffect;
         var nodesToRemoveAtAnimationEnd:Array = new Array();
         var action:IAction = new RemoveVNodesAtAnimationEnd(nodesToRemoveAtAnimationEnd,this);
         _actionsToPerform.push(action);
         var remover :GraphicalActionSynchronizer = new GraphicalActionSynchronizer(action);
         for each (var node:IPTNode in nodesToRemove) {
            if (node.vnode.isVisible== false || node.vnode.view.alpha==0 ) {
               
               _vgraph.removeNode(node.vnode);
            } else{
               if (node.vnode != vnodeToSkip) {
                  effect = new UnfocusPearlEffect(node.vnode.view);
                  effect.duration = 500;
                  nodesToRemoveAtAnimationEnd.push(node);
                  remover.registerComponentToWaitForEvent(effect, TweenEvent.TWEEN_END);
                  disappearEffect.addChild(effect);
               }
            }
         } 
         
         if (effect) {
            effect.addEventListener(TweenEvent.TWEEN_UPDATE, refreshGraphOnEffect, false, 0, true);
         } else {
            disappearEffect = null;
         }
         return disappearEffect;
      }
      
      private function refreshGraphOnEffect(event:TweenEvent):void{ 
         _vgraph.refresh();
      }  
      
      public function moveInPTW(newPTW:BroPearlTree, request:IAction):void {
         _currentRequest = request;
         if (newPTW == null) {
            createPTW(null, null, request);
            return;
         }
         
         Profiler.getInstance().startSession("movePTW");
         var rootNode:BroNeighbourRootPearl = newPTW.getRootNode() as BroNeighbourRootPearl;
         var newRootTree:BroPearlTree = (rootNode.delegateNode as BroTreeRefNode).refTree;
         var rootTreeKey:String = BroPearlTree.getTreeKey(newRootTree.dbId, newRootTree.id);
         var key:String;
         var vnode:IPTVisualNode;
         var allowMultipleNodeByTree:Boolean = (_navModel.isShowingDiscover() && ApplicationManager.getInstance().useDiscover());
         var tree2Node :Dictionary = makeTreeAlias2VnodeFromCurrentVgraph(_vgraph, true, allowMultipleNodeByTree);
         var newNodes:Array = new Array();
         var descendants:Array = newPTW.getRootNode().getDescendants();
         var refNode:BroPTWDistantTreeRefNode; 
         var nodesToKeep:Array = new Array();
         var newRootVNode:IPTVisualNode = _vgraph.createNode("[ptw.root."+rootNode.persistentID+"]:" + rootNode.title, rootNode) as IPTVisualNode;
         
         newRootVNode.view.alpha=0;
         newRootVNode.pearlView.pearl.showRings = false;
         createInvisibleLink(_vgraph.currentRootVNode, newRootVNode);
         for each (var n:BroPTNode in descendants) {
            refNode = n as BroPTWDistantTreeRefNode;
            if (refNode) {
               key = BroPearlTree.getTreeKey(refNode.treeDB, refNode.treeId);
               vnode = tree2Node[key]
               if (vnode) {
                  vnode.view.alpha=1;
                  var bnode:BroPTWDistantTreeRefNode = IPTNode(vnode.node).getBusinessNode() as BroPTWDistantTreeRefNode;
                  bnode.preferredRadialPosition = refNode.preferredRadialPosition;
                  if (bnode.isSearchNode) {
                     if (refNode.isSearchNode) {
                        bnode.isSearchCenter = refNode.isSearchCenter;
                     } else {
                        bnode.isSearchCenter = false;
                     }
                  }
                  bnode.preferredRadialPosition = refNode.preferredRadialPosition ;
                  delete tree2Node[key];
                  _vgraph.unlinkNodes(_vgraph.currentRootVNode, vnode);
                  createInvisibleLink(newRootVNode, vnode);
               }
               else {
                  newNodes.push(refNode);
               }
               
            } 
         }
         
         var vnodesFromOutsideScreen:Array = new Array();
         var nodesToGoAway:Array = new Array();

         for each (vnode in tree2Node) {
            if (getTreeKeyAndResetSearchCenter(vnode, false) == rootTreeKey) {
               
               continue;
            }
            if (isInScreen(vnode)) {
               nodesToGoAway.push(vnode);
               _vgraph.unlinkNodes(_vgraph.currentRootVNode, vnode);
               createInvisibleLink(newRootVNode, vnode);
            } else {
               _vgraph.removeNode(vnode);
            }
         }
         createNodes(newRootVNode, newNodes, vnodesFromOutsideScreen);
         
         _vgraph.origin.x=0;
         _vgraph.origin.y=0;
         
         var gsynchro:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(new MoveINPTWAction(this, _vgraph, vnodesFromOutsideScreen, nodesToGoAway, newRootVNode, tree2Node));
         gsynchro.registerComponentToWaitForCreation(newRootVNode.view);
         for each (vnode in vnodesFromOutsideScreen) {
            vnode.view.alpha=0;
            vnode.pearlView.pearl.showRings = false;
            if (!IUIPearl(vnode.view).isCreationCompleted()) {  
               gsynchro.registerComponentToWaitForCreation(vnode.view);
            }
         }
         gsynchro.performActionAsap();
      }
      private function isInScreen(vnode:IVisualNode):Boolean {
         return IPTNode(vnode.node).isRendererInScreen();        
      }
      
      private function createInvisibleLink(rootVNode:IVisualNode, vnode:IVisualNode):void {
         var vedge:IVisualEdge  = _vgraph.linkNodes(rootVNode, vnode);
         var edgeData:EdgeData= vedge.data as EdgeData;
         edgeData.visible=false;          
      }
      
      private function createNodes(rootVNode:IVisualNode, newBNodes:Array, result:Array):void {
         Profiler.getInstance().addMarker("-", "search");         
         var vnode:IVisualNode;
         while (newBNodes.length>0) {
            var bnode:BroPTNode = newBNodes.pop() as BroPTNode;
            vnode = _vgraph.createNode("[ptw."+bnode.persistentID+"]:" + bnode.title, bnode);
            createInvisibleLink(rootVNode, vnode);  
            result.push(vnode);                        
         }
         Profiler.getInstance().addMarker("create pearls", "search");          
      }
      public function applyPTWStyleToNodes(rootNode:IPTNode):void {
         var nodes:Array = rootNode.getDescendantsAndSelf();
         
         for each (var node:IPTNode in nodes) {
            if (node.predecessors.length>0) {
               EdgeData(IEdge(node.inEdges[0]).data).visible=false;
            }
            if (node.vnode.isVisible) { 
               (node.vnode.view as IUIPearl).forbidMove(true);
            }
         }
         
         var neighbourRootPearl:BroNeighbourRootPearl = rootNode.getBusinessNode() as BroNeighbourRootPearl;
         if (neighbourRootPearl && neighbourRootPearl.delegateNode is BroAnonymousTreeRefNode) {
            rootNode.vnode.view.visible=false;
         } else {
            rootNode.vnode.view.visible=true;
         }
      }
      private function makeTreeAlias2VnodeFromCurrentVgraph(vgraph:IVisualGraph, resetSearchCenter:Boolean, allowMultipleNodeByTree:Boolean=false) :Dictionary {
         var tree2Node :Dictionary = new Dictionary() 
         var refNode:BroPTWDistantTreeRefNode; 
         
         for each (var vnode:IVisualNode in vgraph.visibleVNodes) {
            var tk:String = getTreeKeyAndResetSearchCenter(vnode,resetSearchCenter);
            if (tk) {
               if(tree2Node[tk] && allowMultipleNodeByTree) {
                  tk += "-"+vnode.view.toString();
               }
               tree2Node[tk] = vnode;
            }
         }
         return tree2Node;         
      }
      
      private function getTreeKeyAndResetSearchCenter(vnode:IVisualNode, resetSearchCenter:Boolean):String {
         var bnode:IBroPTWNode = IPTNode(vnode.node).getBusinessNode() as IBroPTWNode;
         if (bnode) {
            if (resetSearchCenter && bnode.isSearchNode && bnode.isSearchCenter) {
               bnode.isSearchCenter = false;
            }
            return bnode.indexKey;
         }
         else {
            if(TRACE_DEBUG) trace ("Bad node type "+IPTNode(vnode.node).getBusinessNode());
            return null;
         }
      }

      public function changeVGraphRoot( vgraph:IVisualGraph,  newRootVnode:IPTVisualNode, tree2VNode:Dictionary, nodesThatGoAway:Array):void {
         var rootNode:BroNeighbourRootPearl = newRootVnode.ptNode.getBusinessNode() as BroNeighbourRootPearl;
         var newRoot:BroTreeRefNode = rootNode.delegateNode as BroTreeRefNode;
         var key:String =BroPearlTree.getTreeKey(newRoot.treeDB, newRoot.treeId);
         var previousVNode:IPTVisualNode= tree2VNode[key];
         var oldVRootNode:IVisualNode  = vgraph.currentRootVNode; 
         if (oldVRootNode) {
            var rootView:IUIPearl =   _vgraph.currentRootVNode.view as IUIPearl;
            if (rootView) {
               (rootView as UICenterPTWPearl).setShowHalo(false);
            }
            if (previousVNode && previousVNode.view) {
               var previousNodePos:Point = previousVNode.pearlView.positionWithoutZoom;

               newRootVnode.pearlView.moveWithoutZoomOffset(previousNodePos.x, previousNodePos.y);
               newRootVnode.pearlView.animationZoomFactor = previousVNode.pearlView.animationZoomFactor;
               var point:Point = _vgraph.currentRootVNode.viewCenter.clone();
               var p :Point =  new Point(rootView.x, rootView.y);
               
               if (isInScreen(previousVNode)) {
                  
                  var graphCenter:Point = newRootVnode.viewCenter;
                  IPTVisualGraph(vgraph).offsetOrigin(graphCenter.x-point.x, graphCenter.y-point.y);
               } else {
                  vgraph.origin.x=0;
                  vgraph.origin.y=0;
               }
               _vgraph.removeNode(previousVNode);
            }
            if (rootNode.delegateNode is BroAnonymousTreeRefNode) {
               
               newRootVnode.view.visible=false;
               _vgraph.origin.x=0;
               _vgraph.origin.y=0;  
            } else {
               
            }
            nodesThatGoAway.push(oldVRootNode);
            vgraph.unlinkNodes(oldVRootNode, newRootVnode);
            createInvisibleLink(newRootVnode, oldVRootNode);
         }
         vgraph.currentRootVNode = newRootVnode;
      }
      
      public function cleanPTWLayout(vgraph:IPTVisualGraph, newVNodes:Array, nodesToGoAway:Array):void {
         Profiler.getInstance().addMarker("-", "search");
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         vgraph.PTLayouter.setPearlTreesWorldLayout(true);
         var rootVNode:IPTVisualNode = _vgraph.currentRootVNode as IPTVisualNode;
         var positions:Dictionary = vgraph.PTLayouter.computeLayoutPositionOnly();
         var vnode:IPTVisualNode;
         var center:Point = _vgraph.currentRootVNode.viewCenter;
         var targetPoint:Point;
         var distanceToCenter:Number = 1; 
         var farDistance:Number = Math.sqrt( _vgraph.width* _vgraph.width +_vgraph.height * _vgraph.height) / 2.0;
         var layoutPar:Parallel = new Parallel;
         
         rootVNode.pearlView.moveWithoutZoomOffset(positions[rootVNode].x, positions[rootVNode].y);
         
         var m:Effect;
         var speed:Number = _vgraph.height / 1000;
         var distance:Number =0;
         var nodesToRemove:Array = new Array();
         var action:IAction = new RemoveVNodesAtAnimationEnd(nodesToRemove,this);
         _actionsToPerform.push(action);
         var remover :GraphicalActionSynchronizer = new GraphicalActionSynchronizer(action);
         
         var registerobjects:Dictionary = new Dictionary();
         var maxAnimationTime:Number = 0;
         for each ( vnode in _vgraph.visibleVNodes) {
            if (IPTNode(vnode.node).isDocked){
               continue;
            }
            var pos:Point = positions[vnode];
            if (pos) {
               center.x = vnode.viewX;
               center.y = vnode.viewY;
               distance = BroceliandMath.getDistanceBetweenPoints(center, pos);
               
               var time:int= distance/speed;
               if (time==0) time =10;
               if(time > maxAnimationTime) maxAnimationTime = time;
               
               if (nodesToGoAway !=null && nodesToGoAway.lastIndexOf(vnode)!=-1) {
                  m = new UnfocusPearlEffect(vnode.view);
                  m.duration = 500;
                  nodesToRemove.push(vnode.node);
               }else{
                  m = _vgraph.moveNodeTo(vnode, pos.x, pos.y,time, false);
               }
               
               if (vnode.view && (Math.ceil(vnode.viewX)!= Math.ceil(pos.x)|| Math.ceil(vnode.viewY)!= Math.ceil(pos.y))) {
                  if (vnode != _vgraph.currentRootVNode && vnode.view.visible){ 
                     if (registerobjects[vnode.view] !=  null) {
                        Alert.show("Register twice");
                     }
                     registerobjects[vnode.view]=true;
                     remover.registerComponentToWaitForEvent(m, TweenEvent.TWEEN_END);
                     if(m is Move) {
                        (vnode as PTVisualNodeBase).notifyInMove(m as Move);
                     }
                  }
               }
               layoutPar.addChild(m);
            }
         }
         layoutPar.play();
         remover.performActionAsap();
         vgraph.PTLayouter.setPearlTreesWorldLayout(false);
         
         Profiler.getInstance().addMarker("prepare animation", "search");
         setTimeout(profileAnimationEnd, maxAnimationTime);
      }
      
      private function profileAnimationEnd():void {
         Profiler.getInstance().addMarker("animation end", "search");
         Profiler.getInstance().endSession("search");
      }

      private function findTreeInCurrentGraph(newPTW:BroPearlTree):BroPearlTree {
         var result:BroPearlTree = null;
         var rootNode:IVisualNode = _vgraph.currentRootVNode;
         if (rootNode && newPTW) {
            
            var rootTree:BroPearlTree= IPTNode(rootNode.node).getBusinessNode().owner;
            var allTrees:Array = rootTree.treeHierarchyNode.getDescendantTrees();
            for each (var tree:BroPearlTree  in allTrees) {
               if (tree.id == newPTW.id && tree.dbId == newPTW.dbId){
                  result = tree;
                  break;
               }
            }
         }
         return result;
      }
   }
   
}
import com.broceliand.ApplicationManager;
import com.broceliand.graphLayout.controller.PTWAnimationController;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.graphLayout.visual.IPTVisualGraph;
import com.broceliand.graphLayout.visual.IPTVisualNode;
import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
import com.broceliand.pearlTree.model.BroPearlTree;
import com.broceliand.ui.model.SelectionModel;
import com.broceliand.ui.util.Profiler;
import com.broceliand.util.IAction;

import flash.utils.Dictionary;
import flash.utils.setTimeout;

import mx.effects.Effect;
import mx.events.EffectEvent;

import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

internal class CreateNewPTWAction implements IAction {
   private var _animationController:PTWAnimationController;
   private var _vgraph:IPTVisualGraph;
   private var _newVNodes:Array;
   private var _nodesToGoAway:Array;
   private var _effect:Effect;
   private var _oldVRoot:IVisualNode;
   private var _selectionModel:SelectionModel;
   public function CreateNewPTWAction (animationController:PTWAnimationController, vgraph:IPTVisualGraph, newVNodes:Array, nodesToGoAway:Array, effect:Effect, oldVRoot:IVisualNode, selectionModel:SelectionModel){
      _animationController = animationController;
      _vgraph = vgraph;
      _newVNodes = newVNodes;
      _nodesToGoAway  = nodesToGoAway;
      _effect = effect;
      _oldVRoot= oldVRoot;
      _selectionModel = selectionModel;
   }
   public function performAction():void {
      Profiler.getInstance().addMarker("pearls creation complete","search");      
      if (_effect) {        
         _effect.play();
         _effect.addEventListener(EffectEvent.EFFECT_END,endEffect);
      } else {
         endEffect(null);
      }

   }
   public function endEffect(e:EffectEvent):void {
      Profiler.getInstance().addMarker("hide pearls","search");       
      if (_newVNodes) {
         for each (var vnode:IVisualNode in _newVNodes) {
            if (vnode.view) {
               vnode.view.visible= true;
            } else {
               return;
            }
         }
         
      }
      _vgraph.currentRootVNode.view.visible = true;
      _animationController.applyPTWStyleToNodes(IPTNode(_vgraph.currentRootVNode.node));
      _animationController.cleanPTWLayout(_vgraph, _newVNodes, _nodesToGoAway);
      if (_oldVRoot) {
         _vgraph.removeNode(_oldVRoot);   
      }
      _selectionModel.highlightTree(null);
   }

}

internal class MoveINPTWAction implements IAction {
   private var _animationController:PTWAnimationController;
   private var _vgraph:IPTVisualGraph;
   private var _newVNodes:Array;
   private var _nodesToGoAway:Array;
   private var _newRootVNode:IPTVisualNode;
   private var _tree2VNode:Dictionary
   public function MoveINPTWAction (animationController:PTWAnimationController, vgraph:IPTVisualGraph, newVNodes:Array, nodesToGoAway:Array, newRootVNode:IPTVisualNode, tree2Node:Dictionary){
      _animationController = animationController;
      _vgraph = vgraph;
      _newVNodes = newVNodes;
      _nodesToGoAway  = nodesToGoAway;
      _newRootVNode= newRootVNode;
      _tree2VNode = tree2Node;
   }
   public function performAction():void {
      Profiler.getInstance().addMarker("pearls creation complete","search");      
      Profiler.getInstance().addMarker("pearls creation complete","movePTW");
      for each (var vnode:IPTVisualNode in _newVNodes) {
         vnode.view.alpha=1;
         vnode.pearlView.pearl.showRings = true;
      }
      _newRootVNode.view.alpha=1;
      _newRootVNode.pearlView.pearl.showRings = true;
      
      _animationController.changeVGraphRoot(_vgraph, _newRootVNode, _tree2VNode, _nodesToGoAway);
      _animationController.applyPTWStyleToNodes(IPTNode(_vgraph.currentRootVNode.node));
      _animationController.cleanPTWLayout(_vgraph, _newVNodes, _nodesToGoAway);
      
   }
}

internal class RemoveVNodesAtAnimationEnd implements IAction {
   private var _nodesToRemove:Array = null;
   private var _animationController:PTWAnimationController;
   public function RemoveVNodesAtAnimationEnd (nodesToRemove:Array, animationControllerToEnd:PTWAnimationController) {
      _nodesToRemove = nodesToRemove;     
      _animationController = animationControllerToEnd;
   }
   public function performAction():void {
      if (_nodesToRemove!=null) {
         for each (var node:IPTNode in _nodesToRemove) {
            if (node.vnode && node.vnode.view && node.vnode != node.vnode.vgraph.currentRootVNode) {
               node.vnode.vgraph.removeNode(node.vnode);
            }
         }
         _nodesToRemove =null;
      }
      if (_animationController) {
         _animationController.onAnimationEnd();
      }
   }
}