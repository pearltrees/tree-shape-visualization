package com.broceliand.ui.pearl
{
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.ui.renderers.pageRenderers.EndPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class UIEndPearl extends EndPearlRenderer
   {
      private static const DEFAULT_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_NORMAL;
      private static const MAX_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_EXCITED;
      
      private var _lastAlphaValue:Number = 1;
      
      public function UIEndPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager)
      {
         super(stateManager, remoteResourceManager);
      }
      override protected function commitProperties():void {
         super.commitProperties();
         commitCanBeVisibleEndNode();
      }
      private function commitCanBeVisibleEndNode():void {
         var endNode:EndNode = node as EndNode;
         if (endNode) {
            if (endNode.canBeVisible && alpha != _lastAlphaValue) {
               super.alpha = _lastAlphaValue;
            } 
            if (!endNode.canBeVisible && alpha != 0){ 
               super.alpha = 0;
            }
         }
      }
      override protected function get pearlDefaultWidth():Number {
         return DEFAULT_PEARL_WIDTH;
      }
      override public function get pearlMaxWidth():Number {
         return MAX_PEARL_WIDTH;
      }      
      override public function set alpha(value:Number):void {
         _lastAlphaValue = value;
         if (node is EndNode && !EndNode(node).canBeVisible){
            value =0;
         }
         super.alpha = value;
         
      }
   }
}