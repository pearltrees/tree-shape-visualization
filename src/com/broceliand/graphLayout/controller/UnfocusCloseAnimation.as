package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.effects.UnfocusPearlEffect;
   import com.broceliand.ui.interactors.DepthInteractor;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.pearlTree.BackFromAliasButton;
   import com.broceliand.ui.pearlTree.UnfocusButton;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   import mx.core.UIComponent;
   import mx.effects.Effect;
   import mx.effects.Fade;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.effects.TweenEffect;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.events.VNodeMouseEvent;
   
   public class UnfocusCloseAnimation extends CloseTreeAnimation 
   {
      private var _nodesToDelete:Array;
      private var _keepFocusNodeAsFixedNode:Boolean;
      private var _nextFocusTree:BroPearlTree;
      private var _gnc:GraphicalNavigationController;
      public function UnfocusCloseAnimation(request:IAction, animationProcessor:GraphicalAnimationRequestProcessor, nextFocusTree:BroPearlTree, gnc:GraphicalNavigationController )  
      {
         super(request, animationProcessor);
         _gnc = gnc;
         _nextFocusTree = nextFocusTree;
      }
      
      private function setEdgeVisible(n:IPTNode, isVisible:Boolean):void {
         for each(var edge:IEdge in n.outEdges){
            (edge.data as EdgeData).visible = isVisible;
         }
         if (n is EndNode) {
            for each( edge in n.inEdges){
               (edge.data as EdgeData).visible = isVisible;
            }
         }
      } 
      override protected function playDisappearAnimation():void {
         _nodesToDelete = super.playQuickCloseAnimation();
      }
      override protected function onEndDisapparition(e:Event):void {
         callAfterDisparition();
      }
      private function callAfterDisparition():void {
         super.updateCloseTreeStates();
         var depthInteractor:DepthInteractor= ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.depthInteractor;
         depthInteractor.movePearlToNormalDepth(_fixedVNode.view as IUIPearl);
         _vgraph.getEditedGraphVisualModification().cancelVisualGraphModificationForLayout();

         var nextFocusNode:IPTNode= _displayModel.getNode(_nextFocusTree);
         if (!nextFocusNode) {
            nextFocusNode = _gnc.createTree(_nextFocusTree, false, false, 0).node as IPTNode;
         }
         _vgraph.currentRootVNode = nextFocusNode.vnode;
         
         var fixedNode:IPTNode = _fixedVNode.node as IPTNode;
         var fixedBNode:BroPTNode = fixedNode.getBusinessNode();
         if (fixedBNode as BroPTRootNode) {
            fixedBNode = fixedBNode.owner.refInParent;
         }
         if (!fixedBNode || !fixedBNode.owner || fixedBNode.owner.getTreeNodes().lastIndexOf(fixedBNode) == -1) {

            _nodesToDelete.push(fixedNode);
         }

         if (_nodesToDelete) {
            for each (var iptNode:IPTNode in _nodesToDelete) {
               _vgraph.removeNode(iptNode.vnode);
            }
         }
         var manipulatedNodeModel:ManipulatedNodesModel = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.manipulatedNodesModel;
         var nodesToShowAtEndOfAnim:Array = FocusController.getDescendantsWithExclusion(nextFocusNode, _fixedVNode.node as IPTNode);
         
         var treeToDisplay:Array = _nextFocusTree.treeHierarchyNode.getDescendantTrees(true);
         var nodesToHide:Array = new Array();
         for (var i:int =nodesToShowAtEndOfAnim.length; i-->0;) {
            var checkNode:IPTNode = nodesToShowAtEndOfAnim[i];
            if (manipulatedNodeModel.isNodeManipulated(checkNode)) {
               nodesToShowAtEndOfAnim.splice(i,1);
               continue;
            }
            if ((checkNode is EndNode && checkNode.treeOwner== _nextFocusTree) || treeToDisplay.lastIndexOf(checkNode.treeOwner)<0) {
               nodesToShowAtEndOfAnim.splice(i,1);
               nodesToHide.push(checkNode);
               checkNode.vnode.view.visible = false;
            }
         }
         
         var gas:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(new GenericAction(null, this, startAppearingAnimation, nodesToShowAtEndOfAnim ));
         setEdgeVisible(_fixedVNode.node as IPTNode, false);
         for each (var n:IPTNode in nodesToShowAtEndOfAnim) {
            var view:IUIPearl = n.vnode.view as IUIPearl;
            if (view) {
               view.visible = false;
               setEdgeVisible(n, false);
               if (!IUIPearl(n.vnode.view).isCreationCompleted()) {
                  gas.registerComponentToWaitForCreation(view.uiComponent);
               }   
            }
         }
         var unfocusButton:UnfocusButton = _vgraph.controls.unfocusButton;
         unfocusButton.visible =false;
         unfocusButton.relax();
         _vgraph.getEditedGraphVisualModification().restoreVisualGraphModificationAfterLayout();
         gas.performActionAsap();
      }
      private function startAppearingAnimation(nodesToHide:Array):void {
         
         _vgraph.origin.x=0;
         _vgraph.origin.y=0;
         var positions:Dictionary = _vgraph.PTLayouter.computeLayoutPositionOnly();
         var positionPoint:Point ;
         var offset:Point = new Point(0,0);
         if (_fixedVNode && _fixedVNode.view) {
            setEdgeVisible(_fixedVNode.node as IPTNode, true);
            
            positionPoint = positions[_fixedVNode];
            if (positionPoint) {
               var oldPearl:IUIPearl = _fixedVNode.view as IUIPearl;
               offset.x =  positionPoint.x - oldPearl.positionWithoutZoom.x;
               offset.y =  positionPoint.y - oldPearl.positionWithoutZoom.y;
               IUIPearl(_fixedVNode.view).animationZoomFactor = oldPearl.animationZoomFactor;
               if (oldPearl.animationZoomFactor >1) {
                  
                  IUIPearl(_fixedVNode.view).setBigger(true);
               }
            }
         }
         _vgraph.offsetOrigin(-offset.x, -offset.y);
         var effect:Effect;
         var p:Parallel = new Parallel();
         
         for each (var n :IPTNode in nodesToHide) {
            var pearl:IUIPearl = n.vnode.view as IUIPearl;
            pearl.alpha = 0;
            pearl.visible = true;
            positionPoint = positions[n.vnode];
            if (positionPoint) {
               pearl.moveWithoutZoomOffset(positionPoint.x -offset.x, positionPoint.y  -offset.y);
            }
            setEdgeVisible(n, true);
            
            effect = new UnfocusPearlEffect(n.vnode.view, false);
            p.addChild(effect);
         }
         if (effect) {
            effect.addEventListener(TweenEvent.TWEEN_UPDATE, refreshGraphOnEffect, false, 0, true);
            p.addEventListener(EffectEvent.EFFECT_END, endAnimation);
            p.play();
         } else {
            endAnimation(null);
         }
      }
      override protected function endAnimation(e:Event=null):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed() && am.embedManager.embedTree == am.visualModel.navigationModel.getFocusedTree()) {
            
         }else{
            var unfocusButton:UnfocusButton = _vgraph.controls.unfocusButton;
            unfocusButton.visible = unfocusButton.includeInLayout = true;
            unfocusButton.bindToNode(_vgraph.currentRootVNode.node as IPTNode);
         }
         var backFromAlias:BackFromAliasButton = _vgraph.controls.backFromAliasButton;
         backFromAlias.visible = backFromAlias.includeInLayout = true;
         backFromAlias.bindToNode(_vgraph.currentRootVNode.node as IPTNode);
         super.endAnimation(e);
      }
      
      private function refreshGraphOnEffect(event:TweenEvent):void{ 
         _vgraph.refresh();
      }
      
   }
}