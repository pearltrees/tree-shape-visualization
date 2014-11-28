package com.broceliand.graphLayout.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   
   import mx.core.Application;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class SavedPearlReference
   {
      private var _node:IPTNode;
      private var _wasSpecialNode:Boolean; 
      private var _wasOpen:Boolean;
      private var _wasEndNode:Boolean;
      private var _isTemporaryLink:Boolean;
      private var _businessNode:BroPTNode;
      
      public function SavedPearlReference(node:IPTNode, isParentLinkTemporary:Boolean=false)
      {
         if (node is PTRootNode) {
            _wasSpecialNode = true;
            _wasEndNode = false;
            _wasOpen = PTRootNode(node).isOpen();
         } else if (node is EndNode) {
            _wasSpecialNode = true;
            _wasEndNode = true;
            _wasOpen = true;
         } else {
            _wasSpecialNode = false;
         }
         _node = node;
         _isTemporaryLink = isParentLinkTemporary;
         _businessNode = node.getBusinessNode();
      }
      public function getBusinessNode():BroPTNode {
         return _businessNode;
      }
      
      public function getNode(forParentLink:Boolean= true):IPTNode {
         
         if (_node.isEnded()) {
            var foundPearl:IPTNode = findPearlInVgraph(_businessNode);
            if (!foundPearl) {
               return null;
            } else {
               _node = foundPearl;
            }
         }
         if (!_node) {
            return null;
         }
         
         if (!_wasSpecialNode) {
            return _node;
         } else {
            
            var result:IPTNode = _node;
            
            if (_wasEndNode) {
               var tree:IPearlTreeModel = PTRootNode(_node.rootNodeOfMyTree).containedPearlTreeModel;
               if (tree.openingState == OpeningState.CLOSING) {
                  return _node.rootNodeOfMyTree;
               }
               if (PTRootNode(_node.rootNodeOfMyTree).isOpen()) {
                  result = PTRootNode(_node.rootNodeOfMyTree).containedPearlTreeModel.endNode;
               } else {
                  return _node.rootNodeOfMyTree;
               }
            }
            else if (!_wasOpen && forParentLink) {
               if (PTRootNode(_node).isOpen()) {
                  result = PTRootNode(_node).containedPearlTreeModel.endNode;
               }
            } else if (_wasOpen && PTRootNode(_node).containedPearlTreeModel.openingState == OpeningState.CLOSED) {
               
               return null;
            }
            if (result is EndNode && result.rootNodeOfMyTree.vnode == _node.vnode.vgraph.currentRootVNode) {
               
               return null;
            }  
            return result;
         }
      }
      
      public function getVnode(forParentLink:Boolean):IVisualNode {
         var node:IPTNode = getNode(forParentLink);
         if (node) {
            return node.vnode;
         } else {
            return null;
         }
      }
      
      public function get name():String {
         return _node.name;         
      }
      public function get isParentTemporaryLink():Boolean {
         return _isTemporaryLink;
      }
      public function set isParentTemporaryLink(value:Boolean):void {
         _isTemporaryLink = value;
      }

      private function findPearlInVgraph(node:BroPTNode):IPTNode {
         if (node.graphNode) {
            return node.graphNode;
         } else if (node is BroPTRootNode && node.owner.refInParent) {
            return node.owner.refInParent.graphNode;
         } else if (node is BroLocalTreeRefNode) {
            return BroLocalTreeRefNode(node).refTree.getRootNode().graphNode;
         }
         return null;
      }
      public function hasNodeBeenEnded():Boolean {
         return _node.isEnded();
      }
      public function getOriginTree():BroPearlTree {
         return (_businessNode.owner);
      }
      
   }
}