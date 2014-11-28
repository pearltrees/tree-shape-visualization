package com.broceliand.ui.effects
{
   import flash.utils.getTimer;
   
   import mx.effects.Tween;
   
   public class SmoothSetter
   {
      private var _currentValue:Number;
      private var _targetValue:Number;
      private var _tween:Tween;
      private var _object:Object;
      private var _propertyName:String;
      private var _lastTargetTime:int;
      private var _tweenTargetCoeficient:Number = 1.0;
      private var _duration :int;
      public function SmoothSetter(object:Object, propertyName:String, duration:int =300)
      {
         _object = object;
         _propertyName = propertyName;
         _lastTargetTime =0;
         _duration = duration;
         _currentValue = _targetValue= object[propertyName];
      }
      public function setValue(targetValue:Number):void {
         _currentValue = _object[_propertyName];
         if (_targetValue ==  targetValue && _currentValue == targetValue) {
            return 
         }
         
         var currentTime:int = getTimer();
         if (currentTime - _lastTargetTime < _duration) {
            
            if (!_tween ) {
               _targetValue = targetValue;
               _tweenTargetCoeficient  = 1;
               setCurrentValue(targetValue);
            } else {
               _tweenTargetCoeficient = targetValue / _targetValue; 
               
            }
         } else {
            _targetValue = targetValue;
            _tweenTargetCoeficient = 1.0;
            _currentValue = _object[_propertyName] as Number;
            var tween:Tween = new Tween(this, _currentValue, _targetValue, _duration, -1);
            _tween = tween;
         }
         _lastTargetTime = currentTime;
      }
      
      public function getValue():Number{
         return _tweenTargetCoeficient* _targetValue;
      }

      public function onTweenUpdate(value:Object):void {
         setCurrentValue(_tweenTargetCoeficient * (value as Number));
      }
      public function onTweenEnd(value:Object):void {
         _tween = null;
         _targetValue = _tweenTargetCoeficient * _targetValue;
         setCurrentValue(_targetValue);
         _tweenTargetCoeficient = 1.0;
         
      }
      
      private function setCurrentValue(value:Number):void {
         _currentValue = value;
         _object[_propertyName] =  _currentValue;
         
      }		
      
      public function getTargetValue():Number {
         return _targetValue;
      }

   }
}