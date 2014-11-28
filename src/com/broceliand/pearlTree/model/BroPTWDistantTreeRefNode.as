package com.broceliand.pearlTree.model
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   
   import flash.geom.Point;
   
   public class BroPTWDistantTreeRefNode extends BroDistantTreeRefNode implements IBroPTWNode {
      
      private var _position:BroRadialPosition;
      private var _isSearchCenter:Boolean;
      private var _isSearchNode:Boolean;
      private var _absolutePosition:Point;

      public function BroPTWDistantTreeRefNode(tree:BroPearlTree, position:BroRadialPosition=null, user:User=null) {
         super(tree, user);
         _position = position;
      }

      override public function get neighbourCount():Number {
         return refTree.getRootNode().neighbourCount;
      }     
      
      override public function get neighbours():IPaginatedList {
         return refTree.getRootNode().neighbours;
      } 
      
      public function get preferredRadialPosition():BroRadialPosition {
         return _position;
      }
      
      public function set preferredRadialPosition(pos:BroRadialPosition ):void {
         _position= pos;
      }     
      
      public function get absolutePosition():Point {
         if(!_absolutePosition){
            _absolutePosition = new Point();
         }
         return _absolutePosition;
      }
      public function set absolutePosition(value:Point):void {
         _absolutePosition = value;
      }      
      
      override public function set owner (value:BroPearlTree):void {}
      
      public function set isSearchCenter (value:Boolean):void {
         _isSearchCenter = value;
      }      
      public function get isSearchCenter ():Boolean {
         return _isSearchCenter;
      }
      
      public function set isSearchNode (value:Boolean):void {
         _isSearchNode = value;
      }      
      public function get isSearchNode ():Boolean {
         return _isSearchNode;
      }
      
      public function get indexKey():String {
         return  BroPearlTree.getTreeKey(this.treeDB, this.treeId);
      }
      
      public function navigateToPearl(selectedNode:IPTNode):void {
         
      }
      
      override public function isTitleEditable():Boolean {
         return false;
      }
      
      override public function canBeCopy():Boolean {
         return !refTree.isCurrentUserAuthor() && super.canBeCopy();
      }
   }
}