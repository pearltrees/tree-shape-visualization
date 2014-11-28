package com.broceliand.graphLayout.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.events.FlexEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   
   public class ChangeNodeTypeAction 
   {
      private var _graphicalAnimationController:GraphicalNavigationController;
      private var _editionController:IPearlTreeEditionController= null;
      
      private var _oldIPTNode:IPTNode;
      private var _newNode:BroPTNode;
      private var _oldNode:BroPTNode;

      public function ChangeNodeTypeAction(ec:IPearlTreeEditionController, graphicalAnimationController:GraphicalNavigationController, 
                                           oldIPTNode:IPTNode, oldNode:BroPTNode, newNode:BroPTNode)
      {
         _editionController = ec;
         _graphicalAnimationController = graphicalAnimationController;
         if (oldIPTNode is EndNode) {
            _oldIPTNode = oldIPTNode.rootNodeOfMyTree;
         } else {
            _oldIPTNode = oldIPTNode;
         }
         _oldNode = oldNode;
         _newNode = newNode;
         
      }
      
      public function replaceGraphicalNode():IPTNode{
         var originNode:BroPTNode = _oldNode;
         var parentBNode:BroPTNode = originNode.parent;
         
         var originIndex:int = parentBNode.getChildIndex(_newNode);
         
         var newIPtNode:IPTNode = _editionController.createNode(_newNode);
         newIPtNode.vnode.view.addEventListener(FlexEvent.CREATION_COMPLETE, removeOldNode);
         
         if (_oldIPTNode.vnode.view) {
            var oldPosition:Point = _oldIPTNode.pearlVnode.pearlView.positionWithoutZoom;
            newIPtNode.pearlVnode.pearlView.moveWithoutZoomOffset(oldPosition.x, oldPosition.y);
            newIPtNode.pearlVnode.pearlView.animationZoomFactor =  _oldIPTNode.pearlVnode.pearlView.animationZoomFactor;
         }
         if (_oldIPTNode.isDocked) {
            newIPtNode.dock(_oldIPTNode.getDock()); 
         } else {
            var ptVgraph:IPTVisualGraph= _oldIPTNode.vnode.vgraph as IPTVisualGraph;
            var parentNode:IPTNode = null; 
            if (_oldIPTNode.predecessors.length>0) {
               parentNode = _oldIPTNode.predecessors[0] as IPTNode; 
            }
            
            var successors:Array =_oldIPTNode.successors;
            var n:INode;
            for (var i:int=successors.length; i-->0;) {
               n = _oldIPTNode.successors[i];
               ptVgraph.unlinkNodes(_oldIPTNode.vnode, n.vnode);
               ptVgraph.linkNodesAtIndex(newIPtNode.vnode, n.vnode,0);
            }
            if (parentNode) {
               ptVgraph.unlinkNodes(parentNode.vnode, _oldIPTNode.vnode);
               
               ptVgraph.linkNodesAtIndex(parentNode.vnode, newIPtNode.vnode, originIndex);
            }
            if (_oldIPTNode is PTRootNode && newIPtNode is PTRootNode) {
               PTRootNode(_oldIPTNode).replaceNode(newIPtNode as PTRootNode, _graphicalAnimationController.displayModel);
            }
            if (ptVgraph.currentRootVNode.node == _oldIPTNode) {
               ptVgraph.currentRootVNode = newIPtNode.vnode;
               ptVgraph.controls.unfocusButton.bindToNode(newIPtNode);
            }
         } 
         return newIPtNode;
      } 
      
      private function removeOldNode(event:Event):void {
         if (_oldIPTNode.isDocked) {
            _oldIPTNode.undock();
         }
         
         if (_oldIPTNode.vnode) {
            _oldIPTNode.vnode.vgraph.removeNode(_oldIPTNode.vnode);
         }
      }

   }
}
