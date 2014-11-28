package com.broceliand.graphLayout.autoReorgarnisation
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   public class EditingBusinessTree implements ITree
   {
      private var _tree:BroPearlTree;
      private var _movingNodeParent:BroPTNode;
      private var _movingNodeBrothers:Array;
      private var _targetNode:BroPTNode;
      private var _targetNodeChildren:Array;
      
      public function EditingBusinessTree(tree:BroPearlTree, movingNode:BroPTNode, targetNode:BroPTNode, targetNodePosition:int)
      {
         _tree = tree;
         _movingNodeParent = movingNode.parent;
         _targetNode = targetNode;
         _targetNodeChildren = new Array();
         for (var j:int =0; j< targetNode.getChildCount(); ++j) {
            var targetNodeChild:BroPTNode = _targetNode.getChildAt(j);
            if (j == targetNodePosition) {
               _targetNodeChildren.push(movingNode);
            }
            if (targetNodeChild != movingNode) {
               _targetNodeChildren.push(targetNodeChild);
            }
         }
         if (targetNodePosition == -1 || targetNode.getChildCount() == targetNodePosition) {
            _targetNodeChildren.push(movingNode);
         }
         if (_movingNodeParent!= targetNode && _movingNodeParent) {
            _movingNodeBrothers = new Array();
            for (var i:int =0; i<_movingNodeParent.getChildCount(); ++i) {
               var c:BroPTNode = _movingNodeParent.getChildAt(i);
               if (c != movingNode) {
                  _movingNodeBrothers.push(c);
               }
            }
         } else {
            _movingNodeBrothers = _targetNodeChildren; 
         }
      }
      
      public function get rootNode():Object {
         return _tree.getRootNode();
      }
      
      public function getChildNodeCount(node:Object):int {
         if (node == _movingNodeParent) {
            return _movingNodeBrothers.length;  
         } else if (node == _targetNode) {
            return _targetNodeChildren.length;
         }  else {
            var n:BroPTNode = node as BroPTNode;
            return n.getChildCount();
         }
      }
      
      public function getChildAt(parentNode:Object, index:int):Object {
         if (parentNode == _movingNodeParent) {
            return _movingNodeBrothers[index];  
         } else if (parentNode == _targetNode) {
            return _targetNodeChildren[index];
         }  else {
            var n:BroPTNode = parentNode as BroPTNode;
            return n.getChildAt(index);
         }
      }
      
      public function isDropZone():Boolean {
         return false;
      }
      public function moveNode(nodeToMove:Object, newParent:Object):void {
         
      }
   }
}