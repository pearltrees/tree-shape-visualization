package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   
   public class DistantTreeRefNeighboursLoadedEvent extends NeighbourModelEvent
   {
      protected var _distantNode:BroDistantTreeRefNode;
      
      function DistantTreeRefNeighboursLoadedEvent(distantNode:BroDistantTreeRefNode, neighbours:IPaginatedList, type:String){
         super(neighbours, type);
         _distantNode = distantNode;
      }
      
      public function get distantNode():BroDistantTreeRefNode {
         return _distantNode;
      }
      
   }
}