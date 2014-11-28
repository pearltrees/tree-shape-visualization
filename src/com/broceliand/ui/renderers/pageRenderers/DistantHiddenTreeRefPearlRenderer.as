package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.DistantTreePearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import mx.controls.Image;
   
   public class DistantHiddenTreeRefPearlRenderer extends UIPearl
   {
      function DistantHiddenTreeRefPearlRenderer(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super(stateManager, remoteResourceManager);
      }
      
      override protected function instanciatePearl():void{
         
         var rootPearl:PTRootPearl = new DistantTreePearl();
         rootPearl.isTreeHidden = true;
         _pearl = rootPearl;
      }
   }
}