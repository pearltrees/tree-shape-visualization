package com.broceliand.pearlTree.model {

   public class BroNotePage extends BroPage {
      
      private var _noteText : String = null;
      
      public function BroNotePage() {
         super();
      }
      
      public function get noteText() : String {
         return _noteText;
      }
      
      public function set noteText(val : String) : void {
         _noteText = val;
      }
      
      public function isDeleted():Boolean {
         return (type == BroPageLayout.TYPE_NOTE_DELETED);
      }
      
   }
}
