package com.broceliand.ui.pearl.view
{
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlBase;
   
   import flash.display.Bitmap;
   import flash.geom.Point;
   
   public interface IUIPearlView
   {
      function get pearlWidth():Number;
      function get pearlCenter():Point;
      function get titleCenter():Point;
      function get scale():Number;
   }
}