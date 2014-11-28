package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.BroPTNode;
   
   import flash.events.Event;
   
   public class NeighbourCountChangedEvent extends Event
   {
      private var _node:BroPTNode;
      
      public function NeighbourCountChangedEvent(node:BroPTNode)
      {
         super(NeighbourModel.NEIGHBOUR_COUNT_CHANGED_EVENT);
         _node = node;
      }
      
      public function get node():BroPTNode {
         return _node;
      }
   }
}