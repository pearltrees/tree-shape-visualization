package com.broceliand.ui.model
{
   import com.broceliand.pearlTree.model.BroNeighbour;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedListItem;
   import com.broceliand.pearlTree.model.paginatedlists.PaginatedList;
   import com.broceliand.pearlTree.model.paginatedlists.PaginatedListItem;
   
   import flash.utils.Dictionary;

   public class NeighbourClientRepository
   {
      private var _nodeIdToNeighbourArray:Dictionary;
      
      public function NeighbourClientRepository()
      {
         _nodeIdToNeighbourArray = new Dictionary();
      }
      public function updateNodesNeighbour(node:BroPTNode, serverNeighbours:IPaginatedList):int{
         var additionalNeighbour:IPaginatedList = _nodeIdToNeighbourArray[node.persistentID];
         var addedNeighbours:int =0;
         if (additionalNeighbour) {
            for (var i:int; i< additionalNeighbour.numberLoaded; i++) {
               var isArlreadyThere:Boolean = false;
               var newNeighbour:BroNeighbour = additionalNeighbour.getInnerItemAt(i) as BroNeighbour;
               for (var j:int; j < serverNeighbours.numberLoaded ; j++) {
                  var serverNeighbour:BroNeighbour = serverNeighbours.getInnerItemAt(j) as BroNeighbour;
                  if (serverNeighbour.neighbourTree.id == newNeighbour.neighbourTree.id) {
                     isArlreadyThere = true;
                     additionalNeighbour.removeItemAt(i);
                     i--;
                     break;
                  }
               }
               if (!isArlreadyThere) {
                  addedNeighbours ++;
                  var newNeighbourItem:IPaginatedListItem = new PaginatedListItem();
                  newNeighbourItem.innerItem = newNeighbour;
                  serverNeighbours.addAtBeginning(newNeighbourItem);
               }
               
            }
            if (additionalNeighbour.numberOfItems ==0) {
               delete _nodeIdToNeighbourArray[node.persistentID];
            }
            
         }
         return addedNeighbours;
      }
      public function declareClientNeighbour(node:BroPTNode, destinationTree:BroPearlTree, crossingNode:BroPTNode=null):Boolean{
         var additionalNeighbour:IPaginatedList = _nodeIdToNeighbourArray[node.persistentID];
         if (!additionalNeighbour) {
            additionalNeighbour= new PaginatedList();
            _nodeIdToNeighbourArray[node.persistentID] = additionalNeighbour;
         }
         
         var newNeighbour:BroNeighbour= new BroNeighbour();
         newNeighbour.neighbourTree = destinationTree;
         if (crossingNode) {
            newNeighbour.neighbourPearlId = crossingNode.persistentID;
         } 
         for (var i:int=0; i<additionalNeighbour.numberLoaded; i++) {
            var alreadyAddedNeighbour:BroNeighbour = additionalNeighbour.getInnerItemAt(i) as BroNeighbour;
            if (alreadyAddedNeighbour.neighbourTree == destinationTree) {
               return false;
            }
         }
         var newNeighbourItem:IPaginatedListItem = new PaginatedListItem();
         newNeighbourItem.innerItem = newNeighbour;
         additionalNeighbour.addAtEnd(newNeighbourItem);
         if (node.neighbours) {
            updateNodesNeighbour(node, node.neighbours);
            if(node.neighbours.numberOfItems < NeighbourModel.MAX_NEIGHBOUR_TO_USE_AS_COUNT) {
               node.neighbourCount = node.neighbours.numberOfItems;
            }
         } else {
            node.neighbourCount+=1;
         }
         return true;
      }

   }
}