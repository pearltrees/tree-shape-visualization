package com.broceliand.ui.pearlBar.deck {
   import com.broceliand.graphLayout.model.IPTNode;
   
   import flash.events.Event;

   public class DockedNodeStateEvent extends Event {
      
      private var _node:IPTNode;
      
      public function DockedNodeStateEvent(type:String, node:IPTNode) {
         super(type);
         _node = node;
      }
      
      public function get node():IPTNode {
         return _node;
      }
   }
}