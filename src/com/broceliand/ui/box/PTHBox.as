package com.broceliand.ui.box {
   
   import mx.containers.HBox;
   import mx.core.UIComponent;

   public class PTHBox extends HBox {
      
      private var _dynamicGap:Boolean = false;
      
      public function PTHBox()
      {
         super();
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         
         if(_dynamicGap) {
            refreshDynamicGap();
         }
      }
      
      private function refreshDynamicGap():void {
         var children:Array = getChildren();
         var visibleChildren:Number = 0;
         var childrenWidth:Number = 0;
         var gap:Number = 0;
         for each(var child:UIComponent in children) {
            if(child.includeInLayout) {

               childrenWidth += child.getExplicitOrMeasuredWidth();
               visibleChildren++;
            }
         }
         if(visibleChildren > 1) {
            var availableWidth:Number = width - childrenWidth;
            var gapsNumber:Number = visibleChildren - 1;
            gap = availableWidth / gapsNumber;
         }
         setStyle('horizontalGap', gap);
      }
      
      public function get dynamicGap():Boolean {
         return _dynamicGap;
      }
      public function set dynamicGap(value:Boolean):void {
         _dynamicGap = value;
      }
      
   }
}