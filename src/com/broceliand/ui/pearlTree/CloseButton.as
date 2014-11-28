package com.broceliand.ui.pearlTree
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.OpenCloseTreeInteractor;
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.pageRenderers.EndPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PTRootPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.tooltip.PTGenericTooltip;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   public class CloseButton extends PearlButton
   {
      private static const BUTTON_WIDTH:Number = 33;
      private static const OVER_WIDTH:Number = 33;
      
      public static const X_OFFSET:int= - GeometricalConstants.PEARL_BUTTON_X;
      public static const Y_OFFSET:int= - GeometricalConstants.PEARL_BUTTON_Y;
      
      public function CloseButton()
      {
         super();
         width = height=OVER_WIDTH;
         toolTip = PTGenericTooltip.TOOLTIP_ENABLER_PREFIX + BroLocale.getInstance().getText("tooltip.close");;
      }
      
      override protected function makeExcitableImage():ExcitableImage {
         var image:ExcitableImage = new ExcitableImage(AssetsManager.getEmbededAsset(PearlAssets.CLOSE_BUTTON), 
            AssetsManager.getEmbededAsset(PearlAssets.CLOSE_BUTTON_OVER));
         
         image.x = OVER_WIDTH - BUTTON_WIDTH;
         image.y = (OVER_WIDTH - BUTTON_WIDTH)/2; 
         image.width = BUTTON_WIDTH;
         image.height = BUTTON_WIDTH;
         return image;
         
      }

      override  protected function getUIComponentFromNode(node:IPTNode,uiComponent:UIComponent=null):UIComponent {
         var rootNode:PTRootNode = node as PTRootNode;
         if (rootNode) {
            return super.getUIComponentFromNode(node, uiComponent);
         }
         return null;
      }
      
      override public function excite():void {
         super.excite();
         var endRenderer:EndPearlRenderer = getEndPearlRenderer();
         if(endRenderer) {
            endRenderer.excite();
         }
         var rootNode:PTRootNode = node as PTRootNode;
         if (rootNode && rootNode.containedPearlTreeModel.openingState == OpeningState.OPEN) {
            ApplicationManager.getInstance().visualModel.highlightManager.highlightCloseTree(rootNode.containedPearlTreeModel.businessTree);
         }
         
      }
      override public function relax():void {
         super.relax();
         
         ApplicationManager.getInstance().visualModel.highlightManager.highlightCloseTree(null);
         var endRenderer:EndPearlRenderer = getEndPearlRenderer();
         if(endRenderer) {
            endRenderer.relax();
         }         
      }
      private function getEndPearlRenderer():EndPearlRenderer {
         if(_node && _node.pearlVnode && _node.pearlVnode.pearlView is PTRootPearlRenderer) {
            var renderer:IUIPearl = _node.pearlVnode.pearlView as IUIPearl;
            var endRenderer:EndPearlRenderer = PearlRendererStateManager.getEndRendererForStartRenderer(renderer);
            return endRenderer;
         }
         return null;
      }
      
      override protected function updateTargetComponentPosition(point:Point):void{
         point.x = Math.floor(_bindedComponent.x)+ scaleX * (GeometricalConstants.PEARL_X - X_OFFSET) ;
         point.y = Math.floor(_bindedComponent.y)+ scaleY * (GeometricalConstants.PEARL_Y - Y_OFFSET) ;
      }
      
      override protected function performAction(event:Event=null):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var openCloseTreeInteractor:OpenCloseTreeInteractor = am.components.pearlTreeViewer.interactorManager.getOpenCloseTreeInteractor();
         openCloseTreeInteractor.closeTree(_node);
      }
   }
}