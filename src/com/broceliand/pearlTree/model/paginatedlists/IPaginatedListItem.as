package com.broceliand.pearlTree.model.paginatedlists {
   
   public interface IPaginatedListItem {
      function get innerItem():Object;
      function set innerItem(value:Object):void;
      function isMorePlaceholder():Boolean;
   }
}