package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.interactors.InteractorManager;
   
   import flash.events.MouseEvent;
   import flash.geom.Point;

   public class DropZoneInteractor extends RemovePearlInteractor
   {
      private var _draggedPearlIsOverDropZone:Boolean = false;
      
      public function DropZoneInteractor(interactorManager:InteractorManager){
         super(interactorManager);
         
      }
      
      private function enterDropZone():void {
         var node:IPTNode = _interactorManager.draggedPearl.node;
         _draggedPearlIsOverDropZone = true;
      } 

      private function exitDropZone():void{
         var node:IPTNode = _interactorManager.draggedPearl.node;
         _draggedPearlIsOverDropZone = false;
      }

      public function moveBranchToDropZone(node:IPTNode):void{
         var bnode:BroPTNode = node.getBusinessNode();
         if (bnode is BroPTRootNode) {
            var nm:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
            if (nm.getSelectedTree() == bnode.owner) {
               var ftree:BroPearlTree = nm.getFocusedTree();
               nm.goTo(ftree.getAssociationId(), nm.getSelectedUser().persistentId, ftree.id, ftree.id); 
            }

            bnode = bnode.owner.refInParent;
            
         }
         var descendantsToRemove:Array = node.getDescendantsAndSelf();
         var editionController:IPearlTreeEditionController = _interactorManager.pearlTreeViewer.pearlTreeEditionController;
         var descendantsBNode:Array = bnode.getDescendants();
         descendantsBNode.splice(0,0, bnode);
         for (var i:int=descendantsBNode.length; i-->0;) {
            var bnodeToDropZone:BroPTNode = descendantsBNode[i];
            var node:IPTNode = bnodeToDropZone.graphNode;
            if (node.parent) {
               editionController.tempUnlinkNodes(node.parent.vnode, node.vnode);
            }
            editionController.addNodeToDropZone(node);
            node.dock(_interactorManager.pearlTreeViewer.vgraph.controls.dropZoneDeckModel);
            if (node is PTRootNode && PTRootNode(node).isOpen()) {
               editionController.closeTreeNode(node.vnode,1,false);
            }  
         }
      }
      
      public function isMouseOverDropZone(event:MouseEvent):Boolean{
         var point:Point = new Point(event.stageX, event.stageY);
         return _interactorManager.pearlTreeViewer.vgraph.controls.isPointOverDropZoneDeck(point);          
      }
      
      public function handleDragForDropZone(event:MouseEvent):void{
         
         var isMouseOverDropZone:Boolean = isMouseOverDropZone(event);
         
         if (_interactorManager.manipulatedNodesModel.containsSubAssociations) {
            return ;
         }
         if(isMouseOverDropZone != _draggedPearlIsOverDropZone){
            if(isMouseOverDropZone){
               enterDropZone();
            }else{
               exitDropZone();
            }
         }
         
      }    
   }
}