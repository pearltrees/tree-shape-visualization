package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.ui.effects.UnfocusPearlEffect;
   import com.broceliand.ui.interactors.DepthInteractor;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.view.IUIPearlView;
   import com.broceliand.util.BroUtilFunction;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.effects.Fade;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.effects.Pause;
   import mx.effects.Sequence;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.utils.events.VNodeMouseEvent;
   
   public class CloseBranchAnimation
   {
      private const maxSpeed:Number = 0.7;
      private var startSpeed:Number = 0.7;
      private const accelerationDuration:Number = 500;
      
      private var _isBranchClosed:Boolean = false;
      private var _branchNodes:Array = new Array();
      private var _followingNode:IUIPearl;
      private var _lastPoint:Point;
      private var _followMode:Boolean = false;
      private var _fadeAway:Parallel;
      private var _startCloseTime:Number;
      private var _editionController:IPearlTreeEditionController;
      private var _hiddenEdgesData:Array;
      private var _draggedNode:IPTNode;
      private var _isDraggedNodeOpenTree:Boolean = false;
      private var _closeBranchForbidden:Boolean = false;
      private var _nodeDepth:Dictionary = new Dictionary();

      private var _treeToCloseNodes:Array; 
      private var _subTreesToClose:Boolean = false;

      private static const FOLLOWING_MOUSE_MOVE_AND_REFRESH_DELAY:Number = 500;
      private static const FOLLOWING_MOUSE_MOVE_AND_REFRESH_AT_FRAME:uint = 2;
      private var _followingMouseMoveFrameCount:Number = 0;
      private var _mouseMoveListenerStartTime:Number = 0;
      
      public function CloseBranchAnimation(draggedNode:IPTNode, editionController:IPearlTreeEditionController) {
         _followMode = false;
         _editionController = editionController;
      }

      private function highlightParentTree(bnode:BroPTNode, vgraph:IPTVisualGraph):void {
         var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         if (selectionModel.getHighlightedTree() == null) {
            if (selectionModel.highlightTree(bnode.owner)) {
               vgraph.refreshNodes();
            }
         }
         
      }
      private function computeBranch(draggedNode:IPTNode, vgraph:IPTVisualGraph):void {
         var treeToCloseNodes:Array;
         var branchNodes:Array;
         var draggedBNode:BroPTNode = draggedNode.getBusinessNode();
         if (draggedBNode is BroPTRootNode) {
            _isDraggedNodeOpenTree = true;
            draggedBNode= draggedBNode.owner.refInParent;
            highlightParentTree(draggedBNode, vgraph);
            treeToCloseNodes = BroUtilFunction.addToArray(treeToCloseNodes , draggedNode.getDescendantsAndSelf());
         } else {
            _isDraggedNodeOpenTree = false;
         }
         var bnodeBranch:Array = draggedBNode.getDescendants();
         branchNodes = BroUtilFunction.addToArray(branchNodes, draggedBNode.graphNode);
         for each (var bnode:BroPTNode in bnodeBranch) {
            var rootNode:PTRootNode = bnode.graphNode as PTRootNode;
            if (rootNode && rootNode.isOpen()) {
               treeToCloseNodes = BroUtilFunction.addToArray(treeToCloseNodes , rootNode.getDescendantsAndSelf());
            }
            branchNodes = BroUtilFunction.addToArray(branchNodes , bnode.graphNode);
         }
         _draggedNode = draggedNode;
         _followingNode = draggedNode.pearlVnode.pearlView;
         _branchNodes = branchNodes;
         _nodeDepth[draggedNode] = 0;
         var maxDepth:int =0;
         for each (var n:IPTNode in branchNodes) {
            var depthParent:int = _nodeDepth[n.parent]; 
            _nodeDepth[n] = depthParent+1;
            if (depthParent+1 > maxDepth) {
               maxDepth = depthParent +1;
            }
         }
         if (maxDepth >7) {
            startSpeed = 0.7;
         } else {
            startSpeed = 0.4;
         }
         _treeToCloseNodes = treeToCloseNodes;
         _subTreesToClose= (_treeToCloseNodes != null);
      }
      
      public function startAnimation(vgraph:IPTVisualGraph, draggedNode:IPTNode, depthInteractor:DepthInteractor):void {
         if (!_isBranchClosed && !_closeBranchForbidden) {
            var node:IPTNode; 
            
            vgraph.controls.emptyMapText.hide();
            _isBranchClosed = true;
            _startCloseTime = getTimer();
            computeBranch(draggedNode, vgraph);
            if (_branchNodes.length > 1) {
               addFollowingListener();   
            }
            _fadeAway = new Parallel();
            var targetPoint:Point = draggedNode.pearlVnode.pearlView.pearlCenter;
            var pearlsToMoveAbove:Array = new Array();;
            for (var j:int=_branchNodes.length; j-->0;) {
               node = _branchNodes[j];
               if (node == _draggedNode) {
                  continue;
               }
               var view:IUIPearl = node.pearlVnode.pearlView;
               view.pearl.moveRingInPearl();
               view.hideTitleToDisplayInfo(true);
               depthInteractor.movePearlAboveAllElse(view);
               pearlsToMoveAbove.push(view);
               var f:Fade = new Fade(view);
               view.alpha = 0.99;
               f.alphaFrom =0.99;
               f.alphaTo =.8;
               _fadeAway.addChild(f);
               
            }
            if(_subTreesToClose) {
               for each (var treeToCloseNode:Array in _treeToCloseNodes) {
                  for (var i:int = 1; i < treeToCloseNode.length; i++) {
                     node = treeToCloseNode[i];
                     var u:Fade = new UnfocusPearlEffect(node.vnode.view);
                     u.duration = 600;
                     _fadeAway.addChild(u);
                  }
               }
               _fadeAway.addEventListener(TweenEvent.TWEEN_END, onEndFadingAway);
            }
            depthInteractor.movePearlAboveAllElse(_followingNode);
            _fadeAway.play();
         }
      }
      
      private function addFollowingListener():void {
         if(_followingNode && _branchNodes.length > 1) {
            var stage:Stage = ApplicationManager.flexApplication.stage;
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _followingMouseMoveFrameCount = 0;
            _mouseMoveListenerStartTime = (new Date()).getTime();
         }
      }
      private function removeFollowingListener():void {
         var stage:Stage = ApplicationManager.flexApplication.stage;
         stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      }
      
      private function onEndFadingAway(event:Event):void {
         closeAllTrees(_editionController);
      }
      
      private function closeAllTrees(editionController:IPearlTreeEditionController):void {
      }
      
      private function onEnterFrame(event:Event):void {
         updateFollowingNodes();
      }
      private function onMouseMove(event:MouseEvent):void {
         
         if(((new Date()).getTime() - _mouseMoveListenerStartTime) > FOLLOWING_MOUSE_MOVE_AND_REFRESH_DELAY &&
            (_followingMouseMoveFrameCount % FOLLOWING_MOUSE_MOVE_AND_REFRESH_AT_FRAME == 0)) {
            updateFollowingNodes();
         }
         _followingMouseMoveFrameCount++;
      }
      
      private function updateFollowingNodes():void {
         var targetPoint:Point = _followingNode.pearlCenter;
         var isFollowMode:Boolean = true;
         var nextTreeToCloseRoot:IPTNode = null;
         var branchIndex:int = 0;
         var subBranchIndex:int = 0;
         var treeToCloseIndex:int =0;
         
         if (_subTreesToClose) {
            nextTreeToCloseRoot = _treeToCloseNodes[treeToCloseIndex][0];
         }
         for each (var n:IPTNode in _branchNodes) {
            targetPoint = moveNode(n, targetPoint, false);   
            if (n == nextTreeToCloseRoot) {
               for (var i:int = 1; i < _treeToCloseNodes[treeToCloseIndex].length; i++) {
                  n = _treeToCloseNodes[treeToCloseIndex][i];
                  moveNode(n , targetPoint, true);
               }
               treeToCloseIndex ++;
               if (treeToCloseIndex < _treeToCloseNodes.length) {
                  nextTreeToCloseRoot = _treeToCloseNodes[treeToCloseIndex][0];
               }
            }
         }
      }
      
      private function moveNode(node:IPTNode, targetPoint:Point, fromClosingTree:Boolean):Point{
         if (!node.isEnded() && node != _draggedNode) {
            var stickyNode:Boolean = _nodeDepth[node] ==null;
            var deepNode:Boolean = stickyNode || ( _nodeDepth[node] > 6) ;
            var view:IUIPearl = node.pearlVnode.pearlView;
            if (view.alpha>0) {
               var pearlCenter:Point = view.pearlCenter;
               var speed:Number = getCurrentSpeed(fromClosingTree);
               if (node.parent && node.parent.vnode.view.alpha >0) {
                  targetPoint = node.parent.pearlVnode.pearlView.pearlCenter;
               }
               var dx:Number =(targetPoint.x - pearlCenter.x) ;
               var dy:Number =(targetPoint.y - pearlCenter.y) ;
               var nextDistance:Number = (dx*dx +dy*dy)
               if (!deepNode || !stickyNode) { 
                  dx*=speed;
                  dy*=speed;
                  nextDistance*=  speed * speed * (1-speed) * (1-speed);
               } if (deepNode && nextDistance <=2 ){
                  delete _nodeDepth[node];
               }
               if (nextDistance > 2 || deepNode || stickyNode) {
                  view.move(view.x + dx , view.y + dy);   
               } 
            } 
         }
         return targetPoint;
      }
      public function restoreBranch(depthInteractor:DepthInteractor, reopenTrees:Boolean):IAction {
         var restoreDepthAction:IAction = null; 
         if (_isBranchClosed) {
            _isBranchClosed = false;
            closeAllTrees(_editionController);
            _fadeAway.stop();
            var par:Parallel = new Parallel();
            removeFollowingListener();
            var fade:Fade;
            var moveNodeToNormalDepthArray:Array = new Array();
            for each (var node:IPTNode in _branchNodes) {
               if (node.isEnded()) {
                  continue;
               }
               var view:IUIPearl = node.pearlVnode.pearlView;
               view.pearl.moveRingOutPearl();
               moveNodeToNormalDepthArray.push(view);
               if (node == _draggedNode) {
                  continue;
               }
               fade = new Fade(view);
               fade.alphaFrom = view.alpha;
               fade.alphaTo = 1;
               fade.duration = 300;
               par.addChild(fade);
               view.hideTitleToDisplayInfo(false);
            }
            restoreDepthAction = new GenericAction(null, this, restoreViewToNormalDepth, depthInteractor, moveNodeToNormalDepthArray); 
            if (_subTreesToClose && reopenTrees) {
               var reopeingTreeEffect:Sequence = new Sequence();
               var p:Pause = new Pause();
               p.duration = 400;
               reopeingTreeEffect.addChild(p);
               var par2:Parallel = new Parallel();
               
               for each (var treeToCloseNode:Array in _treeToCloseNodes) {
                  var rootNode:PTRootNode = treeToCloseNode[0];
                  var endNode:EndNode = rootNode.containedPearlTreeModel.endNode  as EndNode; 
                  for (var i:int = 1; i < treeToCloseNode.length ; i++) {
                     node = treeToCloseNode[i];
                     if (node == endNode) {
                        node.vnode.view.alpha =1 ;
                     } else {
                        var unfocusEffect:Fade= new  Fade(node.vnode.view);
                        unfocusEffect.alphaFrom = node.vnode.view.alpha;
                        unfocusEffect.alphaTo=1;
                        unfocusEffect.duration = 300;
                        par2.addChild(unfocusEffect);
                     }
                  }

               }
               reopeingTreeEffect.addChild(par2);
               reopeingTreeEffect.play();
            }
            par.play();
         }
         return restoreDepthAction; 

      }
      private function restoreViewToNormalDepth(depthInteractor:DepthInteractor, views:Array):void {
         for each (var view:IUIPearl in views) {
            depthInteractor.movePearlToNormalDepth(view);
         }
         
      }
      public function hasCollapsedBranch():Boolean {
         return _branchNodes && _branchNodes.length >0 || _treeToCloseNodes;
      }
      public function isBranchClosed():Boolean{
         return _isBranchClosed;
      }
      public function getCurrentSpeed(fromClosingTree:Boolean):Number {
         if (_followMode ) {
            return maxSpeed;
         }  else {
            var duration:Number = (getTimer() - _startCloseTime) / accelerationDuration;
            if (duration>1) {
               _followMode = true;
               duration = 1;
            } else if (fromClosingTree) {
               duration *=1.20;
               if (duration >1) duration = 1;
            }
            
            return startSpeed + (maxSpeed - startSpeed) * duration;
         }
      }
      public function isDraggedNodeOpenTree():Boolean {
         return _isDraggedNodeOpenTree;
      } 
      public function cancelBranchDetachmentAfterSwap():void {
         _closeBranchForbidden = true;
         
      }   
   }
}