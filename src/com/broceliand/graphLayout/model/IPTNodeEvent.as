package com.broceliand.graphLayout.model
{
   import com.broceliand.graphLayout.model.IPTNode;
   
   import flash.events.Event;
   
   public class IPTNodeEvent extends Event
   {
      private var _node:IPTNode;
      public function IPTNodeEvent(node:IPTNode, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         super(type, bubbles, cancelable);
         _node = node;
      }
      
      public function get node():IPTNode{
         return _node;
      }
   }
}