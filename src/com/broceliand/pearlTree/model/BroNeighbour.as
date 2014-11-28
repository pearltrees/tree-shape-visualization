package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.team.TeamRequest;
   
   public class BroNeighbour
   {
      
      private var _neighbourTree:BroPearlTree;
      private var _neighbourPearlId:int;
      private var _teamRequestSentToNeighbour:TeamRequest;
      
      /*public function get rank():int {
      return _rank;
      }
      public function set rank(value:int):void {
      _rank = value;
      }*/
      
      public function get neighbourTree():BroPearlTree {
         return _neighbourTree;
      }
      public function set neighbourTree(value:BroPearlTree):void {
         _neighbourTree = value;
      }
      
      public function get neighbourPearlId():int {
         return _neighbourPearlId;
      }
      public function set neighbourPearlId(value:int):void {
         _neighbourPearlId = value;
      }
      public function get teamRequestSentToNeighbour():TeamRequest{
         return _teamRequestSentToNeighbour;
      }
      public function set teamRequestSentToNeighbour(value:TeamRequest):void{
         _teamRequestSentToNeighbour = value;
      }
   }
}