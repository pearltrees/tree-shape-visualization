package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.interactors.DepthInteractor;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.util.NullSkin;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   import mx.effects.Effect;
   import mx.effects.Fade;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.effects.Pause;
   import mx.effects.Sequence;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualNode;

   public class CloseTreeAnimation extends OpenTreeAnimationControllerBase implements IOpenTreeAnimationController
   {
      
      protected var _treeToClose:Array;
      protected var _fixedVNode:IPTVisualNode;
      
      protected var _displayModel:GraphicalDisplayedModel; 
      private var _closeStatesUpdated:Boolean = false;
      
      public function CloseTreeAnimation(request:IAction, animationProcessor:GraphicalAnimationRequestProcessor) {
         super(request, animationProcessor);
         _treeToClose = new Array();
      }
      public function addTreeToClose(visualRootOfTheClosedTree:IVisualNode, vnodesToDelete:Array , endNode:IPTNode):void {
         _treeToClose.push(new TreeToCloseArg(visualRootOfTheClosedTree, vnodesToDelete, endNode));
         if(!_vgraph) {
            _vgraph = visualRootOfTheClosedTree.vgraph as IPTVisualGraph;
         }
      }
      public function startClosingAnimation( displayModel:GraphicalDisplayedModel, fixedVNode:IVisualNode=null):void {
         
         var viewer:IPearlTreeViewer = ApplicationManager.getInstance().components.pearlTreeViewer;
         viewer.vgraph.controls.emptyMapText.visible=false;
         if (this.isAnimating) {
            throw new Error("An animation is already occuring");
         }
         _displayModel = displayModel;
         _fixedVNode = fixedVNode as IPTVisualNode;
         startAnimation(false);
         playDisappearAnimation();
         
      }
      
      protected function canNodeBeRemoved(node:IPTNode, manipulatedNodeModel:ManipulatedNodesModel):Boolean {
         return !manipulatedNodeModel.isNodeManipulated(node);
      }
      
      protected function playQuickCloseAnimation():Array {
         var vgraph:IPTVisualGraph = _fixedVNode.vgraph as IPTVisualGraph;
         var rootNode:IPTNode = _fixedVNode.node as IPTNode;
         
         vgraph.getEditedGraphVisualModification().cancelVisualGraphModificationForLayout();
         var descendants:Array = rootNode.getDescendantsAndSelf();
         vgraph.getEditedGraphVisualModification().restoreVisualGraphModificationAfterLayout();
         var anim:Parallel = new Parallel();
         var duration:int=500;
         var pearlXOffset:Number;
         var pearlYOffset:Number;
         var rootPearl:IUIPearl = (rootNode.vnode.view as IUIPearl);
         var rootPearlCenter:Point = rootPearl.pearlCenter;
         var im:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
         var depthInteractor:DepthInteractor = im.depthInteractor;
         var manipulatedNodeModel:ManipulatedNodesModel = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.manipulatedNodesModel;
         if(rootPearl != im.draggedPearl) {
            depthInteractor.movePearlUp(rootPearl);
         }
         var nodesToDelete:Array = new Array();
         for each (var n:IPTNode  in descendants) {
            if (!canNodeBeRemoved(n, manipulatedNodeModel)) {
               continue;
            }
            if (n is PTRootNode) {
               var aRootNOde:PTRootNode = n as PTRootNode;
               if (aRootNOde.isOpen()) {
                  aRootNOde.containedPearlTreeModel.openingState = OpeningState.CLOSING;
               }
            }
            if (n != rootNode) {
               nodesToDelete.push(n);
               if (n.vnode.view) {
                  var pearlView:IUIPearl = n.vnode.view as IUIPearl 
                  if (pearlView) {
                     pearlXOffset = int( 0.5 + pearlView.pearlCenter.x - pearlView.positionWithoutZoom.x);
                     pearlYOffset = int ( 0.5 + pearlView.pearlCenter.y - pearlView.positionWithoutZoom.y);
                  } 
                  var m:Move = vgraph.moveNodeTo(n.vnode, rootPearlCenter.x - pearlXOffset, rootPearlCenter.y - pearlYOffset, duration, false);
                  anim.addChild(m);
                  if (n.vnode.view.alpha>0) {
                     var fade:Fade = new Fade(n.vnode.view);
                     fade.alphaFrom = 1;
                     fade.alphaTo=0.;
                     fade.duration= duration;
                     anim.addChild(fade);
                  }
                  var pearl:IUIPearl = n.vnode.view as IUIPearl;
                  pearl.pearl.markAsDisappearing =true;
               }
            }
         }
         if (anim.children.length> 0) {
            anim.play();
            anim.addEventListener(EffectEvent.EFFECT_END, onEndDisapparition);
         } else {
            onEndDisapparition(null);
         }
         return nodesToDelete;
      }

      protected function playDisappearAnimation():void {
         var par:Parallel = new Parallel();
         var effect:Fade=null;
         var duration:int = 300;
         for each (var t:TreeToCloseArg in _treeToClose) {
            for each (var n:IVisualNode in t.vnodesToDelete) {
               if (n==t.endVNode) {
                  continue;
               }
               effect = new Fade(n.view);
               effect.duration = duration;
               effect.alphaFrom =1;
               effect.alphaTo = 0;
               par.addChild(effect);
            }
         }
         if (effect) {
            effect.addEventListener(TweenEvent.TWEEN_UPDATE,redrawEdges);
            effect.addEventListener(TweenEvent.TWEEN_END,onEndDisapparition);
         } else {
            onEndDisapparition(null);
         }
         par.play();
      }

      protected function onEndDisapparition(e:Event):void {
         if (e && e.target) {
            e.target.removeEventListener(TweenEvent.TWEEN_END,onEndDisapparition);
            e.target.removeEventListener(TweenEvent.TWEEN_UPDATE,redrawEdges);
         }
         if (_vgraph) {
            _vgraph.refresh();
            setTimeout(computeAndPlayFinalLayout, 200);
         }
      }
      
      protected function deleteSubNodesExceptEndNode():void {
         var interactorManager:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
         for each (var t:TreeToCloseArg in _treeToClose) {
            for each(var desc:IVisualNode in t.vnodesToDelete){
               if (desc!=t.endVNode && !IPTNode(desc.node).isEnded()) {
                  if (!interactorManager.manipulatedNodesModel.isNodeManipulated(desc.node as IPTNode)) {
                     _vgraph.removeNode(desc);
                  }
               }   
            }
         }
      }
      private function computeAndPlayFinalLayout():void {
         deleteSubNodesExceptEndNode();
         
         var nodesPositions:Dictionary = null;
         var nodesConnectedToEndNodeByTree:Dictionary = new Dictionary();
         var edgeDataOfEndNodeByTree:Dictionary = new Dictionary();
         var t:TreeToCloseArg ;
         
         for each ( t in _treeToClose) {
            if (t.endVNode) {
               edgeDataOfEndNodeByTree[t] = new Array();
               nodesConnectedToEndNodeByTree[t] = changeGraphForComputeNodes(t.visualRootOfTheClosedTree, t.endVNode, edgeDataOfEndNodeByTree[t]);
            }
         }
         nodesPositions = _vgraph.PTLayouter.computeLayoutPositionOnly();
         
         if (_fixedVNode && _fixedVNode.view && nodesPositions[_fixedVNode]) {
            var fixedNodeView:IUIPearl = _fixedVNode.pearlView;    
            var offset:Point = new Point(Math.round( fixedNodeView.positionWithoutZoom.x - nodesPositions[_fixedVNode].x ), 
               Math.round( fixedNodeView.positionWithoutZoom.y - nodesPositions[_fixedVNode].y));
            
            _vgraph.offsetOrigin(offset.x ,offset.y );
            for (var v:Object in nodesPositions) {
               if (!IPTNode(v.node).isDocked) {
                  nodesPositions[v].offset(offset.x, offset.y);
               }
            }
         }
         
         var endNodeOffsetX:Number =0;
         var endNodeOffsetY:Number =0;
         
         for each ( t in _treeToClose) {
            if (t.endVNode) {
               if (endNodeOffsetX == 0 ) {
                  endNodeOffsetX = (t.endVNode.view.width - t.visualRootOfTheClosedTree.view.width) /2;
                  endNodeOffsetY = (t.endVNode.view.height - t.visualRootOfTheClosedTree.view.height) /2;
               }
               var rootPointPosition:Point = nodesPositions[t.visualRootOfTheClosedTree];
               if (rootPointPosition) {
                  rootPointPosition = rootPointPosition.clone();
                  rootPointPosition.offset(-endNodeOffsetX, -endNodeOffsetY);
                  nodesPositions[t.endVNode] = rootPointPosition;
               }
               changeGraphBackForAnimation(t.visualRootOfTheClosedTree, t.endVNode, nodesConnectedToEndNodeByTree[t], edgeDataOfEndNodeByTree[t]);
            }
         }

         moveToFinalLayout(nodesPositions);
      }

      private function changeGraphForComputeNodes(vrootOfClosingNode:IVisualNode, endVNode:IVisualNode, endNodeEdgesData:Array):Array {
         var nodesConnectedToEndNode:Array= new Array();
         
         if (endVNode && endVNode.node.predecessors.length>0) {
            _vgraph.unlinkNodes(endVNode.node.predecessors[0].vnode, endVNode);
         }
         var  endNode:IPTNode = endVNode.node as IPTNode;

         for each (var node:IPTNode in endNode.successors) {
            if (node.vnode.isVisible && node.vnode.view.visible ) {
               nodesConnectedToEndNode.push(node);
               endNodeEdgesData.push(IEdge(node.inEdges[0]).data);
            }
         }
         
         for (var childIndex:int=nodesConnectedToEndNode.length; childIndex-->0;) {
            _vgraph.unlinkNodes(endVNode,  nodesConnectedToEndNode[childIndex].vnode);
            _vgraph.linkNodes(vrootOfClosingNode,  nodesConnectedToEndNode[childIndex].vnode);
         }
         
         return nodesConnectedToEndNode;
      } 

      private function changeGraphBackForAnimation(vrootOfClosingNode:IVisualNode, endVNode:IVisualNode, nodesConnectedToEndNode:Array, edgeDataArray:Array):void{
         for (var childIndex:int=nodesConnectedToEndNode.length; childIndex-->0;) {
            _vgraph.unlinkNodes(vrootOfClosingNode,  nodesConnectedToEndNode[childIndex].vnode);
            var vedge:IVisualEdge= _vgraph.linkNodes(endVNode,  nodesConnectedToEndNode[childIndex].vnode);
            vedge.data  = vedge.edge.data = edgeDataArray[childIndex]; 
         }   
      }
      private function moveToFinalLayout(nodesPositions:Dictionary):void {
         
         var m:Effect = null;
         var pAnim:Parallel= new Parallel()
         var moveNodeDuration:int = 300;
         for  (var vn:Object in nodesPositions) {
            var p:Point = nodesPositions[vn];
            var pearl:IUIPearl = (vn as IPTVisualNode).pearlView;
            if (p==null || pearl==null || pearl.node.isDocked) continue;
            if (Math.abs(p.x - pearl.x )>=1  || Math.abs(p.y -  pearl.y ) >=1) {
               m = _vgraph.moveNodeTo(pearl.vnode, p.x, p.y , moveNodeDuration, false);
               pAnim.addChild(m);
            }
         }
         if (m!= null) {
            m.addEventListener(TweenEvent.TWEEN_UPDATE, redrawEdges);
            pAnim.addEventListener(EffectEvent.EFFECT_END, onEndClosing);
            pAnim.play();
         }  
         else onEndClosing(null);
      }
      protected  function  onEndClosing(e:Event):void {
         if (e) {
            Effect(e.target).removeEventListener(TweenEvent.TWEEN_END, onEndClosing);
            Effect(e.target).removeEventListener(TweenEvent.TWEEN_UPDATE, redrawEdges);
         }
         removeAllEndsNode();
         updateCloseTreeStates();
         endAnimation(); 
      }
      protected function removeAllEndsNode():void {
         for each (var t:TreeToCloseArg in _treeToClose) {
            
            if (t.visualRootOfTheClosedTree.node) {
               removeEndNode(t.visualRootOfTheClosedTree, t.endVNode);
            }
         }
      }
      protected function updateCloseTreeStates():void  {
         _closeStatesUpdated= true;
         for each (var t:TreeToCloseArg in _treeToClose) {
            var rootNode:PTRootNode = t.visualRootOfTheClosedTree.node as PTRootNode;
            if (rootNode) {
               if (rootNode.containedPearlTreeModel.openingTargetState == OpeningState.CLOSED) {
                  rootNode.containedPearlTreeModel.openingTargetState= null;
               } 
               rootNode.containedPearlTreeModel.openingState = OpeningState.CLOSED;
               rootNode.containedPearlTreeModel.endNode =null;
            }
         }
      }
      protected function removeEndNode(vrootOfClosingNode:IVisualNode, endVNode:IVisualNode):void {
         var nodesConnectedToEndNode:Array= new Array();
         var edgeDataArray:Array= new Array();
         if (endVNode) {
            var  endNode:IPTNode = endVNode.node as IPTNode;
            for each (var node:IPTNode in endNode.successors) {
               
               nodesConnectedToEndNode.push(node);
               edgeDataArray.push(IEdge(node.inEdges[0]).data);

            }
            try {
               _vgraph.removeNode(endVNode);
            } catch ( error:Error) {
               trace (error.getStackTrace());
            } 
            for (var childIndex:int=nodesConnectedToEndNode.length; childIndex-->0;) {
               var vedge:IVisualEdge = _vgraph.linkNodes(vrootOfClosingNode, nodesConnectedToEndNode[childIndex].vnode);
               vedge.data = vedge.edge.data = edgeDataArray[childIndex]; 
            }
            
            if (vrootOfClosingNode.view) {
               vrootOfClosingNode.view.invalidateProperties();
            }
         }
      }   
      
      private function redrawEdges(e:Event):void {
         _vgraph.refresh();
      }
      
   }
}
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
import com.broceliand.graphLayout.visual.IPTVisualGraph;
import com.broceliand.graphLayout.model.IPTNode;

internal class TreeToCloseArg {
   private var _endVNode:IVisualNode;
   private var _visualRootOfTheClosedTree:IVisualNode;
   private var _vnodesToDelete:Array;
   
   public function TreeToCloseArg(visualRootOfTheClosedTre:IVisualNode, visualNodesToDelete:Array , endNode:IPTNode) {
      _visualRootOfTheClosedTree= visualRootOfTheClosedTre;
      _vnodesToDelete = visualNodesToDelete;
      _endVNode = endNode==null?null:endNode.vnode;
      
   }
   public function get endVNode ():IVisualNode
   {
      return _endVNode;
   }
   public function get vnodesToDelete ():Array
   {
      return _vnodesToDelete;
   }
   public function get visualRootOfTheClosedTree ():IVisualNode
   {
      return _visualRootOfTheClosedTree;
   }
}

