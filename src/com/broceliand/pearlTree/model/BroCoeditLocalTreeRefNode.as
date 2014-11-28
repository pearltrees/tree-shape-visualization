package com.broceliand.pearlTree.model {
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   
   public class BroCoeditLocalTreeRefNode extends BroLocalTreeRefNode implements ICoeditNode {
      
      public function BroCoeditLocalTreeRefNode(treeDB:int, treeId:int)
      {
         super(treeDB, treeId);
      }
      override public function isContentTypeMatch(contentType:int, isRepresentative:Boolean = false):Boolean {
         return isRepresentative && contentType== AmfTreeService.CONTENT_TYPE_COEDITED_TREE;
      }
      
   }
}