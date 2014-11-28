package com.broceliand.util
{
   import com.broceliand.ui.button.PTLinkButton;
   
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   import mx.utils.StringUtil;
   
   public class StringManipulator {
      
      public static function cutStringToMaxChars(str : String, n : int = 10) : String {
         if (n<0) return str;
         if (str.length > n) {
            if (n>2) {
               return str.substring(0, n-1) + "..."; 
            } else {
               return str; 
            }
         } else {
            return str;
         }
      }
      
      public static function cutStringToMaxCharsStopAtWord(str : String, n : int = 10) : String {
         var trim : String = cutStringToMaxChars(str, n);
         var index : int = lastWhiteSpaceIndex(trim);
         if (index>0) {
            trim = trim.substring(0, index);
         }
         return trim;
      }
      
      private static function lastWhiteSpaceIndex(str : String) : int {
         var char : String;
         for (var i:int = str.length-1; i >= 0; i--) {
            char = str.charAt(i);
            if (StringUtil.isWhitespace(char)) { 
               return i;
            }
         }
         return -1;
      }
      
      public static function measureString(str:String, format:TextFormat):Rectangle {
         var textField:TextField = new TextField();
         textField.defaultTextFormat = format;
         textField.text = str;
         return new Rectangle(0,0,textField.textWidth, textField.textHeight);
      }
      
      public static function cutStringToMaxSizeInPixels(str:String, container:PTLinkButton, sizeLimit:int):String {
         if (sizeLimit < 0) {
            return str;
         }
         if (container.measureText(str).width <= sizeLimit) {
            return str;
         }
         while ((container.measureText(str + "...").width > sizeLimit) && (str.length > 1)) {
            str = str.substring(0, str.length - 1);
         }
         return (str + "...");
         
         /*
         if (measureString(str, format).width <= sizeLimit) {
         return str;
         }
         while ((measureString(str + "...", format).width > sizeLimit) && (str.length > 1)) {
         str = str.substring(0, str.length -1);
         }
         return (str +"...");
         */
      }
      
   }
}