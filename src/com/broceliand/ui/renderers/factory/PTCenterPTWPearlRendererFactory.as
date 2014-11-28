package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UICenterPTWPearl;
   import com.broceliand.ui.renderers.pageRenderers.PTCenterPTWPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class PTCenterPTWPearlRendererFactory extends PearlRendererFactoryBase
   {
      public function PTCenterPTWPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }

      override public function newInstance():*
      {
         var renderer:PTCenterPTWPearlRenderer= new UICenterPTWPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;
      }
   }
}