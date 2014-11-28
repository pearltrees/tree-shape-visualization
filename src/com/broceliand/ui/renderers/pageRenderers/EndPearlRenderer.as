package com.broceliand.ui.renderers.pageRenderers
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.EndPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class EndPearlRenderer extends UIPearl
   {
      function EndPearlRenderer(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super(stateManager, remoteResourceManager);
      }

      override protected function instanciatePearl():void{
         _pearl = new EndPearl();
      }
      
      override public function canBeMoved():Boolean {
         return false;
      }
      
      override public function get businessNode():BroPTNode {
         if (node) 
            return node.rootNodeOfMyTree.getBusinessNode();
         return null;
      }
      
      override public function markHasNotificationsForNewLabel(value:Boolean):void {
         super.markHasNotificationsForNewLabel(false);
      }

   }
}