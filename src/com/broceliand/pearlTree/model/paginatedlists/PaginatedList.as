package com.broceliand.pearlTree.model.paginatedlists {
   import com.broceliand.pearlTree.io.object.util.paginatedlist.LimitItemData;
   import com.broceliand.pearlTree.io.object.util.paginatedlist.PaginatedListData;
   
   import mx.collections.ArrayCollection;

   public class PaginatedList implements IPaginatedList {
      
      private var _items:ArrayCollection; 
      private var _state:PaginatedListData;
      
      private static var _ref:int = 0;
      private var _myRef:int;
      
      public function PaginatedList() {
         _items = new ArrayCollection();
         _state = new PaginatedListData;
         _state.limit = new Array();
         _state.nonLoadedNumber = 0;

         _ref++;
         _myRef = _ref;
         
         new LimitItemData(); 
      }
      
      public function get innerArray():Array {
         return _items.source;
      }
      
      public function get innerList():ArrayCollection {
         return _items;   
      }
      
      public function set paginationState(state:PaginatedListData):void {
         _state = state;
         refreshMorePlaceholder();
      }
      
      public function get paginationState():PaginatedListData {
         return _state;
      }
      
      public function get numberLoaded():int {
         if (_items.length > 0 && (_items.getItemAt(_items.length - 1) as IPaginatedListItem).isMorePlaceholder()) {
            return _items.length - 1;
         }
         else {
            return _items.length;
         }
      }
      
      public function refreshMorePlaceholder():void {
         if (_items.length > 0 && _state.nonLoadedNumber > 0 && !(_items.getItemAt(_items.length - 1) as IPaginatedListItem).isMorePlaceholder()) {
            var placeHolder:PaginatedListItem = new PaginatedListItem(true);
            _items.addItem(placeHolder);
         }
         else if (_items.length > 0 && _state.nonLoadedNumber == 0 && (_items.getItemAt(_items.length - 1) as IPaginatedListItem).isMorePlaceholder()) {
            _items.removeItemAt(_items.length - 1);
         }         
      }
      
      public function addAtBeginning(value:IPaginatedListItem):void {
         _items.addItemAt(value, 0);
      }
      
      public function replaceAtBeginning(value:IPaginatedListItem):void {
         if (_items.length > 0) {
            _items.removeItemAt(0);
         }
         addAtBeginning(value);
      }
      
      public function addAtEnd(value:IPaginatedListItem):void {
         if (_items.length > 1 && (_items.getItemAt(_items.length - 1) as IPaginatedListItem).isMorePlaceholder()) {
            _items.addItemAt(value, _items.length - 2);
         }
         else {
            _items.addItem(value);
         }
      }
      
      public function get numberOfItems():int {
         if (_items.length > 0 && (_items.getItemAt(_items.length - 1) as IPaginatedListItem).isMorePlaceholder()) {
            return _items.length + (_state?_state.nonLoadedNumber:0) - 1;
         }
         return _items.length + (_state?_state.nonLoadedNumber:0);
      }
      
      public function getInnerItemAt(pos:int):Object {
         if (pos < 0 || pos >= _items.length) {
            return null;
         } else {
            return (_items.getItemAt(pos) as IPaginatedListItem).innerItem;
         }
      }
      
      public function contains(value:Object):Boolean {
         var item:Object;
         for (var i:int = 0; i < numberLoaded ; i++) {
            item = getInnerItemAt(i);
            if (item == value) {
               return true;
            }
         }
         return false;
      }
      
      public function removeItemAt(pos:int):void {
         _items.removeItemAt(pos);
      }
      
      public function mergeAfter(toMerge:IPaginatedList):void {
         removePlaceholder();
         _items.addAll(toMerge.innerList);
         paginationState = toMerge.paginationState;
         refreshMorePlaceholder();
         toMerge.refreshMorePlaceholder();
      }
      
      private function removePlaceholder():void {
         if (_items.length > 0 && (_items.getItemAt(_items.length - 1) as IPaginatedListItem).isMorePlaceholder()) {
            _items.removeItemAt(_items.length - 1);
         }
      }

   }
}