package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;

   public class PTRootPearlRenderer extends UIPearl
   {	   
      
      function PTRootPearlRenderer(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super(stateManager, remoteResourceManager);
      }
      
      override protected function instanciatePearl():void{
         _pearl = new PTRootPearl();
      }
      
      override public function invalidateProperties():void{
         super.invalidateProperties();
         var rootNode:PTRootNode = node as PTRootNode;
         if(rootNode && rootNode.containedPearlTreeModel && rootNode.containedPearlTreeModel.endNode && rootNode.containedPearlTreeModel.endNode.renderer){
            var endPearlRenderer:IUIPearl = rootNode.containedPearlTreeModel.endNode.renderer;
            
            if(endPearlRenderer != this && !endPearlRenderer.updateCompletePendingFlag){ 
               endPearlRenderer.invalidateProperties();
            }            
         }  
      }
   }
}
