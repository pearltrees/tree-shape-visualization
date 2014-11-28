package com.broceliand.util
{
   import flash.events.Event;
   
   public class MultiUploadProgressEvent extends Event
   {
      public static const PROGRESS:String = "MultiUploadProgress";
      private static const SEC_IN_MILLISEC:int = 1000;
      private static const MIN_IN_MILLISEC:int = 60 * SEC_IN_MILLISEC;
      private static const HOUR_IN_MILLISEC:int = 60 * MIN_IN_MILLISEC;
      private static const MAX_REMAINING_TIME_DISPLAYED_IN_HR:int = 5;
      
      private var _progressBatch:uint;
      private var _progressFile:uint;
      private var _filePosition:uint;
      private var _batchPosition:uint;
      private var _lastStepSize:int;
      private var _lastStepTime:int;
      
      public function MultiUploadProgressEvent(progressBatch:Number, progressFile:Number, filePosition:uint, batchPosition:uint, lastStepSize:int = 0, lastStepTime:int = 0, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         super(PROGRESS, bubbles, cancelable);
         _progressBatch = Math.min(100, progressBatch);
         _progressFile = Math.min(100, progressFile);
         _lastStepSize = lastStepSize;
         _lastStepTime = lastStepTime;
         _filePosition = filePosition;
         _batchPosition = batchPosition;
      }
      
      override public function clone():Event {
         return new MultiUploadProgressEvent(_progressBatch, _progressFile, _filePosition, _batchPosition);
      }
      
      public function get progressBatch():uint {
         return _progressBatch;
      }
      
      public function get progressFile():uint {
         return _progressFile;
      }
      
      public function get filePosition():uint {
         return _filePosition;
      }
      
      public static function computeHrMinSecFromMillisec(timeInMillisec:int) : Array {
         var hr:int = timeInMillisec / HOUR_IN_MILLISEC;
         var min:int = (timeInMillisec - hr * HOUR_IN_MILLISEC) / MIN_IN_MILLISEC;
         var sec:int = (timeInMillisec - hr * HOUR_IN_MILLISEC - min * MIN_IN_MILLISEC) / SEC_IN_MILLISEC;
         return new Array(hr, min, sec);
      }
      
      public function getRemainingTimeInString():String {
         var hms: Array = computeHrMinSecFromMillisec(getRemainingTimeInMilliSec());
         var hr:int = hms[0];
         var min:int = hms[1];
         var sec:int = hms[2];
         if (hr > MAX_REMAINING_TIME_DISPLAYED_IN_HR) {
            return "#more than " + MAX_REMAINING_TIME_DISPLAYED_IN_HR + "h";
         }
         else {
            if (hr > 0) {
               sec = 0;
            }
            return   (hr > 0 ? hr.toString() + "h " : "")
            + (min > 0 ? min.toString() + "m " : "") 
               + (sec > 0 ? sec.toString() +"s" : "");
         }
      }
      
      public function getRemainingTimeInMilliSec():int {
         var speed:Number = _lastStepSize/_lastStepTime;
         var remainingSize:int = _progressFile - _progressBatch;
         var remainingTime:Number = remainingSize / speed;
         return remainingTime;
      }
      
      public function hasRemainingTime():Boolean {
         return _lastStepTime > 0;
      }
      
      public function get batchPosition():uint
      {
         return _batchPosition;
      }
      
      public function set batchPosition(value:uint):void
      {
         _batchPosition = value;
      }
      
   }
}