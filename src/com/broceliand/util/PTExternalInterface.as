package com.broceliand.util {
   
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   
   public class PTExternalInterface {
      
      private static var _callbacks:Dictionary = new Dictionary();
      
      public static function get available():Boolean {
         return ExternalInterface.available;
      }
      
      public static function get marshallExceptions():Boolean {
         return ExternalInterface.marshallExceptions;
      }
      public static function set marshallExceptions(value:Boolean):void {
         ExternalInterface.marshallExceptions = value;
      }
      
      public static function get objectID():String {
         return ExternalInterface.objectID;
      }
      
      public static function restoreCallbacks():void {
         for(var functionName:String in _callbacks) {
            ExternalInterface.addCallback(functionName, _callbacks[functionName]);
         }
      }
      
      public static function addCallback(functionName:String, closure:Function):void {
         _callbacks[functionName] = closure;
         ExternalInterface.addCallback(functionName, closure);
      }
      
      public static function call(functionName:String, ...arguments):* {
         arguments.unshift(functionName);
         return ExternalInterface.call.apply(null, arguments);
      }
   }
}