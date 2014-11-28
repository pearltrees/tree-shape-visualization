package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UIRootPearl;
   import com.broceliand.ui.renderers.pageRenderers.PTRootPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class PTRootPearlRendererFactory extends PearlRendererFactoryBase
   {
      public function PTRootPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }

      override public function newInstance():*
      {
         var renderer:PTRootPearlRenderer = new UIRootPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;
      }
      
   }
}