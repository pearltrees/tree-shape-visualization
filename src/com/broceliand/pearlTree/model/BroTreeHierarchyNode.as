package com.broceliand.pearlTree.model
{
   import com.broceliand.util.Alert;
   import com.broceliand.util.logging.Log;
   
   public class BroTreeHierarchyNode
   {
      private static const MAX_LOOP:int= 15000; 
      
      private var _tree:BroPearlTree;

      private var _parentTree:BroTreeHierarchyNode;
      
      private var _childTrees:Array;
      
      private var _isAlias:Boolean;
      
      public function BroTreeHierarchyNode(tree:BroPearlTree)
      {
         _tree = tree;
         _isAlias = false;
      }
      
      public function set isAlias (value:Boolean):void
      {
         _isAlias = value;
      }
      public function get isAlias ():Boolean
      {
         return _isAlias;
      }

      public function addChild(childNode:BroTreeHierarchyNode, changeSubTreesAssociations:Boolean = true):void {
         Log.getLogger("com.broceliand.pearlTree.model.BroTreeHierarchyNode").info("add Child node parent: {0} {1} ({2}) child :{3} {4}({5}) child isOwner: {6}",_tree.traceId(), _tree.title, _tree.id,  childNode._tree.traceId(), childNode._tree.title, 
            childNode._tree.id, childNode._tree.isOwner)
         
         if (childNode._parentTree) {
            childNode._parentTree.removeChild(childNode);
            if (!childNode.isAlias) {
               var oldAssociation:BroAssociation = childNode._tree.getMyAssociation();

               if (changeSubTreesAssociations && oldAssociation != _tree.getMyAssociation() && (!childNode._tree.isAssociationRoot()||oldAssociation.isDissolvedAssociation ))   {
                  _tree.getMyAssociation().moveTreeFromOtherAssociationWithDescendant(childNode._tree);  
               }
            }
         } 
         childNode._parentTree = this;
         getOrMakeChildTrees().push(childNode);
      }
      private function getOrMakeChildTrees():Array {
         if (_childTrees == null) {
            _childTrees = new Array();
         }
         return _childTrees;
      }
      public function removeChild(childNode:BroTreeHierarchyNode):void {
         var i:int = _childTrees.lastIndexOf(childNode);
         if (i>=0) {
            _childTrees.splice(i,1);
         }
      }

      public function getTreePath(limitToParent:BroPearlTree=null):Array {
         var node:BroTreeHierarchyNode = this;
         var result:Array= new Array();
         
         var indexForInfiniteLoop:uint = 0;
         while (node != null) {           
            indexForInfiniteLoop++;
            if(indexForInfiniteLoop > MAX_LOOP){
               throw new Error("Infinite loop in hierarchy of "+_tree.title);
            }
            result.unshift(node._tree);
            if(limitToParent && node._tree == limitToParent) {
               break;
            }
            node = node._parentTree;
         }
         
         return result;
      }

      public function getDescendantTrees(skipAlias:Boolean=false, limitedToAssociation:Boolean=false, withPrivate:Boolean=true):Array {
         var result:Array= new Array();
         
         if (!_tree.getMyAssociation()) {
            Log.getClassLogger(this).error("No association set for {0}", tree.title);
            return result;
         }
         
         var assoId:int = _tree.getMyAssociation().associationId;
         var nodeToProcess:Array= new Array();
         nodeToProcess.push(this);
         var node:BroTreeHierarchyNode;
         
         var indexForInfiniteLoop:uint = 0;
         while (nodeToProcess.length>0) {
            indexForInfiniteLoop++;
            if(indexForInfiniteLoop > MAX_LOOP){
               throw new Error("Infinite loop in hierarchy of "+_tree.title);
            }

            node = nodeToProcess.shift();  
            if (node._childTrees && !node.isAlias) {
               for each (var child:BroTreeHierarchyNode in node._childTrees) {
                  if((!limitedToAssociation || child.tree.getMyAssociation().associationId == assoId)
                     && (withPrivate || !child.tree.isPrivate())) {
                     nodeToProcess.push(child);
                  }
                  
               }
            }
            if (!skipAlias || !node.isAlias ) {
               result.push(node._tree);   
            }
            
         }
         
         return result;
         
      }
      
      public function getChildTrees(withAlias:Boolean=true,withPrivate:Boolean=true):Array {
         var result:Array= new Array();
         if (_childTrees) {
            for each (var n:BroTreeHierarchyNode in _childTrees) {
               if (withAlias || !n.isAlias) {
                  result.push(n._tree);
               }
            }
         }
         return result;
      }
      public function get tree ():BroPearlTree {
         return _tree ;
      }
      public function get parentTree ():BroPearlTree {
         return (_parentTree ==null? null:_parentTree._tree) ;
      }
      public function removeFromParent():void {
         if(_parentTree) {
            _parentTree.removeChild(this);
            _parentTree = null;
         }
      }
   }
}