package com.broceliand.util
{
   public class NoteInputTransferer
   {
      private var _noteInput:String;
      private var _noteInputInShare:Boolean;
      
      public function NoteInputTransferer()
      {
         _noteInput = "";
         _noteInputInShare = false;
      }

      public function getNoteInput():String{
         return _noteInput;
      }
      public function saveNoteInput(s:String):void{
         _noteInput = s;
      }
      public function set noteInputInShare(b:Boolean):void{
         _noteInputInShare = b;
      }
      public function get noteInputInShare():Boolean{
         return _noteInputInShare;
      }
      public function resetNoteInput():void{
         _noteInput = "";
         _noteInputInShare = false;
      }
   }
}