package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.FocusController;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.io.loader.IPearlTreeLoaderCallback;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.effects.UnfocusPearlEffect;
   import com.broceliand.ui.interactors.IGestureInteractor;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.mouse.MouseManager;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   import mx.core.Application;
   import mx.effects.Effect;
   import mx.effects.Fade;
   import mx.effects.Parallel;
   import mx.events.EffectEvent;

   public class InteractiveTreeOpener {
      private var _nodeToOpen:IPTNode =null;
      private var _openingTreeNode:PTRootNode =null;
      private var _treeLoader:LoadedTreeProviderWithDelay;
      private var _interactorManager:InteractorManager;
      private var _draggedPearl:IPTNode;
      private var _currentTreeOpenerRequestor:ITreeOpenerRequestor
      private var _openingEmptyTreeAsap:Boolean;
      private var _currentFadeOutAction:IAction;
      private var _showBusyCursorTimeOut:uint=0;
      private var _hasBusyCursor:Boolean = false;
      private var _arePearlsHidden:Boolean = false;
      public function InteractiveTreeOpener(draggedPearl:IPTNode, interactorManager:InteractorManager) {
         _draggedPearl = draggedPearl;
         _interactorManager = interactorManager;
         _treeLoader = new LoadedTreeProviderWithDelay(this); 
      }
      public function openTreeWithDelay(node:IPTNode, treeRequestor:ITreeOpenerRequestor, delay:int,openingEmptyEndTree:Boolean=false):void {
         _nodeToOpen = node;
         _openingEmptyTreeAsap = openingEmptyEndTree;
         _currentTreeOpenerRequestor = treeRequestor;
         var bnode:BroPTNode = node.getBusinessNode();
         var treeToOpen:BroPearlTree = bnode.owner;
         if (bnode is BroLocalTreeRefNode) {
            treeToOpen =BroLocalTreeRefNode(bnode).refTree;
         }
         _treeLoader.provideLoadedTreeWithDelay(treeToOpen, delay);
      }
      public function openEmptyTreeAsap(node:IPTNode, treeRequestor:ITreeOpenerRequestor):void {
         openTreeWithDelay(node, treeRequestor, 0, true);
      }
      public function reset():void {
         if (_arePearlsHidden && _hasBusyCursor || _showBusyCursorTimeOut>0) {
            makePearlsDisappearEffect(false);
         }
         clearShowBusyCursorTimeout();
         setHasBusyCursor(false);
         _treeLoader.reset();
      }

      public function openAvailableTreeNow(tree:BroPearlTree):void {
         _arePearlsHidden = false;
         clearShowBusyCursorTimeout();
         setHasBusyCursor(false);
         if (!_currentTreeOpenerRequestor.isOpeningTreeNeeded(_nodeToOpen)) {
            return;
         }
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         var user:User = navModel.getSelectedUser();
         var userId:int = -1;
         if (user) {
            userId = user.persistentId;
         }
         
         ApplicationManager.getInstance().visualModel.selectionModel.highlightTree(null);

         if (_nodeToOpen.vnode && _nodeToOpen.vnode.vgraph.currentRootVNode == _nodeToOpen.vnode) {
            var ftree:BroPearlTree = (_nodeToOpen as PTRootNode).containedPearlTreeModel.businessTree;
            var nextFocusTree:BroPearlTree = ftree.treeHierarchyNode.parentTree;
            navModel.goTo(nextFocusTree.getAssociationId(), userId, nextFocusTree.id, nextFocusTree.id, -2);
            return;
         }

         ApplicationManager.getInstance().visualModel.navigationModel.goTo(tree.getAssociationId(), userId, tree.id, tree.id, -2);  

         ApplicationManager.getInstance().visualModel.selectionModel.openingTree = tree;
         _openingTreeNode = _nodeToOpen as PTRootNode;
         _currentTreeOpenerRequestor.onOpeningTree(_openingTreeNode);
         
      }
      public function onDelayHappenWithTreeNotLoaded(tree:BroPearlTree):void {
         if (!_currentTreeOpenerRequestor.isOpeningTreeNeeded(_nodeToOpen)) {
            return;
         }
         if (tree.isEmpty()) {
            setHasBusyCursor(true);
         } else {
            makePearlsDisappearEffect(true);
            _showBusyCursorTimeOut = setTimeout(setHasBusyCursor, 1000, true);
         }
      }
      private function makePearlsDisappearEffect(disappear:Boolean):void {
         _arePearlsHidden = true;   
         
         var pearltreeViewer:IPearlTreeViewer = ApplicationManager.getInstance().components.pearlTreeViewer;
         var vgraph:IPTVisualGraph = pearltreeViewer.vgraph;
         var rootVNode:IPTVisualNode = vgraph.currentRootVNode as IPTVisualNode;
         var descendants:Array = rootVNode.ptNode.getDescendantsAndSelf();
         var manipulatedNodeModel:ManipulatedNodesModel = pearltreeViewer.interactorManager.manipulatedNodesModel;
         var par:Parallel = new Parallel();
         for each (var n:IPTNode in descendants) {
            if (!manipulatedNodeModel.isNodeManipulated(n) && n != _nodeToOpen) {
               var f:Fade = new UnfocusPearlEffect(n.vnode.view, disappear);
               par.addChild(f);
            }
         }
         var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         var playAction:IAction = new GenericAction(null, par, par.play);
         var onEndEffectAction:GenericAction= new GenericAction(null, garp, garp.notifyEndAction, playAction);
         par.addEventListener(EffectEvent.EFFECT_END, onEndEffectAction.performActionOnFirstEvent);
         garp.postActionRequest(playAction);
      }
      
      private function clearShowBusyCursorTimeout():void {
         if (_showBusyCursorTimeOut>0) {
            clearTimeout(_showBusyCursorTimeOut);
            _showBusyCursorTimeOut = 0;
         }
      }
      public function isOpeningANewTree():Boolean {
         if (_openingTreeNode && _openingTreeNode.containedPearlTreeModel.openingState == OpeningState.OPENING) {
            return true;
            
         } else {
            _openingTreeNode = null;
            return false;
         }
         
      }      
      
      private function setHasBusyCursor(value:Boolean):void
      {
         if (value != _hasBusyCursor) {
            ApplicationManager.getInstance().visualModel.mouseManager.showBusy(value);
            _hasBusyCursor = value;
         }
      }
      
   }
}
import com.broceliand.ApplicationManager;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.pearlTree.io.loader.IPearlTreeLoaderCallback;
import com.broceliand.pearlTree.model.BroPTNode;
import com.broceliand.pearlTree.model.BroPearlTree;
import com.broceliand.ui.interactors.drag.DragIntoTreeInteractor;
import com.broceliand.ui.interactors.drag.InteractiveTreeOpener;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

internal class LoadedTreeProviderWithDelay implements IPearlTreeLoaderCallback {
   private var _treeToOpen:BroPearlTree;
   private var _timer:Timer;
   private var _timeOut:Boolean = false;
   private var _interactor:InteractiveTreeOpener;
   public function LoadedTreeProviderWithDelay(interactor:InteractiveTreeOpener) {
      _interactor = interactor;
      _timer =new Timer(500,1);
      _timer.addEventListener(TimerEvent.TIMER, onDelayHappen);
      
   }
   
   public function provideLoadedTreeWithDelay(tree:BroPearlTree, delay:int):void {
      reset();
      _treeToOpen = tree;
      if (delay>10) {
         _timer.delay = delay;
         _timer.start();   
      } else {
         _timeOut = true;
      }
      if (!tree.pearlsLoaded) {
         ApplicationManager.getInstance().pearlTreeLoader.loadTree(tree.getMyAssociation().associationId, tree.id, this, false);
      } else {
         updateState();
      }
      
   } 

   public function onTreeLoaded(tree:BroPearlTree):void {
      if (tree!= _treeToOpen) {
         return;
      } else {
         updateState();
      }

   }
   public function onErrorLoadingTree(error:Object):void {
      trace("Error Loading tree " +error);
   }
   
   private function onDelayHappen(event:Event):void{
      _timeOut = true;
      updateState();
   }
   
   private function updateState():void {
      if (_timeOut && _treeToOpen) {
         if (_treeToOpen.pearlsLoaded) {
            _interactor.openAvailableTreeNow(_treeToOpen);
            reset();
         } else {
            _interactor.onDelayHappenWithTreeNotLoaded(_treeToOpen);
            
         }
      }
   }
   
   public function reset():void {
      _timer.stop();
      _timer.reset();
      _treeToOpen = null;
      _timeOut = false;
   }

}

