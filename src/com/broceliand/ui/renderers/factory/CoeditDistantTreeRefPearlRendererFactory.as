package com.broceliand.ui.renderers.factory {
   
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UICoeditDistantPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class CoeditDistantTreeRefPearlRendererFactory extends PearlRendererFactoryBase {
      
      public function CoeditDistantTreeRefPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager) {
         super(resourceManager, interactorManager, pearlRendererStateManager);
      }
      
      override public function newInstance():* {
         var renderer:IUIPearl = new UICoeditDistantPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;			
      }      
   }
}