package com.broceliand.util.resources
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.utils.Dictionary;
   
   import mx.resources.ResourceManager;
   
   public class ScrapTreeLoader extends RemoteResourceManager
   {
      
      private var _tree:BroPearlTree;
      
      public function ScrapTreeLoader(tree:BroPearlTree)
      {
         super(false);
         _tree = tree;
      }

      public function get tree():BroPearlTree
      {
         return _tree;
      }
      
      public function loadScrap(page:BroPage, resourceCallback:IResourceLoadedCallback, isPreloadingOnly:Boolean = false, formerPremium:Boolean = false):void {
         super.getRemoteResource(resourceCallback, page.getContentUrl(formerPremium), isPreloadingOnly);
      }
      
      public function releaseEditedScrapPage(page:BroPage, formerPremium:Boolean):void {
         super.freeRemoteResourceFromCache(page.getContentUrl(formerPremium));
      }
      
   }
}