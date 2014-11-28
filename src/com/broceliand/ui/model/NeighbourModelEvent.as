package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   
   import flash.events.Event;
   
   public class NeighbourModelEvent extends Event
   {      
      protected var _neighbours:IPaginatedList;
      
      function NeighbourModelEvent(neighbours:IPaginatedList, type:String){
         super(type);
         _neighbours = neighbours;
      }
      
      public function get neighbours():IPaginatedList{
         return _neighbours;
      }
   }
}