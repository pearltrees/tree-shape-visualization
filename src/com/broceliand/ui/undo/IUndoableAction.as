package com.broceliand.ui.undo
{
   public interface IUndoableAction
   {
      function doIt():void ;		
      function getOpposite():IUndoableAction;
      function canUndo():Boolean;
      
   }
}