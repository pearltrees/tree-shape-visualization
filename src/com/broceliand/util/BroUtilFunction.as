package com.broceliand.util
{
   import com.broceliand.util.logging.Log;
   
   import mx.core.Application;
   
   public class BroUtilFunction
   {
      static public function addToArray(array:Array, object:Object):Array {
         if (!object) {
            return array;
         } 
         if (!array) {
            array = new Array();
         } 
         array.push(object);
         return array;
      }
      
      static public function areArrayTheSame(array1:Array, array2:Array):Boolean {
         if (array1 && array2 && array1.length == array2.length) {
            for (var i:int =0; i<array1.length; i++) {
               if (array1[i] != array2[i]) {
                  return false;
               }
            }
            return true;
         } else {
            return array1 == array2;
         }
      }
      static public function throwErrorLater(error:Error, now:Boolean=false):void {
         if (now) {
            throw error;
         } else {
            Log.getLogger("Error").error("StackTrace {0}", error.getStackTrace());
            Application.application.callLater(throwErrorLater, new Array( error, true));  
         }
      }
      static public function getLimitedStackTrace(error:Error):String {
         var str:String = error.getStackTrace();
         if (str != null) {
            return str.substr(0, 700);
         }
         return "stack NaN";
      }
   }
}