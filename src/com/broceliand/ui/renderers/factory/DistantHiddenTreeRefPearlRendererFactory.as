package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UIDistantHiddenPearl;
   import com.broceliand.ui.renderers.pageRenderers.DistantHiddenTreeRefPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class DistantHiddenTreeRefPearlRendererFactory extends PearlRendererFactoryBase
   {
      
      public function DistantHiddenTreeRefPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }
      
      override public function newInstance():*
      {
         var renderer:DistantHiddenTreeRefPearlRenderer = new UIDistantHiddenPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;			
      }
   }
}