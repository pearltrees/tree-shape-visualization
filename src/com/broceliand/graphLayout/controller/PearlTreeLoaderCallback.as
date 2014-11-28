package com.broceliand.graphLayout.controller
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.io.loader.IPearlTreeLoaderCallback;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   public class PearlTreeLoaderCallback implements IPearlTreeLoaderCallback
   {
      private var _node:IPTNode = null;
      private var _loadTreeRequestor:ILoadTreeRequestor;
      public function PearlTreeLoaderCallback(node:IPTNode, loadTreeRequestor:ILoadTreeRequestor)
      {
         _node = node;
         _loadTreeRequestor = loadTreeRequestor;
         
      }
      
      public function onTreeLoaded(tree:BroPearlTree):void{
         if(_node && (_node.getBusinessNode() is BroLocalTreeRefNode)){
            (_node.getBusinessNode() as BroLocalTreeRefNode).refTree = tree;
         }else{
            trace("couldn't set tree on business node, not a BroLocalTreeRefNode");
         }
         if (_loadTreeRequestor) {
            _loadTreeRequestor.onNodeTreeLoaded(tree, _node);
         }
      }
      public function onErrorLoadingTree(error:Object):void {
         if (_loadTreeRequestor) {
            _loadTreeRequestor.onErrorLoadingTree(_node, error);
         }    
      }
   }
}