package com.broceliand.ui.renderers.pageRenderers.pearl
{
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.ui.util.AssetsManager;
   
   public class DistantTreePearl extends PTRootPearl
   {
      public function DistantTreePearl()
      {
      }
      
      override protected function getForegroundSelectedAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.DISTANT_TREE_FOREGROUND_SELECTED_PNG);
      }       
      
      override protected function getForegroundOverAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.DISTANT_TREE_FOREGROUND_OVER_PNG);
      }       
   }
}