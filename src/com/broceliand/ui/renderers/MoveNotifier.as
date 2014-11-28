package com.broceliand.ui.renderers
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IScrollable;
   import com.broceliand.ui.pearl.UIPearl;
   
   import flash.events.Event;
   
   import mx.core.UIComponent;
   import mx.events.MoveEvent;
   import mx.events.ResizeEvent;
   
   public class MoveNotifier
   {
      public static const FORCE_REPOSITION_NOW_EVENT:String = "forceRepositionEvent";
      private var _listeners:Array= new Array();
      private var _vgraph:IPTVisualGraph;
      private var _uicomponent:UIComponent;
      
      private var _lastX:Number;
      private var _lastY:Number;
      private var _lastAlpha:Number;
      private var _lastWidth:Number;

      public function MoveNotifier(uiComponent:UIComponent=null)
      {
         if (uiComponent) {
            uiComponent.addEventListener(MoveEvent.MOVE, afterMove,false,0,true);
            uiComponent.addEventListener(ResizeEvent.RESIZE, afterMove,false,0,true);
            uiComponent.addEventListener("alpha", onAlphaChange);
            uiComponent.addEventListener(UIPearl.WILL_MOVE_EVENT, willMove);
            uiComponent.addEventListener(FORCE_REPOSITION_NOW_EVENT, reposition);
            
         }
         _vgraph = ApplicationManager.getInstance().components.pearlTreeViewer.vgraph; 
      }
      public function end():void {

         _listeners = new Array();
      }
      public function addMoveListener(update:IRepositionable):void {
         _listeners.push(update);
      }
      public function removeMoveListener(update:IRepositionable):void {
         var index:Number = _listeners.lastIndexOf(update);
         if (index>=0) {
            _listeners.splice(index,1);
         }
      }
      public function willMove(event:Event=null):void {
         if(hasChanged()) {
            reposition();
         }
      }
      private function reposition(event:Event= null):void {
         for each (var l:IRepositionable in _listeners) {
            l.reposition();
         }
      }
      public function afterMove(event:Event=null):void {
         if (hasChanged()) {
            if (!_vgraph.isSilentReposition()) {
               reposition();
            } 

         }
      }
      public function onAlphaChange(event:Event=null):void {
         if(hasChanged()) {
            afterMove();
         }
      }
      private function hasChanged():Boolean {
         var hasChanged:Boolean = false;
         if( _uicomponent) {
            if (_lastX != _uicomponent.x) {
               hasChanged = true;
               _lastX != _uicomponent.x;
            }
            if (_lastY != _uicomponent.y) {
               hasChanged = true;
               _lastY != _uicomponent.y;
            }
            if (_lastAlpha != _uicomponent.alpha) {
               hasChanged = true;
               _lastAlpha != _uicomponent.alpha;
            }
            if (_lastWidth != _uicomponent.width) {
               hasChanged = true;
               _lastWidth != _uicomponent.width;
            }
         } else {
            hasChanged = true;
         }
         return hasChanged;
      }

   }
}