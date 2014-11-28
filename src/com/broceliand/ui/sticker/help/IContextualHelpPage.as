package com.broceliand.ui.sticker.help
{
   import com.broceliand.ui.highlight.IHighlightable;
   
   import mx.core.UIComponent;
   
   public interface IContextualHelpPage extends IHighlightable
   {
      function getMaskValue():int;
      function getTitle():String;
      function getText():String;
      function getImageUrl():String;
   }
}