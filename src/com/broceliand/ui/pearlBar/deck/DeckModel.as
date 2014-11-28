package com.broceliand.ui.pearlBar.deck {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.io.exporter.IPearlTreeQueue;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.effects.TrashPearlEffect;
   import com.broceliand.ui.interactors.drag.action.DeleteAction;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.GenericAction;
   
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   
   import mx.containers.Canvas;
   import mx.events.FlexEvent;
   
   public class DeckModel extends EventDispatcher implements IDeckModel {
      
      public static const MODEL_CHANGE:String = "onModelChange";
      public static const NODE_STATE_CHANGE:String = "onNodeStateChange";
      public static const EFFECTS_END:String = "effectsEnd";
      
      public static const TYPE_DROPZONE:uint = 1;
      
      private static const ITEM_WIDTH:Number = 70;
      
      public static const SCROLL_EFFECT_NONE:uint = 0;
      public static const SCROLL_EFFECT_PREVIOUS:uint = 1;
      public static const SCROLL_EFFECT_NEXT:uint = 2;

      private var _items:Vector.<DeckItem>;
      
      private var _nodesToShow:Vector.<IPTNode>;
      
      private var _nodesToHideWithEffect:Vector.<IPTNode>;
      private var _playScrollEffect:uint;
      private var _isScollEffectPlaying:Boolean;

      private var _repositionWithEffect:Boolean;
      
      private var _availableWidth:Number;
      
      private var _dockingNode:IPTNode;
      private var _undockingNode:IPTNode;
      private var _page:uint = 0;
      private var _isLastPage:Boolean;
      private var _maxItemToShow:Number;
      private var _isEnabled:Boolean;
      private var _isHighlighted:Boolean;
      private var _isVisible:Boolean;
      private var _deckType:uint;
      private var _title:String;
      private var _isTitleVisible:Boolean;
      private var _emptyText:String;
      private var _isNavButtonVisible:Boolean;
      private var _itemWidth:Number;
      private var _selectedBusinessNode:BroPTNode = null;
      
      private var _defaultUndockPosition:Point;
      private var _timesHasBeenClicked:int = 0;
      private var _isClearing:Boolean= false;
      
      public function DeckModel() {
         super();
         _isEnabled = true;
         _isNavButtonVisible = true;
         _isTitleVisible = true;
         _isLastPage = true;
         _items = new Vector.<DeckItem>();
         _nodesToShow = new Vector.<IPTNode>();
         _defaultUndockPosition = new Point();
         _itemWidth = ITEM_WIDTH;
      }

      public function addItem(value:DeckItem):void {
         _items.unshift(value);
         _page = 0;
         invalidateNodesToShow();
      }
      
      protected function removeItemAt(itemIndex:int):void {
         if(itemIndex > -1){
            var item:DeckItem = _items[itemIndex];
            
            if(item.node && _nodesToShow.length == 1 && _nodesToShow[0] == item.node && _page > 0) {
               _page--;
               _playScrollEffect = SCROLL_EFFECT_PREVIOUS;
            }
            _items.splice(itemIndex, 1);
            invalidateNodesToShow();
         }
      }
      
      protected function removeAll():void {
         _items = new Vector.<DeckItem>();
         invalidateNodesToShow();
      }
      
      private function invalidateNodesToShow():void {
         dispatchChangeEvent();
      }

      public function refreshNodesToShow():void {
         
         if(!StartPolicyLogger.getInstance().isFirstOpenAnimationStarted()) {
            StartPolicyLogger.getInstance().addEventListener(StartPolicyLogger.NEXT_STEP_EVENT, onStartPolicyNextStep);
            return;
         }
         
         var numItems:Number = _items.length;
         
         _maxItemToShow = Math.floor(_availableWidth / _itemWidth);
         
         if(_maxItemToShow < 1) _maxItemToShow = 1;
         
         var startIndex:Number = _page * _maxItemToShow;
         
         _isLastPage = ((startIndex + _maxItemToShow) >= numItems);
         
         var itemIndex:uint = startIndex;
         var count:uint = 0;
         var node:IPTNode;
         var newNodesToShow:Vector.<IPTNode> = new Vector.<IPTNode>();
         
         while(count < _maxItemToShow && itemIndex < numItems) {
            node = _items[itemIndex].node;
            if(!node) {
               node = createNodeFromDataSource(_items[itemIndex]);
            }else{
               markNodeAsDocked(node);
            }
            if (_selectedBusinessNode && node.data == _selectedBusinessNode) {
               ApplicationManager.getInstance().visualModel.selectionModel.selectNode(node);               
            }
            newNodesToShow.push(node);
            itemIndex++;
            count++;            
         }
         _selectedBusinessNode = null;
         refreshNodesToHide(newNodesToShow);
         
         _nodesToShow = newNodesToShow;
      }

      private function refreshNodesToHide(newNodesToShow:Vector.<IPTNode>):void {
         _nodesToHideWithEffect = new Vector.<IPTNode>();
         var node:IPTNode;
         var item:DeckItem;
         
         for each(node in _nodesToShow) {
            if(newNodesToShow.indexOf(node) == -1 && node.isDocked) {
               _nodesToHideWithEffect.push(node);
            }
         }

         for each (item in _items) {
            if(!item.node) {
               break;
            }
            else if(item.node.isDocked && newNodesToShow.indexOf(item.node) == -1 && _nodesToHideWithEffect.indexOf(item.node) == -1) {
               hideItemNodeNow(item.node);
            }
         }
      }
      
      private function onStartPolicyNextStep(event:Event):void {
         if(StartPolicyLogger.getInstance().isFirstOpenAnimationStarted()) {
            StartPolicyLogger.getInstance().removeEventListener(StartPolicyLogger.NEXT_STEP_EVENT, onStartPolicyNextStep);
            invalidateNodesToShow();
         }
      }

      public function dockNode(node:IPTNode, copy:Boolean=false, effectSource:Point=null):IPTNode {
         var nodeToDock:IPTNode = null;
         if(copy) {
            nodeToDock = dockCopyOfNode(node, effectSource);
            dispatchEvent(new DockedNodeStateEvent(NODE_STATE_CHANGE, nodeToDock));
         }
         else if(_dockingNode != node && _nodesToShow.indexOf(node) == -1) {
            addItem(new DeckItem(node));
            markNodeAsDocked(node);
            repositionWithEffect = true;
            nodeToDock = node;
            dispatchEvent(new DockedNodeStateEvent(NODE_STATE_CHANGE, nodeToDock));
         }
         return nodeToDock;
      }
      
      private function getItemPage(itemIndex:int):uint {
         if(itemIndex < 0 || itemIndex >= _items.length) {
            return 0;
         }else{
            return Math.floor(itemIndex / _maxItemToShow);
         }
      }
      
      public function undockNode(node:IPTNode, withDeleteEffect:Boolean=false, updateSelection:Boolean = true):void {
         if(node && _undockingNode != node) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            var nodeView:IUIPearl = node.renderer;
            var isInNodesToShow:Boolean = (_nodesToShow.indexOf(node) != -1);
            
            if(!withDeleteEffect) {
               _undockingNode = node;
               node.undock();
               _undockingNode = null;
            }
            var itemIndex:int = findItemIndexFromNode(node);
            if(withDeleteEffect && isInNodesToShow) {
               setTimeout(removeItemAt, TrashPearlEffect.DURATION, itemIndex);
            }else{
               removeItemAt(itemIndex);
            }
            if(!isInNodesToShow) {
               _page = getItemPage(itemIndex);
            }
            repositionWithEffect = true;
            
            showItemNodeNow(node);
            
            if(!isInNodesToShow && !withDeleteEffect && nodeView) {
               nodeView.move(_defaultUndockPosition.x, _defaultUndockPosition.y);
            }
            if(isInNodesToShow && !withDeleteEffect && nodeView) {
               var selectedNode:IPTNode = am.visualModel.selectionModel.getSelectedNode();
               if(selectedNode == node && updateSelection) {
                  ApplicationManager.flexApplication.callLater(updateSelectionOnUndock, [node]);
               }
            }
            dispatchEvent(new DockedNodeStateEvent(NODE_STATE_CHANGE, node));
         }
      }
      
      private function updateSelectionOnUndock(node:IPTNode):void {
         if (node.vnode && node.getBusinessNode().owner) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            am.visualModel.selectionModel.selectNode(node, -1 , true);
            am.components.windowController.displayNodeInfo(node);
         }
      }

      protected function dockCopyOfNode(node:IPTNode, effectSource:Point=null):IPTNode {
         var businessNode:BroPTNode = node.getBusinessNode();
         return dockCopyBroPTNode(businessNode, effectSource, node);
      }
      
      public function dockCopyBroPTNode(businessNode:BroPTNode, effectSource:Point=null, node:IPTNode = null):IPTNode {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var editionController:IPearlTreeEditionController = am.components.pearlTreeViewer.pearlTreeEditionController;
         if(businessNode) {
            var newNode:IPTNode = editionController.createCopyOfNode(businessNode);
            
            if (node) {
               if(!effectSource) {
                  effectSource = node.renderer.pearlCenter;
               }
               var offset:Number = node.renderer.pearlWidth / 2;
               newNode.renderer.move(effectSource.x - offset, effectSource.y - offset);
            }
            
            if (newNode.renderer.isCreationCompleted()) {
               dockNode(newNode);
            } else {
               markNodeAsDocked(newNode);
               newNode.renderer.addEventListener(FlexEvent.CREATION_COMPLETE, onNewNodeCreationComplete);
            }
            return newNode;
         }
         return null;
      }
      
      private function onNewNodeCreationComplete(event:Event):void {
         dockNode(IUIPearl(event.target).node);
      }
      
      public function get nodesToShow():Vector.<IPTNode> {
         return _nodesToShow;
      }
      
      public function get nodesToHideWithEffect():Vector.<IPTNode> {
         return _nodesToHideWithEffect;
      }
      
      public function get playScrollEffect():uint {
         return _playScrollEffect;
      }
      
      public function set isScollEffectPlaying(value:Boolean):void {
         if(value != _isScollEffectPlaying) {
            _isScollEffectPlaying = value;
            if(!_isScollEffectPlaying) {
               _playScrollEffect = SCROLL_EFFECT_NONE;
               for each(var node:IPTNode in _nodesToHideWithEffect) {
                  if(node.isDocked) {
                     hideItemNodeNow(node);
                  }
               }
               _nodesToHideWithEffect = null;
               dispatchEvent(new Event(EFFECTS_END));
            }
         }
      }
      public function get isScollEffectPlaying():Boolean {
         return _isScollEffectPlaying;
      }
      
      protected function markNodeAsDocked(node:IPTNode):void {
         _dockingNode = node;
         node.dock(this);
         _dockingNode = null;
         var nodeView:IUIPearl = (node.pearlVnode)?node.pearlVnode.pearlView:null;
         if(nodeView) {
            nodeView.refresh();
            var am:ApplicationManager = ApplicationManager.getInstance();
            var visualGraph:IPTVisualGraph = am.components.pearlTreeViewer.vgraph;
            var visualGraphContainer:Canvas = visualGraph as Canvas;
            var controlsContainer:Canvas = visualGraph.controls as Canvas;
            visualGraphContainer.setChildIndex(nodeView as DisplayObject, visualGraphContainer.getChildIndex(controlsContainer)+1);
         }
      }
      
      protected function hideItemNodeNow(node:IPTNode):void {
         if(node && node.renderer) {
            node.renderer.visible = false;
            node.renderer.move(-100, -100);
         }
      }
      private function showItemNodeNow(node:IPTNode):void {
         if(node && node.renderer) {
            node.renderer.visible = true;
         }
      }
      
      public function get availableWidth():Number {
         return _availableWidth;
      }
      public function set availableWidth(value:Number):void {
         if(value != _availableWidth && value > 0) {
            _availableWidth = value;
            invalidateNodesToShow();
         }
      }
      
      public function get itemWidth():Number {
         return _itemWidth;
      }
      public function set itemWidth(value:Number):void {
         if(value != _itemWidth) {
            _itemWidth = value;
            invalidateNodesToShow();
         }
      }
      
      public function get defaultUndockPosition():Point {
         return _defaultUndockPosition;
      }
      
      public function get isHighlighted():Boolean {
         return _isHighlighted;
      }
      public function set isHighlighted(value:Boolean):void {
         if(value != _isHighlighted) {
            _isHighlighted = value;
            dispatchChangeEvent();
         }
      }
      
      public function get isEnabled():Boolean {
         return _isEnabled;
      }
      public function set isEnabled(value:Boolean):void {
         if(value != _isEnabled) {
            _isEnabled = value;
            dispatchChangeEvent();
         }
      }
      
      public function set isVisible(value:Boolean):void {
         if(value != _isVisible) {
            _isVisible = value;
            dispatchChangeEvent();
         }
      }
      public function get isVisible():Boolean {
         return _isVisible;
      }
      
      public function set title(value:String):void {
         if(value != _title) {
            _title = value;
            dispatchChangeEvent();
         }
      }
      public function get title():String {
         return _title;
      }
      
      public function set isTitleVisible(value:Boolean):void {
         if(value != _isTitleVisible) {
            _isTitleVisible = value;
            dispatchChangeEvent();
         }
      }
      public function get isTitleVisible():Boolean {
         return _isTitleVisible;
      }
      
      public function set emptyText(value:String):void {
         if(value != _emptyText) {
            _emptyText = value;
            dispatchChangeEvent();
         }
      }
      public function get emptyText():String {
         return _emptyText;
      }
      
      public function set deckType(value:uint):void {
         if(value != _deckType) {
            _deckType = value;
            dispatchChangeEvent();
         }
      }
      
      public function refreshAtAnimationEnds():void {
         var animationQueue:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         var ga:GenericAction = new GenericAction(animationQueue, this, dispatchChangeEvent);
         ga.addInQueue();
      }
      
      protected function get items():Vector.<DeckItem> {
         return _items;
      }
      
      protected function createNodeFromDataSource(item:DeckItem):IPTNode {
         if(!item.node && item.dataSource) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            var editionController:IPearlTreeEditionController = am.components.pearlTreeViewer.pearlTreeEditionController;
            if(item.dataSource is BroPTNode) {
               item.node = editionController.createNode(item.dataSource as BroPTNode);
               markNodeAsDocked(item.node);
               hideItemNodeNow(item.node);
               
               am.components.pearlTreeViewer.vgraph.showNodeTitle(item.node.renderer, false, false, true);
            }
         }
         return item.node;
      }
      
      private function findItemIndex(item:DeckItem):int {
         return _items.indexOf(item);
      }
      
      public function findItemIndexFromNode(node:IPTNode):int {
         if(node) {
            var numItems:uint = _items.length;
            for (var i:uint=0; i < numItems; i++) {
               if(_items[i].node == node) {
                  return i;
               }
            }
         }
         return -1;
      }
      
      private function findItemIndexFromDataSource(dataSource:Object):int {
         if(dataSource) {
            var numItems:uint = _items.length;
            for (var i:uint=0; i < numItems; i++) {
               if(_items[i].dataSource == dataSource) {
                  return i;
               }
            }
         }
         return -1;
      }
      
      public function getItemAt(index:int):DeckItem {
         if(!_items || index >= _items.length || index < 0) {
            return null;
         }
         return _items[index];
      }
      
      public function goToNextPage():void {
         _page++;
         _playScrollEffect = SCROLL_EFFECT_NEXT;
         invalidateNodesToShow();
      }
      
      public function goToPreviousPage():void {
         if(_page > 0) {
            _page--;
            _playScrollEffect = SCROLL_EFFECT_PREVIOUS;
            invalidateNodesToShow();
         }
      }
      
      public function goToPageWithBusinessNode(node:BroPTNode):void {
         var index:int = findItemIndexFromDataSource(node);
         var page:int = getItemPage(index);
         if (_page != page) { 
            _playScrollEffect = page > _page ? SCROLL_EFFECT_NEXT : SCROLL_EFFECT_PREVIOUS;
            _page = page;
            if (!node.graphNode) {
               _selectedBusinessNode = node;
            }
            invalidateNodesToShow();            
         }
      }
      
      public function get isNavButtonVisible():Boolean {
         return _isNavButtonVisible;
      }
      public function set isNavButtonVisible(value:Boolean):void {
         if(value != _isNavButtonVisible) {
            _isNavButtonVisible = value;
         }
      }
      
      public function isFirstPage():Boolean {
         return (_page == 0);
      }
      
      public function isLastPage():Boolean {
         return _isLastPage;
      }
      
      public function isDropZone():Boolean {
         return (_deckType == TYPE_DROPZONE);
      }
      
      public function highlight():void {
         isHighlighted = true;
      }
      
      public function unhighlight():void {
         isHighlighted = false;
      }
      
      public function repositionNodes():void {
         repositionWithEffect = true;
         invalidateNodesToShow();
      }
      
      public function get repositionWithEffect():Boolean {
         return _repositionWithEffect;
      }
      
      public function set repositionWithEffect(value:Boolean):void {
         _repositionWithEffect = value;
      }
      
      public function createItemNode(item:DeckItem):IPTNode {
         var node:IPTNode = null;
         if(item) {
            node = item.node;
            if(!node) {
               node = createNodeFromDataSource(item);
            }
         }
         return node;
      }
      
      public function getItemsCount():uint {
         return (_items)?_items.length:0;
      }
      
      public function getNodeAt(itemIndex:int, createIfNotExist:Boolean = true):IPTNode {
         var node:IPTNode = null;
         var item:DeckItem = getItemAt(itemIndex);
         if (item) {
            node = item.node;
            if(!node && createIfNotExist) {
               node = createNodeFromDataSource(item);
            }
         }
         return node;
      }
      
      public function getNodeWithBusinessNode(bnode:BroPTNode):IPTNode {
         var index:int = findItemIndexFromDataSource(bnode);
         return getNodeAt(index, true);
      }
      
      private function dispatchChangeEvent():void {
         dispatchEvent(new Event(MODEL_CHANGE));
      }
      
      public function registerNewClick():void{
         if (timesHasBeenClicked > 2) return;
         _timesHasBeenClicked++;
         dispatchChangeEvent();
      }
      
      public function get timesHasBeenClicked():int
      {
         return _timesHasBeenClicked;
      }
      
      public function set timesHasBeenClicked(value:int):void
      {
         _timesHasBeenClicked = value;
      }
      
      public function clearDropzone():void {
         if (items.length == 0) return;
         var am:ApplicationManager = ApplicationManager.getInstance();
         var editionController:IPearlTreeEditionController = am.components.pearlTreeViewer.pearlTreeEditionController;
         var length:int = _items.length;
         _isClearing = true; 
         timesHasBeenClicked = 0;
         for (var i:int= length; i--; i >= 0) {
            var item:DeckItem = _items[i];
            var bnode:BroPTNode = item.dataSource as BroPTNode;
            var node:IPTNode = item.node;
            if (!node) {
               editionController.deleteBusinessBranch(bnode);
            } else  {
               new DeleteAction(am.components.pearlTreeViewer, node).doIt();
            }
         }
         removeAll();
         _isClearing = false;
      }
      
      public function get isClearing():Boolean {
         return _isClearing;
      }
      
      public function getPearlNumber():int {
         return items.length;
      }
      
   }
}