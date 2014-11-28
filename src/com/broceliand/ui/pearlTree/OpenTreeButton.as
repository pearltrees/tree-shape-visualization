package com.broceliand.ui.pearlTree
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.DistantTreeRefNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.pearl.UICenterPTWPearl;
   import com.broceliand.ui.pearl.UIPTWPearl;
   import com.broceliand.ui.tooltip.PTGenericTooltip;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class OpenTreeButton extends PearlButton
   {

      public static const BUTTON_WIDTH:Number = 33;
      
      public static const X_OFFSET:int= - GeometricalConstants.PEARL_BUTTON_X;
      public static const Y_OFFSET:int= - GeometricalConstants.PEARL_BUTTON_Y;   
      
      private var _haloFilters:Array = null;
      protected var _showHalo:Boolean = false;
      
      public function OpenTreeButton()
      {
         super();
         updateSize();
         
      }
      override protected function makeExcitableImage():ExcitableImage {
         var image:ExcitableImage = new ExcitableImage(AssetsManager.getEmbededAsset(PearlAssets.OPEN_TREE_BUTTON), AssetsManager.getEmbededAsset(PearlAssets.OPEN_TREE_BUTTON_OVER));
         image.width = image.height = BUTTON_WIDTH;
         return image;
      }

      override  protected function getUIComponentFromNode(node:IPTNode,uiComponent:UIComponent=null):UIComponent {
         var rootNode:PTRootNode = node as PTRootNode;
         
         if (rootNode) {
            return super.getUIComponentFromNode(node, uiComponent);
         } 
         return null;
      }
      
      override protected function updateTargetComponentPosition(point:Point):void {
         updateSize();
         point.x = Math.floor(_bindedComponent.x)+ scaleX * (GeometricalConstants.PEARL_X - X_OFFSET) ;
         point.y = Math.floor(_bindedComponent.y)+ scaleY * (GeometricalConstants.PEARL_Y - Y_OFFSET) ;
      }
      override protected function performAction(event:Event=null):void {
         event.stopPropagation();
         if(_node) {
            var rootNode:PTRootNode = _node as PTRootNode;
            if(!rootNode) return;
            var model:IPearlTreeModel = rootNode.containedPearlTreeModel;
            if (model.openingState != OpeningState.CLOSED) {
               return;
            }
            var selectedTree:BroPearlTree = model.businessTree;
            var am:ApplicationManager = ApplicationManager.getInstance();
            var navmodel:INavigationManager = am.visualModel.navigationModel;
            
            navmodel.goTo(navmodel.getFocusedTree().getMyAssociation().associationId, 
               navmodel.getSelectedUser().persistentId, 
               navmodel.getFocusedTree().id,
               selectedTree.id, 
               selectedTree.getRootNode().persistentID);
         }
      }
      
      override protected function updateSize():void {
         width = height = BUTTON_WIDTH * scaleX;
      }
      override public function set visible(value:Boolean):void {
         if (value && value != super.visible) {
            super.visible = value;
            var im:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
            
            repositionNow();
            if (hitTestPoint(im.mousePosition.x, im.mousePosition.y)) {
               excite();
            }
         } else {
            super.visible = value;
         }
      }
   }
}