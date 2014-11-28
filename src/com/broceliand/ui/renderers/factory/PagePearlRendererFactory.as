package com.broceliand.ui.renderers.factory
{
   
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPagePearl;
   import com.broceliand.ui.renderers.pageRenderers.PagePearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class PagePearlRendererFactory extends PearlRendererFactoryBase
   {
      public function PagePearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);         
      }
      
      override public function newInstance():*
      {
         var renderer:PagePearlRenderer;
         if (_recycledPearls.length>0) {
            renderer = _recycledPearls.pop();
         } else {
            renderer = new UIPagePearl(_pearlRendererStateManager, _remoteResourceManager);
         }
         commonInit(renderer);
         return renderer;			
      }
      override public function recyclePearl(pearl:IUIPearl):Boolean {
         if (false && !_isEndingRecycled  && _recycledPearls.length <50 ) {
            _recycledPearls.push(pearl);
            return true;
         } else {
            return false;
         }
      }
      
   }
}