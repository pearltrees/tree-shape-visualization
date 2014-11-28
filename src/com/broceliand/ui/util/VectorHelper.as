package com.broceliand.ui.util {
   
   public class VectorHelper {
      
      public static function vectorToArray(value:*):Array {
         if(!value) return null;
         var vectorCount:int = value.length;
         var newArray:Array = new Array();
         for( var i:int = 0; i < vectorCount; i++ ) {
            newArray[i] = value[i];
         }
         return newArray;         
      }
   }
}