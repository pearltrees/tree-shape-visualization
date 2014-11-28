package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.renderers.pageRenderers.EndPearlRenderer;
   import com.broceliand.ui.window.PTWindow;
   import com.broceliand.util.BroceliandMath;
   
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import flash.geom.Point;

   public class ModeSwitcherInteractor
   {
      
      protected var _interactorManager:InteractorManager = null;
      private   var _garp:GraphicalAnimationRequestProcessor;
      
      public function ModeSwitcherInteractor(interactorManager:InteractorManager, garp:GraphicalAnimationRequestProcessor){
         _interactorManager = interactorManager;
         _garp = garp;
      }
      private var _mouseDownPoint:Point = null;
      private var _mouseIsDown:Boolean = false;
      private var _mouseHasDragged:Boolean = false;
      
      public function updateModeOnMouseDown(ev:MouseEvent):void{
         var point:Point = new Point();
         point.x = ev.stageX;
         point.y = ev.stageY;
         _mouseDownPoint = point; 
         _mouseIsDown = true;
         _mouseHasDragged = false;
         updateModeOnMouseEvent(ev, true);
      }
      
      public function hasMouseDragged():Boolean {
         return _mouseHasDragged;
      }	

      private function considerSwitchingToEditingMode(event:MouseEvent):void{
         
         if (_interactorManager.pearlRendererUnderCursor == null){
            return;
         } 
         
         if(!_mouseIsDown){
            return;
         }
         _interactorManager.actionForbidden = false;
         if(_interactorManager.pearlRendererUnderCursor is EndPearlRenderer){
            
            if(!ApplicationManager.getInstance().currentUser.isAnonymous()){
               _interactorManager.actionForbidden = true;
            }
            return;
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(!_mouseIsDown || (am.isEmbed() && am.embedManager.isModeSmall()) || (am.isWhiteMark() && am.currentUser.isAnonymous())){
            return;
         }
         if(!_interactorManager.userClickedOnPearl){
            return;
         }
         var uim:int = _interactorManager.getUserInteractionMode();
         if(uim != UserInteractionMode.UIM_NEUTRAL){
            return;
         }

         if(!_interactorManager.pearlRendererUnderCursor.node.isDocked) {
            if(_interactorManager.pearlTreeViewer.vgraph.controls.isPointOverAControl(_interactorManager.mousePosition)){
               return;
            }
         }
         if(_interactorManager.pearlRendererUnderCursor.canBeMoved() || _interactorManager.pearlRendererUnderCursor.canBeCopied()){
            
            if(!_garp.isBusy) {
               _interactorManager.setUserInteractionMode(UserInteractionMode.UIM_PEARL_EDITING, event);
            }
         }       	
      }
      
      private function updateHasMouseDragged():void {
         if (_mouseIsDown && !_mouseHasDragged) {
            if (BroceliandMath.getDistanceBetweenPoints(_mouseDownPoint, _interactorManager.mousePosition) > GeometricalConstants.MOUSE_MOVE_DISTANCE_BEFORE_DRAG) {
               
               _mouseHasDragged = true;
            }
         }   
      }

      private function updateModeOnMouseEvent(event:MouseEvent, antiLoop:Boolean = false):void {
         if (!event.buttonDown && _mouseIsDown && !antiLoop) {
            updateModeOnMouseDown(event);
         }
         updateHasMouseDragged();
         
         considerSwitchingToEditingMode(event);
      }
      
      public function updateModeOnMouseMove(ev:MouseEvent):void{
         updateModeOnMouseEvent(ev);
      }
      
      public function updateModeOnMouseUp(ev:MouseEvent):void{
         updateHasMouseDragged(); 
         _mouseIsDown = false;
         _interactorManager.setUserInteractionMode(UserInteractionMode.UIM_NEUTRAL, ev);
      }
   }
}