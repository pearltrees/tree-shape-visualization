package com.broceliand.ui.renderers.pageRenderers.pearl
{
   public class PearlNotificationState
   {
      
      private var _notifyingNewNote:Boolean = false;
      private var _notifyingNewCross:Boolean = false;
      
      public function set notifyingNewNote (value:Boolean):void
      {
         if (_notifyingNewNote != value) {
            _notifyingNewNote = value;
         }
      }
      
      public function get notifyingNewNote ():Boolean
      {
         return _notifyingNewNote;
      }
      
      public function set notifyingNewCross (value:Boolean):void
      {
         _notifyingNewCross = value;
      }
      
      public function get notifyingNewCross ():Boolean
      {
         return _notifyingNewCross;
      }
   }
}