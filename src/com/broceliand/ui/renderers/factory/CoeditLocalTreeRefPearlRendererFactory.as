package com.broceliand.ui.renderers.factory {
   
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UICoeditLocalPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class CoeditLocalTreeRefPearlRendererFactory extends PearlRendererFactoryBase {
      
      public function CoeditLocalTreeRefPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager)
      {
         super(resourceManager, interactorManager, pearlRendererStateManager);
      }
      
      override public function newInstance():* {
         var renderer:IUIPearl = new UICoeditLocalPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;			
      }      
   }
}