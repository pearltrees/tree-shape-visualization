package com.broceliand.ui.model
{
   public interface INoteModelCallback
   {
      function onNotesLoaded():void;
      function onNoteAdded():void;
      function onNoteRemoved():void;
   }
}