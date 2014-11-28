package com.broceliand.graphLayout.model
{
   import com.broceliand.pearlTree.model.BroPTNode;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class PageNode extends PTNode{
      
      public function PageNode(id:int, sid:String, vn:IVisualNode, o:BroPTNode) 
      {
         super(id, sid, vn, o);
      }
      override public function wasSameNode(node:IPTNode):Boolean { 
         return false;
      }
      
   }
}