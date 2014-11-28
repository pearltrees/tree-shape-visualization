package com.broceliand.pearlTree.model.paginatedlists {
   import com.broceliand.pearlTree.io.object.util.paginatedlist.PaginatedListData;
   
   import mx.collections.ArrayCollection;

   public interface IPaginatedList {
      function get innerArray():Array;
      function get innerList():ArrayCollection;
      function set paginationState(state:PaginatedListData):void;
      function get paginationState():PaginatedListData;
      function get numberLoaded():int;
      function getInnerItemAt(pos:int):Object;
      function refreshMorePlaceholder():void;
      function addAtBeginning(value:IPaginatedListItem):void;
      function replaceAtBeginning(value:IPaginatedListItem):void;
      function addAtEnd(value:IPaginatedListItem):void;
      function get numberOfItems():int;
      function contains(value:Object):Boolean;
      function removeItemAt(pos:int):void;
      function mergeAfter(toMerge:IPaginatedList):void;
   }
}