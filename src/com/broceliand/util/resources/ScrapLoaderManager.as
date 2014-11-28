package com.broceliand.util.resources
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import mx.controls.Tree;
   
   public class ScrapLoaderManager
   {
      private static var _singleton:ScrapLoaderManager;
      private var _scrapTreeLoader:ScrapTreeLoader;
      public function ScrapLoaderManager()
      {
      }
      
      public static function getInstance():ScrapLoaderManager {
         if (!_singleton) {
            _singleton = new ScrapLoaderManager();
         }
         return _singleton;
      }
      
      public static function clearScrapCache():void {
         getInstance()._scrapTreeLoader = null;
      }
      
      public function loadScrap(node:BroPageNode, callback:IResourceLoadedCallback, isPreloading:Boolean):void {
         var tree:BroPearlTree = node.owner;
         var treeScrapLoader:ScrapTreeLoader = getScrapLoaderForTree(tree);
         if (tree && tree.isPrivatePearltreeOfCurrentUserNotPremium()) {
            treeScrapLoader.loadScrap(node.refPage, callback, false, true);
         } else {
            treeScrapLoader.loadScrap(node.refPage, callback, false);
         }
      }
      
      public function releaseEditedScrapPage(node:BroPageNode):void {
         var tree:BroPearlTree = node.owner;
         if (tree) {
            var treeScrapLoader:ScrapTreeLoader = getScrapLoaderForTree(tree);
            treeScrapLoader.releaseEditedScrapPage(node.refPage, tree.isPrivatePearltreeOfCurrentUserNotPremium());
         }
      }
      
      private function getScrapLoaderForTree(tree:BroPearlTree):ScrapTreeLoader {
         if (tree && (!_scrapTreeLoader || _scrapTreeLoader.tree.id != tree.id)) {
            _scrapTreeLoader = new ScrapTreeLoader(tree);
         }
         if (!_scrapTreeLoader) {
            _scrapTreeLoader = new ScrapTreeLoader(new BroPearlTree());
         }
         return _scrapTreeLoader;
      }
      
   }
}