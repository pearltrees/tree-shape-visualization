package com.broceliand.util
{
   import flash.display.Sprite;
   import mx.controls.Alert;
   
   public class Alert
   {
      public static function show(text:String = "", title:String = "",
                                  flags:uint = 0x4 /* Alert.OK */, 
                                  parent:Sprite = null, 
                                  closeHandler:Function = null, 
                                  iconClass:Class = null, 
                                  defaultButtonFlag:uint = 0x4 /* Alert.OK */):mx.controls.Alert
      {
         return mx.controls.Alert.show(text, title, flags, parent, closeHandler, iconClass, defaultButtonFlag);
      }
   }
}