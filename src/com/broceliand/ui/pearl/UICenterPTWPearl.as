package com.broceliand.ui.pearl
{
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.renderers.pageRenderers.PTCenterPTWPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTWPearl;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   
   public class UICenterPTWPearl extends PTCenterPTWPearlRenderer 
   {
      private static const DEFAULT_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_NORMAL;
      private static const MAX_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_EXCITED;
      
      private var _showHaloButton:Boolean;
      private var _haloButtonFilters:Array;
      
      public function UICenterPTWPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager)
      {
         super(stateManager, remoteResourceManager);
      }
      
      override protected function get pearlDefaultWidth():Number {
         return DEFAULT_PEARL_WIDTH;
      } 
      override public function get pearlMaxWidth():Number {
         return MAX_PEARL_WIDTH;
      }
      override protected function instanciatePearl():void{
         _pearl = new PTWPearl();
      }
      
      override public function setShowHalo(value:Boolean):void {
         super.setShowHalo(true);
         if (value) {
            setShowHaloOnButton(true);
         } else {
            setShowHaloOnButton(false);
         }
      }      
      
      private function setShowHaloOnButton(value:Boolean):void {
         if(_showHaloButton != value){
            _showHaloButton = value;
            if(_showHaloButton){
               if(!_haloButtonFilters){
                  _haloButtonFilters = getHaloButtonFilters();
               }
            }else{
            }
         }
      }
      
      private function getHaloButtonFilters():Array{
         var color:Number = ColorPalette.getInstance().pearltreesDarkColor;
         var angle:Number = 0;
         var alpha:Number = 0.8;
         var blurX:Number = 20;
         var blurY:Number = 20;
         var distance:Number = 0;
         var strength:Number = 5;
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