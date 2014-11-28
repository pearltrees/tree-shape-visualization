package com.broceliand.util
{
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.setTimeout;
   
   public class GenericAction implements IAction
   {
      private var _thisObj:Object;
      private var _f:Function;
      private var _args:Array;
      private var _animationProcessor:GraphicalAnimationRequestProcessor;
      
      public function GenericAction(animationProcessor:GraphicalAnimationRequestProcessor, thisObject:Object, f:Function, ...args:*):void {
         _thisObj = thisObject;
         _f = f;
         _args = args;
         _animationProcessor = animationProcessor;
      }
      
      public static function actionWithFunctionAndArgs(thisObject:Object, f:Function, args:Array):GenericAction {
         var ga:GenericAction = new GenericAction(null, thisObject, f);
         ga._args = args;
         return ga;
      }
      
      public function performAction():void {
         if (null != _f) {
            _f.apply(_thisObj, _args);
         }
         if (_animationProcessor) {
            _animationProcessor.notifyEndAction(this);
         }
      }
      
      public function performActionOnFirstEvent(event:Event):void {
         removeListener(event, performActionOnFirstEvent);
         performAction();
      }
      
      public function addInQueue():void {
         if (_animationProcessor) {
            _animationProcessor.postActionRequest(this);
         }
      }
      public static function removeListener(event:Event, f:Function):void {
         if (event && event.target is EventDispatcher) {
            EventDispatcher(event.target).removeEventListener(event.type, f);
         }
      }
   }
}