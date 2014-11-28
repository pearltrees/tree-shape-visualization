package com.broceliand.ui.mouse
{
   
   public interface ICursorSetter
   {
      function getWantedCursor(stageX:Number, stageY:Number, isMouseDown:Boolean, distanceToMouseDown:Number):String;
   }
}