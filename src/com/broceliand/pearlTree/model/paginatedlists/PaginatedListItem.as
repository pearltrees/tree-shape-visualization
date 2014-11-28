package com.broceliand.pearlTree.model.paginatedlists {
   import flash.events.EventDispatcher;
   
   public class PaginatedListItem implements IPaginatedListItem {
      
      private var _innerItem:Object;
      private var _isPlaceholder:Boolean;
      
      public function PaginatedListItem(isMorePlaceholer:Boolean = false, innerItem:Object=null) {
         _isPlaceholder = isMorePlaceholer;
         _innerItem = innerItem;
      }
      
      public function get innerItem():Object {
         return _innerItem;
      }
      
      public function set innerItem(value:Object):void {
         _innerItem = value;
      }
      
      public function isMorePlaceholder():Boolean {
         return _isPlaceholder;
      }
      
   }
}