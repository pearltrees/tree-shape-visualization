package com.broceliand.ui.mouse
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.CursorAssets;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.BroUtilFunction;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.logging.Log;
   
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   import mx.core.Application;
   import mx.events.FlexEvent;
   import mx.managers.CursorManager;
   import mx.managers.CursorManagerPriority;

   public class MouseManager
   {

      public static const CURSOR_TYPE_NONE:String = "none";
      
      public static const CURSOR_TYPE_ARROW:String = "arrow";
      public static const CURSOR_TYPE_ARROW_WITH_UPDATE_REQUESTED:String = "arrowWithUpdate";
      public static const CURSOR_TYPE_OPEN_HAND:String = "openHand";
      public static const CURSOR_TYPE_CLOSED_HAND:String = "closedHand";
      public static const CURSOR_TYPE_FORBIDDEN:String = "forbidden";
      public static const CURSOR_TYPE_SCROLL:String = "scroll";
      public static const CURSOR_TYPE_BUSY:String = "busy";
      
      static private var _cursorId:int; 
      private var _cursorManagementDisabled:Boolean= true;
      private var _cursorType:String = null;
      private var _showBusy:Boolean= false;
      private var _isCurrentlyDisplayingBusyCursor:Boolean = false;
      private var _mouseDown:Boolean = false;
      private var _distanceToMouseDownLocation:Number = 0;
      private var _mouseDownPoint:Point = null;
      
      private var _setters:Array;
      private var _setters2Priority:Dictionary;
      private var _updateScheduled:Boolean;
      private var _mouseOnStage:Boolean = false;
      private var _requestUpdateTimer:Timer= null;
      private static const TRACE_DEBUG:Boolean = false;      
      public function MouseManager(browserName:String, os:String)
      {
         if (os == ApplicationManager.OS_NAME_LINUX) {
            _cursorManagementDisabled = true;
         } else {
            if (os == ApplicationManager.OS_NAME_MAC && browserName == ApplicationManager.BROWSER_NAME_CHROME) {
               _cursorManagementDisabled = true;
            }  else if (os == ApplicationManager.OS_NAME_MAC && browserName == ApplicationManager.BROWSER_NAME_FIREFOX && parseInt(ApplicationManager.getInstance().getBrowserVersion())>=4) {
               _cursorManagementDisabled = true;
            }  else if (ApplicationManager.getInstance().isEmbed()){
               _cursorManagementDisabled = true;
            } else if (browserName == ApplicationManager.BROWSER_NAME_SAFARI &&  parseFloat(ApplicationManager.getInstance().getBrowserVersion())>5 ) {
               _cursorManagementDisabled = true;
            } else
            {
               _cursorManagementDisabled = false;
            }
         }
         _cursorType = CURSOR_TYPE_ARROW;
         _setters = new Array();
         _setters2Priority = new Dictionary();
         ApplicationManager.flexApplication.addEventListener(FlexEvent.APPLICATION_COMPLETE, onAppComplete);
      }
      
      private function onAppComplete(event:Event):void{
         if (!_cursorManagementDisabled) {
            setupUpdateOnMouseEvents();
         }
      }
      
      private function setupUpdateOnMouseEvents():void{
         var stage:Stage = ApplicationManager.flexApplication.stage;
         stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
         stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
         stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
         stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
      }
      private function onMouseLeave(event:Event):void {
         _mouseOnStage=false;
         
      }      
      
      private function updateDistanceToMouseDownLocation(event:MouseEvent):void{
         if(_mouseDownPoint){
            _distanceToMouseDownLocation = BroceliandMath.getDistanceBetweenPoints(new Point(event.stageX, event.stageY), _mouseDownPoint);
         }else{
            _distanceToMouseDownLocation = 0;
         } 
      }
      private function onMouseDown(event:MouseEvent):void{
         _mouseDown = true;       
         _mouseDownPoint = new Point(event.stageX, event.stageY);
         
         updateDistanceToMouseDownLocation(event); 
         update();  
      }
      
      private function onMouseUp(event:MouseEvent):void{
         _mouseDown = false;         
         _mouseDownPoint = null;
         updateDistanceToMouseDownLocation(event); 
         update();  
      }
      
      private function onMouseMove(event:MouseEvent):void {
         _mouseOnStage=true;
         updateDistanceToMouseDownLocation(event); 
         update();  
      }
      
      public function get mouseDown():Boolean {
         return _mouseDown;
      }
      
      public function getCursorType():String{
         return _cursorType;
      }
      
      public function showBusy(value:Boolean):void {
         if (_cursorManagementDisabled) {
            if(_showBusy != value) {
               _showBusy = value;
               var am:ApplicationManager = ApplicationManager.getInstance();
               if (_showBusy && systemCanShowBusyCursor()) {
                  cursorManagerSetBusyCursor();
                  if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("setBusyCursor!");
               } else {
                  cursorManagerRemoveBusyCursor();
                  if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("removeBusyCursor!");
               }
            }
         } else {
            _showBusy = value;
            if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("show Busy Value change:{0}",_showBusy );
            if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("@:{0}", BroUtilFunction.getLimitedStackTrace(new Error()));
            update();
         }
      }

      private function updateCursor():void {
         if (_cursorManagementDisabled) {
            return;
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (_cursorType == CURSOR_TYPE_BUSY && systemCanShowBusyCursor()) {
            cursorManagerSetBusyCursor();
         } else {
            switch(_cursorType){
               case CURSOR_TYPE_ARROW:

                  break;
               case CURSOR_TYPE_ARROW_WITH_UPDATE_REQUESTED:
                  break;
               case CURSOR_TYPE_OPEN_HAND:
                  _cursorId = CursorManager.setCursor(AssetsManager.getEmbededAsset(CursorAssets.HAND_OPEN), CursorManagerPriority.HIGH);
                  break;
               case CURSOR_TYPE_CLOSED_HAND:
                  _cursorId = CursorManager.setCursor(AssetsManager.getEmbededAsset(CursorAssets.HAND_CLOSED), CursorManagerPriority.HIGH);
                  break;
               case CURSOR_TYPE_FORBIDDEN:
                  _cursorId = CursorManager.setCursor(AssetsManager.getEmbededAsset(CursorAssets.FORBIDDEN), CursorManagerPriority.HIGH);
                  break;
               case CURSOR_TYPE_SCROLL:
                  _cursorId = CursorManager.setCursor(AssetsManager.getEmbededAsset(CursorAssets.SCROLL), CursorManagerPriority.HIGH, -15, -15);
                  break;
            }
         }
      }
      
      private function systemCanShowBusyCursor():Boolean {
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if(am.isEmbedWindowMode()) {
            return false;
         }
            
         else if(am.getOS() == ApplicationManager.OS_NAME_MAC && am.getOSVersion().indexOf("10.7") == 0) {
            return false;
         }
         else{
            return true;
         }
      }
      
      private function removeCurrentStateOnStateChange(isBusy:Boolean):void {
         cursorManagerRemoveBusyCursor();
         if (!isBusy ||_cursorManagementDisabled) {
            CursorManager.removeCursor(_cursorId);
         }
      } 

      private function updateInternal(event:Event = null):void {        
         if (_cursorManagementDisabled) return;
         _updateScheduled = false;
         var stageX:Number = ApplicationManager.flexApplication.mouseX;
         var stageY:Number = ApplicationManager.flexApplication.mouseY;
         var stageWidth:Number = ApplicationManager.flexApplication.width;
         var stageHeight:Number = ApplicationManager.flexApplication.height;
         var wantedCursor:String = null;
         
         if((stageX <= 0) || (stageY <= 0) || (stageX > stageWidth) || (stageY > stageHeight)){
            wantedCursor = CURSOR_TYPE_NONE;
         }else if(_showBusy){
            wantedCursor = CURSOR_TYPE_BUSY;
         } else{
            var len:int = _setters.length;            
            for(var i:int = 0; i < len; i++){
               var setter:ICursorSetter = _setters[i];
               wantedCursor = setter.getWantedCursor(stageX, stageY, _mouseDown, _distanceToMouseDownLocation); 
               if(wantedCursor){
                  break;
               }
            }           
         } 
         
         if(!wantedCursor){
            wantedCursor = CURSOR_TYPE_ARROW;
         }
         if (wantedCursor == CURSOR_TYPE_ARROW_WITH_UPDATE_REQUESTED) {
            requestUpdateLater();
         }           
         
         if(_cursorType != wantedCursor){
            if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("Updated cursor changes old {0} new {1}", _cursorType, wantedCursor);
            removeCurrentStateOnStateChange(_cursorType == CURSOR_TYPE_BUSY);
            _cursorType = wantedCursor;            
            updateCursor();               
         }      
      }
      public function update():void{
         if(!_updateScheduled && !_cursorManagementDisabled) {
            ApplicationManager.flexApplication.callLater(updateInternal);
            _updateScheduled = true;
         } 
      }
      
      private function sortOnSetterPriority(a:ICursorSetter, b:ICursorSetter):Number{
         var pa:int = _setters2Priority[a];
         var pb:int = _setters2Priority[b];      
         if(pa > pb) {
            return 1;
         } else if(pa < pb) {
            return -1;
         } else  {
            return 0;
         }
         
      }
      public function register(setter:ICursorSetter, priority:int):void{
         _setters2Priority[setter] = priority;
         _setters.push(setter);
         _setters.sort(sortOnSetterPriority);
         update();
      }
      public function requestUpdateLater():void { 
         if (_requestUpdateTimer == null) {
            _requestUpdateTimer = new Timer(InteractorManager.MIN_TIME_UNDER_CURSOR, 1);
            _requestUpdateTimer.addEventListener(TimerEvent.TIMER, updateInternal);
         }
         if (!_requestUpdateTimer.running) {
            _requestUpdateTimer.reset();
            _requestUpdateTimer.start();
         }
      }
      
      private function showMouse():void {
         
         Mouse.show();
      }
      public function showMouseOnRightClick():void {
         showMouse();
      }
      private function cursorManagerSetBusyCursor():void {
         if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("Setting BusyCursor old State {0}", _isCurrentlyDisplayingBusyCursor);
         if (!_isCurrentlyDisplayingBusyCursor) {
            _isCurrentlyDisplayingBusyCursor = true;
            CursorManager.setBusyCursor();
         }
      }
      private function cursorManagerRemoveBusyCursor():void {
         if (TRACE_DEBUG) Log.getLogger("com.broceliand.ui.mouse.MouseManager").info("Remove BusyCursor old State {0}", _isCurrentlyDisplayingBusyCursor);
         if (_isCurrentlyDisplayingBusyCursor) {
            _isCurrentlyDisplayingBusyCursor = false;
            CursorManager.removeBusyCursor();
         }
      }
      
   }
}