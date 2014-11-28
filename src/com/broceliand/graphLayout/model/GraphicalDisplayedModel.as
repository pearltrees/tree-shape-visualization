package com.broceliand.graphLayout.model
{
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.util.logging.BroLogEvent;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.Dictionary;

   public class GraphicalDisplayedModel
   {
      private var _vgraph:IPTVisualGraph;
      
      private var _tree2RootNodes:Dictionary=new Dictionary();
      
      public function GraphicalDisplayedModel(vgraph:IPTVisualGraph)
      {
         _vgraph = vgraph;
      }

      public function getCurrentFocusedTree():BroPearlTree {
         
         if (_vgraph.currentRootVNode) {
            var node:IPTNode= _vgraph.currentRootVNode.node  as IPTNode;
            return getTreeFromRootNode(node);   
         }  return null;
         
      }
      
      public function getTreeFromRootNode(node:IPTNode):BroPearlTree {
         if (node){
            if (node.getBusinessNode() is BroPTRootNode) {
               return node.getBusinessNode().owner;
            } else if (node.getBusinessNode() is BroLocalTreeRefNode) {
               return (node.getBusinessNode() as BroLocalTreeRefNode).refTree;
            } 
         } 
         return null;
      }

      public function getNode(tree:BroPearlTree):IPTNode {
         return   _tree2RootNodes[tree];
      }
      
      public function onTreeGraphBuilt(rootOfTheTree:IPTNode):void {
         if (rootOfTheTree is PTRootNode) {
            
            _tree2RootNodes[getTreeFromRootNode(rootOfTheTree)] =rootOfTheTree;
         } else throw Error("Invalid rootTree"); 
      } 
      public function onNodeRemovedFromGraph(node:IPTNode):void {
         var tree:BroPearlTree = getTreeFromRootNode(node as PTRootNode);
         
         if (tree && _tree2RootNodes[tree] == node) {

            delete _tree2RootNodes[tree];
         }
      }

   }
}