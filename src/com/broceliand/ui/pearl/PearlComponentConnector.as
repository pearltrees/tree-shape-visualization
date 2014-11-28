package com.broceliand.ui.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearlTree.PearlComponentAddOn;
   
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   public class PearlComponentConnector
   {
      protected var _componentAddOn:PearlComponentAddOn;
      protected var _mask:UIComponent;
      protected var _componentTemporaryVisible:Boolean = false;
      protected var _pearl:UIPearl;      
      
      public function PearlComponentConnector(pearl:UIPearl, componentAddOn:PearlComponentAddOn) {
         _pearl = pearl;
         _componentAddOn = componentAddOn;
      }
      
      public function createChildren():void {
         _pearl.node.vnode = _pearl.vnode;
         if(_componentAddOn) {
            _componentAddOn.bindToNode(_pearl.node, _pearl.uiComponent);
         }
      }
      public function restoreState():void {
         if (_componentAddOn) {
            _componentAddOn.bindToNode(_pearl.node, _pearl.uiComponent);
         }
      }
      protected function makeMask():void {
         
      } 
      
      public function updateButtonVisibility():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var intercatorManager:InteractorManager = am.components.pearlTreeViewer.interactorManager;
         var isDragged:Boolean = (intercatorManager.hasMouseDragged() && intercatorManager.draggedPearl && intercatorManager.draggedPearl.node == _pearl.node);
         var showComponentAddOn:Boolean = _componentTemporaryVisible && !isDragged && _pearl.visible && _pearl.node;
         setButtonVisible(showComponentAddOn);
      }
      
      protected function setButtonVisible(value:Boolean):void {
         
         if(_componentAddOn) {
            _componentAddOn.visible = _componentAddOn.includeInLayout = value;
         }
         setMaskVisible(value);         
      }
      
      protected function setMaskVisible(value:Boolean):void {
         if(value) {
            if(_mask) {
               _mask.visible = _mask.includeInLayout = true;
               _mask.callLater(makeMask);
            }else{
               makeMask();
               _pearl.uiComponent.addChild(_mask);
            }
         }else if(_mask) {
            _mask.visible = _mask.includeInLayout = false;
         }
      }
      public function setComponentAddOnTemporaryVisible(value:Boolean):void {
         if (_componentTemporaryVisible != value) {
            _componentTemporaryVisible = value;
            updateButtonVisibility();
         }
      }
      
      internal function forceVisibilityValue(value:Boolean):void {
         setButtonVisible(value);
      }
      
      public function isPointOnComponentAddOn(point:Point):Boolean {
         var isMaskVisible:Boolean = (_mask && _mask.visible);
         var isMouseOverMask:Boolean = (_mask && _mask.hitTestPoint(point.x, point.y, true));
         return (isMaskVisible && isMouseOverMask);
      }
      
      public function end():void {
         clearMemory();
      }
      
      protected function clearMemory():void {
         if (_mask && _mask.parent) {
            _pearl.uiComponent.removeChild(_mask);
         }
         if(_componentAddOn) {
            _componentAddOn.end();
            _componentAddOn = null;
         }
         _pearl = null;
         _mask = null;   
      }
   }
}