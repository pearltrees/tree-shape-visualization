package com.broceliand.ui.pearlBar.deck {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;

   public class DeckItem {
      
      private var _node:IPTNode;
      private var _dataSource:Object;
      
      public function DeckItem(node:IPTNode=null, dataSource:Object=null) {
         _node = node;
         _dataSource = dataSource;
      }
      
      public function get dataSource():Object {
         return _dataSource;
      }
      public function set dataSource(value:Object):void {
         _dataSource = value;
      }
      
      public function get node():IPTNode {
         return _node;
      }
      public function set node(value:IPTNode):void {
         _node = value;
      }   
      
   }
}