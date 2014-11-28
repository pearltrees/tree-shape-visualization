package com.broceliand.ui.renderers.factory {
   
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UICoeditPTWPearl;
   import com.broceliand.ui.pearl.UIPTWPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class CoeditPTWPearlRendererFactory extends PTWPearlRendererFactory {
      
      public function CoeditPTWPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager) {
         super(resourceManager, interactorManager, pearlRendererStateManager);
      }
      
      override protected function createNewInstance():UIPTWPearl {
         return new UICoeditPTWPearl(_pearlRendererStateManager, _remoteResourceManager);
      }
   }
}