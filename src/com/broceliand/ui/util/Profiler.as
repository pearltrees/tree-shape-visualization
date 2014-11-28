package com.broceliand.ui.util
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.FrameDebugId;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.core.Application;
   import mx.logging.LogEventLevel;
   
   public class Profiler
   {
      private var _logger:BroLogger;
      private var _isEnabled:Boolean = true; 
      private var _showFrameId:Boolean = true;
      private var _frameDebugId:FrameDebugId;      
      private var _sessions:Dictionary = new Dictionary();
      
      private static var _singleton:Profiler;
      
      public function Profiler() {
         if (_singleton) {
            throw new Error("Constructor should not be called directly. Use getInstance() instead.");
         }
         _logger = Log.getLogger("com.broceliand.ui.util.profiler");
      }
      
      public function get isEnabled():Boolean
      {
         return _isEnabled;
      }
      
      public function set isEnabled(value:Boolean):void
      {
         _isEnabled = value;
      }
      
      public static function getInstance():Profiler {
         if (!_singleton) {
            _singleton = new Profiler();
            _singleton.init();
         }
         return _singleton;
      }
      
      public function init():void {
         if(ApplicationManager.flexApplication.stage) {
            isEnabled = ApplicationManager.getInstance().isDebug;
         }else{
            ApplicationManager.flexApplication.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
         }
      }
      private function onAddedToStage(event:Event):void {
         init();
      }
      
      public function startSession(sessionName:String, startTime:Number=-1):void {
         if(!isEnabled || !_logger.isUsed) return;
         
         if(!_frameDebugId && _showFrameId) _frameDebugId = FrameDebugId.getInstance();
         if(_sessions[sessionName]) {
            endSession(sessionName);
         }
         var session:ProfilerSession = new ProfilerSession(sessionName, startTime);
         _sessions[sessionName] = session;
         showMessage("[PROFILER-"+sessionName+"][start]");
      }
      
      public function endSession(sessionName:String):void {
         if(!isEnabled || !_logger.isUsed) return;
         
         var session:ProfilerSession = _sessions[sessionName];
         if(session) {
            delete _sessions[sessionName];
            showMessage("[PROFILER-"+sessionName+"][end]");
         }
      }
      
      public function addMarker(markerName:String, sessionName:String):void {
         if(!isEnabled || !_logger.isUsed) return;
         
         var session:ProfilerSession = _sessions[sessionName];
         if(!session) return;
         
         var markerTime:Number = new Date().getTime();
         var markerSessionTime:Number = markerTime - session.startTime;
         var markerToMarkerTime:Number = markerTime - session.lastMarkerTime;
         session.lastMarkerTime = markerTime;
         
         var message:String = "\t"+ getTimer()+"\t[PROFILER-"+sessionName+"] "+markerName+" ";
         if(message.length < 70) {
            var spacers:uint = 70 - message.length;
            for(var i:uint=0; i < spacers; i++) {
               message += "-";
            }
         }
         message += " (last marker: "+markerToMarkerTime+"ms / session: "+markerSessionTime+"ms)";
         if(_showFrameId) message += " (frame: "+_frameDebugId.frameId+")";
         showMessage(message);
      }
      
      private function showMessage(message:String):void {
         _logger.log(LogEventLevel.INFO, message);
      }
   }
}
import flash.utils.getTimer;

class ProfilerSession {
   private var _name:String;
   private var _startTime:Number;
   private var _lastMarkerTime:Number;
   
   public function ProfilerSession(sessionName:String, startTime:Number=-1) {
      _name = sessionName;
      _startTime = startTime;
      if(_startTime < 0) {
         _startTime = new Date().getTime();
      }
      _lastMarkerTime = _startTime;
   }
   
   public function get name():String {
      return _name;
   }
   
   public function get startTime():Number {
      return _startTime;
   }
   
   public function get lastMarkerTime():Number {
      return _lastMarkerTime;
   }
   public function set lastMarkerTime(value:Number):void {
      _lastMarkerTime = value;
   }   
}