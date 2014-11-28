package com.broceliand.graphLayout.autoReorgarnisation
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.util.BroUtilFunction;
   
   import flash.utils.Dictionary;
   
   public class LayoutReorganizer
   {
      private var _squareOfMaxDistanceBetweenPearls:Number; 
      private var _maxDistance:Number;
      private var _maxFirstWeight:Number;
      private var _threshold:Number;
      public static var DefaultDistance:Number = 375;
      public function LayoutReorganizer(maxDistanceBetweenPearls:Number =375)
      {
         maxDistanceBetweenPearls = DefaultDistance; 
         _squareOfMaxDistanceBetweenPearls = maxDistanceBetweenPearls * maxDistanceBetweenPearls;
         _maxDistance = maxDistanceBetweenPearls;
         _maxFirstWeight = 2 * Math.PI * maxDistanceBetweenPearls / GeometricalConstants.MIN_NODE_SEPARATION;
         _threshold =  1 + 2 *Math.sqrt(_maxDistance * _maxDistance - GeometricalConstants.LINK_LENGTH *GeometricalConstants.LINK_LENGTH) /GeometricalConstants.MIN_NODE_SEPARATION;
      }  
      
      public function computeNodeWeights(tree:ITree, node:Object, result:Dictionary, depth:int):Number{
         var childCount:Number = tree.getChildNodeCount(node);
         var endNodeCount:Number=0;
         if (childCount ==0 && depth>0) {
            endNodeCount= 1 /depth;
         } else {
            for (var i:int=0; i<childCount ; i++) {
               endNodeCount +=  computeNodeWeights(tree, tree.getChildAt(node, i), result, depth +1);
            }
         }
         if (depth >0 ) {
            endNodeCount = Math.max(endNodeCount, 1/depth);
         }
         result[node] = endNodeCount
         return endNodeCount;
      }
      
      public function checkCurrentLayout(tree:ITree):Boolean{
         return false;
      }
      
      public function checkCurrentLayoutAtLevel(tree:ITree, startDepth:int =0, startReorganzingDepth:int=-1):Boolean{
         
         var weights:Dictionary = new Dictionary();
         var rootNode:Object = tree.rootNode;
         var w0:Number = computeNodeWeights(tree, rootNode, weights, 0);
         var theta0:Number = w0 * GeometricalConstants.MIN_NODE_SEPARATION  / GeometricalConstants.LINK_LENGTH;
         if (theta0 > 2* Math.PI) {
            theta0 = 2* Math.PI;
         }
         var nodeByLevel:Array = new Array();
         nodeByLevel.push(tree.rootNode);
         var nextLevelNodes:Array = new Array();
         var nodeToReorganize:Array = null;
         
         var level:int =0;
         while(nodeByLevel.length>0 && nodeToReorganize == null) {
            nodeToReorganize = checkLevelWeight(tree, nodeByLevel, weights, nextLevelNodes, level, theta0, w0, startReorganzingDepth);
            var emptyArray:Array = nodeByLevel;
            nodeByLevel = nextLevelNodes;
            nextLevelNodes = emptyArray;
            if (level < startDepth) {
               nodeToReorganize = null;
            }
            level++;
         }
         if (nodeToReorganize != null) {
            if (startReorganzingDepth == -1 ) {
               startReorganzingDepth = level -1;
            }
            reorganizeTree(tree, nodeToReorganize, level-1);
            checkCurrentLayoutAtLevel(tree, level,  startReorganzingDepth);
            return true;
         }
         return false;
         
      }
      private function reorganizeTree(tree:ITree, nodeToReorganize:Array, depth:int):void {
         
         for each (var n:Object in nodeToReorganize) {
            reorganizeChildren(tree, n, depth);
         }
      }
      private function reorganizeChildren(tree:ITree, rootNode:Object, depth:int):void {
         var children:Array = new Array();
         for (var i:int=0 ; i<tree.getChildNodeCount(rootNode); i++) {
            children.push(tree.getChildAt(rootNode,i));
         }
         for (var j:int = depth==0 ? 1 : 0; j<children.length-1;j ++){
            var endNode:Object = children[j];
            var childCount:int;
            while ((childCount= tree.getChildNodeCount(endNode))>0) {
               endNode = tree.getChildAt(endNode, childCount-1);
            }
            
            moveNode(tree, children[j+1] ,endNode)
            j++;
         }
      }
      private function moveNode(tree:ITree, moveNode:Object, newParent:Object):void {
         tree.moveNode(moveNode, newParent);
      }
      private function isNodeTooBig(tree:ITree, node:Object, depth:int, w0:Number, weight:Number, startReorganzingDepth:int):Boolean {
         var firstTry:Boolean = startReorganzingDepth == -1;
         var childCount:int = tree.getChildNodeCount(node); 
         if (firstTry) {
            return ((childCount> _threshold -7) && (weight > _maxFirstWeight / (depth +1))); 
         } else {
            var threshold:int = _threshold;
            switch (depth -startReorganzingDepth) {
               case 1: 
                  threshold +=3;
                  break;
               case 2 :
                  threshold +=1;
                  break;
               default:
            }
            return childCount>threshold;
         }
      }
      private function checkLevelWeight(tree:ITree, nodeByLevel:Array, weights:Dictionary, nextLevelNodes:Array, depth:int, theta0:Number, w0:Number, startReorganzingDepth:int):Array {
         var result:Array = null;
         while (nodeByLevel.length>0) {
            var n:Object = nodeByLevel.shift();
            
            if (isNodeTooBig(tree, n, depth, w0, weights[n], startReorganzingDepth)) {
               result = BroUtilFunction.addToArray(result,n);
            }
            var childCount:int = tree.getChildNodeCount(n);
            for (var i:int=0; i<childCount ; i++) {
               var child:Object = tree.getChildAt(n,i);
               nextLevelNodes.push(child);
            }
         }
         return result;
      }
   }
}