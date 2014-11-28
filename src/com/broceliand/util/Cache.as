package com.broceliand.util
{
   import flash.utils.Dictionary;
   
   public class Cache
   {
      private var _cache:Dictionary  = new Dictionary();
      private var _entries:Array = new Array();
      private var _maxCacheSize:int =0;
      public function Cache(maxCacheElements:int=20) 
      {
         _maxCacheSize = maxCacheElements;
      }
      public function registerObject(id:String, value:Object):void {
         if (_cache[id] == null) {
            _entries.push(id);   
         }
         _cache[id] = value;
         if (_entries.length > _maxCacheSize) {
            var objectToRemove:String = _entries.shift();
            delete _cache[objectToRemove];
         }
      }
      public function getObject(id:String):Object {
         var retValue:Object = _cache[id];
         if (retValue) {
            
            var index:int = _entries.lastIndexOf(id);
            if (index != _entries.length-1) {
               _entries.splice(index,1);
               _entries.push(id);
            }
         }
         return retValue;
      }
      
   }
}