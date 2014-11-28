package com.broceliand.graphLayout.visual
{
   
   import com.broceliand.ui.renderers.pageRenderers.PagePearlRenderer;
   
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualNode;
   
   public class PageVisualNode extends PTVisualNodeBase
   {
      public function PageVisualNode(vg:IVisualGraph, node:INode, id:int, view:UIComponent = null, data:Object = null, mv:Boolean = true):void {
         super(vg, node, id, view, data, mv);
      }
      
      override public function set view(v:UIComponent):void {
         super.view = v;
         _pearlRenderer = PagePearlRenderer(v);
      }		
   }
}