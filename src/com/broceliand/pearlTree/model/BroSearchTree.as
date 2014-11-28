package com.broceliand.pearlTree.model
{
   public class BroSearchTree extends BroPearlTree
   {
      private var _searchResultItem:BroSearchResultItem;
      
      override public function BroSearchTree(source:BroPearlTree)
      {
         super(); 
         treeHierarchyNode.isAlias = true;
      }
      public function set searchResultItem (value:BroSearchResultItem):void
      {
         _searchResultItem = value;
      }
      
      public function get searchResultItem ():BroSearchResultItem
      {
         return _searchResultItem;
      }
   }
}

