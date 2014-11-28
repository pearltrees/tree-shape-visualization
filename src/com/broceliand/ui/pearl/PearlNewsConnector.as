package com.broceliand.ui.pearl {
   
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.pearlTree.NewsLabel;
   import com.broceliand.ui.pearlTree.PearlComponentAddOn;
   
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   public class PearlNewsConnector extends PearlComponentConnector  {
      
      private static const MASK_DEFAULT_WIDTH:int = 47;
      private static const MASK_DEFAULT_HEIGHT:int = 20;
      
      public function PearlNewsConnector(pearl:UIPearl, componentAddOn:PearlComponentAddOn) {
         super(pearl, componentAddOn);
      }
      
      public function get addOn():NewsLabel {
         return _componentAddOn as NewsLabel;
      }
      
      override protected function makeMask():void {
         if(!_mask) {
            _mask = new UIComponent();
            _mask.name = GeometricalConstants.PEARL_NEWS_BUTTON_MASK_NAME;
            _mask.includeInLayout = true;
         }
         var pCenter:Point = _pearl.globalToLocal(_pearl.pearlCenter);
         _mask.x = pCenter.x + NewsLabel.NEWS_BUTTON_X_OFFSET;
         _mask.y = pCenter.y + NewsLabel.NEWS_BUTTON_Y_OFFSET;
         
         _componentAddOn.validateNow();
         var componentWidth:Number = _componentAddOn.measuredWidth / _componentAddOn.scaleX;
         var componentHeight:Number = _componentAddOn.measuredHeight / _componentAddOn.scaleY;
         _mask.width = (componentWidth != 0) ? componentWidth : MASK_DEFAULT_WIDTH;
         _mask.height = (componentHeight != 0) ? componentHeight : MASK_DEFAULT_HEIGHT;
         _mask.graphics.clear();
         _mask.graphics.beginFill(0x000000, 0);
         _mask.graphics.drawRect(0,0, _mask.width, _mask.height);
         _mask.graphics.endFill();
      }
      
   }
}