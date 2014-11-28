package com.broceliand.ui.pearl
{
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.CoeditPTWPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class UICoeditCenterPTWPearl extends UICenterPTWPearl
   {
      public function UICoeditCenterPTWPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager)
      {
         super(stateManager, remoteResourceManager);
      }
      override protected function instanciatePearl():void {
         _pearl = new CoeditPTWPearl();
      }

   }
}