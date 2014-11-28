package com.broceliand.graphLayout.model
{
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
   
   public interface IPTGraph extends IGraph
   {
      
      function linkAtIndex(node1:IPTNode, node2:IPTNode, index:int,  o:Object = null):IEdge;
      
   }
}