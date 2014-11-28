package com.broceliand.pearlTree.model {
   import com.broceliand.ApplicationManager;
   
   public class BroTreeRefNode extends BroPTNode {
      
      protected var _refTree:BroPearlTree = null;
      protected var _dateString:String = null;
      protected var _userId:Number = 0;
      
      private var _treeId:int;
      
      private var _treeDB:int;
      
      public function BroTreeRefNode(treeDB :int, treeId:int) {
         super();
         _treeDB = treeDB;
         _treeId = treeId;
      }
      
      public function get treeDB ():int {
         return _treeDB;
      }
      
      public function get treeId ():int {
         return _treeId;
      }
      
      override public function get title():String {
         if (refTree) {
            return refTree.title;
         }
         return super.title;
      }
      
      override public function set title(value:String):void {
         if(refTree){
            refTree.title = value;
         }
         super.title = value;
      }
      
      public function get userId():Number {
         return _userId;
      }
      
      public function set userId(o:Number):void {
         _userId = o;
      }
      public function get dateString():String {
         return _dateString;
      }
      
      public function set dateString(o:String):void {
         _dateString = o;
      }
      
      public function get refTree():BroPearlTree {
         return _refTree;
      }
      public function isRefTreeLoaded():Boolean {
         return refTree && refTree.pearlsLoaded;
      }
      
      override public function hasNoteNotification():Boolean {
         if(refTree && refTree.getRootNode()) {
            return refTree.getRootNode().hasNoteNotification();
         }
         return hasNoteNotification();
      }
      
      override public function unvalidateNoteNotification():void {
         if (refTree && refTree.getRootNode() && refTree.getRootNode().notifications) {
            refTree.getRootNode().notifications.unvalidateNoteNotification();
         }
         else {
            super.unvalidateNoteNotification();
         }
      }
      
      override public function set owner (value:BroPearlTree):void {
         if ( owner!=value && refTree) {
            
            if (value !=null) {
               
               if (value.treeHierarchyNode.getTreePath().lastIndexOf(refTree)==-1) {
                  value.treeHierarchyNode.addChild(refTree.treeHierarchyNode);
               }
            } else if (owner !=null) {
               owner.treeHierarchyNode.removeChild(refTree.treeHierarchyNode);
            }
            refTree.notifyHierarchyChanged();
         }
         super.owner= value;
      }
      
      public function set refTree(o:BroPearlTree):void {

         if(refTree){
            if(refTree.authorsLoaded && !o.authorsLoaded) {
               o.owner = refTree.getMyAssociation();
               o.authorsLoaded = true;
            }
         }
         
         if (o && o.id != treeId && o.id>0) {
            _treeId = o.id;
            _treeDB = o.dbId;
         }
         _refTree = o;
      }
      
      override public function makeCopy():BroPTNode {
         var user:User = ApplicationManager.getInstance().visualModel.navigationModel.getSelectedUser();
         var newBroDistantTreeRefNode: BroDistantTreeRefNode = new BroDistantTreeRefNode(refTree.makeDelegate(), user);
         newBroDistantTreeRefNode.neighbourCount = neighbourCount;
         newBroDistantTreeRefNode.registerAsNewAlias();
         return newBroDistantTreeRefNode;
      }
      
      public function isContentTypeMatch(contentType:int, isRepresentative:Boolean = false):Boolean {
         return false;
      }
      
      public function changeNodeType(targetNode:BroTreeRefNode):void {
         targetNode.setPersistentId(1, persistentID, true);
         targetNode.title = title;
         
         targetNode.owner = owner;
         targetNode.neighbourCount = this.neighbourCount;
         targetNode.serverNoteCount = this.serverNoteCount;
         targetNode.serverFullFeedNoteCount = this.serverFullFeedNoteCount;
         targetNode.inTreeSinceTime = this.inTreeSinceTime;
         targetNode.commentsAck = this.commentsAck;
         
         targetNode.notifications = this.notifications;
         super.replaceNodeLinks(targetNode);
      }
      
      override public function isRefTreePrivate():Boolean {
         if (refTree != null) {
            return refTree.isPrivate();
         }
         return false;
      }
      public function isTeamOrHasSubTeam():Boolean {
         if (refTree != null) {
            if (!refTree.isTeamRoot()) {
               return refTree.hasSubTeam();
            }
            return true;
         }
         return false;
      }
      public function hasRequestOrSubRequest():Boolean {
         if (refTree != null) {
            return refTree.hasRequestOrSubRequest();
         }
         return false;
      }
      
      override public function getRepresentedTree():BroPearlTree {
         return refTree;
      }
      
   }
}