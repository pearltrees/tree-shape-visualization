package com.broceliand.pearlTree.model {
   
   import flash.events.Event;

   public class PageTypeReloaderEvent extends Event {
      
      private var _page:BroPage;
      
      public function PageTypeReloaderEvent(type:String, page:BroPage) {
         super(type);      
         _page = page;
      }
      
      public function get page():BroPage {
         return _page;
      }
   }
}