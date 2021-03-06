package com.broceliand.ui.pearl {
   
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.CoeditLocalTreePearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class UICoeditLocalPearl extends UIRootPearl {
      
      public function UICoeditLocalPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager) {
         super(stateManager, remoteResourceManager);
      }
      
      override protected function instanciatePearl():void {
         _pearl = new CoeditLocalTreePearl();
      }      
   }
}