package com.broceliand.ui.navBar {
   
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   public class NavBarModelTreeItem extends NavBarModelItem {
      
      private var _tree:BroPearlTree;
      
      public function NavBarModelTreeItem(isAnonymous : Boolean = false) {
         super();
         this.isBold = !isAnonymous;
      }
      
      public function set tree(value:BroPearlTree):void {
         _tree = value;
      }
      public function get tree():BroPearlTree {
         return _tree;
      }      
   }
}