package com.broceliand.ui.interactors
{
   import com.broceliand.graphLayout.autoReorgarnisation.BusinessTreeLayoutChecker;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.utils.describeType;
   
   public class ThrownPearlPositionner
   {
      private static const MAX_CHILD_COUNT:int = 4;
      private static const MAX_BRANCH_LENGTH:int = 5;
      public function ThrownPearlPositionner()
      {
      }

      private static function getNodeAtEndOfBranch(startOfBranch:BroPTNode, depthLimit:int):BroPTNode {
         var level:int = 0;
         var incumbent:BroPTNode = startOfBranch;
         while (incumbent.getChildCount()>0) {
            level++;
            incumbent = incumbent.getChildAt(0);
         }
         if (level > depthLimit) {
            return incumbent = startOfBranch;
         }
         return incumbent;
      }
      public static function findBestPositionInTree(tree:BroPearlTree, node:BroPTNode):BroPTNode {

         var incumbent:BroPTNode = tree.getRootNode();
         
         if (incumbent.getChildCount() < InteractorRightsManager.MAX_NUM_IMMEDIATE_DESCENDANTS_ROOT) {
            incumbent = tree.getRootNode();
         } else {
            
            incumbent = getNodeAtEndOfBranch(incumbent, MAX_BRANCH_LENGTH);
         }
         
         var nodes:Array = null;
         var i:int =1;
         while (!new BusinessTreeLayoutChecker(MAX_CHILD_COUNT).isBNodeMoveAllowed(node, incumbent, 0) ){
            if (nodes == null) {
               nodes = tree.getTreeNodes();
            }
            if (i>= nodes.length) {
               break;
            }
            incumbent = nodes[i++];
         }
         
         if (incumbent != tree.getRootNode()) {
            
            var allowedIncumbent:BroPTNode = incumbent;      
            incumbent = getNodeAtEndOfBranch(incumbent, MAX_BRANCH_LENGTH);
            if (incumbent != allowedIncumbent && !new BusinessTreeLayoutChecker(MAX_CHILD_COUNT).isBNodeMoveAllowed(node, incumbent, 0) ) {
               incumbent = allowedIncumbent;
            }
         }

         if (node.owner == tree) {
            var result:BroPTNode = incumbent;
            while (result.parent != null) {
               if (result == node) {
                  return node.parent;
               }  else {
                  result = result.parent;
               }
            }
         }
         
         return incumbent;      
      }
   }
}