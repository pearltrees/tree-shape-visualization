package com.broceliand.ui.pearlBar.view
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlDeckAssets;
   import com.broceliand.ui.util.AssetsManager;
   
   import flash.events.MouseEvent;
   
   import mx.controls.HSlider;
   import mx.core.UIComponent;
   
   public class ZoomSlider extends HSlider 
   {
      private var _track:SliderTrack;
      private var _isEmbedSkin:Boolean;
      
      public function ZoomSlider() {
         _isEmbedSkin = ApplicationManager.getInstance().isEmbed()
      }

      override protected function createChildren():void{
         super.createChildren();
         if (isEmbedSkin) {
            sliderThumbClass = ZoomEmbedSliderThumb;
            setStyle("thumbSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_EMBED_CURSOR));
            setStyle("thumbDownSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_EMBED_CURSOR_OVER));
            setStyle("thumbOverSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_EMBED_CURSOR_OVER));
            setStyle("trackSkin",SliderTrack);
         } else {
            sliderThumbClass = ZoomSliderThumb;
            setStyle("thumbSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_CURSOR));
            setStyle("thumbDownSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_CURSOR_OVER));
            setStyle("thumbOverSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_CURSOR_OVER));
            setStyle("trackSkin",SliderTrack);
         }
         
         var trackArea:UIComponent = getChildAt(numChildren-1) as UIComponent;
         trackArea = trackArea.getChildAt(trackArea.numChildren -1) as UIComponent;
         trackArea.addEventListener(MouseEvent.MOUSE_DOWN, modifyMouseEventNearZero, false, 1);
      }
      private function modifyMouseEventNearZero(event:MouseEvent):void {
         var t:SliderTrack = getTrack();
         if (t.isOverZero) {
            event.localX = t.localZeroX + t.x;
         }
      }
      private function getTrack():SliderTrack {
         if (!_track) {
            _track = searchTrack();
         }
         return _track;
      }
      private function searchTrack():SliderTrack{
         var children:Array = new Array(this);
         while (children.length!=0) {
            var p:UIComponent= children.shift();
            if (p is SliderTrack) {
               return p as SliderTrack
            } 
            for (var i:int =0; i<p.numChildren; i++) {
               children.push(p.getChildAt(i));
            }
         }
         return null;
      }
      
      public function get isEmbedSkin ():Boolean {
         return _isEmbedSkin;
      }
   }
}