package com.broceliand.ui.renderers.pageRenderers.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.ui.customization.avatar.AvatarManager;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.Assert;
   import com.broceliand.util.resources.ImageFactory;
   import com.broceliand.util.resources.RemoteImage;
   
   import mx.controls.Image;
   import mx.core.UIComponent;
   
   public class PTRootPearl extends PearlBase
   {
      private static const AVATAR_WIDTH_NORMAL:Number = 52; 
      protected static const AVATAR_WIDTH_EXCITED:Number = 52; 
      public static const PEARL_WIDTH_NORMAL:Number = 58; 
      public static const PEARL_WIDTH_EXCITED:Number = 58; 
      public static const PRIVATE_PADLOCK_WIDTH:Number = 13;
      public static const PRIVATE_PADLOCK_HEIGHT:Number = 17;
      
      private var _isTreeDeleted:Boolean;
      private var _isTreeHidden:Boolean;
      private var _deletedMask:Image = null;
      private var _mustLoadAvatar:Boolean = true;

      protected var _avatarImage:RemoteImage = null;
      protected var _foregroundImage:Image = null;
      protected var _foregroundImageExcited:Image = null;
      protected var _foregroundImageSelected:Image = null;
      
      private var _mustLoadNormalAvatar:Boolean = false;
      public function PTRootPearl() {
         super();
         _pearlWidth = PEARL_WIDTH_NORMAL;
      }
      override protected function get excitedWidth():Number {
         return PEARL_WIDTH_EXCITED;
      }
      override protected function get normalWidth():Number {
         return PEARL_WIDTH_NORMAL;
      }     

      override protected function getForegroundSelectedAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.TREE_FOREGROUND_SELECTED_PNG);
      }       
      override protected function getForegroundOverAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.TREE_FOREGROUND_OVER_PNG);
      }       
      public function set isTreeDeleted(value:Boolean):void{
         _isTreeDeleted = value;
         showRings = false;
      }
      public function set isTreeHidden(value:Boolean):void{
         _isTreeHidden = value;
         showRings = false;
      }      
      override protected function commitProperties():void{
         super.commitProperties();
         if(!_node) {
            return;
         }

         if (_mustLoadAvatar) {
            _mustLoadAvatar = false;
            loadAvatars();
         }
      }

      override protected function createChildren():void{
         super.createChildren();
         if(_isTreeDeleted){
            _deletedMask = new Image();
            _deletedMask.smoothBitmapContent = true;
            _deletedMask.source = AssetsManager.getEmbededAsset(PearlAssets.DISTANT_REF_DELETED_FOREGROUND);
            _deletedMask.width = _normalState.width;
            _deletedMask.height = _normalState.height;
            _deletedMask.x = _normalState.x;
            _deletedMask.y = _normalState.y;
            addChild(_deletedMask);
         }
      }           

      override public function set showRings(value:Boolean):void {
         if(_isTreeDeleted || _isTreeHidden) {
            super.showRings = false;
         }
         else{
            super.showRings = value;
         }
      }         
      
      override protected function get titleMarginTop():Number {
         if (node && node.isDocked) {
            return -5;
         }
         return -2;
      }
      
      override protected function makeNormalState():UIComponent {
         var normalState:UIComponent  = super.makeNormalState();
         _avatarImage = createAvatar(normalState, AVATAR_WIDTH_NORMAL);
         return normalState;
      }
      
      private function createAvatar(parentComponent:UIComponent, size:Number):RemoteImage {
         var avatarImage:RemoteImage = ImageFactory.newRemoteImage();
         avatarImage.visible = true;
         avatarImage.width = avatarImage.height = size;
         avatarImage.smoothBitmapContent = true;
         avatarImage.x = (parentComponent.width - avatarImage.width) / 2.0;
         avatarImage.y = (parentComponent.height- avatarImage.height) / 2.0;
         parentComponent.addChild(avatarImage);
         makeAndAddMask(avatarImage);
         return avatarImage;
      }
      
      protected function getPearlTreeForAvatar():BroPearlTree {
         if(!_node) return null;
         var businessNode:BroPTNode = _node.getBusinessNode(); 
         if(businessNode is BroPTRootNode) {
            return businessNode.owner;
         } 
         else if (businessNode is BroTreeRefNode) {
            return BroTreeRefNode(businessNode).refTree;
         }
         else {
            return null;
         }
      }
      
      protected function loadAvatars(normalOnly:Boolean = false):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var tree:BroPearlTree = getPearlTreeForAvatar();
         
         am.avatarManager.loadAvatarToImage(tree, _avatarImage, AvatarManager.TYPE_PEARL_HUGE);
      }
      
      override public function refreshAvatar():void{
         _mustLoadAvatar = true;
         invalidateProperties();
      }
      override protected function clearMemory():void {
         super.clearMemory();
         _avatarImage = null;
      }
      
      override public function getPearlVisibleWidth():Number {
         return pearlWidth - 4/3;
      }
   }
}