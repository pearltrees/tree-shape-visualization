package com.broceliand.ui.effects
{
   import com.broceliand.ApplicationManager;
   
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.effects.effectClasses.TweenEffectInstance;
   
   public class ChangePropertyEffectInstance extends TweenEffectInstance {
      
      private var _targetUIComponent:UIComponent;
      private var _target:Object;
      public var fromValue:Number;
      public var toValue:Number;
      private  var _propertyName:String;
      
      public function ChangePropertyEffectInstance(target:Object) {
         super(target);      
         _target = target;
         _targetUIComponent = target as UIComponent;
         if(!_targetUIComponent) {
            _targetUIComponent = new UIComponent();
         }
      }
      
      public function get propertyName():String {
         return _propertyName;
      }
      
      public function set propertyName(value:String):void {
         _propertyName = value;
      }
      
      override public function play():void {
         target = _targetUIComponent;
         super.play();
         target = _target;
         
         if (isNaN(fromValue)) {
            fromValue = target[_propertyName] ;
         }
         
         tween = createTween(this, fromValue, toValue, duration);
         target[_propertyName] = tween.mx_internal::getCurrentValue(0)
      }
      
      override public function finishEffect():void {
         target = _targetUIComponent;
         super.finishEffect();
         target = _target;
      }
      
      override public function onTweenUpdate(value:Object):void {
         target[_propertyName] = value;
         ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.refresh();
      }
   }
   
}