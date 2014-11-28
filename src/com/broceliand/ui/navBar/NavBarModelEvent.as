package com.broceliand.ui.navBar {
   
   import flash.events.Event;
   
   public class NavBarModelEvent extends Event {
      
      public static const MODEL_CHANGE:String = "modelChanged";
      
      public function NavBarModelEvent(type:String) {
         super(type);
      }
   }
}