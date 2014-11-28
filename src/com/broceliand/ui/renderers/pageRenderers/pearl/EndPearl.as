package com.broceliand.ui.renderers.pageRenderers.pearl
{
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.resources.ImageFactory;
   
   import mx.controls.Image;
   import mx.core.UIComponent;
   
   public class EndPearl extends PearlBase
   {
      public static const PEARL_WIDTH_NORMAL:Number = 28;
      public static const PEARL_WIDTH_EXCITED:Number = 28;   
      
      public function EndPearl() {
         super();
         _pearlWidth = PEARL_WIDTH_NORMAL;
         showRings =false;
      }
      
      override protected function get excitedWidth():Number {
         return PEARL_WIDTH_EXCITED;
      }
      
      override protected function get normalWidth():Number {
         return PEARL_WIDTH_NORMAL;
      }
      
      override protected function getForegroundSelectedAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.END_PEARL_SELECTED_BUTTON);
      }       
      
      override protected function getForegroundOverAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.END_PEARL_OVER);
      }  
      
      override protected function get titleMarginTop():Number {
         return -4;
      }
      
      override protected function createWhiteBackground(width:Number):UIComponent{
         return null;
      }
      
      override public function set showRings(value:Boolean):void { 
         super.showRings=false;   
      }
   }
}