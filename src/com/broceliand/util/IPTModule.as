package com.broceliand.util {
   
   import flash.events.IEventDispatcher;
   
   public interface IPTModule extends IEventDispatcher {
      
      function load(showBusyCursor:Boolean=true):void;
      function isLoaded():Boolean;
      function createClassInstance(classPath:String):Object;
      
   }
}