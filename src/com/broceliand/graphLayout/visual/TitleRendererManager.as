package com.broceliand.graphLayout.visual
{
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.TitleLayer;
   
   import flash.utils.Dictionary;

   public class TitleRendererManager
   {
      private var _titleLayerNotDockedBelow:TitleLayer = null;
      private var _titleLayerNotDockedAbove:TitleLayer = null;
      private var _titleLayerNotDockedTop:TitleLayer = null;
      private var _titleLayerDockedBelow:TitleLayer = null;
      private var _titleLayerDockedAbove:TitleLayer = null;
      private var _pearlRenderer2TitleLayer:Dictionary = null;
      
      public function TitleRendererManager(notDockedBelow:TitleLayer, notDockedAbove:TitleLayer, notDockedTop:TitleLayer, dockedBelow:TitleLayer, dockedAbove:TitleLayer)
      {
         _titleLayerNotDockedBelow = notDockedBelow;
         _titleLayerNotDockedAbove = notDockedAbove;
         _titleLayerNotDockedTop = notDockedTop;
         _titleLayerDockedBelow = dockedBelow;
         _titleLayerDockedAbove = dockedAbove;
         _pearlRenderer2TitleLayer = new Dictionary(true);
      }
      
      public function showNodeTitle(pearlRenderer:IUIPearl, above:Boolean, onTop:Boolean, inDockedSpace:Boolean):void{
         if(pearlRenderer && pearlRenderer.titleRenderer && pearlRenderer.titleRenderer.isMarkedForDestruction){
            trace("title renderer marked for destruction, can't show it " + pearlRenderer.titleRenderer.text);
            return;
         }      
         
         var destTitleLayer:TitleLayer = null;
         if(inDockedSpace){
            if(above){
               destTitleLayer = _titleLayerDockedAbove;
            }else{
               destTitleLayer = _titleLayerDockedBelow;
            }
         }else{
            if(above){
               if (onTop) {
                  destTitleLayer = _titleLayerNotDockedTop;
               }
               else {
                  destTitleLayer = _titleLayerNotDockedAbove;
               }
            }else{
               destTitleLayer = _titleLayerNotDockedBelow;
            }
         }
         
         var currentLayer:TitleLayer = _pearlRenderer2TitleLayer[pearlRenderer]; 
         if(currentLayer == destTitleLayer){
            return;
         }
         if(currentLayer) {
            currentLayer.removeTitle(pearlRenderer);
         }
         
         destTitleLayer.addTitle(pearlRenderer);
         _pearlRenderer2TitleLayer[pearlRenderer] = destTitleLayer;

         if (inDockedSpace) {
            
            inDockedSpace = !pearlRenderer.node.getDock().isDropZone();
         }
         pearlRenderer.titleRenderer.editable = above && !inDockedSpace;         
      }
      
      public function removeTitleRenderer(pearlRenderer:IUIPearl):void {
         var currentLayer:TitleLayer = _pearlRenderer2TitleLayer[pearlRenderer]; 
         if(currentLayer) {
            currentLayer.removeTitle(pearlRenderer);
         }
         delete _pearlRenderer2TitleLayer[pearlRenderer];          
      }
   }
}