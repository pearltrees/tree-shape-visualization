package com.broceliand.ui.effects
{
   import mx.core.UIComponent;
   import mx.effects.IEffectInstance;
   import mx.effects.Tween;
   import mx.effects.TweenEffect;
   import mx.effects.effectClasses.FadeInstance;
   
   public class ChangePropertyEffect extends TweenEffect
   {
      private var _properties:Array;
      public var fromValue:Number;
      public var toValue:Number;
      
      public function ChangePropertyEffect(target:Object, propertyName:String) {
         super(target);
         _properties = new Array(1);
         _properties[0] = propertyName;
         instanceClass = ChangePropertyEffectInstance;
      }
      
      override public function getAffectedProperties():Array {
         return _properties;
      }
      
      override protected function initInstance(instance:IEffectInstance):void {
         super.initInstance(instance);
         var effectInstance:ChangePropertyEffectInstance= ChangePropertyEffectInstance(instance);
         effectInstance.propertyName = _properties[0];
         
         effectInstance.fromValue = fromValue;
         effectInstance.toValue = toValue ;
      }
   }
   
}

