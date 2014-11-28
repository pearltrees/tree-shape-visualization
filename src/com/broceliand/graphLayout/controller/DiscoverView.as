package com.broceliand.graphLayout.controller {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.io.object.tree.OwnerData;
   import com.broceliand.pearlTree.model.BroCoeditPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTWAliasNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTWPageNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.model.discover.DiscoverDisplayModel;
   import com.broceliand.pearlTree.model.discover.DiscoverModel;
   import com.broceliand.pearlTree.model.discover.SpatialHex;
   import com.broceliand.pearlTree.model.discover.SpatialTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.button.PTButton;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.customization.avatar.AvatarManager;
   import com.broceliand.ui.interactors.scroll.ScrollUi;
   import com.broceliand.ui.model.ScrollModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.pearlTree.IScrollControl;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   import com.broceliand.util.resources.ResourceStatus;
   
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   
   import mx.core.Application;
   import mx.effects.Effect;
   import mx.effects.Zoom;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class DiscoverView {
      
      private static const MAX_HEX_WITH_SHOW_EFFECT:uint=1;
      private static const MAX_HEX_WITH_HIDE_EFFECT:uint=1; 
      private static const SHOW_PEARL_DURATION:Number=400;
      private static const SHOW_PEARL_DELAY:Number=200;
      private static const SHOW_HEX_DELAY_TO_LOAD_AVATARS:uint=250;
      private static const SHOW_HEX_DELAY_ON_MULTIPLE_SHOW:uint = 2 * SHOW_PEARL_DURATION;
      private static const MIN_DIST_TO_CONSIDER_DRAG:Number=20;
      private static const MIN_TIME_TO_USE_AVERAGE_SPEED:Number=500;
      private static const HIDE_HEX_DURATION:uint=50;
      private static const SCROLL_GROW_EFFECT_DELAY:Number = 8000;
      private static const SCROLL_GROW_EFFECT_REPEAT_DELAY:Number = 16000;
      private static const MAX_HEX_TO_HIDE_SIZE:int =5;
      public  static const MIN_TIME_BETWEEN_HEX_APPEARANCE:int =600;
      
      private var _model:DiscoverModel;
      private var _vgraph:IPTVisualGraph;
      private var _garp:GraphicalAnimationRequestProcessor;
      private var _scrollControl:IScrollControl;
      private var _spacialTreeToNode:Dictionary;
      private var _hexToHideQueue:Vector.<SpatialHex>;
      private var _numHexWithShowEffect:uint;
      private var _numHexWithHideEffect:uint;
      private var _moveStartPos:Point;
      private var _moveStartTime:Number;
      private var _changeHexFocusedOnMouseUp:Boolean;
      private var _playInitEffectForHex:Vector.<SpatialHex>;
      private var _scrollGrowTimer:Timer;
      private var _displayModel:DiscoverDisplayModel;
      private var _lastAppearTimeScheduled:Number;
      public function DiscoverView() {
         var am:ApplicationManager = ApplicationManager.getInstance();
         _vgraph = am.components.pearlTreeViewer.vgraph;
         var stage:Stage = ApplicationManager.flexApplication.stage;
         _model = new DiscoverModel();
         _displayModel = new DiscoverDisplayModel(_model, _vgraph);
         _model.addEventListener(DiscoverModel.NEW_HEX_LOADED, onNewHexLoaded);
         _model.addEventListener(DiscoverModel.MODEL_CLEARED, onModelCleared);
         _garp = am.visualModel.animationRequestProcessor;
         _scrollControl = _vgraph.controls.scrollControl;
         am.visualModel.scrollModel.addEventListener(ScrollModel.SCROLL_STARTED, onScrollFromButtonsStarted);
         am.visualModel.scrollModel.addEventListener(ScrollModel.SCROLL_STOPPED, onScrollFromButtonsStopped);
         am.visualModel.scrollModel.addEventListener(ScrollModel.SCROLL_CONTINUE, onScrollFromButtonsContinue);
         stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
         stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
         stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
         _model.init(_displayModel);
         _scrollGrowTimer = new Timer(SCROLL_GROW_EFFECT_DELAY);
         _scrollGrowTimer.addEventListener(TimerEvent.TIMER, onTimeToGrowScroll);
         clearView();
         
      }
      
      private function logDebug(s:String):void {
         Log.getLogger("DiscoverView").debug(s);
      }
      
      public function get model():DiscoverModel {
         return _model;
      }
      
      private function onNewHexLoaded(event:Event):void {
         if(_model.enabled) {
            var hexes:Array = _displayModel.updateLoadingHexagonState();
            preloadHexAvatars(hexes);

            populateHexToShowQueue();
            
            _displayModel.fillPTW();
            
            _scrollControl.isDiscoverMode = true;
            scheduleScrollGrowing();
         }
      }
      
      private function scheduleScrollGrowing():void {
         _scrollGrowTimer.reset();
         if(model.isFirstLoad) {
            _scrollGrowTimer.delay = SCROLL_GROW_EFFECT_DELAY;
            _scrollGrowTimer.repeatCount = 1;
         }else{
            _scrollGrowTimer.delay = SCROLL_GROW_EFFECT_REPEAT_DELAY;
            _scrollGrowTimer.repeatCount = 0;
         }
         _scrollGrowTimer.start();
      }
      private function onModelCleared(event:Event):void {
         if(!_model.enabled) {
            _scrollControl.isDiscoverMode = false;
         }
         clearView();
      }
      
      private function clearView():void {
         _spacialTreeToNode = new Dictionary();
         _hexToHideQueue = new Vector.<SpatialHex>();
         _playInitEffectForHex = new Vector.<SpatialHex>();
         _numHexWithShowEffect = 0;
         _numHexWithHideEffect = 0;
         _moveStartPos = new Point();
         _moveStartTime = 0;
         _scrollGrowTimer.reset();
         _vgraph.getPtwPearlRecyclingMananager().releaseRecycled();
      }
      
      private function onTimeToGrowScroll(event:TimerEvent):void {
         ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.controls.scrollControl.scrollUi.playGrowEffect();
         if(_scrollGrowTimer.delay == SCROLL_GROW_EFFECT_DELAY) {
            _scrollGrowTimer.delay = SCROLL_GROW_EFFECT_REPEAT_DELAY + ScrollUi.GROW_EFFECT_DURATION;
            _scrollGrowTimer.repeatCount = 0;
            _scrollGrowTimer.start();
         }
      }
      
      private function populateHexToShowQueue():void {
         
         var treeHex:SpatialHex;
         var hexNeighbour:SpatialHex;
         var hexListToShow:Vector.<SpatialHex> = new Vector.<SpatialHex>();
         
         _displayModel.fillHexesToDisplay(hexListToShow);

         var hasNeighbourVisible:Boolean;
         for each(treeHex in hexListToShow) {
            treeHex.isVisible = true;
            if (treeHex.state == SpatialHex.LOADING) {
               
            }
            
            var index:int = _hexToHideQueue.lastIndexOf(treeHex);
            if (index>=0) {
               _hexToHideQueue.splice(index,1);
               _displayModel.setHexagonState(treeHex, SpatialHex.DISPLAYED);
            } else {
               _displayModel.setHexagonState(treeHex, SpatialHex.TODISPLAY);
            }
            
            if(model.isFirstLoad) {
               _playInitEffectForHex.push(treeHex);
            }
         }
         
         showOrHideHexFromQueues();    
         
      }
      
      private function preloadHexAvatars(spatialHexesArray:Array):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var spatialTree:SpatialTree;
         for each (var hex:SpatialHex  in spatialHexesArray) {
            for each(spatialTree in hex.spacialTreeList) {
               am.avatarManager.preloadAvatar(spatialTree.tree, AvatarManager.TYPE_PEARL_HUGE);
            }
         }
      }
      
      public function showOrHideHexFromQueues():void {
         
         if(hasHexToShow() && _hexToHideQueue.length<MAX_HEX_TO_HIDE_SIZE) {
            showNextHexInQueue();
         }else{
            hideNextHexInQueue();
         }
      }
      public function hasHexToShow():Boolean {
         return _displayModel.hasHexToShow();
      }
      
      private function showNextHexInQueue():void {
         
         if(hasHexToShow()) {
            var treeHex:SpatialHex = _displayModel.getNextHexToDisplayed();
            if(isTreeHexVisibleOnScreen(treeHex)) {
               _displayModel.setHexagonState(treeHex, SpatialHex.DISPLAYED);
               
               var delay:uint = 0;
               var index:int = _playInitEffectForHex.lastIndexOf(treeHex);
               var isFirstLoad:Boolean = index >=0;
               _garp.postActionRequest(new GenericAction(_garp, this, showHex, treeHex, delay, isFirstLoad));
               if (isFirstLoad){
                  _playInitEffectForHex.splice(index, 1);
                  showOrHideHexFromQueues();
               }
               
            }else{
               _displayModel.setHexagonState(treeHex, SpatialHex.HIDDEN);
               treeHex.isVisible = false;
               showOrHideHexFromQueues();
            }
         }
      }
      
      private function populateHexToHideQueue():void {

         var treeHex:SpatialHex;
         for each(treeHex in _model.hexList) {
            if(treeHex.isVisible && treeHex.isLoaded && isTreeHexFullyHiddenFromScreen(treeHex) && _hexToHideQueue.indexOf(treeHex) == -1) {
               _hexToHideQueue.push(treeHex);
               _displayModel.setHexagonState(treeHex, SpatialHex.HIDDEN);
               treeHex.isVisible = false;
            }
         }
         
         showOrHideHexFromQueues();
      }
      
      private function hideNextHexInQueue():void {
         
         if((!_vgraph.isBackdroungDragInProgress() || _hexToHideQueue.length> MAX_HEX_TO_HIDE_SIZE) && _hexToHideQueue.length > 0) {
            var treeHex:SpatialHex = _hexToHideQueue[0];
            if(isTreeHexFullyHiddenFromScreen(treeHex)) {
               if(_numHexWithHideEffect < MAX_HEX_WITH_HIDE_EFFECT) {
                  _numHexWithHideEffect++;
                  _hexToHideQueue.shift();
                  hideHex(treeHex);
               }
            }else{
               _hexToHideQueue.shift();
               if (hasNodeBeenCreated(treeHex)) {
                  _displayModel.setHexagonState(treeHex, SpatialHex.DISPLAYED);
               } else {
                  _displayModel.setHexagonState(treeHex, SpatialHex.TODISPLAY);
               }
               treeHex.isVisible = true;
               showOrHideHexFromQueues();
            }
         }
      }
      
      private function onScrollFromButtonsStarted(event:Event):void {
         if(!_model.enabled) return;  
         _scrollGrowTimer.reset();
         registerMoveStart(_vgraph.origin.x, _vgraph.origin.y);
         _displayModel.onScrollFromButtonsStarted();
      }
      private function onScrollFromButtonsContinue(event:Event):void {
         if(!_model.enabled) return;  
         _displayModel.onScrollFromButtonsContinue();
      }
      private function onScrollFromButtonsStopped(event:Event):void {
         if(!_model.enabled) return;
         scheduleScrollGrowing();
         var dist:Number = BroceliandMath.getDistanceBetweenPoints(_moveStartPos, _vgraph.origin);
         if(dist > (SpatialHex.EDGE_DISTANCE_Y * _vgraph.scale)) {
            updateHexFocusedOnMove(_vgraph.origin.x, _vgraph.origin.y);
         }
         _displayModel.onScrollFromButtonsStopped();
      }
      
      private function onMouseUp(event:MouseEvent):void {
         if(!_model.enabled) return;
         scheduleScrollGrowing();
         populateHexToShowQueue();
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         var isPointOverWindow:Boolean = wc.isPointOverWindow(event.stageX, event.stageY) || wc.isPointOverMenuWindow(event.stageX, event.stageY) || wc.isPointOverNotificationWindow(event.stageX, event.stageY);
         _displayModel.onBackgroundDragEnd();
         
      }
      
      private function onMouseDown(event:MouseEvent):void {
         if(!_model.enabled) return;
         _scrollGrowTimer.reset();
         registerMoveStart(event.stageX, event.stageY);
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         var isPointOverWindow:Boolean = wc.isPointOverWindow(event.stageX, event.stageY) || wc.isPointOverMenuWindow(event.stageX, event.stageY) || wc.isPointOverNotificationWindow(event.stageX, event.stageY);
         if(!isPointOverWindow && event.stageY > 50 && event.stageY < (_vgraph.height - 100)) {
            var localX:int = (event.stageX - _vgraph.origin.x - _vgraph.width / 2.0) / _vgraph.scale;
            var localY:int = (event.stageY - _vgraph.origin.y - _vgraph.height / 2.0) / _vgraph.scale;
            _displayModel.addHexesTowardsPoint(localX, localY);         
         }
         _changeHexFocusedOnMouseUp = true;
         _displayModel.onBackgroundDragBegin();
      }
      
      private function registerMoveStart(moveX:int, moveY:int):void {
         _moveStartPos.x = moveX;
         _moveStartPos.y = moveY;
         _moveStartTime = new Date().getTime();      
      }
      
      private function onMouseMove(event:MouseEvent):void {
         if(!_model.enabled) return;     
         if (_vgraph.isBackdroungDragInProgress()) {
            _displayModel.onBackgroundDragContinue();
         }
         var curPos:Point = new Point(event.stageX, event.stageY);
         var dist:Number = BroceliandMath.getDistanceBetweenPoints(_moveStartPos, curPos);
         if(_vgraph.isBackdroungDragInProgress() && dist > 10) {
            updateHexFocusedOnMove(curPos.x, curPos.y);
            _changeHexFocusedOnMouseUp = false;
            updateScrollControlVisibility();
         }
      }
      
      private function updateHexFocusedOnMove(moveX:int, moveY:int):void {      
         var centerX:Number = -_vgraph.origin.x;
         var centerY:Number = -_vgraph.origin.y;
         var hexFocused:SpatialHex = getTreeHexUnderPoint(centerX, centerY);
         
         if(_model.numHexLoaded <= 1 && hexFocused.hexX == 0 && hexFocused.hexY == 0) {
            var mousePos:Point = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.mousePosition;
            centerX = mousePos.x - _vgraph.width / 2.0;
            centerY = mousePos.y - _vgraph.height / 2.0;
            if(centerX > 0 && centerY > 0) {
               hexFocused = _model.getHex(1,1,true);
            }else if(centerX > 0 && centerY < 0) {
               hexFocused = _model.getHex(1,0,true);
            }else if(centerX < 0 && centerY > 0) {
               hexFocused = _model.getHex(-1,1,true);
            }else{
               hexFocused = _model.getHex(-1,0,true);
            }
         }

         if(_model.hexFocused != hexFocused) {
            populateHexToShowQueue();
            populateHexToHideQueue();
         }
      }
      
      private function getMoveDelta(moveX:int, moveY:int):Point {
         var delta:Point = new Point();
         var currentPos:Point = new Point(moveX, moveY);
         var dist:Number = BroceliandMath.getDistanceBetweenPoints(_moveStartPos, currentPos);
         if(dist > MIN_DIST_TO_CONSIDER_DRAG) {
            var moveTime:Number = new Date().getTime() - _moveStartTime;
            delta.x = -(currentPos.x - _moveStartPos.x);
            delta.y = -(currentPos.y - _moveStartPos.y);
            if(moveTime > MIN_TIME_TO_USE_AVERAGE_SPEED) {
               delta.x = delta.x / moveTime * MIN_TIME_TO_USE_AVERAGE_SPEED;
               delta.y = delta.y / moveTime * MIN_TIME_TO_USE_AVERAGE_SPEED;
            }
         }
         return delta;
      }
      
      public function getTreeHexUnderPoint(x:int, y:int):SpatialHex {
         return _displayModel.getTreeHexUnderPoint(x,y);
      }

      public function isTreeHexVisibleOnScreen(treeHex:SpatialHex):Boolean {
         return _displayModel.isTreeHexVisibleOnScreen(treeHex);
      }
      
      public function isTreeHexFullyHiddenFromScreen(treeHex:SpatialHex):Boolean {
         return _displayModel.isTreeHexFullyHiddenFromScreen(treeHex);      
      }
      
      private function hideHex(treeHex:SpatialHex):void {
         if(!_model.enabled) return;
         Log.getLogger("com.broceliand.graphLayout.controller.DiscoverView").info("hide hex : "+treeHex);
         var spatialTree:SpatialTree;
         var vnode:IVisualNode;
         for each(spatialTree in treeHex.spacialTreeList) {
            vnode = _spacialTreeToNode[spatialTree];
            if(vnode) {
               if(_vgraph.currentRootVNode == vnode) {
                  vnode.view.visible = false;
                  vnode.view.alpha = 0;
               }else{
                  _vgraph.removeNode(vnode);
                  delete _spacialTreeToNode[spatialTree];
               }
            }
         }
         setTimeout(onHexHidden, HIDE_HEX_DURATION);
      }
      
      private function hasNodeBeenCreated(treeHex:SpatialHex):Boolean {
         for each(var spatialTree:SpatialTree in treeHex.spacialTreeList) {
            if (!_spacialTreeToNode[spatialTree]) {
               return false;
            }
         }
         return true;
      }
      
      private function onHexHidden():void {
         if(_numHexWithHideEffect > 0) {
            _numHexWithHideEffect--;
         }
         showOrHideHexFromQueues();
      }
      
      private function showHex(treeHex:SpatialHex, delay:Number=0, isStartAnimation:Boolean = false):void {
         if(!_model.enabled || !_model.isHexLoaded(treeHex.hexX, treeHex.hexY)) return;

         var spatialTree:SpatialTree;
         var newNodes:Array = new Array();
         var refNode:IBroPTWNode;
         var vnode:IVisualNode;
         var view:IUIPearl;
         var nodeCenter:Point;
         var nodeX:int;
         var nodeY:int;
         var isAvatarLoaded:Boolean = true;
         var showAction:OnHexReadyToShowAction = new OnHexReadyToShowAction(treeHex, this, isStartAnimation);
         var gsynchro:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(showAction);
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var isRelated:Boolean = navModel.isShowingDiscover() && am.useDiscover() && !navModel.isShowingSearchResult() && !navModel.isWhatsHot();
         for each(spatialTree in treeHex.spacialTreeList) {
            
            if((isRelated || _vgraph.currentRootVNode.view.visible) && _model.isRootHex(treeHex) && spatialTree.relativeX == 0 && spatialTree.relativeY == 0) {
               _spacialTreeToNode[spatialTree] = _vgraph.currentRootVNode;
               continue;
            }
            if(!spatialTree.tree) {
               continue;
            }
            vnode = _spacialTreeToNode[spatialTree];
            if(!vnode) {
               if (spatialTree.node as BroPTWPageNode) {
                  refNode = spatialTree.node as BroPTWPageNode;
               }  
               else if (spatialTree.node is BroPTWAliasNode) {
                  refNode = spatialTree.node as BroPTWAliasNode;
               } 
               else if(spatialTree.tree.isTeamRoot()) {
                  refNode = new BroCoeditPTWDistantTreeRefNode(spatialTree.tree);
               }
               else{
                  refNode = new BroPTWDistantTreeRefNode(spatialTree.tree);
               }
               
               refNode.absolutePosition = new Point(spatialTree.x, spatialTree.y);
               refNode.isSearchNode = navModel.isShowingSearchResult();
               if (spatialTree.hexX == 0 && spatialTree.hexY == 0 && spatialTree.x == 0 && spatialTree.y == 0) {
                  refNode.isSearchCenter = true;
               }
               vnode = _vgraph.createNode("[ptw."+spatialTree.tree.id+"]:" + refNode.title, refNode);
               view = vnode.view as IUIPearl;
               nodeCenter = localToVGraph(spatialTree.x, spatialTree.y);
               nodeX = nodeCenter.x - (vnode.view.width / 2 * _vgraph.scale);
               nodeY = nodeCenter.y - (vnode.view.height / 2 * _vgraph.scale);
               view.move(nodeX, nodeY);
               _spacialTreeToNode[spatialTree] = vnode;
               var vedge:IVisualEdge = _vgraph.linkNodes(_vgraph.currentRootVNode, vnode);
               EdgeData(vedge.data).visible = false;
               view.visible = false;
               if (!view.isCreationCompleted()) {
                  gsynchro.registerComponentToWaitForCreation(vnode.view);
               }
               var avatarStatus:int = ApplicationManager.getInstance().avatarManager.getAvatarResourceStatus(spatialTree.tree, AvatarManager.TYPE_PEARL_HUGE);
               if(avatarStatus != ResourceStatus.STATUS_LOADED) {
                  isAvatarLoaded = false;
               }
            } else {
               Log.getLogger("com.broceliand.graphLayout.controller.DiscoverView").warn("Tree already created :"+spatialTree.tree.title);
            }
         }
         
         if(!isAvatarLoaded) {
            delay += SHOW_HEX_DELAY_TO_LOAD_AVATARS;
         }      
         showAction.delay = delay;
         
         gsynchro.performActionAsap();
      }
      
      public function onHexReadyToShow(treeHex:SpatialHex):void {
         if(!_model.enabled || !_model.isHexLoaded(treeHex.hexX, treeHex.hexY)) return;    
         Log.getLogger("com.broceliand.graphLayout.controller.DiscoverView").info("onHexReadyToShow : {0}", treeHex);
         
         var previousState:int = treeHex.state;
         _displayModel.setHexagonState(treeHex, SpatialHex.DISPLAYED);
         var spatialTree:SpatialTree;
         var vnode:IPTVisualNode;
         var view:IUIPearl;
         var effect:Effect;
         var treeListToShow:Vector.<SpatialTree> = treeHex.spacialTreeList.concat();
         var showIndex:uint=0;
         var nodeCenter:Point;
         var nodeX:int;
         var nodeY:int;
         var vgraphCenter:Point = localToVGraph(0,0);
         
         var distanceToCenter:Number;
         var randomDistance:Number;
         var hiddenPos:Point;
         var speed:Number;
         var time:int;
         var maxTime:int;
         var pearl:UIPearl;
         var ptwNode:IBroPTWNode;
         var nodeToSelect:IPTNode;
         for(showIndex = 0; treeListToShow.length > 0; showIndex++) {
            var i:Number = Math.floor(Math.random() * treeListToShow.length);
            spatialTree = treeListToShow[i];
            vnode = _spacialTreeToNode[spatialTree];
            view = (vnode)?vnode.pearlView:null;
            if (previousState != SpatialHex.HIDDEN && vnode && vnode.ptNode) {
               ptwNode = vnode.ptNode.getBusinessNode() as IBroPTWNode;
               if (ptwNode && ptwNode.isSearchCenter) {
                  nodeToSelect = vnode.ptNode;
               }
            } else {
               ptwNode = null;
            }
            if(view && !view.visible) {
               nodeCenter = localToVGraph(spatialTree.x, spatialTree.y);
               nodeX = nodeCenter.x - (0.5 * vnode.view.width);
               nodeY = nodeCenter.y - (0.5 * vnode.view.height);
               
               view.move(nodeX, nodeY);
               var z:Zoom = new Zoom(view);
               effect = z;
               z.duration = SHOW_PEARL_DURATION;
               effect.duration = SHOW_PEARL_DURATION;
               effect.startDelay = Math.random()* SHOW_PEARL_DELAY;
               view.pearl.canRingBeVisible = false
               view.visible = true;
               view.alpha = 0;
               var onStart:GenericAction = new GenericAction(null, this, onZoomStart, view);
               var onEnd:GenericAction = new GenericAction(null, this, onZoomEnd, view);
               effect.addEventListener(TweenEvent.TWEEN_UPDATE,  onStart.performActionOnFirstEvent);
               effect.addEventListener(EffectEvent.EFFECT_END,  onEnd.performActionOnFirstEvent);
               effect.play();
            }
            if(nodeToSelect) {
               var am:ApplicationManager = ApplicationManager.getInstance();
               am.visualModel.selectionModel.selectNode(nodeToSelect, -1, true);
               
               am.components.windowController.displayNodeInfo(nodeToSelect);   
            }
            treeListToShow.splice(i,1);
         }
         if(effect) {
            if(_playInitEffectForHex.indexOf(treeHex) != -1) {
               setTimeout(onLastHexPearlShown, maxTime, null);
            }else {
               effect.addEventListener(EffectEvent.EFFECT_END, onLastHexPearlShown);
            }
         }
      }

      private function onZoomStart(pearl:IUIPearl):void {
         
         if (pearl.pearl) {
            pearl.visible = true;
            Application.application.callLater(function():void{pearl.alpha =1; if (pearl.pearl) { pearl.pearl.canRingBeVisible = true;}});
            pearl.pearl.moveRingInPearl();
         }
      }
      private function onZoomEnd(pearl:IUIPearl):void {
         if (pearl.pearl) {
            pearl.pearl.moveRingOutPearl();
            pearl.alpha = 1;
         }
         pearl.setScale(_vgraph.scale); 
      }
      
      private function showPearlWithoutEffect(vnode:IVisualNode):void {
         if(_model.enabled) {
            vnode.view.visible = true;
            vnode.view.alpha = 1;
         }
      }
      
      private function onLastHexPearlShown(event:Event):void {
         if(_numHexWithShowEffect > 0) {
            _numHexWithShowEffect--;
         }
         showOrHideHexFromQueues();
      }
      
      private function updateScrollControlVisibility():void {
         var button:PTButton;
         var localPos:Point;
         
         button = _scrollControl.scrollUi.getButton(ScrollUi.TOP_BUTTON);
         localPos = vgraphToLocal(_vgraph.width / 2.0, button.height);
         
         button.visible = true;
         
         button = _scrollControl.scrollUi.getButton(ScrollUi.RIGHT_BUTTON);
         localPos = vgraphToLocal(_vgraph.width - button.width, _vgraph.height/2.0);
         
         button.visible = true;
         
         button = _scrollControl.scrollUi.getButton(ScrollUi.BOTTOM_BUTTON);
         localPos = vgraphToLocal(_vgraph.width / 2.0, _vgraph.height - button.height);
         
         button.visible = true;
         
         button = _scrollControl.scrollUi.getButton(ScrollUi.LEFT_BUTTON);
         localPos = vgraphToLocal(button.width, _vgraph.height / 2.0);
         
         button.visible = true;
      }
      
      public function get playInitEffectForHex():Vector.<SpatialHex> {
         return _playInitEffectForHex;
      }
      public function clearInitEffectForHex():void {
         _playInitEffectForHex = new Vector.<SpatialHex>();
      }
      
      private function vgraphToLocal(x:int, y:int):Point {
         
         return new Point((x / _vgraph.scale) - _vgraph.center.x - _vgraph.origin.x, (y / _vgraph.scale) - _vgraph.center.y - _vgraph.origin.y);
      }
      
      private function localToVGraph(x:int, y:int):Point {
         return new Point((x * _vgraph.scale) + _vgraph.center.x + _vgraph.origin.x, (y * _vgraph.scale) 
            + _vgraph.center.y + _vgraph.origin.y);
      }
      
      public function get lastAppearTimeScheduled():Number
      {
         return _lastAppearTimeScheduled;
      }
      
      public function set lastAppearTimeScheduled(value:Number):void
      {
         _lastAppearTimeScheduled = value;
      }
      
   }
}
import com.broceliand.ApplicationManager;
import com.broceliand.graphLayout.controller.DiscoverView;
import com.broceliand.pearlTree.model.discover.SpatialHex;
import com.broceliand.pearlTree.model.discover.SpatialTree;
import com.broceliand.util.IAction;

import flash.globalization.LastOperationStatus;
import flash.media.Video;
import flash.net.getClassByAlias;
import flash.utils.getTimer;
import flash.utils.setTimeout;

internal class OnHexReadyToShowAction implements IAction {
   
   private var _treeHex:SpatialHex;
   private var _view:DiscoverView;
   private var _delay:Number;
   private var _isStartAnimation:Boolean;
   
   function OnHexReadyToShowAction(treeHex:SpatialHex, view:DiscoverView, isStartAnimation:Boolean, delay:Number=0) {
      _treeHex = treeHex;
      _view = view;
      _delay = delay;
      _isStartAnimation = isStartAnimation;
   }
   
   public function set delay(value:Number):void {
      _delay = value;
   }
   
   public function performAction():void {
      var time:Number = getTimer();
      if(_isStartAnimation) {
         _delay = 500;
      }else{
         if (time + _delay  < _view.lastAppearTimeScheduled +   DiscoverView.MIN_TIME_BETWEEN_HEX_APPEARANCE ) {
            _delay = _view.lastAppearTimeScheduled +   DiscoverView.MIN_TIME_BETWEEN_HEX_APPEARANCE - time;
         }
      }
      _view.lastAppearTimeScheduled = _delay + time; 
      setTimeout(_view.onHexReadyToShow, _delay, _treeHex);
      
   }
}