package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.autoReorgarnisation.BusinessTreeLayoutChecker;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTWPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.team.TeamRightManager;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.window.IPTWindow;

   public class InteractorRightsManager
   {

      public static const USER_RIGHT_EDIT:int = 0;
      public static const MAX_NUM_NODES_IN_MAP:int = 100;
      public static const MAX_NUM_IMMEDIATE_DESCENDANTS_ROOT:int = 16;
      public static const MAX_NUM_IMMEDIATE_DESCENDANTS:int = 8;
      public static const MAX_NODE_BY_LEVEL:int = 16;
      public static var   PREVENT_TOO_MANY_DESCENDANT:Boolean = true;
      
      public static const CODE_OK:int = 0;
      public static const CODE_NOK_MISC:int = -1;
      public static const CODE_TOO_MANY_NODES_IN_MAP:int = -2;
      public static const CODE_TOO_MANY_IMMEDIATE_DESCENDANTS:int = -3;            
      public static const CODE_NO_TEAM_IN_TEAM:int = -4;      
      public static const CODE_NO_TEAM_TO_THE_ROOT_TEAM:int = -5;
      public static const CODE_NO_PRIVATE_IN_PUBLIC_TEAM:int = -6;
      public static const CODE_NO_PUBLIC_TEAM_IN_PRIVATE:int = -7;
      public static const CODE_NO_PENDING_REQUESTS:int = -8;
      public static const CODE_NOT_IN_PENDING_REQUESTS:int = -9;
      public static const CODE_PRIVATE_EXPIRED_PREMIUM:int = -10;
      public static const CODE_NOT_ALLOW_MOVE_PEARLS_OUTSIDE:int = -11;
      
      private function userOwnsBusinessNode(businessNode:BroPTNode):Boolean{
         var treeThatContainsTheNode:BroPearlTree = getTreeThatContainsNode(businessNode);
         
         if(!treeThatContainsTheNode){
            if (businessNode.owner != null) {
               return  businessNode.owner.isCurrentUserAuthor();
            } else {
               return true;
            } 
            
         }
         return treeThatContainsTheNode.isCurrentUserAuthor();
      }
      
      private function userOwnsNode(node:IPTNode):Boolean{
         if(!node){
            return false;
         }
         var businessNode:BroPTNode = node.getBusinessNode();
         if (!businessNode) {
            return false;
         }
         return userOwnsBusinessNode(businessNode);         
      }
      private function getTreeThatContainsNode(businessNode:BroPTNode):BroPearlTree{
         if(!businessNode || !businessNode.owner){
            return null;
         }
         if(businessNode is BroPTRootNode){
            if (businessNode.owner.refInParent){
               return businessNode.owner.refInParent.owner;
            } else {
               return null;
            }
            
         } else {
            return businessNode.owner;
         }         
      }
      
      public function userIsHome():Boolean {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var user : User = am.currentUser;
         if (user.isAnonymous()) {
            return false;
         }
         return User.areUsersSame(user, am.visualModel.navigationModel.getSelectedUser());
      }

      public function testBigTreeLimitation(potentialParentBNode:BroPTNode, potentialChildBNode:BroPTNode):int{
         if(!potentialParentBNode || !potentialChildBNode){
            
            return CODE_OK;
         }

         if(potentialChildBNode.parent == potentialParentBNode){
            return CODE_OK;
         }

         if(potentialChildBNode is BroPTRootNode){
            
            potentialChildBNode = potentialChildBNode.owner.refInParent;
         }
         if(potentialChildBNode.owner != potentialParentBNode.owner){
            
            var numNodesBeingInserted:int = potentialChildBNode.getDescendantCount();
            
            if(!potentialParentBNode.owner || potentialParentBNode.owner.pearlCount + numNodesBeingInserted > MAX_NUM_NODES_IN_MAP){
               return CODE_TOO_MANY_NODES_IN_MAP;
            } 
            
         }
         var maxChildrenCount:int = MAX_NUM_IMMEDIATE_DESCENDANTS; 
         if (potentialParentBNode is BroPTRootNode) {
            maxChildrenCount = MAX_NUM_IMMEDIATE_DESCENDANTS_ROOT;
         }
         
         if(potentialParentBNode.childLinks && potentialParentBNode.childLinks.length + 1 > maxChildrenCount){
            if (PREVENT_TOO_MANY_DESCENDANT) {
               return CODE_TOO_MANY_IMMEDIATE_DESCENDANTS;
            }
         }
         
         return CODE_OK;
      }      

      public function userHasRightToMoveNode(node:IPTNode):Boolean{
         if (!node) {
            return false;
         }
         var isShowingPearlTreesWorld:Boolean = ApplicationManager.getInstance().visualModel.navigationModel.isShowingPearlTreesWorld();
         if(node.isDocked) {            
            return !isShowingPearlTreesWorld; 
         }
         else if(isShowingPearlTreesWorld) {
            return false;
         }
         else if(node.isTopRoot) {
            return false;
         } else if (isUserAnonymous()) {
            return true;
         }
         else {
            return userOwnsNode(node);
         }
      }
      
      public function isUserAnonymous():Boolean {
         return ApplicationManager.getInstance().currentUser.isAnonymous() && !ApplicationManager.getInstance().isEmbed();
      }
      
      public function userCanCopyNode(businessNode:BroPTNode):Boolean{
         return canAddNodeToMyAccount(businessNode);
      }      
      
      public function canAddNodeToMyAccount(businessNode:BroPTNode):Boolean{
         var treeToCheck:BroPearlTree = null;
         if (businessNode is IBroPTWNode) {
            return false;
         } else if(businessNode is BroTreeRefNode){
            var ref:BroTreeRefNode = businessNode as BroTreeRefNode;
            treeToCheck = ref.refTree;
         } else if(businessNode is BroPTRootNode){
            treeToCheck = businessNode.owner;
            if (isUserAnonymous()) {
               return false;
            }
         }         
         
         if(!treeToCheck){
            return true;
         }
         if(treeToCheck.isCurrentUserAuthor()){
            return false;
         }

         return true;
      }

      public function userHasRightToAddChildrenToNode(node:IPTNode):Boolean{
         if(!node){
            return false;
         }
         
         var treeToCheck:BroPearlTree = null;
         if(node is EndNode){
            treeToCheck = node.rootNodeOfMyTree.getBusinessNode().owner;
         }else{
            treeToCheck = node.getBusinessNode().owner;
         }
         if(!treeToCheck){
            
            return false;
         }        
         if (isUserAnonymous()) {
            return true;
         }
         return treeToCheck.isCurrentUserAuthor();
      }
      private function testIsParentDescendant(draggedNode:IPTNode, nodeToLinkTo:IPTNode):Boolean {
         
         var nextParent:IPTNode = nodeToLinkTo;
         while(nextParent){
            if(nextParent == draggedNode){
               return true;
            }
            nextParent = nextParent.parent;
         }
         return false;
      }
      public function testDragIntoParentTreeAllowed(draggedNode:IPTNode, nodeToLinkTo:IPTNode, manipulatedNodes:ManipulatedNodesModel):int{
         if(!draggedNode || !nodeToLinkTo || nodeToLinkTo.vnode != nodeToLinkTo.vnode.vgraph.currentRootVNode){  
            return CODE_NOK_MISC; 
         }
         if(!(nodeToLinkTo is PTRootNode)){
            return CODE_NOK_MISC;
         }
         var rootNode:BroPTRootNode = nodeToLinkTo.getBusinessNode() as BroPTRootNode;
         if (rootNode) {
            var parentTree:BroPearlTree = rootNode.owner.treeHierarchyNode.parentTree;
            if (parentTree) {
               if(!userOwnsBusinessNode(draggedNode.getBusinessNode())){
                  return CODE_NOK_MISC;
               }
               if(!TeamRightManager.hasMovingOutsideRight(draggedNode.getBusinessNode()) && rootNode.owner.isTeamRoot()) {
                  return CODE_NOT_ALLOW_MOVE_PEARLS_OUTSIDE;
               }
               return testMovingTeamIntoSubTeam(manipulatedNodes, parentTree);
            }
         }
         return CODE_NOK_MISC;
      }
      
      public function testDragIntoTreeAllowed(draggedNode:IPTNode, nodeToLinkTo:IPTNode, manipulatedNodes:ManipulatedNodesModel):int{
         if(!draggedNode || !nodeToLinkTo){  
            return CODE_NOK_MISC; 
         }
         if(!(nodeToLinkTo is PTRootNode)){
            return CODE_NOK_MISC;
         }
         
         if((nodeToLinkTo as PTRootNode).isOpen()){
            return CODE_NOK_MISC;
         }
         if (testIsParentDescendant(draggedNode, nodeToLinkTo)) {
            return CODE_NOK_MISC;
         }
         var bNodeTemp:BroPTNode = nodeToLinkTo.getBusinessNode();
         var bNodeDragged:BroPTNode = draggedNode.getBusinessNode();
         if(!bNodeDragged || !bNodeTemp){
            return CODE_NOK_MISC;
         } 
         
         if(!(bNodeTemp is BroLocalTreeRefNode)){
            return CODE_NOK_MISC;
         }
         
         var bNodeToLinkTo:BroPTRootNode = (bNodeTemp as BroLocalTreeRefNode).refTree.getRootNode();
         var testLinkStructurallyAllowed:int = testBigTreeLimitation(bNodeToLinkTo, bNodeDragged);
         if(testLinkStructurallyAllowed != CODE_OK){
            return testLinkStructurallyAllowed;
         }               
         
         if(!userOwnsBusinessNode(bNodeToLinkTo) || !userOwnsBusinessNode(bNodeDragged)){
            return CODE_NOK_MISC;
         }
         
         var testTeamInTeam:int = testMovingTeamIntoSubTeam(manipulatedNodes, bNodeToLinkTo.owner);
         if (testTeamInTeam != CODE_OK) {
            return testTeamInTeam;
         }
         var testNoFounderMovePearlsOutOfTeam:int = testMoveOutToTreeAllowed(draggedNode, manipulatedNodes, bNodeToLinkTo.owner);
         if (testNoFounderMovePearlsOutOfTeam != CODE_OK) {
            return testNoFounderMovePearlsOutOfTeam;
         }
         return testMovingPrivate(manipulatedNodes, bNodeToLinkTo.owner);
         
      }
      
      public function testMoveOutToTreeAllowed(draggedNode:IPTNode, manipulatedNodesModel:ManipulatedNodesModel, targetTree:BroPearlTree):int {
         if (TeamRightManager.hasMovingOutsideRight(draggedNode.getBusinessNode())) {
            return CODE_OK;
         }
         if (targetTree.getAssociationId() != manipulatedNodesModel.startAssociationId) {
            return CODE_NOT_ALLOW_MOVE_PEARLS_OUTSIDE;
         }
         return CODE_OK;
      }
      
      public function testMovingTeamIntoSubTeam(manipulatadNodeModel:ManipulatedNodesModel, targetTree:BroPearlTree):int {
         if (manipulatadNodeModel.containsSubAssociations) {
            if (targetTree.getAssociationId() != manipulatadNodeModel.startAssociationId) {
               if (targetTree.getMyAssociation().isUserRootAssociation()) {
                  return CODE_NO_TEAM_TO_THE_ROOT_TEAM;
               }
               return CODE_NO_TEAM_IN_TEAM;
            }
         }
         return CODE_OK;  
      }
      
      public function testLinkToOutsideNodeFromTeam(fromNode:BroPTNode, toNode:BroPTNode):int {
         if (!fromNode.owner.isInATeam()) {
            return CODE_OK;
         }
         if (!TeamRightManager.hasRightToAttachNode(fromNode, toNode)) {
            return CODE_NOT_ALLOW_MOVE_PEARLS_OUTSIDE;
         }
         return CODE_OK;
      }
      
      public function testLayoutWillBeOk(checker:BusinessTreeLayoutChecker, movedNode:IPTNode, targetNode:IPTNode, targetIndex:int):int {
         if (checker.isMoveAllowed(movedNode, targetNode, targetIndex)|| !InteractorRightsManager.PREVENT_TOO_MANY_DESCENDANT) {
            return CODE_OK;
         } else return CODE_TOO_MANY_IMMEDIATE_DESCENDANTS;
      }
      
      public function testLinkAllowed(draggedNode:IPTNode, nodeToLinkTo:IPTNode, manipulatadNodeModel:ManipulatedNodesModel, anonymousLink:Boolean):int{
         if(!draggedNode || !nodeToLinkTo){  
            return CODE_OK; 
         }
         var bNodeToLinkTo:BroPTNode = nodeToLinkTo.getBusinessNode();
         var bNodeDragged:BroPTNode = draggedNode.getBusinessNode();
         var testSubTeamCode:int = testMovingTeamIntoSubTeam(manipulatadNodeModel, bNodeToLinkTo.owner);
         if (testSubTeamCode != CODE_OK) {
            return testSubTeamCode;
         }
         var testLinkToOutsideNodeFromTeam:int = testLinkToOutsideNodeFromTeam(bNodeDragged, bNodeToLinkTo);
         if (testLinkToOutsideNodeFromTeam != CODE_OK) {
            return testLinkToOutsideNodeFromTeam;
         }
         if (!bNodeDragged || !bNodeToLinkTo){
            return CODE_NOK_MISC;
         } 
         var testPrivate:int = testMovingPrivate(manipulatadNodeModel, bNodeToLinkTo.owner);
         if (testPrivate != CODE_OK) {
            return testPrivate;
         }
         
         if (testIsParentDescendant(draggedNode, nodeToLinkTo)) {
            return CODE_NOK_MISC;
         }
         var testLinkStructurallyAllowed:int = testBigTreeLimitation(bNodeToLinkTo, bNodeDragged);
         if(testLinkStructurallyAllowed != CODE_OK){
            return testLinkStructurallyAllowed;
         }               
         if(!anonymousLink  && !userHasRightToAddChildrenToNode(nodeToLinkTo)){
            return CODE_NOK_MISC;
         } else if (anonymousLink && !draggedNode.getBusinessNode().owner) {
            return CODE_NOK_MISC;
         }
         
         return CODE_OK;
         
      }
      
      public function testMovingPrivate(manipulatadNodeModel:ManipulatedNodesModel, targetTree:BroPearlTree):int {
         if (targetTree.isPublicTeamRoot() && manipulatadNodeModel.containsPrivateTrees) {
            return CODE_NO_PRIVATE_IN_PUBLIC_TEAM;
         } else if (targetTree.isPrivate() && manipulatadNodeModel.containsPublicSubAssocations) {
            return CODE_NO_PUBLIC_TEAM_IN_PRIVATE;
            /*} else if (targetTree.isPrivate() && manipulatadNodeModel.containsAssoWithPendingRequests) {
            return CODE_NO_PENDING_REQUESTS;
            } else if (targetTree.hasParentsWithTeamRequestsToAccept() && manipulatadNodeModel.containsPrivateTrees) {
            return CODE_NOT_IN_PENDING_REQUESTS;*/
         } else if (targetTree.isPrivatePearltreeOfCurrentUserNotPremium()) {
            return CODE_PRIVATE_EXPIRED_PREMIUM;
         }
         return CODE_OK;
      }
      
      public function convertCodeToTitleMessageCode(code:int, isForDraggingIntoTree:Boolean):int{
         switch(code){
            case CODE_TOO_MANY_IMMEDIATE_DESCENDANTS:
               return NodeTitleModel.MESSAGE_TOO_MANY_IMMEDIATE_DESCENDANTS;
            case InteractorRightsManager.CODE_TOO_MANY_NODES_IN_MAP:
               if(isForDraggingIntoTree){
                  return NodeTitleModel.MESSAGE_TOO_MANY_NODES_IN_CLOSED_MAP;
               }else{
                  return NodeTitleModel.MESSAGE_TOO_MANY_NODES_IN_OPEN_MAP;
               }
            case CODE_NO_TEAM_IN_TEAM:
               return NodeTitleModel.MESSAGE_NO_TEAM_IN_TEAM;
            case CODE_NO_TEAM_TO_THE_ROOT_TEAM:
               return NodeTitleModel.MESSAGE_NO_TEAM_TO_THE_ROOT_TEAM;
            case CODE_NO_PRIVATE_IN_PUBLIC_TEAM:
               return NodeTitleModel.MESSAGE_NO_PRIVATE_IN_PUBLIC_TEAM;
            case CODE_NO_PUBLIC_TEAM_IN_PRIVATE:
               return NodeTitleModel.MESSAGE_NO_PUBLIC_TEAM_IN_PRIVATE;
            case CODE_NO_PENDING_REQUESTS:
               return NodeTitleModel.MESSAGE_NO_PENDING_REQUESTS;
            case CODE_NOT_IN_PENDING_REQUESTS:
               return NodeTitleModel.MESSAGE_NOT_IN_PENDING_REQUESTS;
            case CODE_PRIVATE_EXPIRED_PREMIUM:
               return NodeTitleModel.MESSAGE_PRIVATE_EXPIRED_PREMIUM;
            case CODE_NOT_ALLOW_MOVE_PEARLS_OUTSIDE:
               return NodeTitleModel.MESSAGE_NO_MOVE_PEARL_OUTSIDE_TEAM;
         }
         return NodeTitleModel.NO_MESSAGE;
      }
      
   }
}