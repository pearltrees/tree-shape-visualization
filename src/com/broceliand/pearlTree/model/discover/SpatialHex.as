package com.broceliand.pearlTree.model.discover {
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;

   public class SpatialHex {

      public  static const PEARL_ZOOM:Number = 1.2;
      
      public static const HALF_EDGE_X:Number = 108;
      public static const EDGE_DISTANCE_Y:Number = 186; 

      public static const NONE:int =0;       
      public static const NEIGHBOUR:int =1;  
      public static const TOLOAD:int =2;     
      public static const LOADING:int =3;    
      public static const TODISPLAY:int =4;  
      public static const DISPLAYED:int =5;  
      public static const HIDDEN:int =6;     

      private var _id:String;
      private var _hexX:int;
      private var _hexY:int;
      private var _centerX:int;
      private var _centerY:int;
      private var _isVisible:Boolean;
      private var _isLoaded:Boolean;
      private var _state:int;
      
      private var _spacialTreeList:Vector.<SpatialTree>;
      
      public function SpatialHex(hexX:int, hexY:int) {
         _hexX = hexX;
         _hexY = hexY;
         _spacialTreeList = new Vector.<SpatialTree>();
         _id = getRelatedTreeHexId(hexX, hexY);
         _centerX = 3 * HALF_EDGE_X * hexX;
         _centerY = EDGE_DISTANCE_Y * (hexY * 2 - (hexX & 1));
      }
      
      public function addSpatialTree(spatialTree:SpatialTree):void {
         if(!_isLoaded && _spacialTreeList.indexOf(spatialTree) == -1 && _id == spatialTree.getHexId()) {
            spatialTree.x = _centerX + PEARL_ZOOM * spatialTree.relativeX;
            spatialTree.y = _centerY + PEARL_ZOOM * spatialTree.relativeY;
            spatialTree.hexX = _hexX;
            spatialTree.hexY = _hexY;
            _spacialTreeList.push(spatialTree);
         }
      }
      
      public function get spacialTreeList():Vector.<SpatialTree> {
         return _spacialTreeList;
      }
      
      public function getSpatialTreeAt(relativeX:int, relativeY:int):SpatialTree {
         for each(var spatialTree:SpatialTree in _spacialTreeList) {
            if(spatialTree.relativeX == relativeX && spatialTree.relativeY == relativeY) {
               return spatialTree;
            }
         }
         return null;
      }
      
      public function get id():String {
         return _id;
      }
      
      public static function getRelatedTreeHexId(hexX:int, hexY:int):String {
         return hexX+":"+hexY;
      }
      
      public function get isVisible():Boolean {
         return _isVisible;
      }
      public function set isVisible(value:Boolean):void {
         _isVisible = value;
      }
      
      public function get hexX():int {
         return _hexX;
      }
      
      public function get hexY():int {
         return _hexY;
      }
      
      public function get isLoaded():Boolean {
         return _isLoaded;
      }
      public function set isLoaded(value:Boolean):void {
         _isLoaded = value;
      }
      
      public function get centerX():int {
         return _centerX;
      }
      public function get centerY():int {
         return _centerY;
      }
      
      public function get state():int
      {
         return _state;
      }
      
      public function set state(value:int):void
      {
         _state = value;
      }
      
      public function toString():String {
         if (_spacialTreeList.length) {
            return "hex ( "+id+")["+_spacialTreeList[0]+"]";
         } 
         return "hex ( "+id+")";
         
      }

   }
}