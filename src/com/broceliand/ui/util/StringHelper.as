package com.broceliand.ui.util
{
   import com.broceliand.ApplicationManager;
   
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   
   import mx.controls.Text;
   import mx.core.UIComponent;
   
   public class StringHelper {
      public static var latinRange:intRange;
      public static var currencyRange:intRange;
      
      public static function unescapeWithPlus(str:String):String {
         return unescape(str).replace(/\+/g, " ");
      }
      
      public static function replace(str:String, oldSubStr:String, newSubStr:String):String {
         return str.split(oldSubStr).join(newSubStr);
      }
      
      public static function trim(str:String, char:String):String {
         return trimBack(trimFront(str, char), char);
      }
      
      public static function trimFront(str:String, char:String):String {
         char = stringToCharacter(char);
         if (str.charAt(0) == char) {
            str = trimFront(str.substring(1), char);
         }
         return str;
      }
      
      public static function trimBack(str:String, char:String):String {
         char = stringToCharacter(char);
         if (str.charAt(str.length - 1) == char) {
            str = trimBack(str.substring(0, str.length - 1), char);
         }
         return str;
      }
      
      public static function stringToCharacter(str:String):String {
         if (str.length == 1) {
            return str;
         }
         return str.slice(0, 1);
      }
      
      public static function updateTextHeightBasedOnMaxedWidth(text:Text):void{
         text.explicitWidth = text.maxWidth;
         text.validateNow();
         text.setActualSize(text.width, text.measuredHeight + 3);
         text.validateSize();
      }
      
      public static function indexOfLastSpaceBeforeWidth(stringToParse:String, textContainer:UIComponent, maxWidth:Number):Number {
         return StringHelper.indexOfLastCharBeforeWidth(stringToParse, textContainer, maxWidth, " ");
      }
      
      public static function indexOfLastCharBeforeWidth(stringToParse:String, textContainer:UIComponent, maxWidth:Number, char:String=null):Number {
         var lastSpace:Number=0;
         var width:Number;
         var lastSpaceWidth:Number;
         for(var i:uint=0; i < stringToParse.length; i++) {
            var toMeasure:String = stringToParse.substr(0, i + 1);
            if (!char || stringToParse.charAt(i) == char) {
               lastSpace = i;
               lastSpaceWidth = width;
            }
            width = textContainer.measureText(toMeasure).width;
            if(width > maxWidth && i > 0) {
               return lastSpace > 0 ? lastSpace : i - 1 ;
            }
         }
         return stringToParse.length;         
      }
      
      public static function uintToHex(value:uint):String {
         var prefix:String = "000000";
         var str:String = String(prefix + value.toString(16));
         return str.substr(-6).toUpperCase();
      }
      public static function getDomainFromUrl(value:String):String {

         var domainRegExp:RegExp = /^((http[s]?|ftp):\/)?\/?([^\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)?(.*)?(#[\w\-]+)?$/i;
         var result:Object = domainRegExp.exec(value);
         var domain:String = (result)?result[3]:null;
         if (domain) {
            var semiColomnIndex:int = domain.lastIndexOf(":");
            if (semiColomnIndex>=0) {
               domain = domain.substring(0, semiColomnIndex);
            }
         }           
         return domain;
      }
      
      public static function getFormatedDomainNameFromUrl(value:String):String 
      {
         var domainUrl:String = getDomainFromUrl(value);
         if(value.indexOf(ApplicationManager.DEFAULT_NOTE_PEARL_DOMAIN) == 0 || value.indexOf(ApplicationManager.DEFAULT_PHOTO_PEARL_DOMAIN) == 0) {
            domainUrl = "";
         }
         if (domainUrl.substr(0,4) == "www.") {
            domainUrl = domainUrl.substring(4);
         }
         if (domainUrl.substr(0,3) == "fr.") {
            domainUrl = domainUrl.substring(3);
         }
         return domainUrl;            
      }

      public static function htmlEscape(str:String):String {
         return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString().replace(/"/g,'&#34;');
      }	    
      public static function arrayToString(a:Array, maxDepth:int=0):String {
         if (!a) {
            return null;
         }
         var s:String = "[";
         for (var i:int =0; i < a.length; i++) {
            if (maxDepth>0 && a[i] is Array) {
               s+= arrayToString(a[i] as Array, maxDepth-1);  
            }  else {
               s += a[i].toString();
            }
            if (i<a.length -1) {
               s+=", ";
            }
         }
         s+="]";
         return s;
      }
      
      public static function cutLineAfterFirstWord(str:String):String {
         var a:Array = str.split(/\s+/); 
         var isFirstLoop:Boolean = true;
         var result:String = "";
         for (var i:int = 0; i < a.length; i++) {
            result += a[i] + (isFirstLoop ? "\n" : " ");
            isFirstLoop = false;
         }
         return result;
      }
      
      private static function initUnicodeRanges():void {
         latinRange = new intRange(32, 591);
         currencyRange = new intRange(8352, 8399);
      }
      
      public static function isStringInEmbeddedFont(s:String):Boolean {
         if (!s || s.length == 0) return true;
         var sLength:int = s.length;
         if (!latinRange || !currencyRange) {
            initUnicodeRanges();
         }
         for (var i:int = 0; i<sLength; i++) {
            var charCode:int = s.charCodeAt(i);
            if (!latinRange.contains(charCode)
               && !currencyRange.contains(charCode)) {
               return false;
            }
         }
         return true;
      }
   }
}

internal class intRange {
   
   private var _min:int;
   private var _max:int;
   
   public function intRange(min:int, max:int) {
      _min = min;
      _max = max;
   }
   
   public function contains(value : int):Boolean {
      return ( _min <= value && _max >= value );
   }
}