package com.broceliand.graphLayout.model
{
   import com.broceliand.pearlTree.model.BroPTNode;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class DistantTreeRefNode extends PTNode{
      public function DistantTreeRefNode(id:int, sid:String, vn:IVisualNode, o:BroPTNode) 
      {
         super(id, sid, vn, o);
      }
      
   }
}