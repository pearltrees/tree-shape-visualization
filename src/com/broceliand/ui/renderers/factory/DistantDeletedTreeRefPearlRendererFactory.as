package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UIDistantDeletedPearl;
   import com.broceliand.ui.renderers.pageRenderers.DistantDeletedTreeRefPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class DistantDeletedTreeRefPearlRendererFactory extends PearlRendererFactoryBase
   {
      
      public function DistantDeletedTreeRefPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }
      
      override public function newInstance():*
      {
         var renderer:DistantDeletedTreeRefPearlRenderer = new UIDistantDeletedPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;        
      }
   }
}