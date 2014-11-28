package com.broceliand.util
{
   public class TreeNode
   {
      private var _data:Object;
      private var _parentNode:TreeNode;
      private var _childNodes:Array;
      private var _index:int;

      public function TreeNode(data:Object)
      {
         _data = data;
      }
      public function addChild(childNode:TreeNode):void {
         childNode._parentNode = this;
         var childNodes:Array = getOrMakeChildNodes();
         childNode._index = childNodes.length;
         childNodes.push(childNode);
      }
      public function getParent():TreeNode {
         return _parentNode;
      }
      public function get data():Object {
         return _data;
      }
      public function getIndex():int {
         return _index;
      }
      private function getOrMakeChildNodes():Array {
         if (_childNodes == null) {
            _childNodes= new Array();
         }
         return _childNodes;
      }

   }
}