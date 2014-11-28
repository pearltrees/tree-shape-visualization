package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   
   public class BroCoeditDistantTreeRefNode extends BroDistantTreeRefNode implements ICoeditNode
   {
      
      public function BroCoeditDistantTreeRefNode(tree:BroPearlTree) {
         super(tree);
      }
      public function changeInRepresentantPearl():BroCoeditLocalTreeRefNode {
         var node:BroCoeditLocalTreeRefNode = new BroCoeditLocalTreeRefNode(1, refTree.id);
         node.refTree = refTree;
         changeNodeType(node);   
         return node;
      }
      override public function isContentTypeMatch(contentType:int, isRepresentative:Boolean = false):Boolean {
         return !isRepresentative && contentType== AmfTreeService.CONTENT_TYPE_COEDITED_TREE;
      }      
   }
}