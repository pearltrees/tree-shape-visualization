package com.broceliand.graphLayout.controller
{
   import com.broceliand.ui.interactors.DisplayPWAtEndOfAnimation;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   import mx.logging.LogEventLevel;
   
   public class GraphicalAnimationRequestProcessor extends EventDispatcher {
      
      public static const END_PROCESSING_ACTION_EVENT:String ="EndProcessingActionEvent";
      public static const NEXT_PROCESSING_ACTION_EVENT:String ="NextProcessingActionEvent";
      
      private static const TRACE_DEBUG:Boolean = false;
      private var _logger:BroLogger;
      private var _requests:Array = new Array();
      private var _currentProcessAction:IAction;
      private var _currentTimout:uint;
      
      public function GraphicalAnimationRequestProcessor() {
         _logger = Log.getLogger("com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor");
      }
      private function onTimeOut():void {
         
         _logger.warn("timeout: current action was {0}", _currentProcessAction);
         _currentProcessAction = null;
         _currentTimout =0;
         processAction();
      }
      public function postActionRequest(action:IAction, timeOutMs:int= 5000):void {
         _logger.log(LogEventLevel.INFO, "POST {0}",action);
         _requests.push(new InternalRequest(action,timeOutMs));
         if (!isBusy) {
            processAction();
         }         
      }
      
      public function insertFirstInQueue(action:IAction, timeOutMs:int= 5000):void {
         _logger.log(LogEventLevel.INFO, "POST FIRST {0}",action);
         _requests.unshift(new InternalRequest(action,timeOutMs));
         if (!isBusy) {
            processAction();
         }         
      }  
      
      public function get isBusy():Boolean {
         return _currentProcessAction !=null;
      }
      private function processAction(lastAction:Boolean = false):void {
         if (_requests.length>0) {
            var ir:InternalRequest = (lastAction?_requests.pop() :_requests.shift()) as InternalRequest;
            _currentProcessAction = ir.actionToPerform;
            if (_logger.isUsed) {
               _logger.log(LogEventLevel.INFO, "PROCESS {0}", _currentProcessAction);
            }
            startTimout(ir.timeOut);
            ir.actionToPerform.performAction();
            dispatchEvent(new Event(NEXT_PROCESSING_ACTION_EVENT));
         } else {
            dispatchEvent(new Event(END_PROCESSING_ACTION_EVENT));
         }
      } 
      public function notifyEndAction(action:IAction):void {
         if (_currentProcessAction == action || action == null) {
            if (_logger.isUsed) {
               _logger.log(LogEventLevel.INFO, " END CURRENT ACTION {0}",action);
            }
            cancelTimeout();
            _currentProcessAction = null;
            processAction();
         }
      }
      private function startTimout(delay:int):void {
         cancelTimeout();
         _currentTimout = setTimeout(onTimeOut, delay);
         
      }
      private function cancelTimeout():void {
         if (_currentTimout) {
            clearTimeout(_currentTimout);
            _currentTimout =0;
         }
      }
      
      public function isPearlWindowOpening():Boolean {
         return (_currentProcessAction is DisplayPWAtEndOfAnimation);
      }
   }
}
import com.broceliand.util.IAction;

class InternalRequest {
   public var actionToPerform:IAction;
   public var timeOut:int;
   public function InternalRequest(a:IAction, timeO:int) {
      actionToPerform =a;
      timeOut = timeO;
   }    
}