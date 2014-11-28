package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import mx.core.IFactory;
   
   public class PearlRendererFactoryBase implements IFactory, IPearlRecyclingManager
   {
      protected var _recycledPearls:Array;
      protected var _remoteResourceManager:IRemoteResourceManager;
      private var _interactorManager:InteractorManager;
      protected var _pearlRendererStateManager:PearlRendererStateManager;
      protected var _isEndingRecycled:Boolean;
      
      public function PearlRendererFactoryBase(resourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager){
         _remoteResourceManager = resourceManager;
         _interactorManager = interactorManager;
         _pearlRendererStateManager = pearlRendererStateManager;
         _recycledPearls = new Array();
      }

      protected function commonInit(renderer:IUIPearl):void{
         _interactorManager.depthInteractor.movePearlToNormalDepth(renderer);
         renderer.pearlRecyclingManager = this;
         renderer.restoreInitialState();
      }
      
      public function newInstance():*
      {
         throw new Error("implement in derived class");
      }
      public function recyclePearl(pearl:IUIPearl):Boolean {
         
         return false;
      }
      
      public function releaseRecycled(maxSize:int=0):void {
         _isEndingRecycled = true;
         var recycledToEnd:Array = new Array();
         while (_recycledPearls.length>maxSize) {
            recycledToEnd.push(_recycledPearls.pop());
         }
         for each (var pearl:IUIPearl in recycledToEnd) {
            pearl.end();
         }
         _isEndingRecycled = false;
      }
      
   }
}