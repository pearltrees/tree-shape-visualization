package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPTWPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   public class PTWPearlRendererFactory extends PearlRendererFactoryBase
   {
      
      public function PTWPearlRendererFactory(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         super(resourceManager, interactorManager, pearlRendererStateManager);
      }

      override public function newInstance():*
      {
         var renderer:UIPTWPearl;
         if (_recycledPearls.length>0) {
            renderer = _recycledPearls.pop();
         } else {
            renderer = createNewInstance();
         }
         commonInit(renderer);
         return renderer;
      }
      
      protected function createNewInstance():UIPTWPearl {
         return new UIPTWPearl(_pearlRendererStateManager, _remoteResourceManager);
      }
      
      override public function recyclePearl(pearl:IUIPearl):Boolean {
         if (!_isEndingRecycled && _recycledPearls.length <50 && ApplicationManager.getInstance().visualModel.navigationModel.isShowingPearlTreesWorld()) {
            _recycledPearls.push(pearl);
            return true;
         } else {
            return false;
         }
      }
   }
}