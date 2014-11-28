package com.broceliand.ui.highlight.highlighters
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.highlight.HighlightCommands;
   import com.broceliand.ui.highlight.HighlightManager;
   
   public class MultipleHighlighter extends HighlightableBase
   {
      private var _highlightCommands:Array; 
      
      public function MultipleHighlighter(highlightCommand:String, highlightCommands:Array)
      {
         super(highlightCommand);
         ApplicationManager.getInstance().visualModel.highlightManager.registerHighlightableObject(highlightCommand, this);
         _highlightCommands = highlightCommands;
      }
      
      override protected function highlightInternal():void
      {
         var highlightManager:HighlightManager = ApplicationManager.getInstance().visualModel.highlightManager;
         for each(var highlightCommand:String in _highlightCommands){
            highlightManager.highlight(highlightCommand);
         }
      }
      
      override protected function unhighlightInternal():void
      {
         var highlightManager:HighlightManager = ApplicationManager.getInstance().visualModel.highlightManager;
         for each(var highlightCommand:String in _highlightCommands){
            highlightManager.unhighlight(highlightCommand);
         }
      }
      
   }
}