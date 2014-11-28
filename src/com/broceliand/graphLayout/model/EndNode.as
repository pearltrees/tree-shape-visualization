package com.broceliand.graphLayout.model
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class EndNode extends PTNode{

      private var _rootNodeOfMyTree:IPTNode;
      private var _ownerTree:BroPearlTree;
      
      private var _canBeVisible:Boolean;

      public function EndNode(id:int, sid:String, vn:IVisualNode, tree:BroPearlTree) 
      {
         super(id, sid, vn, null);
         _ownerTree = tree;
         _canBeVisible = false;
      }

      override public function get rootNodeOfMyTree():IPTNode{
         return _rootNodeOfMyTree; 
      }

      public function set rootNodeOfMyTree(value:IPTNode):void{
         _rootNodeOfMyTree = value;
      }
      
      override public function get containingPearlTreeModel():IPearlTreeModel{
         return rootNodeOfMyTree.containingPearlTreeModel;	
      }
      
      override public function updatingNumberOfDescendant():Number{
         var ret:Number = super.updatingNumberOfDescendant();
         _numDescendantCache = ret;
         return ret-1;
      }
      
      override public function getBusinessNode():BroPTNode{
         return _ownerTree.refInParent;
         
      }
      override public function isOnLastBranch():Boolean {
         return rootNodeOfMyTree.isOnLastBranch();
      }    
      
      public function set canBeVisible (value:Boolean):void
      {
         if (_canBeVisible != value) {
            _canBeVisible = value;
            vnode.view.invalidateProperties();
         }
      }
      
      public function get canBeVisible ():Boolean
      {
         return _canBeVisible;
      }
      
      override public function toString():String {
         return "endNode of "+name;
      }
      
      override public function get treeOwner():BroPearlTree { 
         return _ownerTree;
      }
      override public function end():void {
         super.end();
      }

   }
}