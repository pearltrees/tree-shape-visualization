package com.broceliand.util
{
   import flash.display.DisplayObject;
   
   import mx.core.Application;
   
   public class PTComponentUtil
   {    
      public static function isComponentVisible(c:DisplayObject):Boolean {
         if (c == null) return false;
         if (c is Application) return c.visible;
         return c.visible && isComponentVisible(c.parent);
      }
      public static function isComponentOnScreen(c:DisplayObject):Boolean {
         if (c == null) return false;
         if (c.x < 0 || c.x + c.width > c.stage.stageWidth) return false;
         if (c.y < 0 || c.y + c.height > c.stage.stageHeight) return false;
         return true;
      }
   }
}