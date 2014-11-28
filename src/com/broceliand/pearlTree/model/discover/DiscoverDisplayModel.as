package com.broceliand.pearlTree.model.discover
{
   import com.broceliand.graphLayout.controller.DiscoverView;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.io.loader.SpatialTreeLoader;
   import com.broceliand.util.Assert;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.externalServices.IShortener;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   import com.broceliand.util.logging.LoggingParameters;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.sampler.getLexicalScopes;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.rpc.events.HeaderEvent;
   import mx.utils.object_proxy;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph;
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class DiscoverDisplayModel
   {
      
      static private var MAIN_AXIS:Array;
      private var _hiddenHexagons:Dictionary;
      private var _displayedHexagons:Dictionary;
      private var _loadingHexagons:Array;
      private var _toLoadHexagons:Array;
      private var _neighbourHexagons:Array;
      private var _toDisplayHexagons:Dictionary;
      private var _discoverModel:DiscoverModel;
      private var _originCenter:Point;
      private var _lastCenterUpdate:Point;
      private var _dragDistance:Point;
      private var _vgraph:IVisualGraph;
      private static var _debugInstance:DiscoverDisplayModel;
      
      public function DiscoverDisplayModel(discoverModel:DiscoverModel, visualGraph:IPTVisualGraph)
      {
         clearModel();   
         _discoverModel = discoverModel;
         _discoverModel.addEventListener(SpatialTreeLoader.SPATIAL_TREE_COLLECTION_LOADING_ERRROR, onErrorLoading);
         _vgraph = visualGraph;
         _dragDistance = new Point();
         if (!MAIN_AXIS) {
            MAIN_AXIS = new Array(
               new Point(0.01,1),
               new Point(-0.1,1),
               new Point(1,0.01),
               new Point(1,-0.01),
               new Point(SpatialHex.EDGE_DISTANCE_Y * 1.05, 3 * SpatialHex.HALF_EDGE_X),        
               new Point(SpatialHex.EDGE_DISTANCE_Y * 0.95, 3 * SpatialHex.HALF_EDGE_X),        
               new Point(- SpatialHex.EDGE_DISTANCE_Y * 1.05, 3 * SpatialHex.HALF_EDGE_X),
               new Point(- SpatialHex.EDGE_DISTANCE_Y * 0.95, 3 * SpatialHex.HALF_EDGE_X))
         }
         _debugInstance =this;
         
      }
      private static function removeFromArray(array:Array, object:Object):void {
         var index:int = array.lastIndexOf(object);
         if (index>=0) {
            array.splice(index,1);
         }
      }
      public function setHexagonState(hex:SpatialHex, state:int):void{
         var prevState:int = hex.state;
         if (prevState == state)
            return;
         switch (prevState){
            case SpatialHex.NEIGHBOUR:
               removeFromArray(_neighbourHexagons, hex);  
               break;            
            case SpatialHex.TOLOAD:
               removeFromArray(_toLoadHexagons, hex);  
               break;
            case SpatialHex.LOADING:
               removeFromArray(_loadingHexagons, hex);
               break;
            case SpatialHex.TODISPLAY:
               delete _toDisplayHexagons[hex.id];
               break;            
            case SpatialHex.DISPLAYED:
               delete _displayedHexagons[hex.id];
               break;
            case SpatialHex.HIDDEN:
               delete _hiddenHexagons[hex.id];
               break;             
            default:
               break;
         }
         switch (state) {
            case SpatialHex.NEIGHBOUR:
               _neighbourHexagons.push(hex);
               break;            
            case SpatialHex.TOLOAD:
               
               _toLoadHexagons.push(hex);
               break;         	               
            case SpatialHex.LOADING:
               _loadingHexagons.splice(0,0, hex);
               break;
            case SpatialHex.TODISPLAY:
               _toDisplayHexagons[hex.id]= hex;
               break;
            case SpatialHex.DISPLAYED:
               _displayedHexagons[hex.id] = hex;
               break;
            case SpatialHex.HIDDEN:
               _hiddenHexagons[hex.id] = hex;
               break;             
            default:
               break;
         }
         
         hex.state = state;
      }
      
      public static function debugDiscover():void {
         _debugInstance.debugScreenState();
      }  
      private function debugScreenState():void {
         var hexListToShow:Vector.<SpatialHex> = new Vector.<SpatialHex>();
         
         for each(var treeHex:SpatialHex in _discoverModel.hexList) {
            if (!isTreeHexFullyHiddenFromScreen(treeHex)) {
               
            }
         }
         
      }
      
      internal function updateNeighboursForNewHexagon(hex:SpatialHex):void {
         
         var hexNeighbour:Vector.<SpatialHex> = _discoverModel.getHexNeighbours(hex);
         for (var i:int=0; i< hexNeighbour.length; ++i) {
            if (hexNeighbour[i].state==SpatialHex.NONE) {
               setHexagonState(hexNeighbour[i], SpatialHex.NEIGHBOUR); 
            }
         }
      }

      public function onBackgroundDragBegin():void {
         _originCenter = _vgraph.origin.clone();
         _lastCenterUpdate = _originCenter;
      }
      
      public function onBackgroundDragContinue():void {
         var currentPoint:Point = _vgraph.origin ;
         if ((_originCenter != null) && BroceliandMath.getSquareDistanceBetweenPoints(_lastCenterUpdate, currentPoint)>25) {
            _lastCenterUpdate = currentPoint.clone();
            _dragDistance.x =-(currentPoint.x - _originCenter.x);
            _dragDistance.y =-(currentPoint.y - _originCenter.y);
            addHexagonsToLoad();
         }
         fillPTW();
      }
      
      public function onScrollFromButtonsStarted():void {
         onBackgroundDragBegin();
      }
      public function onScrollFromButtonsContinue():void {
         onBackgroundDragContinue();
         if (Math.abs(_dragDistance.x)*2 > _vgraph.width || 2*Math.abs(_dragDistance.y) > _vgraph.height) {
            _originCenter = _lastCenterUpdate;
         }
         
      }
      public function onScrollFromButtonsStopped():void {
         onBackgroundDragEnd();
      }
      
      public function onBackgroundDragEnd():void {
         var currentPoint:Point = _vgraph.origin ;
         if (_originCenter != null) { 
            _lastCenterUpdate = currentPoint.clone();
            _dragDistance.x =-(currentPoint.x - _originCenter.x);
            _dragDistance.y =-(currentPoint.y - _originCenter.y);
            addHexagonsToLoad();
         }
         fillPTW();
      }
      private function getLogger():BroLogger {
         return Log.getLogger("com.broceliand.pearlTree.model.discover.DiscoverDisplayModel");
      }
      
      public function updateLoadingHexagonState():Array {
         
         var newLoadedTrees:Array = new Array();
         for (var i:int = _loadingHexagons.length; i-->0;) {
            var hex:SpatialHex = _loadingHexagons[i];
            if (hex.isLoaded) {
               newLoadedTrees.push(hex);
               if (isTreeHexFullyHiddenFromScreen(hex)) {
                  setHexagonState(hex, SpatialHex.HIDDEN);
               } else {
                  setHexagonState(hex, SpatialHex.TODISPLAY);
               }
            }
         }
         return newLoadedTrees;
      }
      public function fillHexesToDisplay(hexListToShow:Vector.<SpatialHex>):void{
         var hex:SpatialHex= null;
         for each (hex in _hiddenHexagons) {
            if (isTreeHexVisibleOnScreen(hex)) {
               hexListToShow.push(hex);
            }
         }
         for each (hex in _toDisplayHexagons) {
            if (isTreeHexVisibleOnScreen(hex)) {
               hexListToShow.push(hex);
            }
         }

      }
      private function addHexagonsToLoad():void {
         var center:Point = _lastCenterUpdate.clone();
         var hexPoint:Point = new Point();
         for (var i:int = 0; i < 4; i++){
            
            var minDist:Number = Number.MAX_VALUE;
            for each (var hex:SpatialHex in _displayedHexagons) {
               hexPoint.x = hex.centerX;
               hexPoint.y = hex.centerY;
               var dist:Number = BroceliandMath.getDistanceBetweenPoints(_lastCenterUpdate, hexPoint);
               if (dist<minDist) {
                  minDist = dist;
                  center.x = hexPoint.x;
                  center.y = hexPoint.y;
               }
            }
            var missingHexes:Array = shouldFillHexagonsWithSpeed(_dragDistance, center);
            
            if (missingHexes.length == 0 && _toLoadHexagons.length == 0 && _loadingHexagons.length == 0){            
               var hexOnScreen:Boolean = false;
               
               for each(hex in _displayedHexagons){
                  if (isTreeHexVisibleOnScreen(hex)) {
                     hexOnScreen = true;                  
                     break;
                  }
               }

               if (!hexOnScreen){
                  for each ( hex in _toDisplayHexagons){
                     if (isTreeHexVisibleOnScreen(hex)) {
                        hexOnScreen =true; 
                     }
                  }
               }
               if (!hexOnScreen) {
                  getLogger().info("No missing hexes found -> Adding hexes toward the center");
                  addHexesTowardsPoint(displayCoordToLocalCoord(_vgraph.center.x, true), displayCoordToLocalCoord(_vgraph.center.y, false));
               }
            }
            
            if (missingHexes && missingHexes.length>0){
               for each (hex in missingHexes){
                  setHexagonState(hex, SpatialHex.TOLOAD);
                  updateNeighboursForNewHexagon(hex);
               }
            }
            else{
               break;
            }
         }    
      }

      private function shouldFillHexagonsWithSpeed(speed:Point, centerRef:Point):Array{

         if (speed.length == 0) {
            speed = null;
         }
         var missingHexes:Array = new Array();
         for each (var hex:SpatialHex in _neighbourHexagons){                
            if (isTreeHexToLoad(hex)){

               if (!speed || (speed.x * (hex.centerX - centerRef.x) + speed.y * (hex.centerY - centerRef.y )) >0) {
                  missingHexes.push(hex);
                  
               }
            }
         }
         
         return missingHexes;
      }
      
      private function isTreeHexToLoad(treeHex:SpatialHex):Boolean {
         var fillScreenFactor:Number = _vgraph.scale < 1 ? _vgraph.scale : 1;
         return isTreeHexVisibleOnScreen(treeHex, fillScreenFactor);
      }
      
      public function isTreeHexVisibleOnScreen(treeHex:SpatialHex, fillScreenFactor:Number=1):Boolean {
         var hexX:Number = treeHex.centerX * _vgraph.scale;
         var hexY:Number = treeHex.centerY * _vgraph.scale;
         var offsetX:Number = -_vgraph.origin.x;
         var offsetY:Number = -_vgraph.origin.y;
         var halfGraphWidth:Number = Math.max(_vgraph.width / 2.0 * fillScreenFactor, 1.5 * SpatialHex.HALF_EDGE_X * _vgraph.scale);
         var halfGraphHeight:Number = Math.max(_vgraph.height / 2.0 * fillScreenFactor, 1 * SpatialHex.EDGE_DISTANCE_Y * _vgraph.scale);      
         
         if(hexX >= (offsetX - halfGraphWidth) && 
            hexX <= (offsetX + halfGraphWidth) &&
            hexY >= (offsetY - halfGraphHeight) &&
            hexY <= (offsetY + halfGraphHeight)) {
            return true;
         }else{
            
            return false;
         }
      } 
      
      public function isTreeHexFullyHiddenFromScreen(treeHex:SpatialHex):Boolean {
         var hexX:Number = treeHex.centerX * _vgraph.scale;
         var hexY:Number = treeHex.centerY * _vgraph.scale;
         var halfHexWidth:Number = SpatialHex.HALF_EDGE_X * 1.5 * _vgraph.scale;
         var halfHexHeight:Number = SpatialHex.EDGE_DISTANCE_Y * _vgraph.scale;
         var offsetX:Number = -_vgraph.origin.x;
         var offsetY:Number = -_vgraph.origin.y;
         var halfGraphWidth:Number = _vgraph.width / 2.0;
         var halfGraphHeight:Number = _vgraph.height / 2.0;
         if((hexX + halfHexWidth) < (offsetX - halfGraphWidth) || 
            (hexX - halfHexWidth) > (offsetX + halfGraphWidth) ||
            (hexY + halfHexHeight) < (offsetY - halfGraphHeight) ||
            (hexY - halfHexHeight) > (offsetY + halfGraphHeight)) {
            return true;
         }else{
            return false;
         }      
      }
      
      public function clearModel():void {
         _hiddenHexagons = new Dictionary();    
         _displayedHexagons = new Dictionary();    
         _loadingHexagons = new Array();
         _toLoadHexagons = new Array();
         _neighbourHexagons = new Array();
         _toDisplayHexagons = new Dictionary();
      }
      
      public function fillPTW():void {
         if (_discoverModel.isLoading())
            return;    
         if (_discoverModel.isSearchOnlyMode())
            return;
         if (!_toLoadHexagons.length)
            return;

         var neighbourHexs:Dictionary = new Dictionary();

         var toLoadHexes:Vector.<SpatialHex> = new Vector.<SpatialHex>();
         
         var projectedSpeed:Point = projectSpeedOnMainAxis(_dragDistance);
         var sortedHexes:Array = new Array();
         var hex:SpatialHex;
         for each (hex in _toLoadHexagons){
            if (!isHexAdjacentToLoadedZone(hex)){
               continue;        
            }      
            var dist:Number = getDisplayDistance(hex, projectedSpeed);
            sortedHexes.push(new SortedObject(hex, dist));
            
         }
         if (sortedHexes.length > 0) {
            
         }
         var NEIGHBOUR_RANK:int = 4;
         var N_LOADING_MAX:int = 3;
         SortedObject.sortArray(sortedHexes);
         if (sortedHexes.length == 0) {
            return;
         }
         var i:int = 0;    
         for each (var sortedHex:SortedObject in sortedHexes ){
            hex = sortedHex.object as SpatialHex;
            Assert.assert(hex.state == SpatialHex.TOLOAD, "Load an hexagon hex "+hex+" which state was "+hex.state);
            setHexagonState(hex, SpatialHex.LOADING);
            toLoadHexes.push(hex);
            var loadedNeighbours:Vector.<SpatialHex>= _discoverModel.getHexNeighbours(hex, NEIGHBOUR_RANK, true, true);
            for each (var neighbour:SpatialHex in loadedNeighbours) {
               if (!neighbourHexs[neighbour.id]) {
                  neighbourHexs[neighbour.id] = neighbour;
               } 
            }
            if (++i >= N_LOADING_MAX) {    
               break;
            }
         }
         var spatialTree:SpatialTree;      
         
         var nHexs:int = 0;
         var positionedTrees:Vector.<SpatialTree> = new Vector.<SpatialTree>();
         for each (hex in neighbourHexs){
            for each(spatialTree in hex.spacialTreeList) {
               if (spatialTree.tree) {
                  positionedTrees.push(spatialTree);
               }
            }
            nHexs += 1;
         }
         
         if (!positionedTrees.length){
            getLogger().info("No positionned tree -> take all hexes");
            for each(hex in _displayedHexagons){   
               for each(spatialTree in hex.spacialTreeList) {
                  if (spatialTree.tree) {
                     positionedTrees.push(spatialTree);
                  }
               }     
            }
         }
         getLogger().debug("loadHexes: {0} ({1} still to load)", toLoadHexes, _toLoadHexagons.length);      
         _discoverModel.loadHexList(toLoadHexes, positionedTrees, _dragDistance.x, _dragDistance.y);

      } 
      
      public static function getDisplayDistance(hex:SpatialHex, speed:Point):Number{
         return (speed.x * hex.centerX  + speed.y * hex.centerY) + 0.0001 * hex.hexX + 0.01 * hex.hexY;   
      }
      
      private function isHexAdjacentToLoadedZone(hex:SpatialHex):Boolean {
         var neighbours:Vector.<SpatialHex>= _discoverModel.getHexNeighbours(hex);
         for each (var hex:SpatialHex in neighbours) {
            if (hex.isLoaded) {
               return true;
            }
         }
         return false;
      }
      private function isHexAdjacentToDisplayedZone(hex:SpatialHex):Boolean {
         var neighbours:Vector.<SpatialHex>= _discoverModel.getHexNeighbours(hex);
         for each (var hex:SpatialHex in neighbours) {
            if (hex.isLoaded && (hex.state == SpatialHex.DISPLAYED) ) {
               return true;
            }
         }
         return false;
      }

      public function addHexesTowardsPoint(x:int, y:int):void {
         var mainHex:SpatialHex = getTreeHexUnderPoint(x,y); 
         var mainCenter:Point = new Point(mainHex.centerX, mainHex.centerY);
         
         var minDist:Number = Number.MAX_VALUE;
         var minHex:SpatialHex = null ;
         var p:Point = new Point();
         var squreDist:Number;
         if (mainHex.state == SpatialHex.NONE || mainHex.state == SpatialHex.NEIGHBOUR) {                
            
            for each (var hex:SpatialHex in _discoverModel.hexList) {
               if (hex.state != SpatialHex.NONE && hex.state != SpatialHex.NEIGHBOUR) {
                  p.x = hex.centerX;
                  p.y = hex.centerY;
                  squreDist = BroceliandMath.getSquareDistanceBetweenPoints(mainCenter, p);
                  if (squreDist<minDist) {
                     minDist  = squreDist;
                     minHex = hex;
                  }
               }
            }

            if (minHex) {
               minDist = Math.sqrt(minDist);
               var nsteps:Number = minDist / (SpatialHex.EDGE_DISTANCE_Y * _vgraph.scale);
               var start:Point = p;
               start.x = minHex.centerX;
               start.y = minHex.centerY;
               var delta:Point = new Point(mainCenter.x - start.x, mainCenter.y - start.y);
               for (var i:int = 0;  i < nsteps; i++){            
                  var pointHex:SpatialHex = getTreeHexUnderPoint(start.x + i / nsteps * delta.x,start.y + i / nsteps * delta.y);
                  if (pointHex.state == SpatialHex.NONE || pointHex.state == SpatialHex.NEIGHBOUR){
                     
                     setHexagonState(pointHex, SpatialHex.TOLOAD);
                     updateNeighboursForNewHexagon(pointHex);
                  }
               }                    
               _dragDistance = new Point(mainCenter.x - start.x, mainCenter.y - start.y);
               if (_dragDistance.length != 0){
                  var SMALL_DISTANCE:Number = 10;            
                  var normFactor :Number = SMALL_DISTANCE / _dragDistance.length;
                  _dragDistance.x = _dragDistance.x * normFactor;
                  _dragDistance.y = _dragDistance.y * normFactor;
               }

            }
            else{
               getLogger().warn("DiscoverDisplayModel::addHexesTowardsPoint() No hexes found");
            }
            setHexagonState(mainHex, SpatialHex.TOLOAD);
            updateNeighboursForNewHexagon(mainHex);
         }
      }

      public function getTreeHexUnderPoint(x:int, y:int):SpatialHex {
         var halfEdgeX:Number = SpatialHex.HALF_EDGE_X;
         var edgeDistanceY:Number = SpatialHex.EDGE_DISTANCE_Y;
         var hexX:int = Math.floor((x + halfEdgeX * 3 / 2) / (halfEdgeX * 3));
         var hexY:int = Math.floor((y + ((hexX & 1) != 0 ? 2 * edgeDistanceY : edgeDistanceY)) / (edgeDistanceY * 2));
         return _discoverModel.getHex(hexX, hexY, true);
      }

      public function displayCoordToLocalCoord(coord:Number, xCoordinate:Boolean):Number {
         return coord - (xCoordinate ? ( _vgraph.origin.x + _vgraph.width/2):(_vgraph.origin.y + _vgraph.height/2));
      }

      private function projectSpeedOnMainAxis(speed:Point, allocatedResult:Point = null):Point{
         if (!speed) {
            return new Point();
         }
         if (speed.length ==0) {
            return speed;
         }
         var maxCos:Number = 0;
         var maxi:int = 0;
         for (var i:int = 0; i < MAIN_AXIS.length; i++){
            var c:Number  = Math.cos(Geometry.polarAngle(speed)- Geometry.polarAngle(MAIN_AXIS[i]));
            if (Math.abs(c) > Math.abs(maxCos)){
               maxCos = c;
               maxi = i;
            }
         }        
         var axis:Point = MAIN_AXIS[maxi];
         var sign:int = 1;
         if (maxCos < 0){
            sign =-1;
         }
         var mult:Number = speed.length / axis.length;
         if (!allocatedResult) {
            allocatedResult = new Point();
         }
         allocatedResult.x = sign * axis.x * mult; 
         allocatedResult.y =  sign * axis.y * mult;
         
         return allocatedResult;
      }
      
      private function getNextHexToDisplayAdjacent(adjacent:Boolean):SpatialHex {
         if (_toDisplayHexagons == null) {
            return null;
         }
         var minDist:Number = Number.MAX_VALUE;
         var projectedSpeed:Point = projectSpeedOnMainAxis(_dragDistance);

         var minHex:SpatialHex = null;
         for each (var hex:SpatialHex in _toDisplayHexagons){            
            if (adjacent && !isHexAdjacentToDisplayedZone(hex)) {
               continue;
            }
            var dist:Number = getDisplayDistance(hex, projectedSpeed);

            if (dist < minDist){
               minDist = dist;
               minHex = hex;
            }                
         }    

         return minHex;
      }
      
      public function getNextHexToDisplayed():SpatialHex {
         var hexToDisplay :SpatialHex = getNextHexToDisplayAdjacent(true);
         if (!hexToDisplay) {
            hexToDisplay = getNextHexToDisplayAdjacent(false);
         }
         return hexToDisplay;
      }

      public function hasHexToShow():Boolean {
         for (var i:String in _toDisplayHexagons) {
            return true;
         }
         return false;
      }
      private function onErrorLoading(event:Event):void {
         if (_loadingHexagons.length>0) {
            for (var i:int = _loadingHexagons.length; i-->0;) {
               var hex:SpatialHex = _loadingHexagons[i];
               setHexagonState(hex, SpatialHex.TOLOAD);
            }
            if (_discoverModel.enabled) {
               addHexagonsToLoad();
               fillPTW();
            }
         }
      }

   }
   
}

class SortedObject {
   public var object:Object;
   public var value:Number;
   
   public function SortedObject(o:Object, v:Number) {
      this.object = o;
      this.value = v;
   }
   static public function sortArray(array:Array, option:Object= null):void {
      array.sortOn("value", option);     
   }
}
