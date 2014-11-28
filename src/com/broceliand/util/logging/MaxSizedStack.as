package com.broceliand.util.logging
{
   
   public class MaxSizedStack
   {
      private var _data:Array;
      private var _startIndex:int;
      private var _maxSize:int;
      public function MaxSizedStack(maxSize:int)
      {
         _maxSize = maxSize;
         _startIndex = 0;
         _data = new Array();

      }
      public function get length():int {
         return _data.length;
      }
      public function push(elt:Object):void {
         if (_data.length<_maxSize) {
            _data.push(elt);
         } else {
            _data[_startIndex] = elt;
            _startIndex ++;
            if (_startIndex >= _maxSize) {
               _startIndex = 0;
            }
         }
      }
      public function pop():Object {
         if (_startIndex>0) {
            var result:Array = _data.splice(_startIndex - 1, 1);
            _startIndex --;
            return result[0];
         } else {
            return _data.pop();
         }
      }
      public function getElement(index:int):Object {
         if (index > length ){
            throw new Error(index+" is out of bounds");
         }
         index  += _startIndex;
         if (index>= _maxSize) {
            index -= _maxSize;
         }
         return _data[index];
      }
   }
}