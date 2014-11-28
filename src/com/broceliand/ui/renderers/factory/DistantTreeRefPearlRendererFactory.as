package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UIDistantPearl;
   import com.broceliand.ui.renderers.pageRenderers.DistantTreeRefPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class DistantTreeRefPearlRendererFactory extends PearlRendererFactoryBase
   {
      
      public function DistantTreeRefPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }
      
      override public function newInstance():*
      {
         var renderer:DistantTreeRefPearlRenderer = new UIDistantPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;			
      }
   }
}