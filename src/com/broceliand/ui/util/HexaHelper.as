package com.broceliand.ui.util
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.ByteArray;
   
   public class HexaHelper {
      
      public static function hexCharToInt(str : String) : int {
         switch(str) {
            case "0":
               return  0;
            case "1":
               return  1;
            case "2":
               return  2;
            case "3":
               return  3;
            case "4":
               return  4;
            case "5":
               return  5;
            case "6":
               return  6;
            case "7":
               return  7;
            case "8":
               return  8;
            case "9":
               return  9;
            case "a":
            case "A":
               return 10;
            case "b":
            case "B":
               return 11;
            case "c":
            case "C":
               return 12;
            case "d":
            case "D":
               return 13;
            case "e":
            case "E":
               return 14;
            case "f":
            case "F":
               return 15;
         }
         return 0;
      }
      
      public static function hexStringToByteArray(str: String) : ByteArray {
         var len : int = str.length; 
         var res : ByteArray = new ByteArray();
         var i : int;
         var c0 : String;
         var c1 : String;
         var i0 : int;
         var i1 : int;
         var val : uint;
         for (i=0; i<len; i+=2) {
            c0 = str.charAt(i);
            i0 = hexCharToInt(c0);
            if (i<len-1) {
               c1 = str.charAt(i+1);
               i1 = hexCharToInt(c1);
               val = (i0 * 16) + i1;
               res.writeByte(val);
            }
         }
         return res;
      }   
      
      public static function byteArrayToHexString(b:ByteArray):String
      {
         if (b == null) return "";
         var r:String = "";
         for (var i:int = 0; i < b.length; i++)
         {
            var l:int = b[i];
            var h:int = l;
            l &= 0xf;
            h >>= 4;
            h &= 0xf;
            r += String.fromCharCode(h < 10 ? h + 48 : h - 10 + 97);
            r += String.fromCharCode(l < 10 ? l + 48 : l - 10 + 97);
         }
         if (r.length>32) {
            return logged2ServerByteArrayToHexString(b);
         }
         return r;
      }
      private static function logged2ServerByteArrayToHexString(b:ByteArray):String {
         var r:String = "";
         var loggedIntArray:Array = new Array();
         for (var i:int = 0; i < b.length; i++)
         {
            var l:int = b[i];
            loggedIntArray.push(l);
            var h:int = l;
            l &= 0xf;
            h >>= 4;
            h &= 0xf;
            r += String.fromCharCode(h < 10 ? h + 48 : h - 10 + 97);
            r += String.fromCharCode(l < 10 ? l + 48 : l - 10 + 97);
         }
         if (r.length>32) {
            Log.getLogger("com.broceliand.pearlTree.model.BroPage").error("bad byteArrayToHexString conversion : Byte Array {0}, result String {1}", StringHelper.arrayToString(loggedIntArray), r);
            ApplicationManager.getInstance().distantServices.amfNoteService.sendLogs(new Array("bad byteArrayToHexString conversion : Byte Array "+StringHelper.arrayToString(loggedIntArray)+" result String:"+ r));
            return null;
         }
         return r;
      }
      
   }
}