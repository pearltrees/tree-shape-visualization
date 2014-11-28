package com.broceliand.ui.interactors.scroll
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.WeightEdgeComponent;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.UserInteractionMode;
   import com.broceliand.ui.model.ScrollModel;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.pearlTree.IScrollControl;
   import com.broceliand.ui.pearlTree.ScrollDescriptor;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class ScrollInteractor
   {
      private var _lastScrollCalculationTime:Number = 0; 
      private var _timer:Timer = null;
      private var _scrollBounds:Rectangle = null;
      private var _scrollModel:ScrollModel = null;
      private var _scrollControl:IScrollControl = null;
      private var _interactorManager:InteractorManager = null;
      private var _scrollLimiter:ScrollLimiter = null;
      
      public function ScrollInteractor(interactorManager:InteractorManager){
         _interactorManager = interactorManager;
         _timer = new Timer(0, 0); 
         _timer.addEventListener(TimerEvent.TIMER, doTimer);
         _scrollModel = ApplicationManager.getInstance().visualModel.scrollModel;
         _scrollModel.addEventListener(ScrollModel.SCROLL_STARTED, startScrollInternal);
         _scrollModel.addEventListener(ScrollModel.SCROLL_STOPPED, stopScrollInternal);
         _scrollControl = _interactorManager.pearlTreeViewer.vgraph.controls.scrollControl;
         ApplicationManager.getInstance().addEventListener(ApplicationManager.FOCUS_CHANGE_EVENT, onFocusChange);
      }
      
      protected function doTimer(ev:TimerEvent):void{
         var xDelta:Number = 0;
         var yDelta:Number = 0;
         var timeDiff:Number = (getTimer() - _lastScrollCalculationTime) / 1000; 
         _lastScrollCalculationTime = getTimer();
         if (!_scrollModel.canScroll()) {
            return;
         }
         updateBoundingBox(false);
         _scrollLimiter = new ScrollLimiter(_scrollBounds);
         _scrollLimiter.updateScrollDelta(_scrollModel.scrollDescriptor.xMultiplier * timeDiff, _scrollModel.scrollDescriptor.yMultiplier * timeDiff);
         xDelta = _scrollLimiter.xDelta;
         yDelta = _scrollLimiter.yDelta;
         
         if (xDelta!=0 || yDelta !=0) {
            _interactorManager.pearlTreeViewer.vgraph.scroll(xDelta, yDelta);
            _scrollModel.onScrollContinue();
            _scrollBounds.x += xDelta;
            _scrollBounds.y += yDelta;
            
            if (!WeightEdgeComponent.USE_EDGE_COMPONENT) {     
               _interactorManager.pearlTreeViewer.vgraph.refresh();
            }
            ev.updateAfterEvent();
         }
      }
      
      private function startScrollInternal(ev:Event = null):void{
         updateBoundingBox(true);  
         _lastScrollCalculationTime = getTimer();
         _timer.start();
         
      }
      private function updateBoundingBox(forced:Boolean):void {
         if (forced || !_scrollModel.isBoundingBoxValid()) {
            _scrollBounds = _interactorManager.pearlTreeViewer.vgraph.calcNodesBoundingBox();
            _scrollModel.onBoundingBoxBuilt();
         }
      }
      
      private function stopScrollInternal(ev:Event = null):void{
         _timer.stop();
      }
      public function isScrolling():Boolean {
         return _timer.running;
      }
      
      public function onMouseDown(ev:MouseEvent):void{
         var point:Point = new Point(ev.stageX, ev.stageY);
         var scrollDesc:ScrollDescriptor = _scrollControl.getScrollDescriptor(point,false); 
         if(scrollDesc){
            _scrollModel.scrollDescriptor = scrollDesc;
            _scrollModel.startScroll(ScrollModel.SCROLL_TYPE_MOUSEDOWN);
         }   
      }
      
      public function onMouseMove(mousePosition:Point):void{
         var dragging:Boolean = (_interactorManager.getUserInteractionMode() == UserInteractionMode.UIM_PEARL_EDITING);
         var scrollDesc:ScrollDescriptor = _scrollControl.getScrollDescriptor(mousePosition, dragging); 
         if(scrollDesc){
            _scrollModel.scrollDescriptor = scrollDesc;
            
            if (dragging) {
               _scrollModel.startScroll(ScrollModel.SCROLL_TYPE_DRAGGING);
            }
            else {
               _scrollModel.startScroll(ScrollModel.SCROLL_TYPE_MOUSEUP);
            }
         }
         else {
            _scrollModel.stopScroll();
         }
      }
      
      public function onMouseUp(ev:MouseEvent):void{
         _scrollModel.stopScroll();         
      }
      
      public function onClickOnPearl():void {
         _scrollModel.stopScroll();	
      }
      
      public function onMouseOverComponent():void {
         _scrollModel.stopScroll();
         _scrollControl.scrollUi.visible =false;
      }
      
      public function onMouseLeaveStage(ev:Event):void{
         _scrollModel.stopScroll();
      }
      
      private function onFocusChange(event:Event):void {
         if (!ApplicationManager.getInstance().isApplicationFocused) {
            _scrollModel.stopScroll();
         }
      }

   }
}