package com.broceliand.ui.navBar {
   
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   import mx.core.IUIComponent;
   
   public interface INavBar extends IUIComponent {
      
      function isPointOverNavBarLeftButtons(point:Point):Boolean;
      function set model(value:INavBarModel):void;
      function get model():INavBarModel;
      function getAddPearlWindowsDockPosition():Rectangle;
      function enableAddPearlButton():void;
   }
}