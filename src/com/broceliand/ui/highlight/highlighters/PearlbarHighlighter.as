package com.broceliand.ui.highlight.highlighters
{
   import com.broceliand.pearlTree.navigation.impl.Url2Pearlbar;
   import com.broceliand.ui.highlight.HighlightCommands;
   
   public class PearlbarHighlighter extends HighlightableBase
   {
      public function PearlbarHighlighter()
      {
         super(HighlightCommands.PEARL_BAR);
      }
      
      override protected function highlightInternal():void{
         super.highlightInternal();
         Url2Pearlbar.highlightPearlbar();
      }
      
      override protected function unhighlightInternal():void{
         super.unhighlightInternal();
         Url2Pearlbar.unhighlightPearlbar();
      }
      
   }
}