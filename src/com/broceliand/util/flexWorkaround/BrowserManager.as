package com.broceliand.util.flexWorkaround
{
   import mx.managers.IBrowserManager;
   
   public class BrowserManager
   {
      private static var implClassDependency:BrowserManagerImpl;
      
      private static var instance:IBrowserManager;

      public static function getInstance():IBrowserManager
      {
         if (!instance)
         {
            instance = IBrowserManager(BrowserManagerImpl.getInstance());
         }
         return instance;
      }
   }
}
