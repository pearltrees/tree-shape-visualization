package com.broceliand.pearlTree.model{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.model.notification.PearlNotification;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;

   public class BroLocalTreeRefNode extends BroTreeRefNode {
      
      public function BroLocalTreeRefNode(treeDB :int, treeId:int ) {
         super(treeDB, treeId);
      }
      
      override public function set refTree(o:BroPearlTree):void {
         super.refTree =o;
         o.refInParent = this;
      }
      
      override public function get noteCount():int {
         return refTree.rootPearlNoteCount;
      }
      
      override public function getNeighbourCount(cacheResult:Boolean=true):Number {
         return refTree.rootPearlNeighbourCount;
      }
      
      override public function get neighbours():IPaginatedList {
         if(refTree && refTree.getRootNode()) {
            return refTree.getRootNode().neighbours;
         }else{
            return super.neighbours;
         }
      }      
      
      public function addBranchInside(node:BroPTNode):void{
         if (refTree.pearlsLoaded) {
            
            refTree.addToRoot(node);  
         } 
      }
      override public function get notifications():PearlNotification {
         return refTree.getRootNode().notifications;
      }
      
      override public function isContentTypeMatch(contentType:int, isRepresentative:Boolean = false):Boolean {
         return contentType == AmfTreeService.CONTENT_TYPE_TREE;
      }
      
      override public function set graphNode(value:IPTNode):void {
         refTree.getRootNode().graphNode = value;
      }
      
      override public function get graphNode():IPTNode {
         return refTree.getRootNode().graphNode;
      }
      override public function isTitleEditable():Boolean {
         return refTree.getRootNode().isTitleEditable();
      }
   }
}