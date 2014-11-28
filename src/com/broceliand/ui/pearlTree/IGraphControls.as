package com.broceliand.ui.pearlTree
{
   import com.broceliand.ui.mouse.ICursorSetter;
   import com.broceliand.ui.pearlBar.Footer;
   import com.broceliand.ui.pearlBar.IFooter;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   import com.broceliand.ui.pearlBar.view.AnonymousUserSettings;
   import com.broceliand.ui.pearlBar.view.ZoomScale;
   
   import flash.geom.Point;
   
   public interface IGraphControls extends ICursorSetter
   {
      function get scrollControl():IScrollControl;
      function get dropZoneDeckModel():IDeckModel;
      function get footer():IFooter;
      function get unfocusButton():UnfocusButton;
      function get backFromAliasButton():BackFromAliasButton;
      function get emptyMapText():EmptyMapText;
      function get zoomControl():ZoomScale;
      
      function showDiscoverHelpLabel(value:Boolean):void;
      function makeNewsButton():NewsLabel;
      function releaseNewsButton(newsButton:NewsLabel):void;
      
      function addButtonToControlLayer(pearlAddOns:PearlComponentAddOn):void;
      function removeButtonToControlLayer(pearlAddOns:PearlComponentAddOn):void;
      
      function enableScrollControl(isEnabled:Boolean):void;
      
      function isPointOverAControl(point:Point):Boolean;
      function isPointOverTrash(point:Point):Boolean;
      function isPointOverDropZoneDeck(point:Point):Boolean;
      function isPointOverTopButtons(point:Point):Boolean;
      function isPointOverPearlButton(point:Point):Boolean;
      function getDeckUnderPoint(pt:Point):IDeckModel;
      function getDepthInParent():int;
      function isVisible():Boolean
      
      function invalidateDisplayList():void;
   }
}