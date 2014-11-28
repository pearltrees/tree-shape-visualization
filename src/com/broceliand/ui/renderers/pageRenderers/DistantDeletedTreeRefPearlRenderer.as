package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class DistantDeletedTreeRefPearlRenderer extends UIPearl
   {
      function DistantDeletedTreeRefPearlRenderer(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super(stateManager, remoteResourceManager);
      }
      
      override protected function instanciatePearl():void{
         
         var rootPearl:PTRootPearl = new PTRootPearl();
         rootPearl.isTreeDeleted = true;
         _pearl = rootPearl;
      }
   }
}