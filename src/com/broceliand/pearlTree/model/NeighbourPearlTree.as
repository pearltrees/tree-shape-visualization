package com.broceliand.pearlTree.model
{
   public class NeighbourPearlTree extends BroPearlTree
   {

      private var _isSearchTree:Boolean = false;
      private var _spatialTreeCount:uint = 0;
      
      public function NeighbourPearlTree(rootNode:BroPTRootNode, isSearchTree:Boolean, spatialTreeCount:int)
      {
         super();
         _isSearchTree = isSearchTree;
         _root= rootNode;
         _root.owner=this;
         var node:BroPTNode = rootNode;
         _spatialTreeCount = spatialTreeCount;
         if (node is BroNeighbourRootPearl) {
            node = BroNeighbourRootPearl(node).delegateNode;
         }
         if (node is BroDistantTreeRefNode) {
            var refTree:BroPearlTree =(node as BroDistantTreeRefNode).refTree; 
            dbId = refTree.dbId;
            id= refTree.id;
            avatarHash = refTree.avatarHash;
            _root.setPersistentId( refTree.getRootNode().persistentDbID, refTree.getRootNode().persistentID, true);
            
         }
      }
      
      override public function get pearlCount():uint {
         return _spatialTreeCount;
      }
      override public function isWhatsHot():Boolean{
         return (id == 0);
      }
      public function isSearchTree():Boolean {
         return _isSearchTree;
      }
      override public function getMyAssociation():BroAssociation {
         var root:BroNeighbourRootPearl = getRootNode() as BroNeighbourRootPearl;
         if (root && root.delegateNode is BroDistantTreeRefNode) {
            var rootTree:BroPearlTree   = BroDistantTreeRefNode(root.delegateNode).refTree;
            if (rootTree) {
               return rootTree.getMyAssociation();
            }
         }
         return null;
      }
      
      public static function makeNeighbourTreee(root:BroDistantTreeRefNode, isSearch:Boolean, spatialTreeCount:uint):BroPearlTree { 
         var rootPearl:BroNeighbourRootPearl;
         if(root.refTree.isTeamRoot()) {
            rootPearl = new BroCoeditNeighbourRootPearl(root);
         }else{
            rootPearl = new BroNeighbourRootPearl(root);
         }
         var tree:NeighbourPearlTree = new NeighbourPearlTree(rootPearl, isSearch, spatialTreeCount);
         
         tree.title = tree.getRootNode().title;
         
         var pcount:Number =1;
         tree.authorsLoaded = true;
         tree.creationTime = new Date().getTime();
         tree.notifyEndLoadingPearl();
         return tree;
      }
      
   }
}