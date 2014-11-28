package com.broceliand.ui.renderers
{
   import flash.geom.Point;

   public interface ITextRenderer
   {
      function getPointToCenterOn():Point;
      function get text():String;
   }
}