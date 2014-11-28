package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.io.exporter.IPearlTreeQueue;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   import com.broceliand.ui.interactors.InteractorUtils;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.util.Assert;
   
   import flash.geom.Point;
   import flash.net.registerClassAlias;
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;
   
   public class DraggingOnStringInteractor
   {
      
      private var _dx:Number;
      private var _dy:Number;
      private var _previousVNode:IVisualNode;
      private var _maxDistance:Number;
      private var _stringLength:Number;	
      private var _editionController:IPearlTreeEditionController;
      private var _canSwapBetweenChild:Boolean=false;
      private var _canSwapWithPrevious:Boolean=false;
      private var _canSwapWithNext:Boolean = true;
      private var _movenode2SavedPosition:Dictionary= new Dictionary();
      private var _movedNodes:Array = new Array();
      private var _treeToSave:Dictionary = new Dictionary();
      private var _rightsManager:InteractorRightsManager = null;
      private var _hasSwapped:Boolean = false;      
      private static const LITTLE_MOVE_DISTANCE:int  =2; 

      public function DraggingOnStringInteractor(draggedNode:IVisualNode, editionController:IPearlTreeEditionController, rightsManager:InteractorRightsManager)
      {
         _editionController = editionController;
         _rightsManager = rightsManager;
         initStringData(draggedNode, true);            
      }
      private function initStringData(draggedNode:IVisualNode, firstInit:Boolean = false):void {
         var nextNode:INode = null;
         var draggedNodeRoot:PTRootNode = draggedNode.node as PTRootNode;
         var oppositeCoef :Number =1;
         _canSwapWithNext = true;
         
         if (draggedNode.node.successors.length==1 && INode(draggedNode.node.successors[0]).vnode.isVisible) {
            nextNode = draggedNode.node.successors[0];
         } 
         
         _previousVNode= draggedNode.node.predecessors[0].vnode;
         var nextEndNode:EndNode = nextNode as EndNode;
         if (nextEndNode && !nextEndNode.canBeVisible ) {
            _canSwapWithNext = false; 
            nextNode = null;
         }
         
         if (nextNode == null && !firstInit) {
            nextNode = IPTNode(_previousVNode.node).parent;
            oppositeCoef = -1;
         }  
         
         if (nextNode==null) {
            nextNode = draggedNode.node;
         }
         
         _canSwapWithPrevious = _previousVNode.node.predecessors.length>0  && _previousVNode.node.predecessors[0].vnode.isVisible;
         
         if(_canSwapWithPrevious){
            
            if(!_rightsManager.userHasRightToAddChildrenToNode(draggedNode.node.predecessors[0])){
               _canSwapWithPrevious = false;
            }          	
         }
         _canSwapWithNext = _canSwapWithNext && _rightsManager.userHasRightToAddChildrenToNode(draggedNode.node.successors[0])
         if (nextEndNode && !nextEndNode.canBeVisible ) {
            _canSwapWithNext = false; 
         }
         
         if (draggedNodeRoot) {
            var startAsso:int = ManipulatedNodesModel.getStartAssociationId(draggedNodeRoot); 
            var containsSubAssociation:Boolean = ManipulatedNodesModel.checkContainsSubAssociation(draggedNodeRoot, startAsso);
            if (containsSubAssociation) {
               if (_canSwapWithNext) {
                  _canSwapWithNext =  !((draggedNode.node.successors[0] is PTRootNode) || (draggedNode.node.successors[0] is EndNode)) ;  
               }
               if (_canSwapWithPrevious) {
                  _canSwapWithPrevious = !((draggedNode.node.successors[0] is PTRootNode) || (draggedNode.node.successors[0] is EndNode));
               }
               _canSwapWithPrevious = false;
            }
         }

         _dx = nextNode.vnode.x - _previousVNode.x;
         _dy = nextNode.vnode.y - _previousVNode.y;
         
         _stringLength= Math.sqrt(_dx*_dx+_dy*_dy);
         if (_stringLength ==0) _stringLength+=1E-10; 
         _dx /= (oppositeCoef*_stringLength);
         _dy /= (oppositeCoef*_stringLength);
         _maxDistance = computeDistanceToString(draggedNode);
         
      }
      private function computeDistanceToString(draggedNode:IVisualNode):Number {
         draggedNode.refresh();
         var dx:Number= draggedNode.x - _previousVNode.x;
         var dy:Number= draggedNode.y - _previousVNode.y;
         return Math.abs(dy*_dx - dx * _dy); 
      }
      
      private function distanceToPrevious(node:IVisualNode):Number {
         node.refresh();
         var dx:Number= node.x - _previousVNode.x;
         var dy:Number= node.y - _previousVNode.y;   
         
         return (dx*_dx + dy * _dy); 
         
      }
      
      public function isDraggingOnString(v:IVisualNode):Boolean {
         var draggedNode:IPTVisualNode = v as IPTVisualNode;
         Assert.assert(draggedNode != null, "IPTVisualNode should be used here instead of IVisualNode");
         
         var currentDistanceToString:Number= computeDistanceToString(draggedNode);
         if (currentDistanceToString < _maxDistance) {
            _maxDistance= currentDistanceToString;
         } 
         var currentPosition:Number= distanceToPrevious(draggedNode);
         if (currentPosition<0) {
            if (IPTNode(draggedNode.node).parent.parent ==null) {
               return false;
            }
         } else if (currentPosition>_stringLength *1.01) {
            return false;
         }
         if (_canSwapBetweenChild && findNewBestChildIndex(draggedNode) !=-1) {
            return true;
         }
         return currentDistanceToString <_maxDistance + draggedNode.pearlView.pearlWidth * 0.6;
      }
      
      public function swapPearlIfNeeded(v:IVisualNode):Boolean {
         var draggedNode:IPTVisualNode = v as IPTVisualNode;
         Assert.assert(draggedNode != null, "IPTVisualNode should be used here instead of IVisualNode");                      
         
         var currentPosition:Number= distanceToPrevious(draggedNode);
         var hasSwapped:Boolean = false;
         
         if (_canSwapWithPrevious && currentPosition  < draggedNode.pearlView.pearlWidth + LITTLE_MOVE_DISTANCE ) {
            moveNode(draggedNode.node.predecessors[0], true);
         } else if (currentPosition  > _stringLength  - draggedNode.pearlView.pearlWidth - LITTLE_MOVE_DISTANCE ) {
            if (draggedNode.node.successors.length>0 && IPTNode(draggedNode.node.successors[0]).vnode.isVisible) {
               moveNode(draggedNode.node.successors[0], false);
               
            }
         } else {
            cancelMovedNodes();
         } 
         
         if ( currentPosition<  LITTLE_MOVE_DISTANCE && _canSwapWithPrevious) {
            hasSwapped = swapPearlWithPrevious(draggedNode);
         }
         if (currentPosition > _stringLength && _canSwapWithNext) {
            hasSwapped = swapPearlWithNext(draggedNode);

         }
         if (_canSwapBetweenChild) {

            var newIndex:Number = findNewBestChildIndex(draggedNode);
            if (newIndex>=0) {
               hasSwapped = _editionController.swapStringNodeChildIndex(draggedNode, newIndex);
            }
         }
         if (hasSwapped) {
            saveCurrentTreeof(draggedNode);
            _canSwapBetweenChild = true;
            initStringData(draggedNode);
            _hasSwapped = true;
         }
         return hasSwapped;
      }

      private function findNewBestChildIndex(draggedNode:IVisualNode ):int {
         draggedNode.refresh();
         var parent:IPTNode = (draggedNode.node as IPTNode).parent;
         var children:Array = parent.successors;
         var bestIndex:int = -1;
         var draggedAngle:Number = InteractorUtils.getParentAngle(draggedNode);
         var minDistanceAngle:Number = 10;
         var childAngle:Number=0;
         if (children.length>1) {
            for (var i:int=0; i<children.length;i++) {
               var childVnode:IVisualNode = children[i].vnode;
               if (childVnode == draggedNode) {
                  var grandChildVnode:IVisualNode= draggedNode;
                  if (draggedNode.node.successors.length>0) {
                     grandChildVnode= draggedNode.node.successors[0].vnode;	
                  }
                  var dx:Number =  grandChildVnode.x - parent.vnode.x;
                  var dy:Number =  grandChildVnode.y - parent.vnode.y;
                  childAngle = Geometry.polarAngle(new Point(dx, -dy));
                  if (childAngle > Math.PI) childAngle-= 2*Math.PI;
                  if (Math.abs(childAngle-draggedAngle)<minDistanceAngle) {
                     minDistanceAngle = Math.abs(childAngle-draggedAngle);
                     bestIndex = -1;
                  }
                  
               } else {
                  childAngle = InteractorUtils.getParentAngle(children[i].vnode);
                  if (Math.abs(childAngle-draggedAngle)<minDistanceAngle) {
                     minDistanceAngle = Math.abs(childAngle-draggedAngle);
                     bestIndex = i;
                  }
               }
            }
            
         }

         return bestIndex;
         
      }
      
      private function swapPearlWithPrevious( draggedNode:IVisualNode):Boolean {
         saveCurrentTreeof(draggedNode);
         saveCurrentTreeof(IPTNode(draggedNode.node.predecessors[0]).vnode );
         return _editionController.swapNodeWithParent(draggedNode, draggedNode.node.predecessors[0].vnode);
      }
      private function swapPearlWithNext( draggedNode:IVisualNode):Boolean {
         saveCurrentTreeof(draggedNode);
         return _editionController.swapNodeWithChild(draggedNode);
      }  
      
      private function saveCurrentTreeof(vnode:IVisualNode):void {
         
         var node:IPTNode = vnode.node as IPTNode;
         if (_treeToSave[node.containingPearlTreeModel.businessTree] == null) {
            addTreeToSave(node.containingPearlTreeModel.businessTree);
         }
         if (node is PTRootNode && PTRootNode(node).isOpen()) {
            addTreeToSave(PTRootNode(node).containedPearlTreeModel.businessTree);
         }
         
      }
      private function addTreeToSave(tree:BroPearlTree):void {
         if (!tree) {
            return;
         }
         var queue:IPearlTreeQueue = ApplicationManager.getInstance().persistencyQueue;
         if (_treeToSave[tree] == null) {
            queue.registerInQueue(tree);
            _treeToSave[tree] = true;
         }
      }
      private function moveNode(node:INode, toRight:Boolean):void {
         if (_movenode2SavedPosition[node] != null) {
            return;
         }
         var isRight:Number = toRight?1:-1;
         
         node.vnode.refresh();
         _movenode2SavedPosition[node] = new Point(node.vnode.x, node.vnode.y);
         _movedNodes.push(node);
         node.vnode.x += isRight * _dx* LITTLE_MOVE_DISTANCE;
         node.vnode.y += isRight * _dy* LITTLE_MOVE_DISTANCE;
         node.vnode.commit();
         
      }
      
      private function cancelMovedNodes():void {
         while (_movedNodes.length>0) {
            var n:INode =_movedNodes.pop();
            var p:Point = _movenode2SavedPosition[n];
            n.vnode.x= p.x;
            n.vnode.y= p.y;
            n.vnode.commit();
            delete _movenode2SavedPosition[n];
         }        	
      }
      public function get hasSwapped():Boolean {
         return _hasSwapped;
      }
   }
}