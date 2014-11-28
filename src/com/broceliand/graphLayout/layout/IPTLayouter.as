package com.broceliand.graphLayout.layout
{
   import com.broceliand.graphLayout.model.IPTNode;
   
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   
   public interface IPTLayouter extends ILayoutAlgorithm
   {
      
      function computeLayoutPositionOnly():Dictionary ;
      function setPearlTreesWorldLayout(value:Boolean):void;
      function layoutWithFixNodePosition(node:IPTNode):void;
      function centerNextLayoutAndZoomOutBigTree(center:Boolean, zoomOutNextTree:Boolean):void;
      function performSlowLayout(moveTime:Number=1000):Boolean;
      
   }
}