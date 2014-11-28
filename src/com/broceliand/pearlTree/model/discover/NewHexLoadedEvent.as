package com.broceliand.pearlTree.model.discover {
   
   import flash.events.Event;

   public class NewHexLoadedEvent extends Event {
      
      private var _isFirstLoad:Boolean;
      
      public function NewHexLoadedEvent(type:String, isFirstLoad:Boolean=true) {
         super(type);
         _isFirstLoad = isFirstLoad;
      }
      
      public function get isFirstLoad():Boolean {
         return _isFirstLoad;
      }
   }
}