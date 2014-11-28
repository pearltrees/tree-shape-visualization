package com.broceliand.graphLayout.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.ui.list.PTRepeater;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class PTRootNode extends PTNode{

      private var _containedPearlTreeModel:IPearlTreeModel;

      public function PTRootNode(id:int, sid:String, vn:IVisualNode, o:BroPTNode)
      {
         super(id, sid, vn, o);
         _containedPearlTreeModel = new PearlTreeModel(this);
      }
      
      public function isOpen():Boolean {
         return _containedPearlTreeModel.endNode!=this || _containedPearlTreeModel.openingState== OpeningState.OPEN;
      }
      
      public override function get isTopRoot():Boolean {
         if (isEnded()) {
            return false;
         }
         return _containedPearlTreeModel.businessTree ==  ApplicationManager.getInstance().visualModel.navigationModel.getFocusedTree() || vnode.vgraph.currentRootVNode == vnode;
      }
      
      /* 		public function get ownerRootNode():IPTNode {
      return _ownerRootNode;
      }
      
      public function set ownerRootNode(o:IPTNode):void {
      _ownerRootNode = o;
      } */
      
      public function get containedPearlTreeModel():IPearlTreeModel {
         return _containedPearlTreeModel;
      }
      
      override public function get rootNodeOfMyTree():IPTNode {
         return this;
      }
      
      override public function getDescendantsAndSelf():Array{
         return getDesc(_containedPearlTreeModel);
      }
      override public function updatingNumberOfDescendant():Number{
         
         if (isOpen()|| _containedPearlTreeModel.openingState== OpeningState.CLOSING) {
            return super.updatingNumberOfDescendant();
         }
         else {
            var refNode:BroLocalTreeRefNode = (getBusinessNode() as BroLocalTreeRefNode);
            if (refNode) {
               _numDescendantCache = super.updatingNumberOfDescendant() + refNode.refTree.totalDescendantPearlCount;
               return _numDescendantCache;
            }
            return super.updatingNumberOfDescendant();
            
         }
      }
      public function replaceNode(targetNode:PTRootNode, displayModel:GraphicalDisplayedModel):void {
         targetNode._containedPearlTreeModel = _containedPearlTreeModel;
         if (_containedPearlTreeModel.endNode != this && _containedPearlTreeModel.endNode) {
            EndNode(_containedPearlTreeModel.endNode).rootNodeOfMyTree = targetNode;
            if (targetNode.getBusinessNode() is BroTreeRefNode) {
               targetNode.setBusinessNode(BroTreeRefNode(targetNode.getBusinessNode()).refTree.getRootNode());
            }
         }
         PearlTreeModel(_containedPearlTreeModel).replaceNode(targetNode);
         displayModel.onTreeGraphBuilt(targetNode);
      }
      public function setBusinessNode(node:BroPTNode):void {

         if (_businessNode!= node) {
            if (_businessNode) {
               _businessNode.graphNode = null;
            } 
            node.graphNode = this;
            _businessNode = node;
         }
         
      }
   }
}