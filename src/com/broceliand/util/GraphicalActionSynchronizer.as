package com.broceliand.util
{
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   import mx.core.UIComponent;
   import mx.events.FlexEvent;

   public class GraphicalActionSynchronizer
   {
      private var _action:IAction;
      private var _counterBeforePerformingAction:int= 0;
      
      public function GraphicalActionSynchronizer(action:IAction) {
         _action = action;
      }
      
      public function set action(value:IAction):void {
         _action = value;
      }
      
      public function registerComponentToWaitForEvent(eventDispatcher:IEventDispatcher, eventName:String):void{
         eventDispatcher.addEventListener(eventName, onCreationComplete);
         _counterBeforePerformingAction ++;
         
      }
      public function registerComponentToWaitForCreation(uicomponent:UIComponent):void{
         if (uicomponent.initialized) {
            trace("[GAS] WARNING: component already built");
         }
         registerComponentToWaitForEvent(uicomponent, FlexEvent.CREATION_COMPLETE);

      }
      private function onCreationComplete(event:Event):void{
         _counterBeforePerformingAction--;
         IEventDispatcher(event.target).removeEventListener(event.type, onCreationComplete);
         
         if (_counterBeforePerformingAction==0) {
            _action.performAction();
         }     
      }
      public function performActionAsap():void {
         if (_counterBeforePerformingAction==0) {
            _action.performAction();
         }
         
      }
      public function isWaitingForEvent():Boolean {
         return _counterBeforePerformingAction>0;
      }
   }
}