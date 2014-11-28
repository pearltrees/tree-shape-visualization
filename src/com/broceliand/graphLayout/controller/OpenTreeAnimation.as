package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.layout.IPTLayouter;
   import com.broceliand.graphLayout.layout.PTLayouterBase;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.effects.MoveWithScroll;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.EmptyMapText;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.renderers.pageRenderers.pearl.EndPearl;
   import com.broceliand.util.Alert;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import mx.effects.Effect;
   import mx.effects.Fade;
   import mx.effects.Parallel;
   import mx.effects.Pause;
   import mx.effects.Sequence;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   import mx.rpc.events.HeaderEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualNode;

   public class OpenTreeAnimation extends OpenTreeAnimationControllerBase implements IOpenTreeAnimationController
   {
      private static var _isFirstAnimation:Boolean = true;   
      public static const GROWING_ANIMATION:int = 0;
      public static const QUICK_ANIMATION:int = 1;
      public static const FADE_ANIMATION:int = 2;
      private var _endVNode:IVisualNode; 
      private var _emptyMapText:EmptyMapText;
      
      private var _growingTreeAnimation:GrowingTreeAnimation;
      private var _newVNodes:Array=null;
      private var _interactorManager:InteractorManager;
      private var _dontShowEmptySign:Boolean;
      public function OpenTreeAnimation(request:IAction, animationProcessor:GraphicalAnimationRequestProcessor, dontShowEmptySign:Boolean= false)
      {
         super(request, animationProcessor);
         _dontShowEmptySign = dontShowEmptySign;
         var viewer:IPearlTreeViewer = ApplicationManager.getInstance().components.pearlTreeViewer;
         
         _interactorManager = viewer.interactorManager;
         _emptyMapText= viewer.vgraph.controls.emptyMapText;
         _emptyMapText.visible=false; 
      }
      public function animateTreeOpening(tree:IPearlTreeModel, newVNodes:Array, animationType:int):void {
         StartPolicyLogger.getInstance().setFirstOpenAnimationStarted();
         if (isAnimating) {
            throw new Error("An animation is already occuring");
         }
         startAnimation(true);
         tree.openingState= OpeningState.OPENING;
         _tree = tree;
         var rootOfOpenTree:IPTNode = tree.rootNode;
         _vgraph = rootOfOpenTree.vnode.vgraph as IPTVisualGraph;
         var endNode:EndNode= (rootOfOpenTree as PTRootNode).containedPearlTreeModel.endNode as EndNode;

         var animationIsGrowing:Boolean= animationType == GROWING_ANIMATION && shouldPlayGrowingAnimation(endNode);
         if (!animationIsGrowing) {
            if (animationType != FADE_ANIMATION) { 
               playQuickOpenAnimation(newVNodes, endNode, rootOfOpenTree);
            } else {
               playFadeAnimation(newVNodes, endNode, rootOfOpenTree);
            }
         } else {
            playGrowingAnimation(rootOfOpenTree, newVNodes, endNode, _interactorManager.manipulatedNodesModel);
         }
      }
      
      private function shouldPlayGrowingAnimation(endNode:EndNode):Boolean {
         if ( _vgraph.layouter.disableAnimation) {
            return false;
         }
         if (!ApplicationManager.getInstance().components.pearlTreePlayer.isHidden()) {
            return false;
         }
         if (endNode.successors.length>0) {
            var successor:IPTNode = endNode.successors[0];
            if (successor) {
               if (successor is EndNode && !EndNode(successor).canBeVisible) {
                  if (successor.vnode.view && successor.vnode.view.alpha > 0) {
                     return false;
                  } else {
                     return true;
                  }
               }
               return false;
            }
         }
         
         return true;
      }
      private function playQuickOpenAnimation(newVNodes:Array, endNode:IPTNode, rootOfOpenTree:IPTNode):void {
         var draggedNode:IVisualNode =null;
         var rootPearl:IUIPearl = rootOfOpenTree.pearlVnode.pearlView;
         var startPoint:Point = new Point(rootPearl.positionWithoutZoom.x, rootPearl.positionWithoutZoom.y);
         var synchroAnimation:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(new PerformLayoutAction(_vgraph, rootOfOpenTree));
         if (_interactorManager.draggedPearl != null) {
            
            draggedNode = _interactorManager.draggedPearl.vnode;
         }
         _newVNodes = newVNodes;
         if (endNode.vnode.isVisible) {
            var endPearl:IUIPearl  = endNode.pearlVnode.pearlView; 
            var endPearlWidth:Number =endPearl.width;
            if (endPearlWidth == 0) {
               endPearlWidth = EndPearl.PEARL_WIDTH_NORMAL;
            }
            endPearl.moveWithoutZoomOffset(startPoint.x - (endPearlWidth - rootPearl.width)/2 , startPoint.y - (endPearlWidth - rootPearl.height)/2);
         }
         var i:int=0;
         for each (var n:IPTVisualNode in newVNodes) {
            if (n == endNode.vnode) {
               _endVNode = n;
               continue;
            } 
            if (n== draggedNode) {
               continue;
            }
            if (!n.view.initialized) {
               synchroAnimation.registerComponentToWaitForCreation(n.view);
            }
            n.view.alpha=0;
            n.pearlView.moveWithoutZoomOffset(startPoint.x - (n.pearlView.width - rootPearl.width)/2, startPoint.y - (n.pearlView.height- rootPearl.height)/2);
            i++;
         }
         _vgraph.layouter.addEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, makeNodesAppearOnEndLayout);
         if (!synchroAnimation.isWaitingForEvent()) {
            _vgraph.PTLayouter.layoutWithFixNodePosition(rootOfOpenTree);
         }
      }
      
      private function playFadeAnimation(newVNodes:Array, endNode:IPTNode, rootOfOpenTree:IPTNode):void {
         var draggedNode:IVisualNode =null;
         _newVNodes = newVNodes;
         _newVNodes.push(rootOfOpenTree.vnode);
         if (_interactorManager.draggedPearl != null) {
            
            draggedNode = _interactorManager.draggedPearl.vnode;
         }
         var action:GenericAction = new GenericAction(null, this, makeNodesAppearOnEndLayout);
         var synchro:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(action);
         var p:Point;
         var positions:Dictionary = _vgraph.PTLayouter.computeLayoutPositionOnly();
         for each (var n:IPTVisualNode in newVNodes) {
            if (n == endNode.vnode) {
               _endVNode = n;
               continue;
            } 
            if (!n.view.initialized) {
               synchro.registerComponentToWaitForCreation(n.view);
            }
            if (!IPTNode(n.node).isDocked)  {
               n.view.alpha=0;
               p = positions[n];
               if (p) {
                  n.pearlView.moveWithoutZoomOffset(p.x, p.y);
               }
            }
         }
         synchro.performActionAsap();
      }
      
      private function playGrowingAnimation(rootOfOpenTree:IPTNode, newVNodes:Array, endNode:IPTNode, manipulatedNodeModel:ManipulatedNodesModel):void {
         var startPoint:Point = rootOfOpenTree.pearlVnode.pearlView.positionWithoutZoom.clone();
         var pAnim:Parallel= new Parallel();
         var action:PlayAnimationAction = new PlayAnimationAction(pAnim);
         var synchro:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(action);
         var layouter:IPTLayouter = _vgraph.PTLayouter;
         var m:Effect = null;
         var nodesPositions:Dictionary = layouter.computeLayoutPositionOnly();
         
         var rootNodeFinalPosition:Point = nodesPositions[rootOfOpenTree.vnode];
         if (rootNodeFinalPosition ==null) {
            endAnimation();
            return;
         }
         var rootPearl:IUIPearl = rootOfOpenTree.pearlVnode.pearlView;
         
         if (rootOfOpenTree.vnode==_vgraph.currentRootVNode) {
            
            startPoint.x=rootNodeFinalPosition.x;
            startPoint.y=rootNodeFinalPosition.y;
            rootPearl.moveWithoutZoomOffset( startPoint.x , startPoint.y);
         } else {
            if (rootPearl) {
               if (rootPearl.x!=0  || rootPearl.y!=0 ){
                  
                  var offset:Point = new Point(Math.round(rootPearl.positionWithoutZoom.x - rootNodeFinalPosition.x),
                     Math.round( rootPearl.positionWithoutZoom.y - rootNodeFinalPosition.y) );
                  _vgraph.offsetOrigin(offset.x, offset.y);
                  
                  for each(vn in _vgraph.visibleVNodes) {
                     if (IPTNode(vn.node).isDocked) {
                        continue;
                     }
                     if (nodesPositions[vn]) {
                        nodesPositions[vn].offset(offset.x,offset.y);
                     } 
                  }
               }
            }
         }  
         var moveRootPoint: Boolean = rootNodeFinalPosition.equals(startPoint);
         var moveNodeDuration:int = 300;
         
         for  (var vn:Object in nodesPositions) {
            var node:IPTNode = vn.node;
            if(node && node.isDocked){
               continue;
            }
            if (manipulatedNodeModel.isNodeManipulated(node)) {
               continue;
            }
            if (!(vn as IVisualNode).view.initialized) {
               synchro.registerComponentToWaitForCreation((vn as IVisualNode).view);
               (vn as IVisualNode).view.visible=false;
            }
            if (newVNodes.lastIndexOf(vn)==-1) {
               var p:Point = nodesPositions[vn];
               if (Math.abs(p.x - (vn as IVisualNode).viewX )>=1  || Math.abs(p.y -  (vn as IVisualNode).viewY) >=1) {
                  m = _vgraph.moveNodeTo(vn as IVisualNode, int(0.5 +p.x), int (0.5 + p.y) , moveNodeDuration, false);
                  pAnim.addChild(m);
               }
            } else {
               (vn as IPTVisualNode).pearlView.moveWithoutZoomOffset(startPoint.x, startPoint.y );
               (vn as IPTVisualNode).view.alpha = 0;
               if (moveRootPoint) {
                  pAnim.addChild(_vgraph.moveNodeTo(vn as IVisualNode, int(0.5 + rootNodeFinalPosition.x)  , int(0.5 + rootNodeFinalPosition.y), moveNodeDuration, false));
               }
            }
         }
         _growingTreeAnimation = new GrowingTreeAnimation(rootOfOpenTree, nodesPositions, _vgraph, manipulatedNodeModel);
         if (m!= null) {
            m.addEventListener(TweenEvent.TWEEN_END, onEndPositioning);
            if (!synchro.isWaitingForEvent()) {
               pAnim.play();
            }
         } else if (synchro.isWaitingForEvent()) {
            action.setFunctionToCall(this, onEndPositioning); 
         } else {
            onEndPositioning(null);
         }
         
      }
      private function makeNodesAppearOnEndLayout(e:Event=null):void {
         if (e) {
            _vgraph.layouter.removeEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, makeNodesAppearOnEndLayout);
         }
         var effect:Fade=null;
         var duration:int = 600;
         var seq:Sequence= new Sequence();
         var par:Parallel = new Parallel();
         var pause:Pause = new Pause();
         pause.duration=400;
         seq.addChild(pause);
         
         for each (var n:IVisualNode in _newVNodes) {
            if (n==_endVNode) {
               continue;
            }
            effect = new Fade(n.view);
            effect.duration = duration;
            effect.alphaFrom =0;
            effect.alphaTo = 1;
            par.addChild(effect);
            
         }
         seq.addChild(par);
         if (effect) {
            effect.addEventListener(TweenEvent.TWEEN_UPDATE,redrawEdges);
            seq.addEventListener(EffectEvent.EFFECT_END,onEndApparition);
         }
         else onEndApparition(null);
         seq.play();
         
      }
      private function  onEndPositioning(e:Event=null):void {
         if (e)
            e.target.removeEventListener(TweenEvent.TWEEN_END,onEndPositioning);
         
         _vgraph.refresh();
         _growingTreeAnimation.addEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, onEndTreeGrowing);
         if (_isFirstAnimation) {
            _isFirstAnimation = false;
            StartPolicyLogger.getInstance().setFirstPearlsCreated();
         }
         _growingTreeAnimation.playAnimation();

      }
      private function redrawEdges(e:Event):void {
         _vgraph.refresh();
      }
      private function onEndApparition(e:Event):void {
         if (e) {
            e.target.removeEventListener(TweenEvent.TWEEN_END,onEndApparition);
            e.target.removeEventListener(TweenEvent.TWEEN_UPDATE,redrawEdges);
         }
         endAnimation();
         
         _vgraph.refresh();
         
      }
      private function onEndTreeGrowing(e:Event):void {
         _growingTreeAnimation.removeEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, onEndTreeGrowing);
         _growingTreeAnimation = null;
         _vgraph.drawingSurface.callLater(endAnimation);
      }
      override protected function endAnimation(e:Event=null):void {
         _tree.openingState= OpeningState.OPEN;
         if (_tree.openingTargetState== OpeningState.OPEN) {
            _tree.openingTargetState = null;
         }
         
         if (_tree.businessTree.isEmpty() && !_dontShowEmptySign) {
            if (_interactorManager.draggedPearl == null ) {
               _emptyMapText.bindToNode(_tree.rootNode);
               _emptyMapText.visible=true;
            }
         }
         super.endAnimation(e);

      }
   }
}
import com.broceliand.util.IAction;
import mx.effects.Effect;

internal class PlayAnimationAction implements IAction {
   private var _effect:Effect;
   private var _function :Function;
   private var _thisobj:Object;
   
   public function PlayAnimationAction(effect:Effect) {
      _effect = effect;
   }
   
   public function setFunctionToCall(thisobj:Object, func:Function):void {
      _effect = null;
      _function  =func;
      _thisobj = thisobj;
   }
   public   function performAction():void {
      if (_effect) {
         _effect.play();   
      } else {
         _function.call(_thisobj);      
      }

   }
}

import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.graphLayout.visual.IPTVisualGraph;

internal class PerformLayoutAction implements IAction {
   private var _vgraph:IPTVisualGraph;
   private var _fixedNode:IPTNode;
   public function PerformLayoutAction( vgraph:IPTVisualGraph, fixedNode:IPTNode= null) {
      _vgraph = vgraph;
      _fixedNode = fixedNode;
   }
   public   function performAction():void {
      if (_fixedNode) {
         _vgraph.PTLayouter.layoutWithFixNodePosition(_fixedNode); 
      } else {
         _vgraph.layouter.layoutPass();
      }
   }
}

