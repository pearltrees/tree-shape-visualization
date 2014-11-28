package com.broceliand.ui.effects {
   import mx.effects.IEffectInstance;
   import mx.effects.Rotate;
   
   public class StepRotation extends Rotate {
      
      public var angleStep:int = 45;

      public function StepRotation(targetObj:* = null) {
         super(targetObj);
         instanceClass= StepRotationInstance;
      }

      override protected function initInstance(inst:IEffectInstance):void {
         super.initInstance(inst);
         StepRotationInstance(inst).angleStep = angleStep;
      }
   }
}