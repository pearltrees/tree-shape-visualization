package com.broceliand.ui.highlight.highlighters
{
   import mx.controls.Image;
   import mx.core.UIComponent;
   
   public class ButtonsHighlighter extends UIComponentsHighlighter
   {
      protected var _addedImages:Array = null;
      public function ButtonsHighlighter(highlightCommand:String, targetComponents:Array)
      {
         super(highlightCommand, targetComponents);
      }
      
      override protected function highlightInternal():void{
         _addedImages = new Array();
         for each(var comp:UIComponent in _targetComponents){
            var image:Image = new Image();
            image.source = comp.getStyle("overSkin");
            image.setActualSize(comp.width, comp.height);
            _addedImages.push(image);
            
         } 
         comp.addChild(image);
         
      }
      
      override protected function unhighlightInternal():void{
         for each(var image:Image in _addedImages){
            if(image.parent){
               image.parent.removeChild(image);
            }
         }
         _addedImages = null;
      }
      
   }
}