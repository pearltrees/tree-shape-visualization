package com.broceliand.ui.scrollbar {
   
   import mx.controls.Button;
   import mx.controls.scrollClasses.ScrollBar;
   import mx.core.mx_internal;

   public class PTScrollBar extends ScrollBar {
      
      public function PTScrollBar() {
         super();
      }
      
      public function get upArrow():Button {
         return mx_internal::upArrow;
      }
      
      public function get downArrow():Button {
         return mx_internal::downArrow;
      }
   }
}