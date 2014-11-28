package com.broceliand.graphLayout.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.util.logging.Log;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class EndNodeVisibilityManager
   {
      private const DEBUG_LINK:Boolean = true;
      private var _endNodes:Array;
      private var _isEditMode:Boolean = false;
      public function EndNodeVisibilityManager()
      {
         _endNodes = new Array();
      }
      
      public function set editMode(value:Boolean):void {
         if (value != _isEditMode) {
            _isEditMode = value;
            if (_isEditMode) {
               updateAllNodes();
            }
         }
         
      }
      public function updateAllNodes():void {
         for each (var endNode:IPTNode in _endNodes) {
            updateEndNodeVisibility(endNode as EndNode);
         }
      }
      public function onCreateEndNode(vnode:IVisualNode):void {
         _endNodes.push(vnode.node);
      }
      public function onRemoveNode(node:IVisualNode):void {
         if (node is EndNode) {
            _endNodes.splice(_endNodes.lastIndexOf(node.node),1);
         }   
      }
      public function onUnlinkNode(nodeFrom:IVisualNode, nodeTo:IVisualNode):void {
         if (DEBUG_LINK) {
            if (!IPTNode(nodeFrom.node).isEnded()) {
               Log.getLogger("com.broceliand.graphLayout.model.EndNodeVisibilityManager").info("Unlink {0} to {1}",nodeFrom.node ,nodeTo.node);
            }
         }
      } 
      public function onLinkNode(nodeFrom:INode, nodeTo:INode):void {
         if (DEBUG_LINK) {
            if (!IPTNode(nodeFrom).isEnded()) {
               Log.getLogger("com.broceliand.graphLayout.model.EndNodeVisibilityManager").info("Link {0} to {1}",nodeFrom ,nodeTo);
            }
         }      
      }
      public function updateEndNodeVisibility(node:EndNode, isNewNode:Boolean = false):void {
         if (node == null || node.vnode == null || !node.vnode.isVisible ) {
            return;
         }
         if (_isEditMode) {
            if (isNewNode) computeEndNodeVisibilityInStaticMode(node);
            computeEditEndNodeVisibility(node);
         } else {
            computeEndNodeVisibilityInStaticMode(node);
         }
      }
      
      private function computeEditEndNodeVisibility(node:EndNode):void {
         if (node.canBeVisible) {
            return;
         } else {
            var rootNode:PTRootNode = node.rootNodeOfMyTree as PTRootNode;
            if (rootNode == null || rootNode.getBusinessNode() == null) {
               node.canBeVisible = false;
               return ;
            } 
            var selectedTree:BroPearlTree = ApplicationManager.getInstance().visualModel.navigationModel.getSelectedTree();
            var focusTree :BroPearlTree = ApplicationManager.getInstance().visualModel.navigationModel.getFocusedTree();
            var endNodeTree:BroPearlTree = rootNode.containedPearlTreeModel.businessTree;
            if (endNodeTree.isEmpty()) {
               return;
            }
            if (endNodeTree == focusTree) {
               return;
            }
            
            if (endNodeTree == selectedTree) {
               node.canBeVisible =true;
            }
            if (endNodeTree == ApplicationManager.getInstance().visualModel.selectionModel.getHighlightedTree()) {
               node.canBeVisible = true;
            }
         }
      }

      private function computeEndNodeVisibilityInStaticMode(node:EndNode):void {
         var focusTree:BroPearlTree = ApplicationManager.getInstance().visualModel.navigationModel.getFocusedTree();
         var rootNode:PTRootNode = node.rootNodeOfMyTree as PTRootNode;
         if (rootNode == null || rootNode.getBusinessNode() == null) {
            node.canBeVisible = false;
            return ;
         } 
         
         var endNodeTree:BroPearlTree = rootNode.containedPearlTreeModel.businessTree;
         var shouldBeVisible:Boolean = false;
         var currentNode:BroPTNode;
         while (endNodeTree != focusTree && endNodeTree) {
            currentNode = endNodeTree.refInParent;
            if (!currentNode) {
               break;
            }
            else if (!endNodeTree.isEmpty() && endNodeTree.getMyAssociation().isMyAssociation()) {
               shouldBeVisible = true;
               break;
            }
            
            if (currentNode.getChildCount() >0 ) {
               shouldBeVisible = true;
               break;
            } else {
               var isLastNode:Boolean = currentNode.isLastNodeOfTree();
               if (!isLastNode) {
                  break;
               } else {
                  endNodeTree = currentNode.owner;
               }
            } 
         }
         node.canBeVisible = shouldBeVisible; 
      }

   }
}