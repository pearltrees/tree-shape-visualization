package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.ui.effects.UnfocusPearlEffect;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.pearlTree.BackFromAliasButton;
   import com.broceliand.ui.pearlTree.UnfocusButton;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   import com.broceliand.ui.welcome.tunnel.NewTreeDetector;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import mx.core.UIComponent;
   import mx.effects.Effect;
   import mx.effects.Parallel;
   import mx.effects.Pause;
   import mx.effects.Sequence;
   import mx.effects.TweenEffect;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.events.VNodeMouseEvent;
   
   public class OpenCrossingAnimationController extends OpenTreeAnimationControllerBase
   {
      protected var _nodesToRemoveAtEndOfAnimation:Array = new Array();
      protected var _displayModel:GraphicalDisplayedModel;
      
      public function OpenCrossingAnimationController(request:IAction, animationProcessor:GraphicalAnimationRequestProcessor, vgraph:IPTVisualGraph, displayModel:GraphicalDisplayedModel)
      {
         super(request, animationProcessor);
         _vgraph = vgraph;
         _displayModel = displayModel;
      }
      
      public function performAnimation(rootNodeOfNewTree:IPTNode,  nodesToRemoveFromPreviousTree:Array, crossingNode:BroPTNode, isUnfocusAnimation:Boolean = false, shouldRecenter:Boolean = false, needToSlowDOwn:Boolean = false):void {
         
         var ga:GenericAction = new GenericAction(null, this, internalPerformAnimationAfterNodesCreation, rootNodeOfNewTree, nodesToRemoveFromPreviousTree, crossingNode, isUnfocusAnimation, shouldRecenter);
         var gas:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(ga);
         var descendants:Array = rootNodeOfNewTree.getDescendantsAndSelf();
         for each (var newNode:IPTNode  in descendants) {
            if (!newNode.vnode) { 
               continue;
            }
            var view:UIComponent = newNode.vnode.view;
            if (!view) {
               continue;
            }
            view.visible = false;
            view.alpha =0;
            if (!IUIPearl(view).isCreationCompleted()) {
               gas.registerComponentToWaitForCreation(view);
            }
         } 
         startAnimation(false);
         if (crossingNode) {
            ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(crossingNode.owner);
         }
         gas.performActionAsap();
      }
      
      public function internalPerformAnimationAfterNodesCreation(rootNodeOfNewTree:IPTNode,  nodesToRemove:Array, crossingNode:BroPTNode, isUnfocusAnimation:Boolean, shouldRecenter:Boolean):void {
         
         if (crossingNode  is BroNeighbourRootPearl) {
            crossingNode= BroNeighbourRootPearl(crossingNode).delegateNode;
         }
         
         var sequence:Sequence = new Sequence();
         var appearEffect:Parallel = new Parallel();
         var effect:Effect;
         var descendants:Array = rootNodeOfNewTree.getDescendantsAndSelf();
         var newNode:IPTNode;
         var crossingIPTNodeNewTree:IPTNode = findCrossingNewNode(descendants, crossingNode, isUnfocusAnimation);
         var isLookingForOldNode:Boolean    = !isUnfocusAnimation && crossingIPTNodeNewTree;
         var crossingIPTNodeOldTree:IPTNode = null;
         var endNodeToHide:IPTNode = PTRootNode(rootNodeOfNewTree).containedPearlTreeModel.endNode;
         
         nodesToRemove.push(_vgraph.currentRootVNode.node);

         crossingIPTNodeOldTree = addDisappearAnimationAndFindOldCrossingNode(nodesToRemove, _nodesToRemoveAtEndOfAnimation, sequence, crossingNode, isLookingForOldNode);

         var vedge:IVisualEdge= _vgraph.linkNodes(rootNodeOfNewTree.vnode, _vgraph.currentRootVNode);
         _vgraph.currentRootVNode = rootNodeOfNewTree.vnode;
         _vgraph.unlinkNodes(vedge.edge.node1.vnode, vedge.edge.node2.vnode); 
         _vgraph.origin.x=0;
         _vgraph.origin.y=0;
         var positions:Dictionary = _vgraph.PTLayouter.computeLayoutPositionOnly();
         var positionPoint:Point ;
         var offset:Point = new Point(0,0);
         var recenterAnimation:Parallel = null;

         var newTitleOrientation:int = TitleRenderer.BIG_SIZE;
         if (crossingIPTNodeNewTree) {
            var newPearlTargetPosition:Point = _vgraph.center.clone();
            if (crossingIPTNodeOldTree && crossingIPTNodeOldTree.vnode.view) {
               var oldPearl:IUIPearl = crossingIPTNodeOldTree.vnode.view as IUIPearl;
               newPearlTargetPosition = oldPearl.positionWithoutZoom.clone();
               
               var newPearl:IUIPearl = crossingIPTNodeNewTree.vnode.view as IUIPearl;
               IUIPearl(crossingIPTNodeNewTree.vnode.view).animationZoomFactor = oldPearl.animationZoomFactor;
               if (oldPearl.titleRenderer && newPearl.titleRenderer) {
                  newPearl.titleRenderer.orientation = oldPearl.titleRenderer.orientation;
               }
               if (oldPearl.animationZoomFactor >1) {
                  
                  IUIPearl(crossingIPTNodeNewTree.vnode.view).setBigger(true);
               }
               IUIPearl(crossingIPTNodeNewTree.vnode.view).setBigger(oldPearl.isBigger());
               
            } else {
               var aNewPearl:IUIPearl = (crossingIPTNodeNewTree.vnode.view as UIPearl);
               var centerPearl:Point = crossingIPTNodeNewTree.vnode.viewCenter;
               newPearlTargetPosition.x +=  aNewPearl.positionWithoutZoom.x - centerPearl.x; 
               newPearlTargetPosition.y +=  aNewPearl.positionWithoutZoom.y - centerPearl.y;
               
            }
            positionPoint = positions[crossingIPTNodeNewTree.vnode];
            offset.x =  Math.round(positionPoint.x - newPearlTargetPosition.x);
            offset.y =  Math.round(positionPoint.y - newPearlTargetPosition.y) ;
            
         }
         
         for each (newNode in descendants) {
            if (newNode == endNodeToHide) {
               continue;
            }
            var pearl:IUIPearl = newNode.vnode.view as IUIPearl;
            positionPoint = positions[newNode.vnode];
            if (positionPoint) {
               if (shouldRecenter && newNode != crossingIPTNodeNewTree && crossingIPTNodeOldTree ) {
                  pearl.moveWithoutZoomOffset(positionPoint.x, positionPoint.y );
               } else {
                  pearl.moveWithoutZoomOffset(positionPoint.x -offset.x, positionPoint.y  -offset.y);   
               }
            }
            pearl.visible = true;
            if (newNode != crossingIPTNodeNewTree) {
               pearl.alpha = 0;
               effect = new UnfocusPearlEffect(newNode.vnode.view, false);
               appearEffect.addChild(effect);   
            } else {
               pearl.alpha = 1;
            }
         }

         if (effect) {
            effect.addEventListener(TweenEvent.TWEEN_UPDATE, refreshGraphOnEffect, false, 0, true);
         }
         
         var aPearl:IUIPearl;
         
         if (shouldRecenter && offset.length >0 && crossingIPTNodeOldTree) {
            var par:Parallel = new Parallel();
            effect = null;
            for each (var vnode:IVisualNode in _vgraph.visibleVNodes) {
               if (!IPTNode(vnode.node).isDocked) {
                  if (vnode.node == crossingIPTNodeNewTree || vnode.node == crossingIPTNodeOldTree) {
                     aPearl = vnode.view as IUIPearl;
                     var zoomPoint:Point = aPearl.positionWithoutZoom;
                     effect = _vgraph.moveNodeTo(vnode, zoomPoint.x + offset.x, zoomPoint.y +offset.y, 300, false);
                     par.addChild(effect);
                  }  
               }  
            }
            if (effect) {
               sequence.addChild(par);
            }
         }
         
         var pause:Pause = new Pause();
         pause.duration =300;
         pause.addEventListener(EffectEvent.EFFECT_END, onEndPause);
         sequence.addChild(pause);
         
         if (appearEffect.children.length>0) {
            sequence.addChild(appearEffect);
         }
         if (offset.length>0 ) {
            var shouldRecenterGraph:Boolean = false;
            if (crossingIPTNodeNewTree.vnode.viewX<0 || (crossingIPTNodeOldTree && crossingIPTNodeOldTree.vnode.viewX>_vgraph.width)) {
               shouldRecenterGraph = true;
            }
            if (crossingIPTNodeNewTree.vnode.viewY<0 || (crossingIPTNodeOldTree && crossingIPTNodeOldTree.vnode.viewY>_vgraph.height)) {
               shouldRecenterGraph = true;
            }
            if (!shouldRecenter || !crossingIPTNodeOldTree) {
               if (!shouldRecenterGraph) {
                  _vgraph.offsetOrigin(-offset.x, -offset.y);
               } else {
                  for each (newNode in descendants) {
                     aPearl = newNode.vnode.view as IUIPearl;
                     pearl.moveWithoutZoomOffset(aPearl.x - offset.x, aPearl.y - offset.y );
                  }  
               }
            } 
         }
         sequence.addEventListener(EffectEvent.EFFECT_END, endAnimation);
         sequence.play();
      }
      
      protected function findCrossingNewNode(descendants:Array, crossingNode:BroPTNode, isUnfocusAnimation:Boolean):IPTNode {
         var crossingIPTNodeNewTree:IPTNode;
         if (!isUnfocusAnimation) {
            
            for each (var newNode:IPTNode  in descendants) {
               if (newNode is EndNode) {
                  continue;
               }
               if (isNodeCrossing(newNode.getBusinessNode(), crossingNode, true)) {
                  crossingIPTNodeNewTree = newNode;
                  break;
               } 
            }
         } else {
            crossingIPTNodeNewTree = _vgraph.currentRootVNode.node as IPTNode;
         }
         return crossingIPTNodeNewTree;
      }
      
      protected function addDisappearAnimationAndFindOldCrossingNode(nodesToRemove:Array, nodesToRemoveAtEndOfAnimation:Array, sequence:Sequence, crossingNode:BroPTNode, lookingForOldCrossingNode:Boolean ):IPTNode {
         var disappearEffect:Parallel = new Parallel();
         var effect:Effect;
         var crossingIPTNodeOldTree:IPTNode = null;
         for each (var node:IPTNode in nodesToRemove) {
            var bnode:BroPTNode = node.getBusinessNode(); 
            if (lookingForOldCrossingNode && !(node is EndNode) && isNodeCrossing(bnode, crossingNode, false)  ) {
               crossingIPTNodeOldTree = node;
               nodesToRemoveAtEndOfAnimation.push(crossingIPTNodeOldTree);
               continue;
            }
            if (node.vnode ==null) {
               continue;
            }
            if (node.vnode.isVisible== false || node.vnode.view.alpha==0 ) {
               
               if (node.vnode == _vgraph.currentRootVNode) {
                  nodesToRemoveAtEndOfAnimation.push(node);
               } else {
                  removeNode(node);
               }
            } else{
               effect = new UnfocusPearlEffect(node.vnode.view);
               effect.duration = 500;
               disappearEffect.addChild(effect);
               if (node.vnode != _vgraph.currentRootVNode) {
                  effect.addEventListener(TweenEvent.TWEEN_END, removeNodeAfterGoneAway);
                  
               } else {
                  nodesToRemoveAtEndOfAnimation.push(node);
               }
               effect.addEventListener(TweenEvent.TWEEN_UPDATE, refreshGraphOnEffect, false, 0, true);
            }
         }
         if (disappearEffect.children.length>0){ 
            sequence.addChild(disappearEffect);
         }
         return crossingIPTNodeOldTree;
      }
      
      protected function onEndPause(event:Event):void {
         var rootnode:IPTNode = _vgraph.currentRootVNode.node as IPTNode;
         
         _vgraph.controls.unfocusButton.bindToNode(rootnode);
         _vgraph.controls.backFromAliasButton.bindToNode(rootnode);
         disableButtonsForDisappearingNodes();
      }
      
      private function removeNodeAfterGoneAway(event:TweenEvent):void {
         var move:TweenEffect= event.target as TweenEffect;
         if(move){
            var pearlRenderer:PearlRendererBase = move.target as PearlRendererBase;
            if (pearlRenderer.vnode) {
               removeNode(pearlRenderer.node);
            }
         }
         
      }
      
      protected function refreshGraphOnEffect(event:TweenEvent):void{ 
         _vgraph.refresh();
      }
      
      private function isNodeCrossing(bnode:BroPTNode, refNode:BroPTNode, isNewNode:Boolean):Boolean {
         if (bnode == refNode) {
            return true;
         } else if (isNewNode) {
            if (refNode is BroPTRootNode) {
               var tmpNode:BroPTNode;
               tmpNode = refNode;
               refNode = bnode;
               bnode = tmpNode;
            }
            if (refNode is BroPageNode) {
               if (bnode is BroPageNode) {
                  return BroPageNode(refNode).refPage.url == BroPageNode(bnode).refPage.url;
               } else {
                  return false;
               }
            } else if (refNode is BroTreeRefNode) {
               if (bnode is BroPTRootNode) {
                  if(bnode.owner.dbId== BroTreeRefNode(refNode).treeDB) {
                     if (bnode.owner.id == BroTreeRefNode(refNode).treeId) {
                        return true;
                     }
                  };
               } else if (bnode is BroTreeRefNode) {
                  if ( BroTreeRefNode(refNode).treeId ==  BroTreeRefNode(bnode).treeId &&  BroTreeRefNode(refNode).treeDB== BroTreeRefNode(bnode).treeDB) {
                     return true;
                  }
               }
            }
         } else if (bnode is BroNeighbourRootPearl) {
            return BroNeighbourRootPearl(bnode).delegateNode == refNode
         }
         return false;
      }
      
      override protected function endAnimation(e:Event=null):void {
         super.endAnimation(e);
         var unfocusButton:UnfocusButton= _vgraph.controls.unfocusButton;
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed() && am.embedManager.embedTree == am.visualModel.navigationModel.getFocusedTree()) {
            
         }else{
            unfocusButton.visible = unfocusButton.includeInLayout = true;
         }
         unfocusButton.bindToNode(_vgraph.currentRootVNode.node as IPTNode);
         var backFromAlias:BackFromAliasButton= _vgraph.controls.backFromAliasButton;
         backFromAlias.visible = backFromAlias.includeInLayout = true;
         backFromAlias.bindToNode(_vgraph.currentRootVNode.node as IPTNode);
         removeNodes();
         ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(null);
         _vgraph.layouter.layoutPass();
         
         ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.updatePearlUnderCursorAfterCross();
         
      }

      private function disableButtonsForDisappearingNodes():void {
         for each (var n:IPTNode in _nodesToRemoveAtEndOfAnimation) {
            if (!n.isEnded()) {
               n.pearlVnode.pearlView.pearl.markAsDisappearing = true;
               n.pearlVnode.pearlView.invalidateProperties();
            }
         }
      }
      private function removeNodes():void {
         while (_nodesToRemoveAtEndOfAnimation.length>0) {
            var n:IPTNode = _nodesToRemoveAtEndOfAnimation.pop();
            if (n.vnode && n.vnode.view) {
               removeNode(n);  
            }
         }
      }
      private function removeNode(node:IPTNode):void {
         _vgraph.removeNode(node.vnode);
      }
      
   }
}