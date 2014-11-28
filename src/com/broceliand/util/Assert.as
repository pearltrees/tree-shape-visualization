package com.broceliand.util {
   public class Assert {

      public static const enabled:Boolean = true;
      
      public static function assert(assertion:Boolean, msg:String = null):void {
         if (!assertion) {
            throw new Error("An assertion failed" + (msg ? (": " + msg) : "."));
         }
      }
   }
}

