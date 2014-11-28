package com.broceliand.pearlTree.model{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.notification.PearlNotification;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   import com.broceliand.pearlTree.model.paginatedlists.PaginatedList;
   import com.broceliand.ui.model.NeighbourModel;
   import com.broceliand.ui.model.NoteModel;
   import com.broceliand.util.Alert;
   import com.broceliand.util.Assert;
   
   import mx.effects.easing.Back;

   public class BroPTNode
   {
      
      private var _graphNode:IPTNode;
      private var _tempId:int = 0;
      private var _persistentID:int = -1;
      private var _persistentDbID:int = -1;
      private var _parentLink:BroLink;
      private var _childLinks:Array;
      protected var _owner:BroPearlTree;
      private var _neighbours:IPaginatedList;
      private var _serverNoteCount:int = 0;
      private var _serverFullFeedNoteCount:int = 0;
      protected var _noteMode:uint;
      private var _noteModeHasChanged:Boolean = false;
      private var _isFirstChange:Boolean = true;
      private var _noteModeSaved:Boolean;
      private var _neighbourCount:Number = 0;
      private var _title:String;
      private var _notifications:PearlNotification;
      private var _inTreeSinceTime:Number;
      private var _inTreeSinceVersion:int;
      private var _lastEditorUserId:int;
      private var _deletedByUser:Boolean;
      private var _commentsAck:Number = 0;
      private var _skipNotificationOnPersist:Boolean;
      private var _editionStatus:int = 0;
      private var _originId:Number = 0;

      public static const DATA_FORMAT_BROPTNODE:String = "DATA_FORMAT_BROPTNODE";
      function BroPTNode(){
         _childLinks=new Array();
         _notifications = new PearlNotification();
         _noteModeSaved = true;
         _noteMode = NoteModel.MODE_TREE_DEFAULT;
      }
      
      public function get skipNotificationOnPersist():Boolean {
         return _skipNotificationOnPersist;
      }
      
      public function set skipNotificationOnPersist(value:Boolean):void {
         _skipNotificationOnPersist = value;
      }
      
      public function set deletedByUser(value:Boolean):void {
         _deletedByUser = value;
      }
      
      public function get deletedByUser():Boolean {
         return _deletedByUser;
      }
      
      public function get inTreeSinceTime():Number{
         return _inTreeSinceTime;
      }
      
      public function set inTreeSinceTime(value:Number):void{
         _inTreeSinceTime = value;
      }
      
      public function get inTreeSinceVersion():int{
         return _inTreeSinceVersion;
      }
      
      public function set inTreeSinceVersion(value:int):void{
         _inTreeSinceVersion = value;
      }
      
      public function get lastEditorUserId():int{
         return _lastEditorUserId;
      }
      
      public function set lastEditorUserId(value:int):void{
         _lastEditorUserId = value;
      }
      
      public function set noteMode(value:uint):void{
         _noteMode = value;
      }
      public function get noteMode():uint{
         return _noteMode;
      }
      
      public function set noteModeSaved(value:Boolean):void{
         _noteModeSaved = value;
      }
      public function get noteModeSaved():Boolean{
         return _noteModeSaved;
      }
      
      public function get notifications():PearlNotification{
         return _notifications;
      }
      
      public function set notifications(value:PearlNotification):void{
         _notifications = value;
      }
      
      public function hasNotifications():Boolean{
         return _notifications && (_notifications.hasNotesNotification()|| _notifications.hasCrossingNotification());
      }
      
      public function hasNoteNotification():Boolean {
         if (!_notifications) return false;
         var noteModel:NoteModel = ApplicationManager.getInstance().visualModel.noteModel;
         if (noteModel.isNotesLoaded(this)) {
            return ((_notifications.hasNotesNotification() || noteModel.isInRealTime(this)) && !noteModel.isNotesLoadedAndRead(this));
         }
         else {
            return _notifications.hasNotesNotification();
         }
      }
      
      public function unvalidateNoteNotification():void {
         if (_notifications) {
            _notifications.unvalidateNoteNotification();
            if (owner) {
               owner.notifyNotificationUnvalidated();
            }
         }
      }
      
      public function hasNotificationCross():Boolean {
         return _notifications && _notifications.hasCrossingNotification();
      }
      
      static public function getPearlKey(pearlDb:Number, pearlId:Number):String {
         return ""+pearlDb+":"+pearlId;
      }
      
      public function set title (value:String):void {
         _title = value;
         if (_owner !=null) {
            owner.notifyPearlTitleChange(this);
         }
      }
      
      public function get title ():String {
         return _title;
      }
      
      public function set owner (value:BroPearlTree):void {
         var oldOwner:BroPearlTree = owner;
         _owner = value;
         if (oldOwner != value) {
            if (oldOwner) {
               oldOwner.resetCache();
               oldOwner.notifyPearlRemoved(this);
               oldOwner.notifyLostNode(this, value);
            }
            if (value) {
               value.resetCache();
               if (persistentID<0) {
                  value.assignAutoId(this);
               }
            }
            if (oldOwner && _owner && oldOwner.isPrivate() != _owner.isPrivate()) {
               _noteModeHasChanged = true;
            }
         }
      }
      public function get owner ():BroPearlTree {
         return _owner;
      }
      
      public function get neighbourCount():Number {
         if (isRefTreePrivate()) {
            return 0;
         } else {
            return getNeighbourCount();
         }
      }
      
      public function set neighbourCount (value:Number):void {
         if(value == 0) _neighbours = new PaginatedList();
         if(_neighbourCount != value) {
            _neighbourCount = value;
            ApplicationManager.getInstance().visualModel.neighbourModel.neighbourCountChanged(this);
         }
      }
      
      public function getNeighbourCount(cacheResult:Boolean=true):Number {
         if (isRefTreePrivate()) {
            return 0;
         } else {
            return _neighbourCount;
         }
      }
      
      public function get neighbours():IPaginatedList {
         if (isRefTreePrivate()) {
            return null;
         } else {
            return _neighbours;
         }
      }
      
      public function set neighbours(value:IPaginatedList):void {
         _neighbours = value;
         if(neighbourCount != _neighbours.numberOfItems && _neighbours.numberOfItems < NeighbourModel.MAX_NEIGHBOUR_TO_USE_AS_COUNT){
            if(owner) owner.notifyNewNeighbour();
            neighbourCount = _neighbours.numberOfItems;
         }
      }
      
      public function get noteCount():int{
         var noteModel:NoteModel = ApplicationManager.getInstance().visualModel.noteModel;
         return noteModel.getNoteCount(this);
      }

      public function set serverNoteCount(value:int):void{
         _serverNoteCount = value;
      }
      
      public function get serverNoteCount():int{
         return _serverNoteCount;
      }

      public function set serverFullFeedNoteCount (value:int):void{
         _serverFullFeedNoteCount = value;
      }
      public function get serverFullFeedNoteCount():int{
         return _serverFullFeedNoteCount;
      }
      
      public function notifyNewNote():void{
         if(_owner){
            _owner.notifyNewNote();
         }
      }
      public function notifyNewNeighbour():void {
         if(_owner){
            _owner.notifyNewNeighbour();
         }
      }
      
      public function addChildLink(aLink:BroLink, index:int):void {
         if (persistentID == 46997183) {
            trace("JAY gg");
         }
         
         if (index>=0)
            _childLinks.splice(index, 0, aLink);
         else
            _childLinks.push(aLink);
      }
      
      public function set parentLink(val:BroLink):void {
         _parentLink = val;
      }
      
      public function get parentLink():BroLink {
         return _parentLink;
      }

      public function get childLinks():Array {
         return _childLinks;
      }
      
      public function getChildIndex(node:BroPTNode):int {
         if (_childLinks) {
            for (var i:int =0; i<_childLinks.length; i++) {
               if (BroLink(childLinks[i]).toPTNode == node) {
                  return i;
               }
            }
         }
         return -1;
      }
      
      public function toString():String {
         return "pearl ("+persistentID+"):"+title;
      }
      
      public function get parent():BroPTNode {
         if (parentLink !=null) {
            return parentLink.fromPTNode;
         }
         return null;
      }
      
      public function get depth():Number {
         if (parent !=null) {
            return parent.depth+1; 
         }
         return 0;
      }
      
      public function removeAllNodes():void {
         _childLinks = new Array();
      }
      
      public function removeChildLink(link:BroLink):Boolean {
         var index:int = _childLinks.lastIndexOf(link);
         if (index>=0) {
            _childLinks.splice(index,1);
            return true;
         }
         return false;
      }
      
      public function getChildAt(index:int):BroPTNode{
         if (index>=0 && index<childLinks.length) {
            return BroLink(childLinks[index]).toPTNode;
         }
         Assert.assert(false, "invalid index : "+index+" for "+toString());
         return null;
      }
      
      public function getChildCount():int {
         return (_childLinks?_childLinks.length:0);
      }
      
      public function setPersistentId(persistentDB:int, persistentID:int, isNewNode:Boolean ):void {
         if(_persistentDbID != persistentDB || _persistentID != persistentID) {
            _persistentDbID = persistentDB;
            _persistentID = persistentID;
            
            var noteModel:NoteModel = ApplicationManager.getInstance().visualModel.noteModel;
            noteModel.registerNodeToNotifyChange(this, isNewNode);
            if(isPersisted()) {
               noteModel.processNotesToSave(this);
               if(!_noteModeSaved) {
                  noteModel.saveNoteMode(this);
                  _noteModeSaved = true;
               }
            }
            
            ApplicationManager.getInstance().visualModel.neighbourModel.neighbourCountChanged(this);
         }
      }
      
      public function isPersisted():Boolean {
         return (_persistentDbID > 0 && _persistentID > 0);
      }
      
      public function get persistentID ():int {
         return _persistentID;
      }
      
      public function get persistentDbID ():int {
         return _persistentDbID;
      }
      public function getDescendantCount():int {
         var count:int = 1;
         for each (var l:BroLink in childLinks) {
            count += l.toPTNode.getDescendantCount();
         }
         return count;
      }

      public function getDescendants():Array {
         var descendants:Array = new Array();
         for each (var l:BroLink in childLinks) {
            descendants.push(l.toPTNode);
            descendants = descendants.concat(l.toPTNode.getDescendants());
         }
         return descendants;
      }
      
      public function getDescendantCommentCount():int {
         var count:int = noteCount;
         for each (var l:BroLink in childLinks) {
            count += l.toPTNode.getDescendantCommentCount();
         }
         return count;
      }
      
      public function getDescendantNeighbourCount(cacheResult:Boolean=true):int {
         var count:int = getNeighbourCount(cacheResult);
         for each (var l:BroLink in childLinks) {
            count += l.toPTNode.getDescendantNeighbourCount(cacheResult);
         }
         return count;
      }
      
      public function isCurrentUserOwner():Boolean {
         if(owner) return owner.isCurrentUserAuthor();
         else return false;
      }
      
      static public function getNodeKey(nodeDb:int, nodeId:int):String {
         return ""+nodeDb+"_"+nodeId;
      }
      
      public function getKey():String {
         return getNodeKey(persistentDbID, persistentID);
      }
      
      public function set tempId (value:int):void {
         _tempId = value;
      }
      
      public function get tempId ():int {
         return _tempId;
      }
      
      public function set commentsAck(value:Number):void {
         _commentsAck = value;
      }
      
      public function get commentsAck():Number {
         return _commentsAck;
      }
      
      public function makeCopy():BroPTNode {
         Alert.show("copying this kind of node is not yet supported");
         return null;
      }
      
      public function isLastNodeOfTree():Boolean {
         if (getChildCount()>0) {
            return false;
         } else {
            var node:BroPTNode = this;
            var parentNode:BroPTNode = parent;
            var isLastNode:Boolean = true;
            while (parentNode) {
               if (parentNode.getChildAt(parentNode.getChildCount()-1)  != node) {
                  isLastNode = false;
                  break;
               } else {
                  node = parentNode;
                  parentNode = parentNode.parent;
               }
            }
            return isLastNode;
         }
      }
      
      public function isLastEditor():Boolean {
         return _lastEditorUserId == ApplicationManager.getInstance().currentUser.persistentId;
      }
      
      protected function replaceNodeLinks(targetNode:BroPTNode):void {
         for each (var l:BroLink in childLinks) {
            l.replaceNode(this, targetNode);
         }
         parentLink.replaceNode(this, targetNode);
         targetNode.parentLink = this.parentLink;
         targetNode._childLinks = _childLinks;
         _childLinks = new Array();
      }
      
      public function get graphNode():IPTNode {
         return _graphNode;
      }
      
      public function set graphNode(value:IPTNode):void {
         _graphNode = value;
      }
      public function setEditedStatus():void {
         _editionStatus = 1;
      }; 
      public function setCollectedStatus():void {
         _editionStatus = 0;
      }
      public function isEdited():Boolean {
         return _editionStatus == 1;
      }
      public function get originId():Number
      {
         return _originId;
      }
      
      public function set originId(value:Number):void
      {
         _originId = value;
      }
      
      public function isOwnerPrivate():Boolean {
         if (owner != null) {
            return owner.isPrivate();
         }
         return false;
      }
      public function isRefTreePrivate():Boolean {
         return false;
      }
      
      public function get noteModeHasChanged():Boolean{
         return _noteModeHasChanged;
      }
      
      public function set noteModeHasChanged(value:Boolean):void{
         _noteModeHasChanged = value;
      }

      public function getRepresentedTree():BroPearlTree {
         return owner;
      }

      public function canBeCopy():Boolean {
         var tree:BroPearlTree = getRepresentedTree();
         if (tree && tree.isPrivate() && !tree.isCurrentUserAuthor()) {
            return false;
         }
         return true;
      }
      
      public function isTitleEditable():Boolean {
         return owner && owner.isCurrentUserAuthor() && !owner.isPrivatePearltreeOfCurrentUserNotPremium();     
      }

   }
}