package com.broceliand.ui.interactors.scroll
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   
   import flash.geom.Rectangle;
   
   public class ScrollLimiter
   {
      private var _scrollBounds:Rectangle = null;
      private var _xDelta:Number = 0;
      private var _yDelta:Number = 0;
      
      public function ScrollLimiter(scrollBounds:Rectangle)
      {
         _scrollBounds = scrollBounds;
      }
      
      public function updateScrollDelta(xDelta:Number, yDelta:Number):void {
         var canScrollX:Boolean = false;
         var canScrollY:Boolean = false;
         var b:IPearlTreeViewer = ApplicationManager.getInstance().components.pearlTreeViewer;
         
         _xDelta = xDelta;
         _yDelta = yDelta;
         
         if (_xDelta > 0) { 
            if(b.x + b.width * GeometricalConstants.SCROLLUI_LIMIT_PROPORTION - _scrollBounds.x - _xDelta > 0){
               canScrollX = true;
            }
         }else{
            if(b.x + b.width * GeometricalConstants.SCROLLUI_LIMIT_INVERSE_PROPORTION - _scrollBounds.x  - _xDelta - _scrollBounds.width < 0){
               canScrollX = true;
            }
            
         }
         if (_yDelta > 0) {	
            if(b.y + b.height * GeometricalConstants.SCROLLUI_LIMIT_PROPORTION - _scrollBounds.y - _yDelta> 0){
               canScrollY = true;
            }
         }else{
            if(b.y + b.height * GeometricalConstants.SCROLLUI_LIMIT_INVERSE_PROPORTION - _scrollBounds.y - _yDelta  - _scrollBounds.height < 0){
               canScrollY = true;
            }
            
         }
         
         if (!canScrollX) {
            _xDelta = 0;
         }
         if(!canScrollY) {
            _yDelta = 0;
         }
         _xDelta = Math.round(_xDelta);
         _yDelta = Math.round(_yDelta)
      }
      
      public function set xDelta(x:Number):void {
         _xDelta = x;
      }
      
      public function get xDelta():Number {
         return _xDelta;
      }
      
      public function set yDelta(y:Number):void {
         _yDelta = y;
      }
      
      public function get yDelta():Number {
         return _yDelta;
      }
      
      public function canScroll():Boolean {
         return (_xDelta != 0 || _yDelta != 0)
      }
      
   }
}