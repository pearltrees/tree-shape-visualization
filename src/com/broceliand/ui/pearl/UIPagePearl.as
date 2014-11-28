package com.broceliand.ui.pearl
{
   import com.broceliand.ui.renderers.pageRenderers.PagePearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PagePearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class UIPagePearl extends PagePearlRenderer
   {
      private static const DEFAULT_PEARL_WIDTH:Number = PagePearl.PEARL_WIDTH_NORMAL;
      private static const MAX_PEARL_WIDTH:Number = PagePearl.PEARL_WIDTH_EXCITED;
      
      public function UIPagePearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager)
      {
         super(stateManager, remoteResourceManager);
      }
      
      override protected function get pearlDefaultWidth():Number {
         return DEFAULT_PEARL_WIDTH;
      }   
      override public function get pearlMaxWidth():Number {
         return MAX_PEARL_WIDTH;
      }      
   }
}