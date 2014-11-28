package com.broceliand.pearlTree.model.discover {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.SpatialTreeLoader;
   import com.broceliand.pearlTree.io.loader.SpatialTreeLoaderEvent;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.SearchEvent;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   
   import mx.core.Application;

   public class DiscoverModel extends EventDispatcher {
      
      public static const NEW_HEX_LOADED:String = "newHexLoaded";
      public static const MODEL_CLEARED:String = "modelCleared";
      
      private static const MIN_LOAD_TIME_TO_SHOW_BUSY:Number = 500;
      
      private var _loader:SpatialTreeLoader;
      private var _navModel:INavigationManager;
      private var _enabled:Boolean;
      
      private var _hexFocused:SpatialHex;
      private var _lastDeltaX:Number;
      private var _lastDeltaY:Number;
      private var _hexList:Dictionary;
      private var _numHexLoaded:uint=0;
      private var _busyOnLoadHex:SpatialHex;
      private var _discoverDisplayModel:DiscoverDisplayModel;
      private var _isFirstLoad:Boolean;
      private var _searchOnlyMode:Boolean;
      
      public function DiscoverModel() {
         super();
         var am:ApplicationManager = ApplicationManager.getInstance();
         _loader = new SpatialTreeLoader();
         _loader.addEventListener(SpatialTreeLoader.SPATIAL_TREE_COLLECTION_LOADED, onSpacialTreeLoaded);
         _loader.addEventListener(SpatialTreeLoader.SPATIAL_TREE_COLLECTION_LOADING_ERRROR, onSpacialTreeNotLoaded);
         _navModel = am.visualModel.navigationModel;
         _navModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         _navModel.addEventListener(SearchEvent.SEARCH_EVENT, onSearchChange);
         updateSearchMode();
         clearModel();
      }

      public function init(discoverDisplayModel:DiscoverDisplayModel):void {
         _discoverDisplayModel = discoverDisplayModel;
         if(_navModel.isShowingDiscover() && _navModel.getFocusNeighbourTree() && !_navModel.isShowingSearchResult()) {
            _enabled = true;
            if(_navModel.isWhatsHot()) {
               loadFirstHex();
            } else {
               loadFirstHex(_navModel.getFocusNeighbourTree());
            }
         }
      }
      
      private function onNavigationChange(event:NavigationEvent):void {
         if(event.newNeighbourTree && _navModel.isShowingDiscover()) {
            updateSearchMode(event.searchUserId);
            if(event.newNeighbourTree != event.oldNeighbourTree && !event.searchKeyword) {
               _enabled = true;
               clearModel();
               if(event.spatialTreeList) {
                  addSpatialTreeLoaded(event.spatialTreeList);
               } else {
                  if(_navModel.isWhatsHot()) {
                     loadFirstHex();
                  }else{
                     loadFirstHex(event.newNeighbourTree);
                  }
               }
            }
         }else if(_enabled) {
            _enabled = false;
            clearModel();
         }
      }
      
      private function onSearchChange(event:SearchEvent):void {
         if(_navModel.isShowingDiscover()) {
            updateSearchMode(event.searchUserId);
            _enabled = true;
            clearModel();
            addSpatialTreeLoaded(event.spatialTreeList);
         }
      }
      
      private function clearModel(stopAutoLoad:Boolean=true):void {
         ApplicationManager.getInstance().visualModel.mouseManager.showBusy(false);
         _busyOnLoadHex = null;
         _hexList = new Dictionary();
         _numHexLoaded = 0;
         _lastDeltaX = 0;
         _lastDeltaY = 0;
         _hexFocused = getHex(0,0,true);
         if (_discoverDisplayModel) {
            _discoverDisplayModel.clearModel();
         }
         _isFirstLoad = true;
         dispatchEvent(new Event(MODEL_CLEARED));
      }
      
      private function onSpacialTreeLoaded(event:SpatialTreeLoaderEvent):void {
         if(event.rootHex != getHex(0,0)) return;
         addSpatialTreeLoaded(event.spatialTreeLoaded);
      }
      
      private function onSpacialTreeNotLoaded(event:Event):void {
         dispatchEvent(event);
      }
      private function addSpatialTreeLoaded(spatialTreeLoaded:Vector.<SpatialTree>):void {
         var hexToMarkLoaded:Vector.<SpatialHex> = new Vector.<SpatialHex>();
         var spatialTree:SpatialTree;
         var hex:SpatialHex;
         for each(spatialTree in spatialTreeLoaded) {
            hex = getHex(spatialTree.hexX, spatialTree.hexY, true);
            if (hex.state == SpatialHex.NONE || hex.state == SpatialHex.NEIGHBOUR) {
               
               _discoverDisplayModel.updateNeighboursForNewHexagon(hex);
            }
            _discoverDisplayModel.setHexagonState(hex, SpatialHex.TODISPLAY);
            
            if(!hex.isLoaded) {
               hex.addSpatialTree(spatialTree);
               if(hexToMarkLoaded.indexOf(hex) == -1) {
                  hexToMarkLoaded.push(hex);
               }
            }
         }
         for each(hex in hexToMarkLoaded) {
            hex.isLoaded = true;
            _numHexLoaded++;
            if(hex == _busyOnLoadHex) {
               _busyOnLoadHex = null;
               ApplicationManager.getInstance().visualModel.mouseManager.showBusy(false);
            }
         }
         dispatchEvent(new NewHexLoadedEvent(NEW_HEX_LOADED, _isFirstLoad));
         _isFirstLoad = false;
      }
      
      public function get numHexLoaded():uint {
         return _numHexLoaded;
      }
      
      public function get isFirstLoad():Boolean {
         return _isFirstLoad;
      }
      
      private function loadFirstHex(tree:BroPearlTree=null):void {
         var hexListToLoad:Vector.<SpatialHex> = new Vector.<SpatialHex>();
         var centerHex:SpatialHex = getHex(0,0);
         hexListToLoad.push(centerHex);
         _discoverDisplayModel.setHexagonState(centerHex, SpatialHex.TOLOAD);
         var positionedTrees:Vector.<SpatialTree> = new Vector.<SpatialTree>();
         if(tree) {
            var spacialTree:SpatialTree = centerHex.getSpatialTreeAt(0,0);
            if(!spacialTree) {
               spacialTree = new SpatialTree();
               spacialTree.tree = tree;
               spacialTree.relativeX = 0;
               spacialTree.relativeY = 0;
               centerHex.addSpatialTree(spacialTree);
            }
            positionedTrees.push(spacialTree);
         }
         _discoverDisplayModel.updateNeighboursForNewHexagon(centerHex);
         loadHexList(hexListToLoad, positionedTrees, 0, 0);
      }
      
      public function loadHexList(hexListToLoad:Vector.<SpatialHex>, positionedTrees:Vector.<SpatialTree>, deltaX:int, deltaY:int, showBusyCursor:Boolean = false):void {
         var missingTrees:Vector.<SpatialTree> = new Vector.<SpatialTree>();
         
         for each(var hexToLoad:SpatialHex in hexListToLoad) {
            var spatialTree:SpatialTree = new SpatialTree();
            spatialTree.hexX = hexToLoad.hexX;
            spatialTree.hexY = hexToLoad.hexY;
            missingTrees.push(spatialTree);
            _discoverDisplayModel.setHexagonState(hexToLoad, SpatialHex.LOADING);
         }
         for each(hexToLoad in hexListToLoad) {
            _discoverDisplayModel.updateNeighboursForNewHexagon(hexToLoad);
         }
         if(showBusyCursor && hexListToLoad.length > 0) {
            _busyOnLoadHex = hexListToLoad[0];
            setTimeout(onTimeToShowBusyCursor, MIN_LOAD_TIME_TO_SHOW_BUSY, hexListToLoad[0]);
         }
         _loader.loadSpatialTreeCollection(positionedTrees, missingTrees, deltaX, deltaY, getHex(0,0));
      }
      
      private function onTimeToShowBusyCursor(hexToLoad:SpatialHex):void {
         if(hexToLoad && hexToLoad == _busyOnLoadHex) {
            ApplicationManager.getInstance().visualModel.mouseManager.showBusy(true);
         }
      }
      
      public function getHex(hexX:int, hexY:int, create:Boolean=false):SpatialHex {
         var hexId:String = SpatialHex.getRelatedTreeHexId(hexX,hexY);
         var treeHex:SpatialHex = _hexList[hexId];
         if(!treeHex && create) {
            treeHex = new SpatialHex(hexX, hexY);
            _hexList[hexId] = treeHex;
         }
         return treeHex;
      }
      
      public function isHexLoaded(hexX:int, hexY:int):Boolean {
         var hex:SpatialHex = getHex(hexX, hexY);
         return (hex && hex.isLoaded);
      }
      
      public function isRootHex(hex:SpatialHex):Boolean {
         return (hex && hex.hexX == 0 && hex.hexY == 0);
      }
      
      public function getHexNeighbours(hex:SpatialHex, range:uint=1, includeAllToRange:Boolean=false, isLoadedOnly:Boolean=false, isVisibleOnly:Boolean=false):Vector.<SpatialHex> {
         var neighbours:Vector.<SpatialHex> = new Vector.<SpatialHex>();
         if(range <= 1) {
            
            addHexToNeighbours(getHex(hex.hexX,hex.hexY+1,true),neighbours,isLoadedOnly,isVisibleOnly);
            addHexToNeighbours(getHex(hex.hexX,hex.hexY-1,true),neighbours,isLoadedOnly,isVisibleOnly);
            addHexToNeighbours(getHex(hex.hexX+1,hex.hexY,true),neighbours,isLoadedOnly,isVisibleOnly);
            addHexToNeighbours(getHex(hex.hexX-1,hex.hexY,true),neighbours,isLoadedOnly,isVisibleOnly);
            if((hex.hexX & 1) == 0) {
               addHexToNeighbours(getHex(hex.hexX+1,hex.hexY+1,true),neighbours,isLoadedOnly,isVisibleOnly);
               addHexToNeighbours(getHex(hex.hexX-1,hex.hexY+1,true),neighbours,isLoadedOnly,isVisibleOnly);
            } else {
               addHexToNeighbours(getHex(hex.hexX+1,hex.hexY-1,true),neighbours,isLoadedOnly,isVisibleOnly);
               addHexToNeighbours(getHex(hex.hexX-1,hex.hexY-1,true),neighbours,isLoadedOnly,isVisibleOnly);
            }
         }else{
            var hexX:int = hex.hexX;
            var hexY:int = hex.hexY;
            var minY:int = hexY - range;
            var maxY:int = hexY + range;
            var i:int;
            for (i = minY; i <= maxY; ++i) {
               if (i != hexY) {
                  if(includeAllToRange || i == minY || i == maxY) {
                     addHexToNeighbours(getHex(hexX,i,true),neighbours,isLoadedOnly,isVisibleOnly);
                  }
               }
            }
            var xOff:int = 1;
            for (xOff = 1; xOff <= range; xOff++) {
               if ((hexX+xOff) % 2 == 0) maxY--; else minY++;
               for (i = minY; i <= maxY; i++) {
                  if(includeAllToRange || i == minY || i == maxY || xOff == range) {
                     addHexToNeighbours(getHex(hexX+xOff,i,true),neighbours,isLoadedOnly,isVisibleOnly);
                     addHexToNeighbours(getHex(hexX-xOff,i,true),neighbours,isLoadedOnly,isVisibleOnly);
                  }
               }
            }
         }
         return neighbours;
      }
      
      private function addHexToNeighbours(neighbour:SpatialHex, neighbourList:Vector.<SpatialHex>, isLoadedOnly:Boolean=false, isVisibleOnly:Boolean=false):void {
         if(neighbour && neighbourList.indexOf(neighbour) == -1 &&
            (!isLoadedOnly || neighbour.isLoaded) && 
            (!isVisibleOnly || neighbour.isVisible)) {
            neighbourList.push(neighbour);
         }
      }

      public function get showDiscoverHelpLabel():Boolean{
         return !ApplicationManager.getInstance().currentUser.isAnonymous();
      }
      
      public function get hexList():Dictionary {
         return _hexList;
      }
      
      public function get enabled():Boolean {
         return _enabled;
      }
      
      public function get hexFocused():SpatialHex{
         return _hexFocused;
      }   
      
      public function isLoading():Boolean {
         return _loader.isLoading;
      }
      public function isEnabled():Boolean {
         return _enabled;
      }
      private function updateSearchMode(searchUserId:int = -1):void{
         _searchOnlyMode =  _navModel.isShowingSearchResult() && (_navModel.isShowingSearchPeopleResult() || (searchUserId > 0)); 
      }
      public function isSearchOnlyMode():Boolean {
         return _searchOnlyMode;
      }
   }
}