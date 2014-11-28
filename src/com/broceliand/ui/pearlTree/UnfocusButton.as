package com.broceliand.ui.pearlTree
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearl.UIRootPearl;
   import com.broceliand.ui.tooltip.PTGenericTooltip;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.BroLocale;
   
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   import mx.binding.utils.BindingUtils;
   import mx.containers.Box;
   import mx.core.Application;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   
   public class UnfocusButton extends PearlButton
   {
      private static const BUTTON_WIDTH:Number = 33;
      private var _mask:UIComponent;
      private var _inSelection:Boolean;
      private var _centerPoint:Point;
      private var _relaxedSourceSmall:Class;

      public function UnfocusButton()
      {
         super();
         toolTip = PTGenericTooltip.TOOLTIP_ENABLER_PREFIX + BroLocale.getInstance().getText("tooltip.unfocus");
      }
      
      override protected function makeExcitableImage():ExcitableImage {
         var image:ExcitableImage = new ExcitableImage(AssetsManager.getEmbededAsset(PearlAssets.UNFOCUS_BUTTON), AssetsManager.getEmbededAsset(PearlAssets.UNFOCUS_BUTTON_OVER), AssetsManager.getEmbededAsset(PearlAssets.UNFOCUS_BUTTON_DISABLED));
         
         _relaxedSourceSmall = image.relaxedSource;
         image.width = image.height = BUTTON_WIDTH;
         return image;
      }
      
      override protected function createChildren():void {
         super.createChildren();
         visible = includeInLayout = false;
      }

      override   protected function getUIComponentFromNode(node:IPTNode,uiComponent:UIComponent=null):UIComponent {
         if (node is PTRootNode) {
            var focusTree:BroPearlTree = PTRootNode(node).containedPearlTreeModel.businessTree;
            if (focusTree.getRootNode().isAssociationHierarchyRoot() && focusTree.getMyAssociation().isUserRootAssociation()) {
               visible = includeInLayout = false;
               return null;
            } else {
               visible = includeInLayout = true;
            }
            return super.getUIComponentFromNode(node, uiComponent);
         }
         return null;
      }

      override protected function updateTargetComponentPosition(point:Point):void{
         point.x = Math.floor(_bindedComponent.x)+ scaleX * (GeometricalConstants.PEARL_X + GeometricalConstants.PEARL_BUTTON_X) ;   
         point.y = Math.floor(_bindedComponent.y)+ scaleY * (GeometricalConstants.PEARL_Y + GeometricalConstants.PEARL_BUTTON_Y) ;       
      }
      
      override protected function performAction(event:Event=null):void {
         
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         var focusTree:BroPearlTree = navModel.getFocusedTree();
         var newFocus:BroPearlTree = focusTree.treeHierarchyNode.parentTree;
         if (newFocus ==null) {
            if (focusTree.isAssociationRoot() && !focusTree.getMyAssociation().isUserRootAssociation()) {
               var sm:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
               sm.saveCrossingBusinessNode(this.node);
               navModel.goToAssociationParentPearl(focusTree.getAssociationId());
            }
            return;
         }
         var node:BroPTNode = newFocus.getRootNode();
         
         var user:User = navModel.getSelectedUser();
         if (newFocus) {
            navModel.goTo(newFocus.getMyAssociation().associationId,
               user.persistentId,
               newFocus.id,
               newFocus.id,
               node.persistentID);
         }
      }
      
      override protected function onChangeBoundComponent(oldComponent:IUIComponent, newComponent:IUIComponent):void {
         var oldPearl:UIRootPearl = oldComponent as UIRootPearl;
         if (oldPearl) {
            oldPearl.unfocusButton = null;
         }
         var newPearl:UIRootPearl = newComponent as UIRootPearl;
         if (newPearl) {
            newPearl.unfocusButton = this;
         }
      }

      public function addMask(newParent:UIComponent):UIComponent{
         if(!_mask) {
            
            _mask = new Box();
            _mask.name = GeometricalConstants.PEARL_CLOSE_BUTTON_MASK_NAME;
            _mask.x = GeometricalConstants.PEARL_X + GeometricalConstants.PEARL_BUTTON_X; 
            _mask.y = GeometricalConstants.PEARL_Y + GeometricalConstants.PEARL_BACK_BUTTON_Y - 4; 
            _mask.width = - GeometricalConstants.PEARL_BUTTON_X + 6;
            _mask.height = 36;
            _mask.includeInLayout = true;
         }
         _mask.graphics.clear();
         _mask.graphics.beginFill(0x000000, 0);
         _mask.graphics.drawRect(0,0, _mask.width, _mask.height);
         _mask.graphics.endFill();
         if (_mask.parent != newParent && _mask.parent) {
            _mask.parent.removeChild(_mask);
         }
         if (newParent) {
            _mask.visible = _mask.includeInLayout = true;
            newParent.addChild(_mask);
         } 
         return _mask;
      }
      
      public function removeMask(oldParent:UIComponent):void {
         if (oldParent == _mask.parent) {
            oldParent.removeChild(_mask);
         }
      }
      public function setInSelection(value:Boolean):void {
         _focusImage.setDisabled(!value);          
      }
      
      override public function set visible(value:Boolean):void {
         super.visible = value;
      }
      
      public function getCenterButton():Point {
         if (!_centerPoint) {
            _centerPoint = new Point();
         }
         _centerPoint.x = x +  width /2;
         _centerPoint.y = y + height/2;
         return _centerPoint;
      }

   }
   
}