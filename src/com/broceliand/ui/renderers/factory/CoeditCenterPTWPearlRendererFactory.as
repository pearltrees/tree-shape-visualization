package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.UICoeditCenterPTWPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class CoeditCenterPTWPearlRendererFactory extends PTCenterPTWPearlRendererFactory
   {
      public function CoeditCenterPTWPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager)
      {
         super(resourceManager, interactorManager, pearlRendererStateManager);
      }
      override public function newInstance():*
      {
         var renderer:UICoeditCenterPTWPearl= new UICoeditCenterPTWPearl(_pearlRendererStateManager, _remoteResourceManager);
         commonInit(renderer);
         return renderer;
      }
   }
}