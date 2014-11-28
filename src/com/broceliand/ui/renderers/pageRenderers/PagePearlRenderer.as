package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PagePearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class PagePearlRenderer extends UIPearl
   {
      function PagePearlRenderer(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super(stateManager, remoteResourceManager);
      }
      
      override protected function instanciatePearl():void{
         _pearl = new PagePearl();
      }
   }
}
