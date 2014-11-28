package com.broceliand.pearlTree.model{
   import com.broceliand.ApplicationManager;

   public class BroPTRootNode extends BroPTNode
   {
      public override function toString():String {
         return "ROOT NODE";
      }
      
      override public function get title ():String {
         if (owner){
            return owner.title;
         }
         return super.title;   
      }
      
      public function isAssociationHierarchyRoot():Boolean {
         return  (owner && owner.isAssociationRoot());
      }
      override public function makeCopy():BroPTNode {
         
         var user:User = ApplicationManager.getInstance().visualModel.navigationModel.getSelectedUser();
         var newBroDistantTreeRefNode:BroDistantTreeRefNode= new BroDistantTreeRefNode(this.owner.makeDelegate(), user);
         newBroDistantTreeRefNode.neighbourCount = neighbourCount;
         newBroDistantTreeRefNode.registerAsNewAlias();
         return newBroDistantTreeRefNode;
      }
      override public function setCollectedStatus():void {
         if (owner && owner.refInParent) {
            owner.refInParent.setCollectedStatus();
         }
      }
      override public function setEditedStatus():void {
         if (owner && owner.refInParent) {
            owner.refInParent.setEditedStatus();
         }
      }
      
      override public function isRefTreePrivate():Boolean {
         return isOwnerPrivate();
      }
      
      override public function isTitleEditable():Boolean {
         if (owner.isUserRoot()) {
            return false;
         } return super.isTitleEditable();
      }
      
   }
}