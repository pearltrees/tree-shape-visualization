package com.broceliand.util
{
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   public class MoveOnValidation extends EventDispatcher implements IMoveOnValidation
   {
      private var _uiComponent:UIComponent;
      private var _targetPoint:Point;
      private var _utilPoint:Point = new Point();
      
      public function MoveOnValidation(component:UIComponent)
      {
         _uiComponent = component;
      }
      
      public function moveOnValidation(x:Number, y:Number) :Boolean{
         var needToMove:Boolean = false;
         _utilPoint.x = x;
         _utilPoint.y = y;
         needToMove = (x!= _uiComponent.x) || (y != _uiComponent.y);
         if (needToMove) {
            if (_targetPoint != null) {
               needToMove = (_targetPoint.x!= x) || (y != _targetPoint.y);
            }
            _targetPoint = _utilPoint;
         }  else {
            _targetPoint = null;
         }
         return needToMove; 
      }
      public function getTargetMove():Point {
         return _targetPoint;
      }
      public function commitMove():Boolean {
         if (_targetPoint) {
            var targetPoint:Point = _targetPoint;
            _targetPoint = null;
            _uiComponent.move(Math.round(targetPoint.x), Math.round(targetPoint.y));
            return true;
         }
         return false;
      }
      public function resetMove():void {
         _targetPoint = null;
      }
      
   }
}