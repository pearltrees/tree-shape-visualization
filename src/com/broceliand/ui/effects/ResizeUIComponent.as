package com.broceliand.ui.effects {
   
   import mx.core.UIComponent;

   public class ResizeUIComponent extends UIComponent {
      
      override public function set width(value:Number):void {
         if(super.width != value) {
            super.width = value;
            validateDisplayList();
         }
      } 
      
   }
}