package com.broceliand.pearlTree.model{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ApplicationMessageBroadcaster;
   import com.broceliand.pearlTree.io.LazyValueAccessor;
   import com.broceliand.pearlTree.io.loader.PearlHitsAndTeamCountsAccessor;
   import com.broceliand.pearlTree.io.loader.TeamInsideAccessor;
   import com.broceliand.pearlTree.io.sync.editions.TreeEdition;
   import com.broceliand.pearlTree.model.event.ChangeTreeEvent;
   import com.broceliand.pearlTree.model.notification.TreeNotification;
   import com.broceliand.pearlTree.model.team.ITeamRequestModel;
   import com.broceliand.pearlTree.model.treeEdito.TreeEdito;
   import com.broceliand.util.Assert;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.EventDispatcher;
   import flash.utils.setTimeout;
   
   public class BroPearlTree extends EventDispatcher
   {
      
      public static const DEFAULT_SERVER_TITLE:String = "unnamed map";
      public static const DEFAULT_PRIVATE_TITLE:String = "*private*";
      
      static public const VISIBLE:int = 0;
      static public const HIDDEN:int = 1;
      static public const PRIVATE:int = 2;
      
      static public const STATE_NORMAL:uint = 0;
      static public const STATE_DELETED:uint = 1;
      
      static public const OPEN:uint = 0;
      static public const COLLAPSED:uint = 1;
      static private var _autoIDGenerator:int =-2;
      
      static public const ORGANIZE_STATE_NORMAL:uint =0;
      static public const ORGANIZE_STATE_NOTIFY_SIMPLE:uint =1;
      static public const ORGANIZE_STATE_FORCED_ONLY:uint =2;
      static public const ORGANIZE_STATE_NOTIFY_FORCED:uint =3;
      static public const ORGANIZE_STATE_NOTIFY_BATCH:uint = 4;
      
      static public const TITLE_CHANGED:String  = "titleChanged";
      static public const HIERARCHY_CHANGED:String = "HIERARCHY_CHANGED";
      static public const NODE_TITLE_CHANGED:String = "NODE_TITLE_CHANGED";
      static public const NODE_OWNER_CHANGED:String = "NODE_OWNER_CHANGED";
      static public const TREE_STRUCTURE_CHANGED:String  = "TREE_STRUCTURE_CHANGED";
      
      static private var UID:int = -1;
      private var _debugId:int = UID --;
      private var _appliBroadcasterCached:ApplicationMessageBroadcaster;
      protected var _root:BroPTRootNode;
      protected var _treeHierarchy:BroTreeHierarchyNode;
      private var _hierarchyOwner:BroAssociation;
      private var _creationTime:Number;
      private var _lastEditorVisit:Number;
      [Bindable]
      private var _title:String;
      private var _id:int  = -1;
      private var _dbId:int = -1;
      private var _clientId:int;
      private var _version:int;
      private var _totalHitsPearlsAndTeamsAccessor:PearlHitsAndTeamCountsAccessor;
      private var _teamsInsideAccessor:TeamInsideAccessor;
      private var _isUsingHitsPearlsAndTeamsAccessor:Boolean = false;
      private var _hasEdito:Boolean;
      
      private var _lastModificationDate:Number = -1;
      private var _lastSaveDate:Number=0;
      private var _refInParent:BroLocalTreeRefNode;
      private var _treeOwnership:BroTreeOwnership;
      private var _authorsLoaded:Boolean = false;
      private var _pearlCount:uint=1;
      
      private var _isOwner:Boolean; 
      private var _rank:int = -1;
      private var _state:int;
      private var _neighbourPearlID:int;
      private var _neighbourPearlDB:int;
      private var _rootPearlDb:int;
      private var _rootPearlId:int;
      private var _rootPearlNoteCount:int;
      private var _rootPearlNeighbourCount:int;
      private var _hits:uint=0;
      private var _organize:uint=0;
      private var _visibility:uint=0;
      private var _collapsed:uint=0;
      private var _avatarHash:String;
      private var _backgroundHash:String;
      private var _containsSubTeam:Boolean;
      private var _containsSubRequest:Boolean;
      private var _cachedValues:HierarchicalTreeCachedValues = new HierarchicalTreeCachedValues();
      private var _pearlsLoaded:Boolean = false;
      private var _serverStructure:Array;
      private var _notifications:TreeNotification;      
      private var _mustRecomputeChildrenCount:Boolean=true;
      private var _treeEdito:TreeEdito = null;
      private var _totalMembershipCount:int;

      public function BroPearlTree() {
         _treeHierarchy = new BroTreeHierarchyNode(this);
         _id = _debugId;
      }
      
      public function get serverStructure():Array {
         return _serverStructure;
      }
      
      public function set serverStructure(value:Array):void {
         _serverStructure = value;
      }
      
      public function setRootTreeId(rootDb:int, rootId:int):void {
         if (_root) {
            _root.setPersistentId(rootDb,rootId, true);
         } else {
            _rootPearlDb = rootDb;
            _rootPearlId = rootId;
         }
      }

      public function get notifications():TreeNotification{
         return _notifications;
      }
      public function set notifications(value:TreeNotification):void{
         _notifications = value;
         notifyNotificationUnvalidated();
      }
      
      internal function get cachedValues ():HierarchicalTreeCachedValues {
         return _cachedValues;
      }
      
      public function get rank():int{
         return _rank;
      }
      public function set rank(value:int):void{
         _rank = value;
      }
      
      public function get state():int{
         return _state;
      }
      public function set state(value:int):void{
         _state = value;
      }
      public function isDeleted():Boolean {
         return (_state == STATE_DELETED);
      }
      public function isHidden():Boolean {
         return (_visibility == HIDDEN);
      }
      
      public function get neighbourPearlId():int{
         return _neighbourPearlID;
      }
      public function set neighbourPearlId(value:int):void{
         _neighbourPearlID = value;
      }
      
      public function get neighbourPearlDb():int{
         return _neighbourPearlDB;
      }
      public function set neighbourPearlDb(value:int):void{
         _neighbourPearlDB = value;
      }

      public function get isOwner():Boolean{
         return _isOwner;
      }
      public function set isOwner(value:Boolean):void{
         _isOwner = value;
      }
      
      public function get pearlsLoaded():Boolean{
         return _pearlsLoaded;
      }
      public function notifyEndLoadingPearl():void{
         _pearlsLoaded = true;
         cachedValues.resetCache(this);
      }
      public function resetCache():void {
         cachedValues.resetCache(this);
         if (isUsingHitsPearlsAndTeamsAccessor) {
            getHitsPearlsAndTeamLoader().resetValue();
         }
      }
      
      public function getTreeNodes():Array{
         if(!pearlsLoaded) return null;
         var nodes:Array = new Array();
         nodes.push(getRootNode());
         return nodes.concat(getRootNode().getDescendants());
      }
      
      private function recomputeChildrenCount():void {
         _pearlCount = 1;
         var descendants:Array = getRootNode().getDescendants();
         for each(var node:BroPTNode in descendants) {
            if(node is BroPageNode || node is BroLocalTreeRefNode || node is BroDistantTreeRefNode) {
               _pearlCount++;
            }
         }
         _mustRecomputeChildrenCount = false;
      }
      
      public function get pearlCount():uint {
         if(_pearlsLoaded && _mustRecomputeChildrenCount) {
            recomputeChildrenCount();
         }
         return (_pearlCount > 0)?(_pearlCount - 1):0;
      }
      public function set pearlCount(value:uint):void {
         _pearlCount = value;
      }
      
      public function isEmpty():Boolean {
         return (pearlCount < 1);
      }
      
      public function set rootPearlNoteCount (value:int):void {
         _rootPearlNoteCount = value;
         if(!_pearlsLoaded) {
            getRootNode().serverNoteCount = _rootPearlNoteCount;
            getRootNode().serverFullFeedNoteCount = _rootPearlNoteCount;
         }
      }
      public function get rootPearlNoteCount ():int {
         
         return getRootNode().noteCount;
      }
      
      public function set rootPearlNeighbourCount (value:int):void {
         _rootPearlNeighbourCount = value;
         if(!_pearlsLoaded) {
            getRootNode().neighbourCount = _rootPearlNeighbourCount;
         }
      }
      public function get rootPearlNeighbourCount ():int {
         
         return getRootNode().neighbourCount;
      }
      public function set hits(value:uint):void{
         _hits = value;
      }
      public function get hits():uint{
         return _hits;
      }
      
      public function set organize(value:uint):void {
         _organize = value;
      }
      public function get organize():uint {
         return _organize;
      }
      
      public function set visibility(value:uint):void {
         _visibility = value;
      }
      public function get visibility():uint {
         return _visibility;
      }
      
      public function set collapsed(value:uint):void {
         _collapsed = value;
      }
      public function get collapsed():uint {
         return _collapsed;
      }
      
      public function get treeHierarchyNode ():BroTreeHierarchyNode {
         return _treeHierarchy;
      }
      public function set hierarchyOwner (value:BroAssociation):void {
         _hierarchyOwner = value;
      }
      
      public function get hierarchyOwner ():BroAssociation {
         return _hierarchyOwner;
      }
      
      public function set owner(association:BroAssociation):void{
         _treeOwnership = TreeOwnershipFactory.getInstance().setTreeOwnership(this, association);
         authorsLoaded=true;
      }
      
      public function getMyAssociation():BroAssociation{
         if(_treeOwnership) {
            return _treeOwnership.association;
         }
         return null;
      }
      public function get authorsLoaded():Boolean{
         return _authorsLoaded;
      }
      public function set authorsLoaded(value:Boolean):void{
         _authorsLoaded = value;
      }
      
      public function get refInParent():BroLocalTreeRefNode {
         return _refInParent;
      }
      
      public function set refInParent(o:BroLocalTreeRefNode):void {
         _refInParent = o;
      }
      
      public function set id (value:int):void {
         _id = value;
      }
      public function get id ():int {
         return _id;
      }
      
      public function set clientId (value:int):void {
         _clientId = value;
      }
      
      public function get clientId ():int {
         return _clientId;
      }
      
      public function set version (value:int):void {
         _version = value;
      }
      public function get version ():int {
         return _version;
      }
      
      public function set dbId (value:int):void {
         _dbId = value;
      }
      public function get dbId ():int {
         return _dbId;
      }
      
      public function set creationTime (value:Number):void {
         _creationTime = value;
      }
      public function get creationTime():Number {
         return _creationTime;
      }
      
      public function set lastEditorVisit(value:Number):void {
         _lastEditorVisit = value;
      }
      public function get lastEditorVisit ():Number {
         return _lastEditorVisit;
      }
      
      public function get hasEdito():Boolean {
         return _hasEdito;
      }
      public function set hasEdito(value:Boolean):void {
         _hasEdito = value;
      }
      
      public function set title(value:String):void {
         if (_title != value) {
            if (_title != null) {
               _title = value;
               if (isAssociationRoot() && getMyAssociation() && getMyAssociation().info) {
                  getMyAssociation().info.title = _title;
               }
               
               dispatchEvent(new BroPTDataEvent(this,TITLE_CHANGED));
            } else {
               _title = value;
            }
         }
      }
      
      public function get title():String {
         if(_title == DEFAULT_SERVER_TITLE) {
            return BroLocale.getInstance().getText('defaultMapName');
         }
         else if (isDefaultPrivateName(_title)) {
            if (isAssociationRoot()) {
               return foreignInvisiblePrivateTeamName();                  
            }
            else {
               return BroLocale.getInstance().getText('defaultPrivatePearltreeName');
            }
         } 
         return _title; 
      }
      
      public static function isDefaultPrivateName(name:String):Boolean {
         return (name == DEFAULT_PRIVATE_TITLE);
      }
      
      public static function foreignInvisiblePrivateTeamName():String {
         return BroLocale.getInstance().getText('defaultPrivateTeamName');                  
      }
      
      public static function isPrivateName(name:String):Boolean {
         return name == DEFAULT_PRIVATE_TITLE;
      }
      
      public static function isDefaultName(name:String):Boolean {
         return (name == BroLocale.getInstance().getText('defaultMapName'));
      }
      
      public function get treeEdito():TreeEdito {
         if (!_treeEdito) {
            _treeEdito = new TreeEdito();
            _treeEdito.treeId = id;
         }
         return _treeEdito;
      }
      
      public function makeNode(pageNode:BroPage):BroPageNode {
         var p:BroPageNode = new BroPageNode(pageNode);
         return p;
      }
      
      public function addToRoot(node:BroPTNode, index:int=-1):void {
         if(!isCurrentUserAuthor()){
            Assert.assert(false, "user must have the right to add the tree");
            return;
         }
         addToNode(getRootNode(), node, index);
      }
      
      public function removeBranch(branchRoot:BroPTNode):void{
         if(!isCurrentUserAuthor()){
            Assert.assert(false, "user must have the right to remove the branch");
            return;
         }
         if(branchRoot is BroPTRootNode){
            
            branchRoot = (branchRoot as BroPTRootNode).owner.refInParent;
         }
         var parentLink : BroLink =branchRoot.parentLink;
         if (parentLink ) {
            if (parentLink.fromPTNode.removeChildLink(parentLink)) {
               notifyPearlTreeChanged();
            }
         }
         var nodesToDelete:Array = new Array();
         nodesToDelete.push(branchRoot);
         var nodeBeingTreated:BroPTNode = null;
         while(nodesToDelete.length > 0){
            nodeBeingTreated = nodesToDelete.shift();
            nodeBeingTreated.owner = null;
            nodeBeingTreated.deletedByUser = true;
            
            for each(var outLink:BroLink in nodeBeingTreated.childLinks){
               nodesToDelete.push(outLink.toPTNode);
            }
         }
      }

      public function importBranch(newBranchParent:BroPTNode, branchStart:BroPTNode, index:int = -1):void{
         if(!isCurrentUserAuthor()){
            Assert.assert(false, "user must have the right to remove the branch");
            return;
         }
         if (!newBranchParent || !branchStart) {
            if (!newBranchParent) {
               Assert.assert(false, "parent node must not be null");
            } else {
               Assert.assert(false, "branchStart must not be null");
            }
         }
         var operatedNode:BroPTNode = branchStart;
         if(branchStart is BroPTRootNode){
            
            if(branchStart.owner && branchStart.owner.refInParent){
               operatedNode = branchStart.owner.refInParent;
            }
         }
         
         var nodesToImport:Array = new Array();
         nodesToImport.push(operatedNode);
         var nodeBeingTreated:BroPTNode = null;
         var isTargetPrivate:Boolean = newBranchParent.owner.isPrivate();
         while(nodesToImport.length > 0){
            nodeBeingTreated = nodesToImport.shift();
            nodeBeingTreated.owner = newBranchParent.owner;
            if ((nodeBeingTreated is BroLocalTreeRefNode)  && isTargetPrivate) {
               var refTree:BroPearlTree = (nodeBeingTreated as BroLocalTreeRefNode).refTree;
               if (!refTree.isPrivate()) {
                  refTree.changePrivacyState(true);  
               }
            }
            for each(var outLink:BroLink in nodeBeingTreated.childLinks){
               nodesToImport.push(outLink.toPTNode);
            }
         }
         addToNode(newBranchParent, operatedNode, index);
      }
      public function isDropZone():Boolean {
         var currentUser:User= ApplicationManager.getInstance().currentUser;
         if (currentUser.isAnonymous()) {
            return false;
         } else {
            return currentUser.dropZoneTreeRef.treeId == id;
         }
      }
      public function addToNode(nodeFrom:BroPTNode, nodeTo:BroPTNode, index:int=-1):void {

         if (nodeTo is BroTreeRefNode) {
            var myDropZoneTreeRef:BroLocalTreeRefNode = ApplicationManager.getInstance().currentUser.dropZoneTreeRef;
            if (myDropZoneTreeRef && myDropZoneTreeRef.treeId == BroTreeRefNode(nodeTo).treeId) {
               Log.getLogger("com.broceliand.pearlTree.model.BroPearltree").error("The node {0} ({1}) is an alias to my dropzone, which is forbidden", nodeTo.title, nodeTo.persistentID);
               return;
            }
         }
         if (nodeFrom ==null) {
            nodeFrom = getRootNode();
         }
         if(nodeTo.parentLink != null){
            var oldParentNode:BroPTNode = nodeTo.parentLink.fromPTNode;
            var len:Number = oldParentNode.childLinks.length;
            var oldIndex:Number = oldParentNode.getChildIndex(nodeTo);
            if (oldIndex>=0) {
               oldParentNode.childLinks.splice(oldIndex,1);
            }
            var prevOwner:BroPearlTree = oldParentNode.owner;
            if (prevOwner != this ) {
               if (prevOwner) {
                  prevOwner.notifyPearlTreeChanged();
                  
                  for each (var child:BroPTNode in nodeTo.getDescendants()) {
                     child.owner = this;
                  }
               }
               
            }
         }
         var l:BroLink =new BroLink(nodeFrom,nodeTo);
         nodeFrom.addChildLink(l, index);
         nodeTo.parentLink=l;
         nodeTo.owner=this;
         notifyPearlTreeChanged();
         Assert.assert(nodeFrom.owner==this,"The node from is not in the tree");
      }
      
      public function getRootNode():BroPTRootNode{
         if  (_root==null) {
            _root = new BroPTRootNode();
            _root.setPersistentId(_rootPearlDb,_rootPearlId, true);
            _root.owner=this;
            
            _root.serverNoteCount = _rootPearlNoteCount;
            _root.neighbourCount = _rootPearlNeighbourCount;
         }
         return _root;
      }

      internal function notifyPearlTreeChanged():void {
         _lastModificationDate= new Date().getTime();
         _mustRecomputeChildrenCount = true;
         if (pearlsLoaded) {
            dispatchEvent(new BroPTDataEvent(this,TREE_STRUCTURE_CHANGED));
         }
         
      }
      
      public function notifyPearlTreeSaved():void {
         _lastSaveDate = new Date().getTime();
      }
      
      public function shouldBeSaved():Boolean{
         return _lastModificationDate>0 && _lastModificationDate>_lastSaveDate;
      }
      
      public function isCurrentUserAuthor():Boolean{
         if(authorsLoaded && getMyAssociation()) {
            return getMyAssociation().isMyAssociation();
         }else if(isOwner && _hierarchyOwner.isMyAssociation()) {
            return true;
         }else{
            return false;
         }
      }
      
      public function get totalDescendantHitCount():int {
         if (!isUsingHitsPearlsAndTeamsAccessor || pearlsLoaded) {
            var pcount:int;
            if (isOwner) {
               pcount = totalDescendantHitCountWithoutAlias(true);
            } else {
               pcount = totalDescendantHitCountWithoutAlias(false);
            }
            return pcount;
         } else {
            getHitsPearlsAndTeamLoader();
            if (_totalHitsPearlsAndTeamsAccessor) {
               return _totalHitsPearlsAndTeamsAccessor.getTotalHitsCount();
            }
            return -1;
         }
      }
      
      public function totalDescendantHitCountWithoutAlias(withPrivate:Boolean):int{
         var result:int = cachedValues.getTotalHitCount();
         if (result<=0){
            var descendantTrees:Array = _treeHierarchy.getDescendantTrees(true, true, withPrivate);
            result=0;
            for each (var tree:BroPearlTree in descendantTrees) {
               result += tree.hits;
            }
            cachedValues.saveTotalHitCount(result);
         }
         return result;
      }

      private function getTotalDescendantPearlCountWithoutAliasInternal(limitedToAsso:Boolean, withPrivate:Boolean=true):int{
         var result:int;
         if (limitedToAsso) {
            if (withPrivate) {
               result = cachedValues.getTotalPearlsCountWithoutAliasLimitedToAsso();
            } else {
               result = cachedValues.getTotalPearlsCountWithoutAliasLimitedToAssoWithoutPrivate();
            }
         }
         else {
            result = cachedValues.getTotalPearlsCountWithoutAlias();
         }
         if (result<=0){
            var descendantTrees:Array= _treeHierarchy.getDescendantTrees(true, limitedToAsso, withPrivate);
            result=0;
            for each (var tree:BroPearlTree in descendantTrees) {
               result+= tree.pearlCount;
            }
            Log.getLogger("com.broceliand.pearlTree.model.HierarchicalTreeCachedValues").info("Recompute Total descendant pearl count {0}({1}), limiteToAss {2} : new count : {3}", title, id, limitedToAsso, result);
            
            if (limitedToAsso) {
               if (withPrivate) {
                  cachedValues.saveTotalPearlsCountWithoutAliasLimitedToAsso(result);
               } else {
                  cachedValues.saveTotalPearlsCountWithoutAliasLimitedToAssoWithoutPrivate(result);
               }
            } else {
               cachedValues.saveTotalPearlsCountWithoutAlias(result);
            }
         }
         return result;
      }
      
      internal function notifyNewNeighbour():void {
         cachedValues.resetTotalNeighboursCount(this);
      }
      internal function notifyNewNote():void {
         cachedValues.resetTotalCommentsCount(this);
      }
      public function notifyNotificationUnvalidated():void {
         cachedValues.resetHasCrossNotification(this);
         cachedValues.resetHasNotesNotification(this);
         cachedValues.resetHasStructureNotification(this);
      }
      
      public function hasNotesNotificationInDescendant(descendant:Boolean=true):Boolean{
         var result:int = cachedValues.hasNotesNotification();
         if (result <0) {
            result = 0;
            if (notifications && notifications.hasNotesNotification()) {
               result =1;
            } else if (descendant) {
               var descendantTrees:Array= _treeHierarchy.getDescendantTrees();
               for each (var tree:BroPearlTree in descendantTrees) {
                  if (tree == this) continue;
                  if (tree.hasNotesNotificationInDescendant(false)) {
                     result = 1;
                     break;
                  }
               }
               cachedValues.saveHasNotesNotification(result==1);
            }
         }
         return  result==1;
      }
      public function hasCrossNotificationInDescendant(descendant:Boolean=true):Boolean{
         var result:int = cachedValues.hasCrossNotification();
         if (result <0){
            result =0;
            if (notifications && notifications.hasCrossingNotification()) {
               result =1;
            } else if (descendant) {
               var descendantTrees:Array= _treeHierarchy.getDescendantTrees();
               for each (var tree:BroPearlTree in descendantTrees) {
                  if (tree == this) continue;
                  if (tree.hasCrossNotificationInDescendant(false)) {
                     result = 1;
                     break;
                  }
               }
               cachedValues.saveHasCrossNotification(result==1);
            }
         }
         return result==1;
      }
      
      public function getTeamsInsideLoader():LazyValueAccessor {
         if (!_teamsInsideAccessor) {
            _teamsInsideAccessor = new TeamInsideAccessor();
            _teamsInsideAccessor.owner = this;
         }
         return _teamsInsideAccessor;
      }
      
      public function getTeamsInsideList():Array {
         getTeamsInsideLoader();
         return _teamsInsideAccessor.getTeamList();
      }
      
      public function hasSubTeam(descendant:Boolean = true):Boolean {
         var result:Number = cachedValues.hasSubTeam();
         if (result < 0) {
            result = 0;
            if (pearlsLoaded) {
               var totalPearls:int = getRootNode().getChildCount();
               for (var i:int = 0 ; i < totalPearls ; i++) {
                  var node:BroPTNode = getRootNode().getChildAt(i);
                  if (node is BroCoeditDistantTreeRefNode || node is BroCoeditLocalTreeRefNode) {
                     result = 1;
                     break;
                  }
                  else if (descendant && node is BroLocalTreeRefNode) {
                     if (BroLocalTreeRefNode(node).refTree.hasSubTeam(true)) {
                        result = 1;
                        break;
                     }
                  }
               }
            }
            else {
               if (_containsSubTeam) {
                  result = 1;
               }
               else if (descendant) {
                  var descendantTrees:Array= _treeHierarchy.getDescendantTrees(false, true);
                  for each (var tree:BroPearlTree in descendantTrees) {
                     if (tree == this) continue;
                     if (tree.hasSubTeam(false)) {
                        result = 1;
                        break;
                     }
                  }
               }
            }
            
            if (result == 1 || descendant) {
               cachedValues.saveHasSubTeam(result);
            }
         }
         return result == 1;
      }
      
      public function hasRequestOrSubRequest(descendant:Boolean = true):Boolean {
         var result:Number = 0;
         if (descendant) {
            var descendantTrees:Array= _treeHierarchy.getDescendantTrees(false, true);
            for each (var tree:BroPearlTree in descendantTrees) {
               
               if (tree.hasTeamRequestsToAccept()) {
                  result = 1;
                  break;
               }
            }
            /*if (result == 1) {
            cachedValues.saveHasSubRequest(result);
            }*/
         }
         return result == 1;
      }
      
      public function set containsSubTeam(value:Boolean):void {
         _containsSubTeam = value;
      }
      
      public function notifyHierarchyChanged():void {
         dispatchEvent(new BroPTDataEvent(this,HIERARCHY_CHANGED));
      }
      
      public function isEqual(tree:BroPearlTree):Boolean {
         return (tree && tree.id == id);
      }
      
      static public function getTreeKey(treedb:Number, treeId:Number):String {
         return "" + treedb + "_" + treeId;
      }
      
      static public function parseTreerKey(key:String):Array {
         if (key == null) {
            return null;
         }
         var stringIds:Array = key.split("_");
         if (stringIds.length!=2) { return null;};
         var result:Array = new Array(2);
         result[0] = parseInt(stringIds[0]);
         result[1] = parseInt(stringIds[1]);
         if (isNaN(result[0]) || isNaN(result[1])) {
            return null;
         }
         return result;
      }
      
      internal function assignAutoId(node:BroPTNode):void {
         if (node.persistentDbID<0) {
            node.setPersistentId(-1, _autoIDGenerator--, true);
         }
      }
      
      public function getPearl(id:int, tempId:int =0):BroPTNode {
         var nodesToProcess:Array = new Array();
         nodesToProcess.push(getRootNode());
         while(nodesToProcess.length>0) {
            var n:BroPTNode = nodesToProcess.pop();
            if (id == 0) {
               if (n.tempId == tempId) {
                  return n;
               }
            } else if (n.persistentID == id) {
               return n;
            }
            for each (var links:BroLink in  n.childLinks) {
               nodesToProcess.push(links.toPTNode);
            }
         }
         return null;
      }
      
      internal function notifyPearlTitleChange(node:BroPTNode):void {
         dispatchEvent(new BroPTDataEvent(this, NODE_TITLE_CHANGED, dbId, id, node));
      }
      
      internal function notifyPearlRemoved(node:BroPTNode):void {
         dispatchEvent(new BroPTDataEvent(this, NODE_OWNER_CHANGED, dbId, id, node));
      }
      
      public function equals(value:BroPearlTree):Boolean {
         if(!value) return false;
         return (isPersisted() && value.isPersisted() && value.dbId == dbId && value.id == id);
      }
      public function isPersisted():Boolean {
         return (dbId > 0 && id > 0);
      }
      
      public function makeDelegate():BroPearlTree {
         return new BroPearlTreeDelegate(this);
      }
      
      public function isWhatsHot():Boolean{
         
         return false;
      }

      public function performTreeHierarchyUpdate(edition:TreeEdition, treeHiearchyAdded:Array, treeHiearchyRemove:Array):void {
         if (edition.tree != this ) {
            Assert.assert(false, "Tree not supposed to be logged");
         }
         if (pearlsLoaded){
            return;
         }
         var shouldResetTreePathCache:Boolean = false;
         if (treeHiearchyRemove) {
            for each (var t:BroPearlTree in treeHiearchyRemove) {
               if (t.treeHierarchyNode.parentTree == this) {
                  treeHierarchyNode.removeChild(t.treeHierarchyNode);
               }
               shouldResetTreePathCache = true;
               
            }
         }
         if (treeHiearchyAdded) {
            for each (var addedTree:BroPearlTree in treeHiearchyAdded) {
               shouldResetTreePathCache = true;
               if (treeHierarchyNode.getTreePath().lastIndexOf(addedTree)==-1) {
                  treeHierarchyNode.addChild(addedTree.treeHierarchyNode);
               }
            }
         }
         if (shouldResetTreePathCache) {
            var path:Array = treeHierarchyNode.getTreePath();
            for each (var tree:BroPearlTree in path) {
               tree.cachedValues.resetCache(null);
            }
         }
         
      }
      
      public function set avatarHash (value:String):void {
         _avatarHash = value;
      }
      public function get avatarHash ():String {
         return _avatarHash;
      }
      
      public function set backgroundHash (value:String):void {
         if (value != _backgroundHash) {
            _backgroundHash = value;
            if (_backgroundHash && isAssociationRoot() && getMyAssociation().info) {
               getMyAssociation().info.backgroundHash = _backgroundHash;
            }
         }
      }
      
      public function get backgroundHash ():String {
         return _backgroundHash;
      }
      
      public function isAssociationRoot():Boolean {
         return getMyAssociation() && getMyAssociation().associationId == id;
      }
      public function isInATeam():Boolean {
         return (getMyAssociation() && !getMyAssociation().isUserRootAssociation());
      }
      public function isTeamRoot():Boolean {
         return (isInATeam() && isAssociationRoot());
      }
      public function isUserRoot():Boolean {
         return (getMyAssociation() && getMyAssociation().associationId == id && getMyAssociation().isUserRootAssociation());
      }
      public function isPremiumUserRoot():Boolean {
         return isUserRoot() &&  getMyAssociation().isPreferredUserPremium();
      }
      public function isPrivateTeamRoot():Boolean {
         return !isUserRoot() && isAssociationRoot() && isPrivate();
      }
      public function isPublicTeamRoot():Boolean {
         return !isUserRoot() && isAssociationRoot() && !isPrivate();
      }
      public function isInAPublicTeam():Boolean {
         return (getMyAssociation() && !getMyAssociation().isUserRootAssociation() && !getMyAssociation().isPrivate());
      }
      
      public function isEditoAvailableForCurrentUser():Boolean {
         var isEditoAvailable:Boolean = false;
         var editoOwner:User = (getMyAssociation())?getMyAssociation().info.foundingUser:null;   
         if (hasEdito || User.areUsersSame(editoOwner, ApplicationManager.getInstance().currentUser)) {
            if (!isAssociationRoot()  || isInATeam()){
               isEditoAvailable = true;
            }
         }
         else {
            isEditoAvailable = false;
         }
         return isEditoAvailable;
      }
      
      public function notifyLostNode(node:BroPTNode, newTree:BroPearlTree):void {
         getAppliBroadcaster().broadcastMessage(new ChangeTreeEvent(node, this, newTree));
      }
      private function getAppliBroadcaster():ApplicationMessageBroadcaster {
         if (!_appliBroadcasterCached) {
            _appliBroadcasterCached = ApplicationManager.getInstance().visualModel.applicationMessageBroadcaster;
         }
         return _appliBroadcasterCached;
      }
      
      public function unloadTree(dataRepository:BroDataRepository):void {
         hierarchyOwner.treeHierarchy.removeTreeFromHierarchy(this);
         dataRepository.releaseTree(this);
         var rootPersistentId:Number = _root.persistentID;
         _root = new BroPTRootNode();
         _root.setPersistentId(1, rootPersistentId, true);
         _pearlsLoaded =false;
      }
      public function traceId():String {
         return "Tree 0x"+_debugId;
      }
      public function getAssociationId():int {
         if (_treeOwnership) {
            return getMyAssociation().associationId;
         } else {
            Log.getLogger("com.broceliand.pearlTree.model.BroPearltree").error("No association set for tree {0} {1}({2})", traceId(), title, id);
            return -1;
         }
      }
      
      public function isPrivate():Boolean {
         return this.visibility == PRIVATE;
      }
      
      public function containsPrivateTrees():Boolean {
         var allTrees:Array = treeHierarchyNode.getDescendantTrees(true);
         if (!allTrees) return false;
         for each (var tree:BroPearlTree  in allTrees) {
            if (tree.isPrivate()){
               return true;
            }
         }
         return false;
      }
      
      public function isParentPrivate():Boolean {
         return !treeHierarchyNode.parentTree || treeHierarchyNode.parentTree.isPrivate();
      }
      
      public function isCurrentUserParentAuthor():Boolean {
         return !(!treeHierarchyNode.parentTree || !treeHierarchyNode.parentTree.isCurrentUserAuthor());
      }
      
      public function canChangePrivacy():Boolean {
         return isPrivate();
      }
      
      public function changePrivacyState(isPrivate:Boolean, withDescendant:Boolean = true, persist:Boolean = true, loadSubTree:Boolean = false):void {
         
         this.visibility = isPrivate ? PRIVATE : VISIBLE;
         if (persist) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            if (!pearlsLoaded && loadSubTree) {
               setTimeout(changePrivacyState, 200, isPrivate, withDescendant, persist, loadSubTree);
            } else {
               am.persistencyQueue.savePrivateState(this);
               
               if (withDescendant) {
                  for each (var tree:BroPearlTree in treeHierarchyNode.getDescendantTrees(true, true)) {
                     tree.changePrivacyState(isPrivate, false, true);
                  }
               }
            }
         }
         
      }
      
      public function getHitsPearlsAndTeamLoader():LazyValueAccessor {
         if (!_totalHitsPearlsAndTeamsAccessor) {
            _totalHitsPearlsAndTeamsAccessor = new PearlHitsAndTeamCountsAccessor();
            _totalHitsPearlsAndTeamsAccessor.owner = this;
         }
         return _totalHitsPearlsAndTeamsAccessor;
      }
      
      public function get totalDescendantPearlCount():int {
         if (!isUsingHitsPearlsAndTeamsAccessor || pearlsLoaded) {
            var pcount:int;
            if (isOwner) {
               pcount = getTotalDescendantPearlCountWithoutAliasInternal(true,true);
            } else {
               pcount = getTotalDescendantPearlCountWithoutAliasInternal(true,false);
            }
            return pcount;
         } else {
            getHitsPearlsAndTeamLoader();
            if (_totalHitsPearlsAndTeamsAccessor) {
               return _totalHitsPearlsAndTeamsAccessor.getTotalPearlsCount();
            }
            return -1;
         }
      }
      
      public function hasTeamRequestsToAccept():Boolean {
         var requestModel:ITeamRequestModel  = ApplicationManager.getInstance().notificationCenter.teamRequestModel;
         return requestModel.hasRequestsToAccept(this);
      }
      
      public function get totalMembershipCount():int {
         if (!isUsingHitsPearlsAndTeamsAccessor) {
            /*if (cachedValues.getTotalMembershipCount()) {
            resfreshTeamProperties(true, true);
            }*/
            return cachedValues.getTotalMembershipCount();
         } else {
            getHitsPearlsAndTeamLoader();
            if (_totalHitsPearlsAndTeamsAccessor) {
               return _totalHitsPearlsAndTeamsAccessor.getTotalMembershipCount();
            }
            return -1;
         }
      }
      
      public function get isUsingHitsPearlsAndTeamsAccessor():Boolean {
         return _isUsingHitsPearlsAndTeamsAccessor;
      }
      public function set isUsingHitsPearlsAndTeamsAccessor(value:Boolean):void {
         _isUsingHitsPearlsAndTeamsAccessor = value;
      }
      
      public function isForeignPrivateInvisiblePearltree():Boolean {
         
         if (!isPrivate()) {
            return false;
         }
         if (pearlCount > 0 || hits > 0 ) {
            return false;
         }
         if (isCurrentUserAuthor()) {
            return false;
         }
         if (!isPrivateName(_title)) {
            return false;
         }
         return true;
      }
      
      public function unloadForeignPrivateInvisiblePearltree():Boolean {
         if (pearlsLoaded && isForeignPrivateInvisiblePearltree()) {
            _pearlsLoaded  = false;
            
            return true;
         }
         return false;
      }
      
      public function isPrivatePearltreeOfCurrentUserNotPremium():Boolean {
         return isPrivate() && isCurrentUserAuthor() && ApplicationManager.getInstance().isPremium != 1;
      }

      public function releasePearls():void {
         _root.removeAllNodes();
         _pearlsLoaded = false;
      }
      
      public function isBackgroundCustomized():Boolean {
         return backgroundHash != null  && avatarHash != backgroundHash ;
      }
      
      public function getLastCreatedPearlPageId():int {
         var lastPearlId:int = getRootNode().persistentID;
         var maxInTreeSince:Number = 0;
         var descendants:Array = getRootNode().getDescendants();
         var logger:BroLogger = Log.getLogger("com.broceliand.pearlTree.model.BroPearlTree");
         logger.info("getLastCreatedPearlPageId descendants {0}", descendants.length);  
         for each(var node:BroPTNode in descendants) {
            if (node is BroPageNode) {
               if (node.inTreeSinceTime > maxInTreeSince) {
                  maxInTreeSince = node.inTreeSinceTime;
                  lastPearlId = node.persistentID;
               }
            }
         }
         logger.info("getLastCreatedPearlPageId {0}", lastPearlId);  
         return lastPearlId;
      }
   }
}

