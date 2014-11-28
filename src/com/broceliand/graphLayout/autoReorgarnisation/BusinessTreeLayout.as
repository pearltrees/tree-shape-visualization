package com.broceliand.graphLayout.autoReorgarnisation
{
   import com.broceliand.ui.interactors.InteractorRightsManager;
   
   public class BusinessTreeLayout
   {
      public function BusinessTreeLayout()
      {
      }
      
      public function checkLayoutIsValid(tree:ITree):Boolean {
         var nodesByLevel:Array = buildNodesByLevelArray(tree);
         for (var i:int = 1; i< nodesByLevel.length; ++i) {
            if ((nodesByLevel[i] as Array).length > i * InteractorRightsManager.MAX_NODE_BY_LEVEL) {
               return false;
            }
         }
         return true;
      }
      
      internal static  function buildNodesByLevelArray(tree:ITree):Array {
         
         var nodesByLevel:Array = new Array();
         nodesByLevel.push(new Array(tree.rootNode));
         var i:int = 0;
         while (i<nodesByLevel.length) {
            var parentNodes:Array = nodesByLevel[i++];
            var nextLevelNode:Array = null;
            for (var j:int = 0; j<parentNodes.length; j++) {
               var childNodeCount:int = tree.getChildNodeCount(parentNodes[j]);
               for (var k:int =0; k<childNodeCount; k++) {
                  if (!nextLevelNode) {
                     nextLevelNode = new Array();
                     nodesByLevel.push(nextLevelNode);
                  }
                  nextLevelNode.push(tree.getChildAt(parentNodes[j], k));
               }
            }
         }
         return nodesByLevel;
      }
      
      private function computeRadiusFirstPass(nodesByLevel:Array, minNodeSeparation:Number, radiusInc:Number):Array{
         var radiusArray:Array = new Array();
         var nbNode:int=0;
         var currentRadius :Number= 0;
         for (var i:int = 1; i< nodesByLevel.length; i++) { 
            nbNode= (nodesByLevel[i] as Array).length;
            currentRadius = Math.round(Math.max(currentRadius+ radiusInc, nbNode*minNodeSeparation/(2*Math.PI)));
            
            var preferredRadius:Number = getComputedPreferredRadiusAtLevel(i, nbNode, radiusArray, radiusInc) ;
            
            if (preferredRadius> currentRadius) {
               currentRadius = preferredRadius;
            }
            radiusArray.push(currentRadius);
            i++;
         }
         return radiusArray;
      }
      
      private function getComputedPreferredRadiusAtLevel(i:int, nbOfPearlsAtLevel:int, radiusArray:Array, radiusInc:Number):Number {
         if (i==1) {
            if ( nbOfPearlsAtLevel < 10) {
               return radiusInc + (180- radiusInc)* nbOfPearlsAtLevel /10
            }  else if ( nbOfPearlsAtLevel > 9 && nbOfPearlsAtLevel < 15) {
               return 180 + (nbOfPearlsAtLevel - 10) / 5 * 10;
            } else return 190;
         } else if (i == 2) {
            return radiusArray[0] + 1.4 * radiusInc; 
         } else if (i ==3) {
            return radiusArray[1] + 1.2 * radiusInc;
         } 
         return radiusArray[i-2] + radiusInc;
      }

   }
}

import com.broceliand.graphLayout.autoReorgarnisation.BusinessTree;
import com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2;
import com.broceliand.util.Assert;
import com.broceliand.util.logging.BroLogger;
import com.broceliand.util.logging.Log;

import flash.utils.Dictionary;

import org.un.cava.birdeye.ravis.utils.Geometry;

class PearlGroup {
   
   private var _indexes:Array;
   private var _groupLeftIndex:int;
   private var _isPositioned:Boolean;
   private var _tree:BusinessTree;
   
   public function PearlGroup(tree:BusinessTree, parentIndex:int):void {
      _indexes = new Array();
      _groupLeftIndex = parentIndex;
      _indexes.push(parentIndex);
      _isPositioned = false;
   }
   
   public function positionNodesInGroup(parentNodes:Array, indexWithChildren:Array, deltaToFill:Array, offsetBetweenDeltasInGroup:Array):void {
      if (!_isPositioned) {
         _isPositioned = true;
         var i:int;
         var currentSum:Number = 0;
         var totalSum:Number = 0;
         for (i=1; i<_indexes.length; i++) {
            currentSum += offsetBetweenDeltasInGroup[_indexes[i]];
            totalSum += currentSum;
         }

         var delta:Number = - totalSum / _indexes.length;
         for (i=0; i<_indexes.length; i++) {
            if (i>0) {
               delta += offsetBetweenDeltasInGroup[_indexes[i]]; 
            }
            deltaToFill[indexWithChildren[_indexes[i]]] = delta;
            if (delta != 0 && ConcentricRadialLayoutV2.DEBUG) {
               var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.autoReorgarnisation.BusinessTreeLayout");
               logger.info("Positioning group {2} : Delta Position of {0} in deg = {1}", ( parentNodes[indexWithChildren[_indexes[i]]]), Geometry.rad2deg(delta),
                  (parentNodes[indexWithChildren[_groupLeftIndex]]));  
            }
         }
      } 
   }
   
   private function getRightGroupAngle(parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaOfParent:Array, sizeInRadOfNode:Number, checkChildrendHitting:Boolean):Number {
      var lastIndex:int = _indexes.length -1;
      var leftIndex:int =indexWithChildren[_indexes[lastIndex]];
      var leftNode:Object= parentNodes[leftIndex];
      var childCount:int = checkChildrendHitting?_tree.getChildNodeCount(leftNode):1;
      return tetaAtLevel[leftIndex] + deltaOfParent[leftIndex] - childCount  * (sizeInRadOfNode/2); 
   }
   
   private function getLeftGroupAngle(parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaOfParent:Array, sizeInRadOfNode:Number,checkChildrendHitting:Boolean):Number {
      var rightIndex:int =indexWithChildren[_indexes[0]];
      var rightNodeParent:Object= parentNodes[rightIndex];
      var childCount:int = checkChildrendHitting?_tree.getChildNodeCount(rightNodeParent):1;
      return tetaAtLevel[rightIndex] + deltaOfParent[rightIndex] + childCount * (sizeInRadOfNode/2);
   }
   
   public function isHittingRightGroup(rightGroup:PearlGroup, parentNodes:Array, indexWithChildren:Array, tetaAtLevel:Array, deltaOfParent:Array, sizeInRadOfNode:Number, checkChildrendHitting:Boolean):Boolean {
      
      var rightAngleLeftGroup:Number = getRightGroupAngle(parentNodes, indexWithChildren, tetaAtLevel, deltaOfParent, sizeInRadOfNode, checkChildrendHitting );
      var add2PI:Boolean = _indexes[_indexes.length-1] > rightGroup._groupLeftIndex;
      if (add2PI ) {
         rightAngleLeftGroup += Math.PI * 2;
      }
      var leftAngleRightGroup:Number = rightGroup.getLeftGroupAngle(parentNodes, indexWithChildren, tetaAtLevel, deltaOfParent, sizeInRadOfNode, checkChildrendHitting);
      if (ConcentricRadialLayoutV2.DEBUG) {
         var logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.layout.ConcentricRadialLayoutV2");
         logger.info("Test grouping grouping left group {0} (angle = {2}) with right group {1} (angle = {3}", this.getName(parentNodes, indexWithChildren), rightGroup.getName(parentNodes, indexWithChildren),
            Geometry.rad2deg(rightAngleLeftGroup), Geometry.rad2deg(leftAngleRightGroup));     
      }
      return rightAngleLeftGroup < leftAngleRightGroup;
   }
   
   public function addRightGroup(rightGroup:PearlGroup):void {
      _isPositioned = false;
      for (var i:int =0; i< rightGroup._indexes.length; i++) {
         _indexes.push(rightGroup._indexes[i]);
      }
   }
   
   public function getName(parentNodes:Array, indexWithChildren:Array):String {
      var s:String = "[";
      for (var i:int =0; i< _indexes.length; i++) {
         if (i>0) {
            s+= ",";
         }
         s += _indexes[i];
      }
      s += "]";
      return (parentNodes[indexWithChildren[_groupLeftIndex]] ).toString()+ s;
   }
}
