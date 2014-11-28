package com.broceliand.ui.tooltip {
   
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   
   import mx.controls.Label;
   import mx.core.UIComponent;
   
   public class PTEmbedTooltip extends PTTooltip {
      
      public static const POSITION_TOP:String = "top";
      public static const POSITION_BOTTOM:String = "bottom";
      
      private var _background:UIComponent;
      private var _label:Label;
      private var _position:String;
      
      private static const TARGET_PADDING:Number = 4;
      
      public function PTEmbedTooltip(tooltipTarget:UIComponent, position:String=POSITION_TOP)
      {
         super(tooltipTarget);
         _position = position;
      }
      
      override protected function createChildren():void
      {
         _background = new UIComponent();
         addChild(_background);
         
         _label = new Label();
         _label.text = target.toolTip;
         _label.percentWidth = 100;
         _label.setStyle('textAlign', 'center');
         _label.setStyle('fontFamily', 'PTArial');
         _label.setStyle('fontSize', 11);
         _label.setStyle('paddingLeft', 2);
         _label.setStyle('paddingRight', 2);
         _label.setStyle('paddingBottom', -5);
         _label.setStyle('paddingTop', 2);
         _label.setStyle('color', ColorPalette.getInstance().pearltreesDarkColor);
         _label.filters = getLabelFilters();
         addChild(_label);
      }      
      
      private function getLabelFilters():Array{
         var color:Number = ColorPalette.getInstance().backgroundColor;
         var angle:Number = 0;
         var alpha:Number = 1;
         var blurX:Number = 4;
         var blurY:Number = 4;
         var distance:Number = 0;
         var strength:Number = 10;
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
      
      override protected function calculateBasePosition(targetPosition:Point):void {
         if(_position == POSITION_BOTTOM) {
            y = targetPosition.y + target.height + TARGET_PADDING;
            x = targetPosition.x + (target.width / 2.0) - (width / 2.0);            
         }
         else {
            y = targetPosition.y - height - TARGET_PADDING;
            x = targetPosition.x + (target.width / 2.0) - (width / 2.0);
         }
      }
      
      public function get position():String {
         return _position;
      }
      
      public function set position(value:String):void {
         if(value && value != _position) {
            _position = value;
         }
      }
   }
}