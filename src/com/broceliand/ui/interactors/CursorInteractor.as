package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.mouse.CursorSetterConsts;
   import com.broceliand.ui.mouse.ICursorSetter;
   import com.broceliand.ui.mouse.MouseManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIEndPearl;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getTimer;
   
   public class CursorInteractor implements ICursorSetter
   {
      private var _interactorManager:InteractorManager = null;
      private var _vgraph:IPTVisualGraph = null;
      private var _lastRenderer:Object;
      private var _lastRendererTime:Number;
      
      private var _mouseIsDirectlyOverMap:Boolean = true;
      
      public function CursorInteractor(interactorManager:InteractorManager, pearlTreeViewer:IPearlTreeViewer){
         _interactorManager = interactorManager;
         _vgraph = _interactorManager.pearlTreeViewer.vgraph;
         pearlTreeViewer.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
         pearlTreeViewer.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
         ApplicationManager.getInstance().visualModel.mouseManager.register(this, CursorSetterConsts.MAP);
      }

      private function updaterMouseDirectlyOnMap(event:MouseEvent):void{
         var wc:IWindowController =  ApplicationManager.getInstance().components.windowController;
         if(wc.isPointOverWindow(event.stageX, event.stageY)) {
            _mouseIsDirectlyOverMap = false;
         }else{
            _mouseIsDirectlyOverMap = true;
         }
         
      }
      
      private function onMouseOver(event:MouseEvent):void{
         updaterMouseDirectlyOnMap(event);
      }
      
      private function onMouseOut(event:MouseEvent):void{
         updaterMouseDirectlyOnMap(event);
      }
      
      private function getCursorCorrespondingToPearlRenderer(renderer:IUIPearl, mousePoint:Point):String {
         var cursor:String = MouseManager.CURSOR_TYPE_ARROW;
         if(renderer.isPointOnPearl(mousePoint)) {
            if(_interactorManager.getActive() && (_interactorManager.userHasRightToMoveNode || _interactorManager.userHasRightToCopyNode)) {
               cursor = MouseManager.CURSOR_TYPE_OPEN_HAND;
            }
            else if(renderer.node.isTopRoot) {
               cursor = MouseManager.CURSOR_TYPE_SCROLL;
            }
         }
         return cursor;
      }

      public function getWantedCursor(stageX:Number, stageY:Number, isMouseDown:Boolean, distanceToMouseDown:Number):String{
         if(_interactorManager.actionForbidden && distanceToMouseDown > 2){
            
            return MouseManager.CURSOR_TYPE_FORBIDDEN;
         }
         if(_interactorManager.draggedPearl){
            return MouseManager.CURSOR_TYPE_CLOSED_HAND;
         }
         if(!_mouseIsDirectlyOverMap){
            
            return null;
         }
         
         var renderer:IUIPearl = _interactorManager.pearlRendererUnderCursor;        
         if(_vgraph.backgroundDragInProgress()) {
            return MouseManager.CURSOR_TYPE_SCROLL;
         }
         
         if(renderer is UIEndPearl) {
            return MouseManager.CURSOR_TYPE_ARROW;
         }
         
         var stagePoint:Point = new Point(stageX, stageY);
         if(_vgraph.controls.isVisible()) {
            var isOverControl:Boolean = _vgraph.controls.isPointOverAControl(stagePoint);
            if(isOverControl){
               if(renderer && renderer.node && !renderer.node.isDocked){
                  
                  renderer = null;
               }
               
               var wantedByGraphControl:String = _vgraph.controls.getWantedCursor(stageX, stageY, isMouseDown, distanceToMouseDown);
               if(wantedByGraphControl){
                  return wantedByGraphControl;
               }
            }
         }
         if(renderer) {
            if (renderer != _lastRenderer) {
               _lastRenderer = renderer;
               _lastRendererTime = getTimer();
            } else if (getTimer() - _lastRendererTime > InteractorManager.MIN_TIME_UNDER_CURSOR) {               
               return getCursorCorrespondingToPearlRenderer(renderer, stagePoint);
            }

            return MouseManager.CURSOR_TYPE_ARROW_WITH_UPDATE_REQUESTED; 
         }else{
            return MouseManager.CURSOR_TYPE_ARROW; 
         }  
      }           
   }
}