package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.SavedPearlReference;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;

   public class ManipulatedNodesModel
   {
      private var _nodes:Dictionary;
      private var _startAssociationId:int;
      private var _containsSubAssocations:Boolean;
      private var _containsPublicSubAssocations:Boolean;
      private var _containsPrivateTrees:Boolean;
      
      private var _draggedPearlTree:BroPearlTree;
      
      public function ManipulatedNodesModel()
      {
         
      }
      
      public function get containsSubAssociations():Boolean {
         return _containsSubAssocations;
      }
      
      public function get containsPublicSubAssocations():Boolean {
         return _containsPublicSubAssocations;
      }
      
      public function get containsPrivateTrees():Boolean {
         return _containsPrivateTrees;
      }
      
      /*public function get containsAssoWithPendingRequests():Boolean {
      return _containsAssoWithPendingRequests;
      }*/
      
      public function get startAssociationId():int {
         return _startAssociationId;
      }
      
      public static function getStartAssociationId(draggedNode:IPTNode):int {
         var bnode:BroPTNode = draggedNode.getBusinessNode();
         if (bnode is BroPTRootNode) {
            bnode = bnode.owner.refInParent;
         }
         if (bnode.owner) {
            return bnode.owner.getAssociationId();
         } else {
            return ApplicationManager.getInstance().currentUser.getAssociation().associationId;
         }
      }
      
      public function updateManipulatedNodesFromDraggedNode(draggedNode:IPTNode, updateChildren:Boolean = true):void{
         if (updateChildren) {
            _containsSubAssocations =  _containsPrivateTrees = false;
            setContainPublicAssociations(false);
            _startAssociationId = getStartAssociationId(draggedNode);
            flush();
            _draggedPearlTree = draggedNode.getBusinessNode().owner;
            if (draggedNode.getBusinessNode() is BroPTRootNode) {
               _draggedPearlTree = _draggedPearlTree.refInParent.owner;
            }
            _nodes = new Dictionary(true);
            var nodesToLookAt:Array = new Array();
            nodesToLookAt.push(draggedNode);
            _nodes[draggedNode] = draggedNode;
            while(nodesToLookAt.length > 0){ 
               var node:IPTNode = nodesToLookAt[0];
               for each(var successor:IPTNode in node.successors){
                  var edge:IEdge = successor.edgeToParent;
                  if(edge && edge.data && (edge.data is EdgeData) && (!(edge.data as EdgeData).temporary)){
                     _nodes[successor] = successor;
                     nodesToLookAt.push(successor);
                  } 
               }
               checkWhatNodesContain(node as PTNode, _startAssociationId);
               nodesToLookAt.shift();
            }
            Log.getLogger("com.broceliand.ui.interactors.ManipulatedModel").info("Manipulated node root {0}, startAssociation={1} containsSubAssociation={2}",draggedNode.name, _startAssociationId, _containsSubAssocations);
         } else {
            _nodes = new Dictionary(true);
            _nodes[draggedNode] = draggedNode;
         }
         refreshNodeRenderers(_nodes);        
      }
      public function checkWhatNodesContain(node:PTNode, startAssociationId:int):void {
         if (node == null) {
            
            return;
         }
         var bnode:BroPTNode = node.getBusinessNode();
         var tree:BroPearlTree = null;
         if (bnode is BroPTRootNode) {
            tree = bnode.owner;   
         } else if (bnode is BroLocalTreeRefNode) {
            tree = BroLocalTreeRefNode(bnode).refTree;

         }
         if (tree) {
            var subTrees:Array = tree.treeHierarchyNode.getDescendantTrees(true,false);
            for each (var t:BroPearlTree in subTrees) {
               if (!_containsSubAssocations && t.getAssociationId() != startAssociationId) {
                  _containsSubAssocations = true;
               }
               if (!_containsPublicSubAssocations && t.getAssociationId() != startAssociationId && !t.isPrivate()) {
                  setContainPublicAssociations(true);
               }
               if (!_containsPrivateTrees && t.isPrivate()) {
                  _containsPrivateTrees = true;
               }
               
               /*if (!_containsAssoWithPendingRequests && t.hasTeamRequestsToAccept()) {
               _containsAssoWithPendingRequests = true;
               }
               if (_containsSubAssocations && _containsPublicSubAssocations && _containsPrivateTrees && _containsAssoWithPendingRequests) return;*/
               if (_containsSubAssocations && _containsPublicSubAssocations && _containsPrivateTrees) return;
            } 
         }
      }
      
      private function setContainPublicAssociations(value:Boolean):void {
         if (_containsPublicSubAssocations != value) {
            _containsPublicSubAssocations = value;
         }
      }
      public static function checkContainsSubAssociation(node:PTRootNode, startAssociationId:int):Boolean {
         if (node == null) {
            return false;
         }
         var bnode:BroPTNode = node.getBusinessNode();
         var tree:BroPearlTree = null;
         if (bnode is BroPTRootNode) {
            tree = bnode.owner;   
         }  else if (bnode is BroLocalTreeRefNode) {
            tree = BroLocalTreeRefNode(bnode).refTree;
         } 
         if (tree) {
            var subTrees:Array = tree.treeHierarchyNode.getDescendantTrees(true,false);
            for each (var t:BroPearlTree in subTrees) {
               if (t.getAssociationId() != startAssociationId) {
                  return true;
               }
            } 
         }
         return false;
      }
      
      public function isNodeManipulated(node:IPTNode):Boolean{
         if(!_nodes){
            return false;
         }
         return (_nodes[node] != null);
      }

      private function refreshNodeRenderers(dict:Dictionary):void{
         for each(var node:IPTNode in dict){
            var renderer:IUIPearl = node.renderer;
            if(renderer){
               renderer.refresh();
            }
         }
      }
      public function fillManipulatedBusinessNode2IPTNodeDictionary(bnode2IPTNode:Dictionary):void {
         if (_nodes) {
            for each (var n:IPTNode in _nodes) {
               var bnode:BroPTNode = n.getBusinessNode();
               if (n is PTRootNode && PTRootNode(n).isOpen()) {
                  bnode = bnode.owner.refInParent;
               }
               bnode2IPTNode[bnode] = n;
            }
         }
      }
      
      public function flush():void{
         if(_nodes){
            var copy:Dictionary = _nodes;
            _nodes = null;
            refreshNodeRenderers(copy);
         }
         _draggedPearlTree = null;
         _containsSubAssocations = false;
         
      } 
      
      public function isDraggedNodeTree(tree:BroPearlTree):Boolean {
         return tree && tree == _draggedPearlTree;
      }
      
      public function isPrivateNodeTree():Boolean {
         return _draggedPearlTree && _draggedPearlTree.isPrivate();
      }
      
      public function savePearlRef(node:IPTNode):SavedPearlReference {
         return new SavedPearlReference(node);
      }

   }
}