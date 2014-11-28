package com.broceliand.ui.model
{
   import com.broceliand.ui.pearlTree.ScrollDescriptor;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.ui.interactors.scroll.ScrollLimiter;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   public class ScrollModel  extends EventDispatcher
   {
      static public var SCROLL_STARTED:String = "SCROLL_STARTED";
      static public var SCROLL_STOPPED:String = "SCROLL_STOPPED";
      static public var SCROLL_CONTINUE:String = "SCROLL_CONTINUE";
      static public var SCROLL_TYPE_MOUSEDOWN:int = 0;
      static public var SCROLL_TYPE_MOUSEUP:int = 1;
      static public var SCROLL_TYPE_DRAGGING:int = 2;
      private static var _DELAY_BEFORE_MOUSEUP_SCROLL:Number = 350;
      
      private var _scrollDescriptor:ScrollDescriptor;
      private var _isScrolling:Boolean;
      private var _startScrollTime:Number;
      private var _scrollType:int;
      private var _isBoundingBoxValid:Boolean;
      private var _vetoOnScrollEnd:int;

      public function ScrollModel()
      {
         _vetoOnScrollEnd = -1;
      }
      
      public function startScroll(scrollTypeValue:int):void{
         if (isVetoOnScrollPeriod()) {
            return;
         }
         _scrollType = scrollTypeValue;
         if(!_isScrolling){
            _isScrolling = true;
            _startScrollTime = getTimer();
            dispatchEvent(new Event(SCROLL_STARTED));
         }
      }
      
      public function isVetoOnScrollPeriod():Boolean {
         if (_vetoOnScrollEnd > 0 && getTimer() < _vetoOnScrollEnd) {
            return true;
         } else {
            _vetoOnScrollEnd = -1;
         }
         return false;
      } 
      public function vetoOnScrollForAPeriod(timeInMs:int):void {
         _vetoOnScrollEnd = getTimer() + timeInMs;
      }
      
      public function stopScroll():void{
         if(_isScrolling){
            _isScrolling = false;
            _startScrollTime = 0;
            dispatchEvent(new Event(SCROLL_STOPPED));
         }
      }
      
      public function get scrollDescriptor():ScrollDescriptor {
         return _scrollDescriptor;
      }
      
      public function set scrollDescriptor(value:ScrollDescriptor):void {
         _scrollDescriptor = value;
      }
      
      public function canScroll():Boolean {
         if (isVetoOnScrollPeriod()) {
            return false;
         }
         if ((_scrollType == SCROLL_TYPE_MOUSEUP) && (getTimer() - _startScrollTime) < _DELAY_BEFORE_MOUSEUP_SCROLL) {
            return false;
         }
         return true;
      }
      
      public function onScrollContinue():void {
         dispatchEvent(new Event(SCROLL_CONTINUE));
      }
      public function invalidateBoundingBox():void {
         _isBoundingBoxValid = false;
      }
      public function isBoundingBoxValid():Boolean {
         return _isBoundingBoxValid;
      }
      public function onBoundingBoxBuilt():void {
         _isBoundingBoxValid = false;
      }
      
      public function handleTrackpadDrag(cumDeltaX:Number, cumDeltaY:Number, steps:Number, vgraph:IPTVisualGraph ):void {
         var scrollBounds:Rectangle = vgraph.calcNodesBoundingBox();
         var scrollLimiter:ScrollLimiter = new ScrollLimiter(scrollBounds);
         scrollLimiter.updateScrollDelta(cumDeltaX, cumDeltaY);
         if (scrollLimiter.canScroll()) {
            startScroll(ScrollModel.SCROLL_TYPE_DRAGGING);
            onScrollContinue();
            vgraph.scroll(scrollLimiter.xDelta,scrollLimiter.yDelta);
            vgraph.refresh();
            stopScroll();
         }   
      }
      
   }
}