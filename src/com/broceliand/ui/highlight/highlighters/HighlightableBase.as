package com.broceliand.ui.highlight.highlighters
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.highlight.IHighlightable;
   
   import flash.events.EventDispatcher;
   
   public class HighlightableBase extends EventDispatcher implements IHighlightable
   {
      protected var _highlighted:Boolean = false;
      
      public function HighlightableBase(highlightCommand:String=null){
         if(highlightCommand) {
            ApplicationManager.getInstance().visualModel.highlightManager.registerHighlightableObject(highlightCommand, this);
         }
      }
      
      public function highlight():void
      {
         if(!_highlighted){
            highlightInternal();
            _highlighted = true;
         }
      }
      
      public function unhighlight():void
      {
         if(_highlighted){
            unhighlightInternal();
            _highlighted = false;
         }
      }
      
      protected function highlightInternal():void{
         
      }
      
      protected function unhighlightInternal():void{
         
      }
      
   }
}