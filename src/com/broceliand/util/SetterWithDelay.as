package com.broceliand.util
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class SetterWithDelay
   {
      private var _source:Object;
      private var _propertyName:String;
      private var _propertyName2:String;
      private var _value:Object;
      private var _value2:Object
      private var _valueSet:Boolean = false;
      private var _value2Set:Boolean = false;
      private var _timer:Timer;

      public function SetterWithDelay(owner:Object, propertyName:String, delay:int, secondProperty:String=null ) 
      {
         _source = owner;
         _propertyName = propertyName;
         _propertyName2 = secondProperty;
         _timer = new Timer(delay,1);
         _timer.addEventListener(TimerEvent.TIMER, setValueOnTimer);
      }
      public function getValue():Object {
         return _value;
      }
      public function setValue(value:Object):void {
         _value = value;
         _valueSet = true;
         
         if (!_timer.running) {
            _timer.reset();
            _timer.start();
         }
      }
      public function setSecondValue(value:Object):void {
         _value2Set = true;
         _value2 = value;
         if (!_timer.running) {
            _timer.reset();
            _timer.start();
         }
      }
      private function setValueOnTimer(event:TimerEvent):void {
         if (_valueSet) {
            _source[_propertyName]=_value;
            _valueSet = false;
         }
         if (_propertyName2 && _value2Set) {
            _source[_propertyName2] = _value2;
            _value2Set = false;
         }
      }
      
      public function areSetActionPending():Boolean {
         return _timer.running;
         
      }
      
      public function interrupt():void {
         
         _timer.stop();
      }
   }
}