package com.broceliand.ui.renderers.pageRenderers.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.ui.customization.logo.LogoManager;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   import com.broceliand.util.resources.ImageFactory;
   import com.broceliand.util.resources.RemoteImage;
   
   import mx.core.UIComponent;
   
   public class PagePearl extends PearlBase
   {
      public static const PEARL_WIDTH_NORMAL:Number = 42; 
      public static const PEARL_WIDTH_EXCITED:Number = 42; 
      private static const TITLE_MARGIN_TOP:Number = -3;
      private static const ICON_WIDTH:Number = 16;
      private static const CUSTOM_ICON_WIDTH:Number = 36;

      private var iconChanged:Boolean = false;
      protected var _iconImageNormalState:RemoteImage = null;
      
      public function PagePearl() {
         super();
         _pearlWidth = PEARL_WIDTH_NORMAL;
         iconChanged = true;
      }
      
      override protected function get titleMarginTop():Number {
         return TITLE_MARGIN_TOP;
      }
      
      override protected function get excitedWidth():Number {
         return PEARL_WIDTH_EXCITED;
      }
      
      override protected function get normalWidth():Number {
         return PEARL_WIDTH_NORMAL;
      }
      
      private function getRefPage():BroPage {
         if (_node) {
            var pageNode:BroPageNode = _node.getBusinessNode() as BroPageNode;
            return pageNode.refPage;
         }
         return null;
      }

      override protected function commitProperties():void{
         if (_nodeChanged) {
            iconChanged = true;
         }
         super.commitProperties();
         if(!_node || _node.isEnded()) return;
         if(iconChanged) {
            iconChanged = false;
            var broPage:BroPage = getRefPage();
            if(broPage.logoUrl) {
               var remoteImageManager:IRemoteResourceManager = ApplicationManager.getInstance().remoteResourceManagers.remoteImageManager;
               remoteImageManager.getRemoteResource(_iconImageNormalState, broPage.logoUrl);
               setIconWidthAndPosition();
               if (broPage.logoUrl.indexOf(".jpg") > 0 || broPage.logoType == LogoManager.TEMPORARY_TYPE || broPage.logoType == LogoManager.SERVER_TYPE) {
                  makeAndAddMask(_iconImageNormalState);
               } else {
                  removeMask(_iconImageNormalState);
               }
            } 
            else {
               _iconImageNormalState.source = AssetsManager.getEmbededAsset(PearlAssets.DEFAULT_ICON);
            }
         }
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         updateIconPostion(_iconImageNormalState);
      }
      
      private function updateIconPostion(icon:RemoteImage):void {
         if (icon) {
            icon.x = (icon.parent.width - icon.width) / 2.0;
            icon.y = (icon.parent.height- icon.height) / 2.0;
         }
      }
      
      private function setIconWidthAndPosition():void {
         var customIcon:Boolean = !(LogoManager.isStandardIcon(getRefPage().logoType));
         if (!customIcon && getRefPage().isNote()) {
            customIcon = true;
         }
         var width:Number = (customIcon? CUSTOM_ICON_WIDTH : ICON_WIDTH);
         _iconImageNormalState.width = _iconImageNormalState.height= width;
         updateIconPostion(_iconImageNormalState);
         updateMask(_iconImageNormalState);
      }
      
      override public function refreshLogo():void {
         iconChanged = true;
         invalidateProperties();
      }
      
      override protected function clearMemory():void {
         super.clearMemory();
         _iconImageNormalState = null;
      }
      
      private function makeIcon(parent:UIComponent):RemoteImage {
         var icon:RemoteImage = ImageFactory.newRemoteImage();
         var broPage:BroPage = getRefPage();
         icon.smoothBitmapContent=true;
         icon.width= icon.height = ICON_WIDTH;
         icon.x = (parent.width- icon.width) /2;
         icon.y =  (parent.height- icon.height) /2;
         icon.smoothBitmapContent = true;
         parent.addChild(icon);
         return icon;
      }
      
      override protected function makeNormalState():UIComponent {
         var normalState:UIComponent= super.makeNormalState();
         _iconImageNormalState= makeIcon(normalState);
         normalState.addChild(_iconImageNormalState);
         return normalState;
         
      }

      override protected function getForegroundOverAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.PEARL_FOREGROUND_OVER_PNG);
      }
      
      override protected function getForegroundSelectedAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.PEARL_FOREGROUND_SELECTED_PNG);
      }
      
      override public function getPearlVisibleWidth():Number {
         return pearlWidth - 8/3;
      }
      
   }
}
