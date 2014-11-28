package com.broceliand.ui.interactors.drag
{
   import com.broceliand.graphLayout.controller.CloseBranchAnimation;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.DepthInteractor;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   import com.broceliand.util.Assert;
   
   import flash.geom.Point;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;
   
   public class DraggingOnArcState
   {
      private var _endNodeDetachementManager:EndNodeDetachementManager;
      private var _startLength:Number;
      private var _childAngles:Array;
      private var _gparentAngle:Number;
      private var _minAngle:Number;           
      private var _maxAngle:Number;
      private var _startingIndex:Number;
      private var _excitedLeftNode:IVisualNode;
      private var _excitedRightNode:IVisualNode;
      private var _vgraph:IVisualGraph;
      private var _branchCloser:CloseBranchAnimation;
      private var _depthInteractor:DepthInteractor;
      
      public function DraggingOnArcState(draggedVnode:IVisualNode, endNodeDetachementManager:EndNodeDetachementManager, branchCloser:CloseBranchAnimation, depthInteractor:DepthInteractor)
      {
         initState(draggedVnode);
         _vgraph = draggedVnode.vgraph;
         _endNodeDetachementManager = endNodeDetachementManager;
         _branchCloser = branchCloser;
         _depthInteractor = depthInteractor;
      }
      public function initState(v:IVisualNode): void{
         var vnode:IPTVisualNode = v as IPTVisualNode;
         Assert.assert(vnode != null, "IPTVisualNode should be used here instead of IVisualNode");

         var parentNode:IPTNode= IPTNode(vnode.node.predecessors[0]);
         var parentVn:IVisualNode = parentNode.vnode;
         
         _gparentAngle =0;

         if (parentNode.predecessors.length>0 && parentNode.predecessors[0] != null && parentNode.predecessors[0].vnode.isVisible) {
            var gpVnode:IVisualNode = parentNode.predecessors[0].vnode;
            gpVnode.refresh(); 
            
            _gparentAngle = Geometry.polarAngle(new Point(parentVn.x- gpVnode.x, -parentVn.y + gpVnode.y));
            if (_gparentAngle > Math.PI) _gparentAngle-= 2*Math.PI;
         } 
         
         vnode.refresh();
         parentVn.refresh();
         
         var dx:Number = vnode.x- parentVn.x;
         var dy:Number = vnode.y- parentVn.y;
         _startLength = Math.sqrt(dx*dx+dy*dy);

         var deltaAngle:Number = (vnode.pearlView.pearlWidth + GeometricalConstants.LITTLE_MOVE_DISTANCE) / _startLength ;
         _childAngles = new Array(parentNode.successors.length);
         for (var i:int=0; i<parentNode.successors.length;i++) {
            var child:IVisualNode = (parentNode.successors[i]as INode).vnode;
            if (child.isVisible) {
               child.refresh();    	
            }
            
            if (child == vnode) {
               _startingIndex =i;
            } 
            dx = child.x - parentVn.x;
            dy = child.y - parentVn.y;
            
            var parentAngle:Number = Geometry.polarAngle(new Point(dx, -dy));
            if (parentAngle > Math.PI + _gparentAngle) parentAngle-= 2*Math.PI;
            _childAngles[i] = parentAngle; 	
         }
         _maxAngle= _childAngles[0]+ deltaAngle;
         _minAngle = _childAngles[_childAngles.length-1]  - deltaAngle;         
         
      }
      
      public function shouldNodeBeDetached(vnode:IVisualNode):Boolean {
         var parentVn:IVisualNode = INode(vnode.node.predecessors[0]).vnode;
         var dx:Number  =vnode.viewCenter.x - parentVn.x;
         var dy:Number  =vnode.viewCenter.y - parentVn.y;
         var newLength:Number = Math.sqrt(dx*dx+dy*dy);
         var parentAngle:Number = Geometry.polarAngle(new Point(dx, -dy));
         if (parentAngle > Math.PI + _gparentAngle) parentAngle-= 2*Math.PI;
         return parentAngle<_minAngle || parentAngle>_maxAngle ||newLength > _startLength*GeometricalConstants.DISTANCE_BREAK_LINK_FACTOR ;      	
      }
      private function getParentNodeAngle(vnode:IVisualNode):Number {
         var parentVn:IVisualNode = INode(vnode.node.predecessors[0]).vnode;
         var dx:Number  =vnode.viewCenter.x - parentVn.x;
         var dy:Number  =vnode.viewCenter.y - parentVn.y;
         var parentAngle:Number = Geometry.polarAngle(new Point(dx, -dy));
         if (parentAngle > Math.PI + _gparentAngle) parentAngle-= 2*Math.PI;
         return parentAngle;
         
      }
      
      public function exciteSurroundingNodes(vnode:IVisualNode):void {
         
         var currentParentAngle:Number = getParentNodeAngle(vnode);
         var parentNode:INode= INode(vnode.node.predecessors[0]);
         var previousIndex:int = -1;
         var nextIndex:int = -1;
         for (var i:int=0; i<parentNode.successors.length;i++) {
            var child:IVisualNode = (parentNode.successors[i]as INode).vnode;
            if (!child.isVisible) continue;
            if (i==_startingIndex) continue;
            if (getParentNodeAngle(child)> currentParentAngle) {
               previousIndex = i;
            } else if (nextIndex==-1) {
               nextIndex =i;
            }
         }
         if (previousIndex+1 != _startingIndex) {
            updateExcitedNodes(parentNode, previousIndex, true);
            updateExcitedNodes(parentNode, nextIndex, false);
            
         } else {
            if (_excitedLeftNode) {
               restoreNodePosition(_excitedLeftNode, true);
            }
            if (_excitedRightNode) {
               restoreNodePosition(_excitedRightNode, false);
            }
         }
         _endNodeDetachementManager.onChangeNodePositionByDraggingOnArc(vnode,nextIndex == -1);
         
         if (previousIndex+1 != _startingIndex){
            _branchCloser.startAnimation(vnode.vgraph as IPTVisualGraph, vnode.node as IPTNode, _depthInteractor);
            var edge:IEdge = vnode.node.inEdges[0];
            if (edge) {
               (edge.data as EdgeData).temporary = true;
            }
         }

      }
      
      private function updateExcitedNodes(parentNode:INode, index:int, isLeft:Boolean):void {
         var newLeftNode:IVisualNode =  null;
         if (index>=0) {
            newLeftNode= INode(parentNode.successors[index]).vnode;
         }
         var oldLeftNode :IVisualNode = isLeft?_excitedLeftNode:_excitedRightNode;
         
         if (oldLeftNode != newLeftNode) {
            if (oldLeftNode !=null) restoreNodePosition(oldLeftNode, isLeft);
            
            if (newLeftNode) {
               exciteNode(parentNode.vnode, newLeftNode, isLeft);
            }
            if (isLeft) {
               _excitedLeftNode = newLeftNode;
            } else {
               _excitedRightNode = newLeftNode;
            }
            
         } 

      }
      private function exciteNode(parentNode:IVisualNode, vnode:IVisualNode, toLeft:Boolean):void {
         var root:IVisualNode = vnode.vgraph.currentRootVNode;
         var dx:Number  =vnode.x - root.x;
         var dy:Number  =vnode.y - root.y;
         var distanceToRoot:Number = Math.sqrt(dx*dx+dy*dy);
         var parentAngle:Number = Geometry.polarAngle(new Point(dx, dy));
         var deltaAngle:Number = GeometricalConstants.LITTLE_MOVE_DISTANCE/ distanceToRoot;
         var newAngle :Number= parentAngle+(toLeft? -1:1) *deltaAngle;
         moveVnodeTo(vnode, vnode.x + distanceToRoot * (Math.cos(newAngle) - Math.cos(parentAngle)),
            vnode.y + distanceToRoot * (Math.sin(newAngle) - Math.sin(parentAngle))); 
      }
      private function moveVnodeTo(vnode:IVisualNode, x:Number, y:Number) :void{
         var target:IUIPearl = vnode.view as IUIPearl;
         if(!target) return;
         var pearlXOffset:Number = target.pearlCenter.x - target.x;
         var pearlYOffset:Number = target.pearlCenter.y - target.y;        	  
         target.move(x - pearlXOffset , y - pearlYOffset); 
      }

      private function restoreNodePosition(node:IVisualNode, wasLeft:Boolean):void {
         moveVnodeTo(node, node.x, node.y);
      }
      
      public function restoreNodePositions():void {
         if (_excitedLeftNode) restoreNodePosition(_excitedLeftNode, true);
         if (_excitedRightNode) restoreNodePosition(_excitedRightNode, false);	
      }
   }
}