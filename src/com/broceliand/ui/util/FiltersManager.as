package com.broceliand.ui.util {
   import com.broceliand.assets.filters.FiltersAssets;
   
   import flash.display.Shader;
   import flash.filters.ShaderFilter;
   import flash.utils.ByteArray;
   
   public class FiltersManager {
      
      public static function getColorizeFilter(color:uint, alpha:Number = 1):ShaderFilter {
         var colorizer:ByteArray = new FiltersAssets.COLORIZE_FILTER();
         var shader:Shader = new Shader(colorizer);
         var components:Array = getComponentsFloats(color);
         shader.data.color.value = [components[0], components[1], components[2], alpha];
         return new ShaderFilter(shader);
      }
      
      private static function getComponentsFloats(color:uint):Array {
         var red:Number = (color >> 16) & 0xff;
         var green:Number = (color >> 8) & 0xff;
         var blue:Number = color & 0xff;
         return [red/0xff, green/0xff, blue/0xff];
      }
   }
}