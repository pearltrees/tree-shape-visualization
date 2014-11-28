package com.broceliand.util.logging {
   public class InstanceTracer {
      
      public static function getInstanceHash(obj:Object):String {
         var memoryHash:String;
         
         try  {
            FakeClass(obj);
         }
         catch (e:Error) {
            memoryHash = String(e).replace(/.*([@|\$].*?) en .*$/gi, '$1');
         }
         return memoryHash;
      }
   }
}
internal final class FakeClass { }