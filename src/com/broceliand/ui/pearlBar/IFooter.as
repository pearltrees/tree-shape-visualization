package com.broceliand.ui.pearlBar {
   import com.broceliand.ui.pearlBar.footerBanner.FooterBanner;
   import com.broceliand.ui.pearlBar.footerBanner.IFooterBanner;
   import com.broceliand.ui.pearlBar.view.ZoomScale;
   
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   import mx.core.IUIComponent;

   public interface IFooter extends IUIComponent {
      
      function isPointOverFooter(point:Point):Boolean;
      function set isPearlDraggedOverTrashBox(value:Boolean):void;
      function get footerBanner():IFooterBanner;
      function get isPearlDraggedOverTrashBox():Boolean;
      function isPointOverTrashBox(point:Point):Boolean;
      function isPointOverDropZoneDeck(point:Point):Boolean;
      function get isTrashBoxRecovering():Boolean;
      function set isTrashBoxRecovering(value:Boolean):void;
      
      function getPearlWindowDockPosition():Rectangle;
      function getImportWindowDockPosition():Rectangle;
      function getInstallPearlerWindowDockPosition():Rectangle;
      function getSocialSyncWindowDockPosition():Rectangle;
      function getInviteWindowDockPosition():Rectangle;
      function getDeletionRecoveryWindowDockPosition():Rectangle;
      function getPremiumWindowDockPosition():Rectangle;
      function onPearlerStatusChange():void;
      function hidePearlWindowContainer():void;
      function isDeckVisible():Boolean;
   }
}