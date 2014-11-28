package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.layout.PTLayouterBase;
   import com.broceliand.graphLayout.layout.UpdateTitleRendererLayout;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.PearlTreeModel;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.effects.UnfocusPearlEffect;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.list.PTRepeater;
   import com.broceliand.ui.model.OpenTreesStateModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.BackFromAliasButton;
   import com.broceliand.ui.pearlTree.UnfocusButton;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.core.Application;
   import mx.effects.Effect;
   import mx.effects.Parallel;
   import mx.effects.Pause;
   import mx.effects.Sequence;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.Node;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class FocusController
   {
      private static const TRACE_DEBUG:Boolean = false;
      private var _oldFocusedVNode:IVisualNode;
      private var _focusedVNode:IVisualNode;
      private var _nodesToShowAtEndOfAnim:Array = null;
      private var _pearlTreeEditionController:PearlTreeEditionController = null;
      protected var _vgraph:IPTVisualGraph = null;
      private var _isAnimating:Boolean;
      private var _animationStartTime:Number;
      private var _displayModel:GraphicalDisplayedModel;
      private var _nodesToHide:Array;
      private var _unfocusButton:UnfocusButton;
      private var _backFromAlias:BackFromAliasButton;
      private var _currentRequest:IAction;
      private var _animationProcessor:GraphicalAnimationRequestProcessor;
      
      public function FocusController(pearlTreeEditionController:PearlTreeEditionController, vgraph:IPTVisualGraph, animationProcessor:GraphicalAnimationRequestProcessor){
         _pearlTreeEditionController = pearlTreeEditionController;
         _vgraph = vgraph;
         _unfocusButton = _vgraph.controls.unfocusButton;
         _backFromAlias = _vgraph.controls.backFromAliasButton;
         _animationProcessor = animationProcessor;
      }
      public function get focusedVNode():IVisualNode {
         return _focusedVNode;
      }
      
      public function set focusedVNode(o:IVisualNode):void {
         _focusedVNode = o;
      }
      public function get isAnimating():Boolean {
         return _isAnimating;
      }
      private function setIsAnimating(value:Boolean):void {
         if (!value) {
            if (_vgraph) {
               UpdateTitleRendererLayout.updateTitleRendererNow(_vgraph);
            }
            _animationProcessor.notifyEndAction(_currentRequest);
         } else {
            _animationStartTime = getTimer();
         }
         _isAnimating = value;
      }

      public function focusOnNode(request:IAction, vnodeToFocusOn:IVisualNode, displayModel:GraphicalDisplayedModel, crossingBusinessNode:BroPTNode):void{
         setIsAnimating(true);
         _vgraph.PTLayouter.setPearlTreesWorldLayout(false);
         _displayModel = displayModel;
         _oldFocusedVNode = _focusedVNode;
         
         if (_oldFocusedVNode &&! _oldFocusedVNode.view) {
            _oldFocusedVNode = vnodeToFocusOn.vgraph.currentRootVNode;
         }
         _focusedVNode = vnodeToFocusOn;
         _currentRequest = request;
         
         if(_vgraph.currentRootVNode == vnodeToFocusOn){
            if (vnodeToFocusOn) {
               var nodeToFocusOn:IPTNode = vnodeToFocusOn.node as IPTNode;
               var am:ApplicationManager = ApplicationManager.getInstance();
               
               if(!am.isEmbed() || am.embedManager.embedTree != am.visualModel.navigationModel.getFocusedTree()) {
                  _unfocusButton.bindToNode(nodeToFocusOn);
                  _unfocusButton.visible= _unfocusButton.includeInLayout = true;
               }
               _backFromAlias.visible = _backFromAlias.includeInLayout = true;
               _backFromAlias.bindToNode(nodeToFocusOn);
            }
            if(TRACE_DEBUG) trace("[FocusController] same focus, do nothing");
            setIsAnimating(false);
            return;
         }else{
            _unfocusButton.visible = _unfocusButton.includeInLayout = false;
            _backFromAlias.visible = _backFromAlias.includeInLayout = false;
         }
         focusZoomIn(vnodeToFocusOn);
      }

      public static function getDescendantsWithExclusion(rootNode:IPTNode, excludingRootNode:IPTNode):Array{
         var ret:Array = new Array();
         var nodesToProcess:Array = new Array();
         nodesToProcess.push(rootNode);
         while(nodesToProcess.length > 0){
            var processedNode:IPTNode = nodesToProcess.pop();
            if(processedNode != excludingRootNode){
               for each(var successor:IPTNode in processedNode.successors){
                  nodesToProcess.push(successor);
               }
               ret.push(processedNode);
            }else{
               var model:IPearlTreeModel = (processedNode as PTRootNode).containedPearlTreeModel;
               var endNode:IPTNode = model.endNode;
               if (endNode is EndNode) {
                  nodesToProcess.push(endNode);
               } else {
                  for each(successor in endNode.successors){
                     nodesToProcess.push(successor);
                  }
               }
            }
         }
         return ret;
      }
      
      private function focusZoomIn(vnodeToFocusOn:IVisualNode):void{
         _vgraph.getEditedGraphVisualModification().cancelVisualGraphModificationForLayout();
         _nodesToHide= getDescendantsWithExclusion(_oldFocusedVNode.node as IPTNode, vnodeToFocusOn.node as IPTNode);
         _vgraph.getEditedGraphVisualModification().restoreVisualGraphModificationAfterLayout();
         
         var seq:Sequence= new Sequence();
         var par:Parallel = new Parallel();
         var pause:Pause = new Pause();
         var lastEffect:UnfocusPearlEffect;
         var manipulatedModel:ManipulatedNodesModel = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.manipulatedNodesModel;
         for (var i:int = _nodesToHide.length; i-->0;) {
            var node:IPTNode = _nodesToHide[i];
            if (manipulatedModel.isNodeManipulated(node)) {
               _nodesToHide.splice(i,1);
               continue;
            }
            if (!node.isEnded() && (node.vnode.view.alpha != 0)) {
               lastEffect = new UnfocusPearlEffect(node.vnode.view);
               lastEffect.alphaFrom = node.vnode.view.alpha;   
               par.addChild(lastEffect);
            }
         }
         var subTree:IPearlTreeModel = (_oldFocusedVNode.node as PTRootNode).containedPearlTreeModel;
         
         ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(subTree.businessTree);
         if (subTree && subTree.endNode is EndNode && !subTree.endNode.isEnded()) {
            _vgraph.removeNode(subTree.endNode.vnode);
         }
         if (lastEffect) {
            seq.addChild(par);
            lastEffect.addEventListener(TweenEvent.TWEEN_UPDATE, showZoomInEdges);
            pause.addEventListener(TweenEvent.TWEEN_START, showZoomInEdges);
            pause.duration=300;
            seq.addChild(pause);
         }
         _vgraph.endNodeVisibilityManager.updateAllNodes();
         _vgraph.refresh();
         if(lastEffect){
            seq.addEventListener(EffectEvent.EFFECT_END, focusZoomInStep2, false, 0, true);
            seq.play();
         }else{
            focusZoomInStep2(null);
         }

      }
      
      private function focusZoomInStep2(ev:Event):void{
         _vgraph.currentRootVNode = _focusedVNode;
         if (ev) {
            ev.currentTarget.removeEventListener(EffectEvent.EFFECT_END, focusZoomInStep2);
         }
         
         var focusNode:PTRootNode = _focusedVNode.node as PTRootNode;
         var shouldPerformLayout:Boolean = focusNode.containedPearlTreeModel.openingState != OpeningState.CLOSED; 
         _pearlTreeEditionController.refreshEdgeWeights(_vgraph.currentRootVNode);
         
         _vgraph.refresh();
         if (!shouldPerformLayout && focusNode.isRendererInScreen()) {
            var point:Point= _focusedVNode.viewCenter.clone();
            point = point.subtract(_oldFocusedVNode.viewCenter);
            _vgraph.offsetOrigin(point.x, point.y);
         }
         var openTreeModel:OpenTreesStateModel =ApplicationManager.getInstance().visualModel.openTreesModel;
         for each (var n:IPTNode in _nodesToHide) {
            var rootNode:PTRootNode = n as PTRootNode;
            if (rootNode && rootNode.isOpen()) {
               openTreeModel.closeTree(1, rootNode.containedPearlTreeModel.businessTree.id);
            }
            _vgraph.removeNode(n.vnode);
            
            openTreeModel.closeAllTees();   
         }
         if (shouldPerformLayout) {
            _vgraph.layouter.addEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, focusZoomInStep3);
            if (IPTNode(focusNode).isRendererInScreen()) {
               _vgraph.PTLayouter.layoutWithFixNodePosition(focusNode)
            }   else {
               _vgraph.layouter.layoutPass();
            }
         } else {
            focusZoomInStep3(null);
         } 
      }
      
      private function focusZoomInStep3(ev:Event):void{
         if (ev) {
            _vgraph.layouter.removeEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, focusZoomInStep3);
         }
         var rootNode:IPTNode = _vgraph.currentRootVNode.node as IPTNode;
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed() && am.embedManager.embedTree == am.visualModel.navigationModel.getFocusedTree()) {
            
         }else{
            _unfocusButton.visible = _unfocusButton.includeInLayout = true;
            _unfocusButton.bindToNode(rootNode);
         }
         _backFromAlias.visible = _backFromAlias.includeInLayout = true;
         _backFromAlias.bindToNode(rootNode);
         
         if (rootNode.vnode.view) {
            rootNode.vnode.view.invalidateProperties();
         }
         setIsAnimating(false);
         
      }
      private function showZoomInEdges(ev:Event=null):void{
         _vgraph.refresh();
      }  
   }
}
import com.broceliand.util.IAction;
import mx.effects.Effect;

internal class PlayAnimationAction implements IAction {
   private var _effect:Effect;
   
   public function PlayAnimationAction(effect:Effect) {
      _effect = effect;
   }
   public   function performAction():void {
      _effect.play();
   }
}