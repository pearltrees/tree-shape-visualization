package com.broceliand.ui.pearlBar.view
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlDeckAssets;
   import com.broceliand.ui.model.ZoomModel;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   import mx.containers.Canvas;
   import mx.controls.Image;
   import mx.controls.sliderClasses.Slider;
   import mx.core.UIComponent;
   
   public class SliderTrack extends Canvas
   {
      private var _parentSlider:Slider;
      private var _centerButton:Image;
      
      private var _isOverZero:Boolean = false;
      private var _isEmbedMode:Boolean = false;
      public function SliderTrack()
      {
         clipContent = false;
         _isEmbedMode = ApplicationManager.getInstance().isEmbed();
      }
      override public function get height():Number {
         return 3;
      }
      
      private function get slider():Slider {
         if (!_parentSlider) {
            var aParent:DisplayObject = this;
            while (aParent!= null) {
               if (aParent is Slider) {
                  _parentSlider = aParent as Slider;
                  break;
               }
               aParent = aParent.parent;
            }
         }
         return _parentSlider;	
      }
      
      private function updateCenterPosition():void  {
      }
      override protected function createChildren():void{
         super.createChildren();
         _centerButton = new Image();
         if (_isEmbedMode) {
            _centerButton.source = AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_EMBED_ZERO);			
         } else {
            _centerButton.source = AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_ZERO);
         }
         addChild(_centerButton);
         hitArea = _centerButton;
         if (slider) {
            var trackArea:UIComponent = slider.getChildAt(slider.numChildren-1) as UIComponent;
            trackArea = trackArea.getChildAt(trackArea.numChildren -1) as UIComponent;
            slider.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)
            slider.addEventListener(MouseEvent.ROLL_OUT, onRollOutZero);
         }
      } 
      public function get localZeroX():Number {
         return _centerButton.x + getZeroButtonWidth()/ 2 ;
      }
      private function onMouseMove(event:MouseEvent):void {
         isOverZero =_centerButton.hitTestPoint(event.stageX, event.stageY);
      }
      public function set isOverZero(value:Boolean):void {
         if (value != _isOverZero) {
            _isOverZero = value;
            if (_isOverZero) {
               if (_isEmbedMode) {
                  _centerButton.source = AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_EMBED_ZERO_OVER);
               } else {
                  _centerButton.source = AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_ZERO_OVER);
               } 
            } else {
               if (_isEmbedMode) {
                  _centerButton.source = AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_EMBED_ZERO);
               } else {
                  _centerButton.source = AssetsManager.getEmbededAsset(PearlDeckAssets.ZOOM_ZERO);
               } 
            }
         } 
      }
      public function get isOverZero():Boolean {
         return _isOverZero;
      }
      private function onRollOutZero(event:MouseEvent):void {
         isOverZero = false;			
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);

         var color:int = ColorPalette.PEARLTREES_LIGHT_GRAY_COLOR;
         var parentSlider:Slider = slider;
         
         var x:int= 0;
         var centerX :Number = -1;
         if (parentSlider) {
            centerX =  0.5 * unscaledWidth; 
            _centerButton.visible = true;

            _centerButton.x = centerX - getZeroButtonWidth()/2;
            _centerButton.y = - getZeroButtonHeight()/2 -2;
         }
         
         graphics.beginFill(color);
         while (x +1 < unscaledWidth) {
            if (centerX<0 || Math.abs(centerX - x) > (_isEmbedMode ? 4 : 5)) { 
               if (_isEmbedMode) {
                  graphics.drawCircle(x, -2, 1.4);
               } else {
                  graphics.drawCircle(x, -2, 1.5);
               }
            }
            x += _isEmbedMode ? 5:6 ;
         }
         graphics.endFill();
      }
      private function getZeroButtonWidth():Number {
         if (_isEmbedMode) {
            return 18;
         } else {
            return 20;
         }
      }
      private function getZeroButtonHeight():Number {
         if (_isEmbedMode) {
            return 25;
         } else {
            return 17;
         }
      }
      
   }
}