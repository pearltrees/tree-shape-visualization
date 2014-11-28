package com.broceliand.graphLayout.autoReorgarnisation
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   
   import flash.utils.Dictionary;
   
   public class BusinessTreeLayoutChecker
   {
      private var _movedNode:BroPTNode;
      private var _maxChildCountForNonRootNode:int;
      private var _cacheResults:Dictionary;
      private var _alreadyInvalidTrees:Dictionary;
      public function BusinessTreeLayoutChecker(maxChildCountForNonRootNode:int = -1) {
         if (maxChildCountForNonRootNode == -1) {
            maxChildCountForNonRootNode = InteractorRightsManager.MAX_NUM_IMMEDIATE_DESCENDANTS;
         }
         _maxChildCountForNonRootNode = maxChildCountForNonRootNode;
      }

      public function isMoveAllowed(moveNode:IPTNode, targetNode:IPTNode, targetNodeIndex:int = -1):Boolean {
         var moveBNode:BroPTNode = moveNode.getBusinessNode();
         var targetBNode:BroPTNode = targetNode.getBusinessNode();
         return isBNodeMoveAllowed(moveBNode, targetBNode, targetNodeIndex);
      }
      
      public function isBNodeMoveAllowed(moveBNode:BroPTNode, targetBNode:BroPTNode, targetNodeIndex:int = -1):Boolean {
         var maxChildCount:int  = _maxChildCountForNonRootNode;
         if (targetBNode is BroPTRootNode) {
            maxChildCount = InteractorRightsManager.MAX_NUM_IMMEDIATE_DESCENDANTS_ROOT;
         }
         if (moveBNode is BroPTRootNode) {     
            moveBNode = moveBNode.owner.refInParent;
         }
         if (moveBNode != _movedNode) {
            _movedNode     = moveBNode;
            _cacheResults  = new Dictionary();
            _alreadyInvalidTrees = new Dictionary();
         }
         
         var key:String = targetBNode.toString() + "_" + targetNodeIndex;
         if (_cacheResults[key] != null) {
            return _cacheResults[key] == 1;
         }
         var targetNodeTree:BroPearlTree  = targetBNode.owner;
         
         if (targetBNode != moveBNode) {
            if ((targetBNode is BroPTRootNode)) {
               
            }
         }
         var isOriginalLayoutValid:Boolean  = false;
         if (_alreadyInvalidTrees[targetNodeTree.id] == null) {
            var targetTree:ITree = new BusinessTree(targetNodeTree);
            isOriginalLayoutValid = new BusinessTreeLayout().checkLayoutIsValid(targetTree);
            _alreadyInvalidTrees[targetNodeTree.id] = isOriginalLayoutValid;
         } else {
            isOriginalLayoutValid = _alreadyInvalidTrees[targetNodeTree.id];
         }
         if (!isOriginalLayoutValid) {
            return true;
         }
         var editingTree:ITree = new EditingBusinessTree(targetNodeTree, moveBNode, targetBNode, targetNodeIndex);
         var result:Boolean = new BusinessTreeLayout().checkLayoutIsValid(editingTree);
         if (editingTree.getChildNodeCount(targetBNode) > maxChildCount) {
            return false;
         } 
         if (result) {
            _cacheResults[key] = 1;  
         } else {
            _cacheResults[key] = 2;
         }
         return result;
      }
      
      private function checkChildCountOnMove(targetNode:BroPTNode, movedNode:BroPTNode):Boolean {

         return true;
      }

   }
}