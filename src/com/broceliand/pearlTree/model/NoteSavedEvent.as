package com.broceliand.pearlTree.model
{
   import flash.events.Event;
   
   public class NoteSavedEvent extends Event
   {
      public static const NOTE_SAVED:String = "NoteSaved";
      private var _note:BroComment; 
      
      public function NoteSavedEvent(note:BroComment, bubbles:Boolean=false, cancelable:Boolean=false) {
         super(NOTE_SAVED, bubbles, cancelable);
         _note = note;
      }
      
      public function get note():BroComment {
         return _note;
      }
   }
}