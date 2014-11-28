package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.ui.model.NoteModel;
   
   public class BroDistantTreeRefNode extends BroTreeRefNode
   {
      
      private var _treeOwnership:BroTreeOwnership;

      public function BroDistantTreeRefNode(tree:BroPearlTree, user:User=null)
      {
         super(tree.dbId, tree.id);
         _treeOwnership = TreeOwnershipFactory.getInstance().setTreeOwnership(tree, tree.getMyAssociation());
         super.refTree = tree;

      }
      
      override public function get noteCount():int{
         var noteModel:NoteModel = ApplicationManager.getInstance().visualModel.noteModel;
         if(refTree.isDeleted() || refTree.isHidden()) {
            return 0;
         }
         else if(noteModel.isNotesLoaded(this)) {
            return super.noteCount;
         } 
         else {
            return refTree.rootPearlNoteCount;
         }
      }
      
      public function get user():User {
         return _treeOwnership.association.preferredUser;
      }

      override public function set refTree(o:BroPearlTree):void {
         _treeOwnership = TreeOwnershipFactory.getInstance().setTreeOwnership(o, o.getMyAssociation());
         super.refTree = o;
         
      }
      override public function makeCopy():BroPTNode {
         var newBroDistantTreeRefNode: BroDistantTreeRefNode = new BroDistantTreeRefNode(refTree.makeDelegate(), user);
         newBroDistantTreeRefNode.neighbourCount = neighbourCount;
         newBroDistantTreeRefNode.registerAsNewAlias();
         return newBroDistantTreeRefNode;
      }
      public function registerAsNewAlias():void {
         ApplicationManager.getInstance().pearlTreeLoader.updateTreHierarchyOnNewAlias(this);
      }
      override public function isContentTypeMatch(contentType:int, isRepresentative:Boolean = false):Boolean {
         return contentType == AmfTreeService.CONTENT_TYPE_TREE_LOCATION;
      }
      
      override public function isTitleEditable():Boolean {
         return false;
      }
      
   }
}