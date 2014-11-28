package com.broceliand.util
{
   public class StringNormalizer {
      
      private static var LOWERCASE_ASCII:String =
         "aeiou"    
         + "aeiouy"  
         + "aeiouy"  
         + "aon"        
         + "aeiouy"  
         + "a"            
         + "c"            
         + "ou"          
         ;
      
      private static var LOWERCASE_UNICODE:String =
         "\u00E0\u00E8\u00EC\u00F2\u00F9"             
         + "\u00E1\u00E9\u00ED\u00F3\u00FA\u00FD" 
         + "\u00E2\u00EA\u00EE\u00F4\u00FB\u0177" 
         + "\u00E3\u00F5\u00F1"
         + "\u00E4\u00EB\u00EF\u00F6\u00FC\u00FF" 
         + "\u00E5"                                                             
         + "\u00E7" 
         + "\u0151\u0171" 
         ;
      
      private static var TO_REMOVE:String = ".;,/ '\"#";
      
      public static function normalize(txt:String):String {
         if (txt == null) {
            return null;
         }
         var txtLower:String = txt.toLowerCase();
         var result:String = "";
         var n:int = txtLower.length;
         for (var i:int = 0; i < n; i++) {
            var c:String = txtLower.charAt(i);
            if (TO_REMOVE.indexOf(c) == -1) {
               var pos:int = LOWERCASE_UNICODE.indexOf(c);
               if (pos > -1) {
                  result = result + LOWERCASE_ASCII.charAt(pos);
               }
               else {
                  result = result + c;
               }
            }
         }
         return result;
      }
      
      /*
      public static String toLowerCaseNoAccent(String txt) {
      if (txt == null) {
      return null;
      } 
      String txtLower = txt.toLowerCase();
      StringBuilder sb = new StringBuilder();
      int n = txtLower.length();
      for (int i = 0; i < n; i++) {
      char c = txtLower.charAt(i);
      int pos = LOWERCASE_UNICODE.indexOf(c);
      if (pos > -1){
      sb.append(LOWERCASE_ASCII.charAt(pos));
      }
      else {
      sb.append(c);
      }
      }
      return sb.toString();
      }
      */

   }
}