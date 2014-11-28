package com.broceliand.ui.util {
   
   import flash.text.TextFieldAutoSize;
   
   import mx.core.UITextField;

   public class PTMultilineTextField extends UITextField {
      
      public function PTMultilineTextField() {
         super();
         multiline = true;
         wordWrap = true;
         autoSize = TextFieldAutoSize.LEFT;
      }
      
      override public function truncateToFit(s:String = null):Boolean {
         return false;
      }
      
   }
}