package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UIEndPearl;
   import com.broceliand.ui.renderers.pageRenderers.EndPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class EndPearlRendererFactory extends PearlRendererFactoryBase
   {
      public function EndPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }
      
      override public function newInstance():*
      {
         var renderer:EndPearlRenderer = new UIEndPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;			
      }
   }
}