package com.broceliand.ui.interactors.drag
{
   import flash.events.MouseEvent;
   
   public interface IDragInteractor
   {
      function dragBegin(ev:MouseEvent):void;	
      function handleDrag(ev:MouseEvent):void;
      function dragEnd(ev:MouseEvent):void;
   }
}