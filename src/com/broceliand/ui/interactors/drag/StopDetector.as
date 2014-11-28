package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.getTimer;
   
   import mx.core.IUIComponent;
   
   public class StopDetector  
   {
      private const _precision:Number = 400; 
      private var _isRunning:Boolean = false;
      private var _listeners:Array = new Array();
      private var _stoppingDelays:Array = new Array();
      private var _currentStoppingLength:Number;
      private var _startTime:Number; 
      public function StopDetector() {
      }
      
      private function reset():void {
         _currentStoppingLength = 0;
         _startTime = getTimer();
      }
      public function onMove():void {
         if (_isRunning) {
            reset();
         }
      }
      
      public function onEnterFrame(event:Event):void {
         updateTime();
      }
      
      public function startStopDetector():void {
         if (!_isRunning) {
            _isRunning =true;
            onMove();
            var stage:Stage = ApplicationManager.getInstance().components.pearlTreeViewer.stage;
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
         }
      }
      public function stopStopDetector():void {
         if (_isRunning) {
            var stage:Stage = ApplicationManager.getInstance().components.pearlTreeViewer.stage;
            stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            _isRunning = false;
         }
      }
      
      private function updateTime():void {
         var l:Number = getTimer();
         var newStopTime:Number = (l - _startTime) / _precision; 
         var shouldNotify:Boolean = Math.floor(newStopTime) != Math.floor(_currentStoppingLength);
         _currentStoppingLength = newStopTime;
         if (shouldNotify) {
            notifyListenerStoppedHappen();
         }
      }   
      
      public function getCurrentStoppingLength():Number {
         return _currentStoppingLength * _precision;
      }
      
      public function addStopEventListener(l:Function, delayInMS:int):void {
         if (_listeners.length ==0 && !_isRunning) {
            startStopDetector();
         }
         var lastIndexOfListeners:int = _listeners.lastIndexOf(l);
         if (lastIndexOfListeners<0) {
            _listeners.push(l);
            _stoppingDelays.push(delayInMS);
         } else {
            _stoppingDelays[lastIndexOfListeners] = delayInMS;  
         }
         
      }
      public function clear():void {
         if (_listeners.length>0) {
            _listeners = new Array();
            _stoppingDelays = new Array();
         }
         reset();
         stopStopDetector();
      }
      public function removeStopEventListener(l:Function):void {
         var index:int = _listeners.indexOf(l);
         if (index>=0) {
            _listeners.splice(index, 1);
            _stoppingDelays.splice(index, 1);
         } 
         if (_listeners.length ==0) {
            stopStopDetector();
         }
      }
      public function notifyListenerStoppedHappen():void {
         var currentDelay:Number = getCurrentStoppingLength(); 
         for (var i:int = _listeners.length; i-->0;) {
            if (_stoppingDelays[i] <= currentDelay) {
               (_listeners[i] as Function).call();
               _listeners.splice(i,1);
               _stoppingDelays.splice(i,1);
            }
         }
         if (_listeners.length == 0) {
            stopStopDetector();
         }
      }
   }
}