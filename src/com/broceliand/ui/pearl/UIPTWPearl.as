package com.broceliand.ui.pearl
{
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTWPearl;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.resources.IRemoteResourceManager;
   import com.broceliand.util.resources.ImageFactory;
   
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   
   import mx.controls.Image;
   
   public class UIPTWPearl extends UIRootPearl
   {
      
      public function UIPTWPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager) {
         super(stateManager, remoteResourceManager);
      }
      
      override protected function hasCloseButton():Boolean{ 
         return false;
      }
      override protected function createChildren():void {
         super.createChildren();
      }
      override protected function clearMemory():void {
         super.clearMemory();
      }
      override protected function instanciatePearl():void{
         _pearl = new PTWPearl();
      }
      
      override protected function getHaloFilters():Array{
         if (node && node.getBusinessNode() is BroPTWDistantTreeRefNode && BroPTWDistantTreeRefNode(node.getBusinessNode()).isSearchNode) {
            return getSearchHaloFilters();
         }
         return super.getHaloFilters();
      }
      private function getSearchHaloFilters():Array{
         var color:Number = ColorPalette.getInstance().pearltreesDarkColor;
         var angle:Number = 0;
         var alpha:Number = 0.8;
         var blurX:Number = 35;
         var blurY:Number = 35;
         var distance:Number = 0;
         var strength:Number = 2;
         var inner:Boolean = false;
         var knockout:Boolean = false;
         var quality:Number = BitmapFilterQuality.MEDIUM;
         var filter:DropShadowFilter = new DropShadowFilter(distance,
            angle,
            color,
            alpha,
            blurX,
            blurY,
            strength,
            quality,
            inner,
            knockout);
         var ret:Array = new Array();
         ret.push(filter);
         return ret;
      }
   }
}