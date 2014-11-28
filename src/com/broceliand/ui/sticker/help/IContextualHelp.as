package com.broceliand.ui.sticker.help {
   
   import mx.core.IUIComponent;
   import mx.containers.Canvas;

   public interface IContextualHelp extends IUIComponent {

      function show(isGettingStarted:Boolean = true):void;
      function hide(goHomeFirst:Boolean = false):void;
      
   }
}