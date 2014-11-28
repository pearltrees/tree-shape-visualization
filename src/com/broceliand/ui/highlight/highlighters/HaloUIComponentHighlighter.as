package com.broceliand.ui.highlight.highlighters {
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   
   import mx.core.UIComponent;

   public class HaloUIComponentHighlighter extends UIComponentsHighlighter  {
      
      public function HaloUIComponentHighlighter(highlightCommand:String, targetComponents:Array) {
         super(highlightCommand, targetComponents);
      }
      
      override protected function highlightInternal():void{
         
         var haloFilters:Array = getHaloFilters();
         
         for each(var comp:UIComponent in _targetComponents) {
            comp.filters = haloFilters;
            comp.invalidateProperties();
         }
         
      }
      
      override protected function unhighlightInternal():void{
         
         for each(var comp:UIComponent in _targetComponents) {
            comp.filters = null;
            comp.invalidateProperties();
         }
         
      }
      
      private function getHaloFilters():Array{
         var color:Number = ColorPalette.getInstance().pearltreesDarkColor;
         var angle:Number = 0;
         var alpha:Number = 0.8;
         var blurX:Number = 35;
         var blurY:Number = 35;
         var distance:Number = 0;
         var strength:Number = 2;
         var inner:Boolean = false;
         var knockout:Boolean = false;
         var quality:Number = BitmapFilterQuality.MEDIUM;
         var filter:DropShadowFilter = new DropShadowFilter(distance,
            angle,
            color,
            alpha,
            blurX,
            blurY,
            strength,
            quality,
            inner,
            knockout);
         var ret:Array = new Array();
         ret.push(filter);
         return ret;
      }

   }
}