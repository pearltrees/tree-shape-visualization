package com.broceliand.ui.effects {
   import mx.effects.effectClasses.RotateInstance;
   
   public class StepRotationInstance extends RotateInstance {
      
      public var angleStep:int;
      
      public function StepRotationInstance(targetObj:*) {
         super(targetObj);
      }

      override public function onTweenUpdate(val:Object):void {
         super.onTweenUpdate(int(Number(val) / angleStep) * angleStep);
      }

      override public function onTweenEnd(val:Object):void {
         super.onTweenEnd(int(Number(val) / angleStep) * angleStep);
      }
   }
}