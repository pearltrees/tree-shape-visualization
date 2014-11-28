package com.broceliand.util
{
   import mx.core.UIComponent;
   import mx.events.FlexEvent;
   
   public class InvokeAfterCreationCompleted
   {
      private var _args:*;
      private var _f:Function;
      private var _thisObject:Object;
      
      static public function performActionAfterCreationCompleted(uiComponent:UIComponent, f:Function, thisObject:Object, ...args:*):void {
         if (!uiComponent.processedDescriptors) {
            new InvokeAfterCreationCompleted(uiComponent, f, thisObject, args);
         } else {
            f.apply(thisObject, args);
         } 
         
      }
      public function InvokeAfterCreationCompleted(uiComponent:UIComponent, f:Function, thisObject:Object, args:*) {
         _args = args;
         _f = f;
         _thisObject = thisObject;
         uiComponent.addEventListener(FlexEvent.CREATION_COMPLETE, invokeOnCreationComplete);
         
      }
      private function invokeOnCreationComplete(event:FlexEvent):void {
         UIComponent(event.target).removeEventListener(FlexEvent.CREATION_COMPLETE, invokeOnCreationComplete);
         
         _f.apply(_thisObject ,_args);
      }
      
   }
}