package com.broceliand.ui.interactors
{
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.util.BroceliandMath;
   
   import flash.geom.Point;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class InteractorUtils
   {
      private static function addDescendantsToArray(n:IVisualNode, ret:Array):void{
         for each(var nChild:INode in n.node.successors){
            addDescendantsToArray(nChild.vnode, ret);
            ret.push(nChild.vnode);
         }
      }
      
      public static function getDescendants(n:IVisualNode):Array{
         var ret:Array = new Array();
         addDescendantsToArray(n, ret);
         return ret;
      }
      
      public static function getDescendantsAndVNode(n:IVisualNode):Array{
         var ret:Array = getDescendants(n);
         ret.push(n);
         return ret;
      }

      public static function getChildIndex(parentNode:INode, childNode:INode):int {
         var index:int = -1;
         if (parentNode!=null) {
            var successors:Array = parentNode.successors;
            for (var i:int=0; i<successors.length; i++) {
               if (childNode == successors[i]) {
                  index = i;
                  break;
               }
            }
         }
         return index;
      } 		
      
      public static function getParentAngle(vnode:IVisualNode, parentVn:IVisualNode=null):Number {
         if (!parentVn) {
            var parent:IPTNode = (vnode.node as IPTNode).parent;
            parentVn = parent.vnode;
         }
         
         var dx:Number =  vnode.x - parentVn.x;
         var dy:Number = vnode.y - parentVn.y;
         var draggedAngle:Number = Geometry.polarAngle(new Point(dx, -dy));
         if (draggedAngle > Math.PI) draggedAngle-= 2*Math.PI;
         return draggedAngle;
      }
      
      public static function getNearestNode(targetNode:IPTNode, maxDistance:Number):IPTNode{
         var squareMaxDistance:Number = maxDistance * maxDistance;
         var min:Number = uint.MAX_VALUE;
         var ret:IPTNode = null;
         for each(var n:IVisualNode in targetNode.vnode.vgraph.visibleVNodes){
            if (!n.view || n.view.alpha<1) continue;
            
            var candidateNode:IPTNode = n.node as IPTNode;
            
            var parentTree:IPearlTreeModel = candidateNode.containingPearlTreeModel;
            if (candidateNode is EndNode) {
               if (!EndNode(candidateNode).canBeVisible ) {
                  if (candidateNode.vnode && candidateNode.vnode.view && candidateNode.vnode.view.alpha ==0) {
                     continue;
                  }
               }
               parentTree = PTRootNode(candidateNode.rootNodeOfMyTree).containedPearlTreeModel;
            }
            if (parentTree && (parentTree.openingState == OpeningState.CLOSING)) {
               continue;
            }
            if((n != targetNode.vnode) && (!candidateNode.isDocked)){
               var squareDistance:Number = BroceliandMath.getSquareDistanceBetweenPoints(n.viewCenter, targetNode.vnode.viewCenter);
               if(squareDistance < min){
                  min = squareDistance;
                  ret = n.node as IPTNode;
               }
            }
         }
         
         if(min > squareMaxDistance && maxDistance >0){
            return null;
         }else{
            return ret;
         }
      }
      
   }
}