package com.broceliand.ui.pearlTree
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.controller.AliasNavigationModel;
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.pearl.UIRootPearl;
   import com.broceliand.ui.tooltip.PTGenericTooltip;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.events.ToolTipEvent;
   
   public class BackFromAliasButton extends PearlButton
   {
      private static const BUTTON_WIDTH:Number= 28;
      
      private var _aliasNavigationModel:AliasNavigationModel;
      
      public function BackFromAliasButton() {
         _aliasNavigationModel = ApplicationManager.getInstance().visualModel.navigationModel.getAliasNavigationModel();
         toolTip = PTGenericTooltip.TOOLTIP_ENABLER_PREFIX + BroLocale.getInstance().getText("tooltip.backfromalias");
      }
      
      override protected function makeExcitableImage():ExcitableImage {
         var image:ExcitableImage = new ExcitableImage(PearlAssets.BACK_FROM_ALIAS_BUTTON, PearlAssets.BACK_FROM_ALIAS_BUTTON_OVER, PearlAssets.BACK_FROM_ALIAS_BUTTON_DISABLED);   
         image.width = image.height = BUTTON_WIDTH;
         return image;
      }
      
      override protected function createChildren():void {
         super.createChildren();
         visible = includeInLayout = false;
      }

      override   protected function getUIComponentFromNode(node:IPTNode,uiComponent:UIComponent=null):UIComponent {
         if (node is PTRootNode) {
            if (_aliasNavigationModel.isBackFromAlias) {
               visible = includeInLayout = true;
            } else {
               visible = includeInLayout = false;
            }
            return super.getUIComponentFromNode(node, uiComponent);
         }
         return null;
      }
      
      override protected function updateTargetComponentPosition(point:Point):void{         
         point.x = Math.floor(_bindedComponent.x) + scaleX * (GeometricalConstants.PEARL_X + GeometricalConstants.PEARL_BACK_BUTTON_X);
         point.y = Math.floor(_bindedComponent.y) + scaleY * (GeometricalConstants.PEARL_Y + GeometricalConstants.PEARL_BACK_BUTTON_Y);
      }
      override protected function performAction(event:Event=null):void {
         ApplicationManager.getInstance().visualModel.selectionModel.saveCrossingBusinessNode(_node);
         _aliasNavigationModel.goBackFromCurrentLocation(); 
      }
      public function setInSelection(value:Boolean):void {
         _focusImage.setDisabled(!value);          
      }
      
      override protected function onChangeBoundComponent(oldComponent:IUIComponent, newComponent:IUIComponent):void {
         var oldPearl:UIRootPearl = oldComponent as UIRootPearl;
         if (oldPearl) {
            oldPearl.backFromAliasButton= null;
         }
         var newPearl:UIRootPearl = newComponent as UIRootPearl;
         if (newPearl) {
            newPearl.backFromAliasButton= this;
         }
      }
      
   }
   
}