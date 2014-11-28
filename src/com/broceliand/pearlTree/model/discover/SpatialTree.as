package com.broceliand.pearlTree.model.discover {
   
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.sampler.getGetterInvocationCount;

   public class SpatialTree {
      
      private var _hexX:int;
      private var _hexY:int;
      private var _relativeX:int;
      private var _relativeY:int;
      private var _tree:BroPearlTree;
      private var _node:BroPTNode;
      private var _x:int;
      private var _y:int;

      public function getHexId():String {
         return SpatialHex.getRelatedTreeHexId(_hexX, _hexY);
      }
      public function get hexX():int { 
         return _hexX; 
      }
      public function set hexX(value:int):void { 
         _hexX = value; 
      }
      public function get hexY():int { 
         return _hexY; 
      }
      public function set hexY(value:int):void { 
         _hexY = value; 
      }
      public function get relativeX():int { 
         return _relativeX; 
      }
      public function set relativeX(value:int):void { 
         _relativeX = value; 
      }
      public function get relativeY():int { 
         return _relativeY; 
      }
      public function set relativeY(value:int):void { 
         _relativeY = value; 
      }
      public function get tree():BroPearlTree { 
         return _tree; 
      }
      public function set tree(value:BroPearlTree):void { 
         _tree = value; 
      }
      public function get x():int {
         return _x;
      }
      public function set x(value:int):void {
         _x = value;
      }
      public function get y():int {
         return _y;
      }
      public function set y(value:int):void {
         _y = value;
      }
      
      public function get node():BroPTNode
      {
         return _node;
      }
      
      public function set node(value:BroPTNode):void
      {
         _node = value;
      }
      
      public function toString():String {
         return _tree?_tree.title:"";
      }
   }
}