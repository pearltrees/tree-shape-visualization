package com.broceliand.ui.tooltip {
   import com.broceliand.ApplicationManager;
   
   import flash.geom.Point;
   
   import mx.containers.Canvas;
   import mx.core.IToolTip;
   import mx.core.UIComponent;
   import mx.events.ToolTipEvent;

   public class PTTooltip extends Canvas implements IToolTip {
      
      private var _target:UIComponent;
      
      private static const STAGE_PADDING:Number = 2;
      
      public function PTTooltip(tooltipTarget:UIComponent) {
         super();
         target = tooltipTarget;
      }
      
      public function get target():UIComponent {
         return _target;
      }
      
      public function set target(value:UIComponent):void {
         if(value != _target) {
            if (_target != null) {
               _target.removeEventListener(ToolTipEvent.TOOL_TIP_SHOW, onToolTipShow);
            }
            _target = value;
            value.addEventListener(ToolTipEvent.TOOL_TIP_SHOW, onToolTipShow);
         }
      }
      
      protected function calculateBasePosition(targetPosition:Point):void {
         
      }
      
      private function onToolTipShow(event:ToolTipEvent):void {
         var globalTargetPos:Point = _target.localToGlobal(new Point(0,0));
         
         calculateBasePosition(globalTargetPos);
         
         var stageHeight:Number = ApplicationManager.flexApplication.stage.stageHeight;
         var stageWidth:Number = ApplicationManager.flexApplication.stage.stageWidth;
         
         if(y < STAGE_PADDING) y = STAGE_PADDING;
         if((y + height) > stageHeight) y = stageHeight - height - STAGE_PADDING;
         if(x < STAGE_PADDING) x = STAGE_PADDING;
         if((x + width) > stageWidth) x = stageWidth - width - STAGE_PADDING;
      }
      
      public function get text():String {
         return null;
      }
      
      public function set text(value:String):void {
      } 
      
   }
   
}