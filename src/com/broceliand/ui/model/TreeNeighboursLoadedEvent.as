package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   
   public class TreeNeighboursLoadedEvent extends NeighbourModelEvent
   {
      protected var _tree:BroPearlTree;
      
      function TreeNeighboursLoadedEvent(tree:BroPearlTree, neighbours:IPaginatedList, type:String){
         super(neighbours, type);
         _tree = tree;
      }
      
      public function get tree():BroPearlTree {
         return _tree;
      }
   }
}