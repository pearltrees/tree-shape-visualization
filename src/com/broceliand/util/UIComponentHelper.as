package com.broceliand.util {
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   
   import mx.core.UIComponent;

   public class UIComponentHelper {
      
      private static var _singleton:UIComponentHelper;
      private var _listenToStageSize:Boolean;
      private var _traceParentsSize:UIComponent;
      
      public function UIComponentHelper()
      {
      }
      
      public static function getInstance():UIComponentHelper {
         if(!_singleton) {
            _singleton = new UIComponentHelper();
         }
         return _singleton;
      }
      
      public function traceParentsSize(comp:UIComponent):void {
         if(!_listenToStageSize) {
            _listenToStageSize = true;
            comp.stage.addEventListener(Event.RENDER, onStageResize);
         }
         _traceParentsSize = comp;
      }
      
      private function onStageResize(event:Event):void {
         if(_traceParentsSize) {
            _traceParentsSize.callLater(traceParentsSizeNow);
         }
      }
      
      private function traceParentsSizeNow():void {
         var parent:DisplayObjectContainer = _traceParentsSize.parent;
         while(parent != null) {
            var result:String = "width: "+parent.width;
            var parentComponent:UIComponent = parent as UIComponent;
            if(parentComponent) {
               result += " minWidth: "+parentComponent.minWidth+
                  " explicit: "+parentComponent.explicitWidth+
                  " percentWidth: "+parentComponent.percentWidth;
            }
            result += " name: "+parent.name;
            trace(result);
            parent = parent.parent;
         }
      }
   }
}