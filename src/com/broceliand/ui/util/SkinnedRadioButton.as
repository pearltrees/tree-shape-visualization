package com.broceliand.ui.util {
   
   import com.broceliand.assets.pearlWindow.base.PWCheckBoxAssets;
   
   import mx.controls.RadioButton;
   
   public class SkinnedRadioButton extends RadioButton {
      
      public function SkinnedRadioButton() {
         setStyle('disabledIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_OFF));
         setStyle('downIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_OFF));
         setStyle('overIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_OVER));
         setStyle('upIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_OFF));
         setStyle('selectedDownIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_ON));
         setStyle('selectedDisabledIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_ON));
         setStyle('selectedOverIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_OVER));
         setStyle('selectedUpIcon',AssetsManager.getEmbededAsset(PWCheckBoxAssets.RADIO_BUTTON_ON));
         setStyle('focusSkin', NullSkin);
      }
   }
}