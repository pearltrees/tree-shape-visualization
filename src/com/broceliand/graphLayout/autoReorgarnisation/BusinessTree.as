package com.broceliand.graphLayout.autoReorgarnisation
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.utils.Dictionary;
   
   public class BusinessTree implements ITree
   {
      private var _tree:BroPearlTree;
      private var _stillNode:BroPTNode;
      private var _bnodeToPTNode:Dictionary;
      public function BusinessTree(tree:BroPearlTree)
      {
         _tree = tree;
      }
      
      public function get rootNode():Object {
         return _tree.getRootNode();   
      }
      public function toBNode(node:Object):BroPTNode {
         return node as BroPTNode;
      }
      public function getChildNodeCount(node:Object):int {
         return toBNode(node).getChildCount();
      }
      public function getChildAt(parentNode:Object, index:int):Object {
         return toBNode(parentNode).getChildAt(index);
      }
      public function forbidMove(node:BroPTNode):void {
         _stillNode = node;
      }
      public function canMoveNode(node:Object):Boolean {
         var forbidenNode:BroPTNode = _stillNode;
         while (forbidenNode != null) {
            if (node == forbidenNode) {
               return false;
            }
            forbidenNode = forbidenNode.parent;
            
         }
         return true;
      }
      public function moveNode(nodeToMove:Object, newParent:Object):void{
         if (!canMoveNode(nodeToMove)) { 
            return;
         }
         
         if (_bnodeToPTNode == null ) {
            buildGraphNodeAccessor();
         }
         var inodeToMove:IPTNode= null;
         var newParentNode:IPTNode = null;
         if (_bnodeToPTNode) {
            inodeToMove = _bnodeToPTNode[nodeToMove] as IPTNode;
            newParentNode = _bnodeToPTNode[newParent] as IPTNode;
         }
         if (nodeToMove && newParentNode) {
            var ec:IPearlTreeEditionController = ApplicationManager.getInstance().components.pearlTreeViewer.pearlTreeEditionController;
            ec.tempUnlinkNodes(inodeToMove.parent.vnode, inodeToMove.vnode);
            var index:int =0;
            if (newParentNode.successors) {
               index = newParentNode.successors.length;
            }
            ec.tempLinkNodes(newParentNode.vnode, inodeToMove.vnode , index);
            ec.confirmNodeParentLink(inodeToMove.vnode);
         } else {
            
            _tree.addToNode(toBNode(newParent), toBNode(nodeToMove), toBNode(newParent).getChildCount());
         }

      } 
      private function buildGraphNodeAccessor():void {
         var graphNode:IPTNode = _tree.getRootNode().graphNode;
         if (graphNode && graphNode.getBusinessNode() == _tree.getRootNode()) {
            _bnodeToPTNode = new Dictionary();
            var toProcess:Array = graphNode.getDescendantsAndSelf();
            for each (var n:IPTNode  in toProcess) {
               var bnode:BroPTNode = n.getBusinessNode();
               if (bnode.owner == _tree) {
                  _bnodeToPTNode[bnode] = n;
               }
            }
         }
         
      }
      
      public function isDropZone():Boolean {
         return _tree.isDropZone();
      }

   }
}