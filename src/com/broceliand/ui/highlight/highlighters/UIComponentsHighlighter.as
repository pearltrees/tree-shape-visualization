package com.broceliand.ui.highlight.highlighters
{
   import mx.core.UIComponent;
   
   public class UIComponentsHighlighter extends HighlightableBase
   {
      protected var _targetComponents:Array;
      
      public function UIComponentsHighlighter(highlightCommand:String, targetComponents:Array)
      {
         super(highlightCommand);
         _targetComponents = targetComponents;
      }
   }
}