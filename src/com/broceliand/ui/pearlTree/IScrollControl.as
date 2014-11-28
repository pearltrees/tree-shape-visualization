package com.broceliand.ui.pearlTree
{
   import com.broceliand.ui.interactors.scroll.ScrollUi;
   
   import flash.geom.Point;

   public interface IScrollControl
   {
      
      function getScrollDescriptor(point:Point, isDragging:Boolean):ScrollDescriptor;
      function updateOnMouseMove(posX:Number, posY:Number, isDraggingPearl:Boolean):void;
      
      function hideWhileNotOncePassedBottomLine():void;

      function setForceShowControls(value:Boolean):void;
      function get scrollUi():ScrollUi;
      function set isDiscoverMode(value:Boolean):void;
   }
}