package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
   import com.broceliand.pearlTree.model.premium.PremiumRightManager;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   import mx.rpc.events.FaultEvent;
   
   public class UserGaugeModel extends EventDispatcher implements IAmfRetArrayCallback
   {
      private static const MEGABYTE:int = 1024;
      private static const GIGABYGE:int = 1024 * MEGABYTE;
      public static const GAUGE_CHANGED_EVENT:String = "GaugeChanged";
      private static const GAUGE_END_LOADED_EVENT:String = "GaugeLoaded";
      private var _currentGauge:Number;
      private var _maxGauge:Number;
      private var _isUpdating:Boolean;
      private var _needUpdate:Boolean;
      private var _userId:Number;
      private var _lastTryIsError:Boolean = false;
      private var _lastUpdateTime:uint;
      private var _timeoutId:uint;
      
      public function UserGaugeModel()
      {
         _currentGauge = _maxGauge = 0;
         _needUpdate = false;
      }

      public function get maxGauge():Number
      {
         return _maxGauge;
      }
      
      public function get currentGauge():Number
      {
         return _currentGauge;
      }
      
      public function setUserId(userId:Number):void {
         _userId = userId;
         ApplicationManager.getInstance().premiumRightManager.addEventListener(PremiumRightManager.PREMIUM_RIGHTS_EVENT, onPremiumChanged);  
         _needUpdate = true;
      }
      
      private function updateGauge(currentGauge:Number, maxGauge:Number):void {
         _needUpdate = false;
         if (_currentGauge != currentGauge || maxGauge != _maxGauge) {
            _currentGauge = currentGauge;
            _maxGauge = maxGauge;
            dispatchEvent(new Event(GAUGE_CHANGED_EVENT));
         }
      }
      
      public function onReturnValue(value:Array):void {
         updateGauge(value[0], value[1]);
         onLoadingEnd();
      }
      
      private function onLoadingEnd():void {
         _isUpdating = false;
         clearUpdateTimeout();
         dispatchEvent(new Event(GAUGE_END_LOADED_EVENT));
      }
      
      public function onError(message:FaultEvent):void {
         clearUpdateTimeout();
         _lastTryIsError = true;
         Log.getClassLogger(this).error("fail loading gauge : {0}", message);
         onLoadingEnd();
      }
      
      private function requestUpdate():void {
         if (!_isUpdating) {
            _isUpdating = true;
            _lastUpdateTime = getTimer();
            scheduleUpdateTimeout();
            ApplicationManager.getInstance().distantServices.amfTreeService.getGauge(_userId, this);
            
         }
      }
      
      private function scheduleUpdateTimeout():void {
         clearUpdateTimeout();   
         _timeoutId = setTimeout(onUpdateTimeOut, 1000);
      }
      
      private function onUpdateTimeOut():void {
         clearUpdateTimeout();
         onError(null);
      }

      private function clearUpdateTimeout():void {
         if (_timeoutId > 0) {
            clearTimeout(_timeoutId);
            _timeoutId = 0;
         }       
      }
      public function isLoaded():Boolean {
         return _maxGauge != 0;
      }
      
      public function invalidGauge():void {
         _needUpdate = true;
      }
      
      public function updateIfNeeded():Boolean {
         if (_needUpdate) {
            requestUpdate();
            return true;
         }
         return false;
      }
      
      public function isOverMax():Boolean {
         if (_maxGauge != 0) {
            return _currentGauge >= _maxGauge;
         }
         return false;
      }
      
      public function performActionIfNotOverMax(actionOK:IAction, actionFail:IAction, showCursor:Boolean = false):void {
         if (!_needUpdate || _lastTryIsError) {
            _lastTryIsError = false;
            if (isOverMax()) {
               actionFail.performAction();
            } else {
               actionOK.performAction();
            }
         } else {
            var ga:GenericAction = new GenericAction(null, this, performActionIfNotOverMax, actionOK, actionFail, showCursor);
            addEventListener(GAUGE_END_LOADED_EVENT, ga.performActionOnFirstEvent);
            requestUpdate();
         }
      }
      
      public function onPearlCreated(pearlType:int):void {
         invalidGauge();
      }
      
      public function onDocumentCreated(docSizeInKB:int):void {
         if (!_needUpdate) {
            _currentGauge += docSizeInKB;
         }
         if (isOldData()) {
            invalidGauge();
         }
      }
      
      private function isOldData():Boolean {
         if (getTimer() - _lastUpdateTime > 60 * 1000 * 5) {
            return true;
         }
         return false;
      }

      public function onPearlDeleted(bnode:BroPTNode):void {
         invalidGauge();
      }
      
      private function onPremiumChanged(event:Event):void {
         invalidGauge();
      }
      
      public function onCopyPearl(bnode:BroPTNode):void {
         invalidGauge();  
      }
      
   }
}