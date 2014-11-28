package com.broceliand.ui.pearlTree
{
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.util.Assert;
   
   import mx.core.UIComponent;
   
   public class TitleLayer extends UIComponent
   {
      private static const TRACE_DEBUG:Boolean = false;
      private static const MAX_RECYCLED_TITLES:Number = 150;
      
      private var _titlesContainedAreEditable:Boolean;      
      private var _recycledTitles:Array = new Array();      
      private var _layerName:String; 

      private var _addChildCount:Number = 0;
      private var _removeChildCount:Number = 0;
      
      public function TitleLayer(titlesContainedAreEditable:Boolean, layerName:String = null)
      {
         super();
         _titlesContainedAreEditable = titlesContainedAreEditable;
         _layerName = layerName;
      }
      
      private function storeRecycledTitle(titleRenderer:TitleRenderer):void {
         if(TRACE_DEBUG && titleRenderer.pearlRenderer && titleRenderer.pearlRenderer.node) {
            trace("[TitleLayer] store: "+titleRenderer.text+"("+titleRenderer.name+") pearlRenderer: "+titleRenderer.pearlRenderer.node.getBusinessNode().title+" layer: "+_layerName);
         }
         titleRenderer.recycled = true;
         titleRenderer.pearlRenderer = null;
         titleRenderer.setStyle("backgroundAlpha", 0);
         titleRenderer.visible = titleRenderer.includeInLayout = false;
         _recycledTitles.push(titleRenderer);
         
      }
      
      private function getRecycledTitle():TitleRenderer {
         if(_recycledTitles.length == 0) return null;
         var titleRenderer:TitleRenderer = _recycledTitles.pop();
         titleRenderer.recycled=false;
         if(TRACE_DEBUG && titleRenderer.pearlRenderer && titleRenderer.pearlRenderer.node) {
            trace("[TitleLayer] get: "+titleRenderer.text+"("+titleRenderer.name+") pearlRenderer: "+titleRenderer.pearlRenderer.node.getBusinessNode().title+" layer: "+_layerName);
         }
         Assert.assert(!titleRenderer.includeInLayout, "Recycled title is already in layout");
         return titleRenderer;
      }      
      
      public function addTitle(pearlRenderer:IUIPearl):void {                 
         var freeTitleInLayer:TitleRenderer = getRecycledTitle();
         if(!freeTitleInLayer) {
            freeTitleInLayer = new TitleRenderer(pearlRenderer);
            addChild(freeTitleInLayer);
            
            if(TRACE_DEBUG) {
               _addChildCount++;
            }         
         }
         if(pearlRenderer.titleRenderer) {
            freeTitleInLayer.initFromTitleRenderer(pearlRenderer.titleRenderer);
         }
         freeTitleInLayer.pearlRenderer = pearlRenderer;
         pearlRenderer.titleRenderer = freeTitleInLayer;
         freeTitleInLayer.visible = true;
         freeTitleInLayer.includeInLayout = false;
         
      }
      
      public function removeTitle(pearlRenderer:IUIPearl):void {
         var titleRenderer:TitleRenderer = pearlRenderer.titleRenderer;
         if(!titleRenderer) return;
         
         if(_recycledTitles.length < MAX_RECYCLED_TITLES) {
            storeRecycledTitle(titleRenderer);
         }
         else{
            removeChild(titleRenderer);
            titleRenderer.end();
            
            if(TRACE_DEBUG) {
               _removeChildCount++;
            }      
         }        
      }
      
      public function refresh():void{
         for(var i:int = numChildren;i-->0;){
            var renderer:TitleRenderer = getChildAt(i) as TitleRenderer;
            if(renderer && renderer.includeInLayout){
               renderer.reposition();
            }
         }
      }
      
      public function get titlesContainedAreEditable():Boolean {
         return _titlesContainedAreEditable;
      }
      
   }
}