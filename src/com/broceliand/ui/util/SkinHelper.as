package com.broceliand.ui.util
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.filters.BitmapFilter;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   import mx.core.UIComponent;
   import mx.utils.NameUtil;
   
   public class SkinHelper
   {
      public static function getBoxDropShadow(isEnabled:Boolean=true, distance:Number = 0,knockout:Boolean=false, blur:Number = 18):BitmapFilter {
         var shadow:DropShadowFilter = new DropShadowFilter();
         if(isEnabled) {
            shadow.color = ColorPalette.getInstance().pearltreesColor;
         }else{
            shadow.color = 0xCCCCCC;
         }
         
         shadow.angle = 133;
         shadow.distance = distance;

         shadow.blurX = blur;
         shadow.blurY = blur;
         shadow.strength = 2;
         shadow.inner=false;
         shadow.knockout = knockout;

         shadow.alpha = 0.24;
         return shadow;         
      }
      
      public static function getDropShadowFilter(color:int=-1,angle:Number=0,knockout:Boolean=false, inner:Boolean = false):BitmapFilter {
         if(color == -1) {
            color = ColorPalette.getInstance().backgroundColor;
         }
         var alpha:Number = 0.24;
         var blurX:Number = 0;
         var blurY:Number = 10;
         var distance:Number = 0;
         var strength:Number = 2;
         var quality:Number = BitmapFilterQuality.MEDIUM;
         var filter:DropShadowFilter = new DropShadowFilter(distance,angle,color,alpha,blurX,blurY,strength,quality,inner,knockout);
         return filter;
      }
      
      public static function getPTButtonTextFilter(color:int=-1,blurX:Number=3,blurY:Number=3,knockout:Boolean=false):BitmapFilter { 
         if(color == -1) {
            color = 0x000000;
         }
         var filter:DropShadowFilter = new DropShadowFilter(1,90,0x000000,0.5,2,2);
         
         return filter;
      }
      
      public static function viewMessageFilter():Array{
         var color:Number = ColorPalette.getInstance().backgroundColor;
         var angle:Number = 0;
         var alpha:Number = 1;
         var blurX:Number = 2;
         var blurY:Number = 2;
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
      
      public static function createOnePixelGrid(background:UIComponent,color:uint=0xFFC2C2C2, motifSize:int=3):void { 
         var repeatedItem:BitmapData = new BitmapData(motifSize,motifSize,true,0xFFFFFF);
         var bg:Graphics = background.graphics;
         
         repeatedItem.setPixel32(0,0,color);
         bg.clear();
         bg.beginBitmapFill(repeatedItem,new Matrix());
         bg.drawRect(0,0,background.width,background.height);
         bg.endFill();
      }
   }
}