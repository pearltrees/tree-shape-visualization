package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   
   public class PageNeighboursLoadedEvent extends NeighbourModelEvent
   {
      protected var _pageNode:BroPageNode;
      
      function PageNeighboursLoadedEvent(pageNode:BroPageNode, neighbours:IPaginatedList, type:String){
         super(neighbours, type);
         _pageNode = pageNode;
      }
      
      public function get pageNode():BroPageNode {
         return _pageNode;
      }
   }
}