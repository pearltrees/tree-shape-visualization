package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.DistantTreePearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import mx.controls.Image;
   
   public class DistantTreeRefPearlRenderer extends UIPearl
   {
      
      function DistantTreeRefPearlRenderer(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super(stateManager, remoteResourceManager);
      }
      
      override protected function instanciatePearl():void {
         _pearl = new DistantTreePearl();
      }
      
   }
}
