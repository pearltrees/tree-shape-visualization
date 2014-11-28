package com.broceliand.pearlTree.model
{
   import com.broceliand.pearlTree.model.notification.TreeNotification;
   import com.broceliand.pearlTree.model.treeEdito.TreeEdito;

   public class BroPearlTreeDelegate extends BroPearlTree
   {
      private var _delegate:BroPearlTree;
      private var _isOwner:Boolean=false;
      
      override public function BroPearlTreeDelegate(source:BroPearlTree)
      {
         super(); 
         _delegate = source;
         treeHierarchyNode.isAlias = true;
         
      }

      override internal function get cachedValues ():HierarchicalTreeCachedValues
      {
         if (_delegate) {
            return _delegate.cachedValues;
         } else return super.cachedValues;
      }
      override internal function assignAutoId(node:BroPTNode):void {
         if (_delegate)
            _delegate.assignAutoId(node);
         else super.assignAutoId(node);
      }

      override public function get treeHierarchyNode ():BroTreeHierarchyNode
      {
         return super.treeHierarchyNode;
      }
      
      override public function get notifications():TreeNotification{
         return _delegate.notifications;
      }
      override public function set notifications(value:TreeNotification):void{
         _delegate.notifications=value;
      }

      override public function get rank():int{
         return _delegate.rank;
      }
      override public function set rank(value:int):void{
         _delegate.rank = value;
      }      
      
      override public function get state():int{
         return _delegate.state;
      }
      override public function set state(value:int):void{
         _delegate.state = value;
      }
      override public function isDeleted():Boolean{
         return _delegate.isDeleted();
      }
      override public function isHidden():Boolean{
         return _delegate.isHidden();
      }
      
      override public function get neighbourPearlId():int{
         return _delegate.neighbourPearlId;
      }
      override public function set neighbourPearlId(value:int):void{
         _delegate.neighbourPearlId = value;
      }
      
      override public function get neighbourPearlDb():int{
         return _delegate.neighbourPearlDb;
      }
      override public function set neighbourPearlDb(value:int):void{
         _delegate.neighbourPearlDb = value;
      }      

      override public function get isOwner():Boolean{
         return _isOwner;
      }
      override public function set isOwner(value:Boolean):void{
         _isOwner = value;
      }      
      
      override public function get pearlsLoaded():Boolean{
         return _delegate.pearlsLoaded;
      }
      override public function notifyEndLoadingPearl():void{
         _delegate.notifyEndLoadingPearl();
      }
      override public function getTreeNodes():Array{
         return _delegate.getTreeNodes();
      }
      
      override public function isEditoAvailableForCurrentUser():Boolean{
         return _delegate.isEditoAvailableForCurrentUser();
      }
      
      override public function get pearlCount():uint{
         return _delegate.pearlCount;
      }     
      
      override public function get hits():uint{
         return _delegate.hits;
      }      
      
      override public function get hasEdito():Boolean {
         return _delegate.hasEdito;
      }
      
      override public function set hasEdito(value:Boolean):void {
         _delegate.hasEdito = value;
      }

      override public function set owner(association:BroAssociation):void{
         _delegate.owner= association;
      }
      override public function getMyAssociation():BroAssociation {
         return _delegate.getMyAssociation();
      }
      override public function get authorsLoaded():Boolean{
         return _delegate.authorsLoaded;
      }
      override public function set authorsLoaded(value:Boolean):void{
         _delegate.authorsLoaded = value;
      }
      override public function get refInParent():BroLocalTreeRefNode {
         return _delegate.refInParent;
      }
      
      override public function set refInParent(o:BroLocalTreeRefNode):void {
         _delegate.refInParent= o;
      }
      
      override public function set id (value:int):void
      {
         _delegate.id = value;
      }
      
      override public function get id ():int
      {
         return _delegate.id;
      }
      
      override public function set dbId (value:int):void
      {
         _delegate.dbId = value;
      }
      
      override public function get dbId ():int
      {
         return _delegate.dbId;
      }
      override public function set creationTime (value:Number):void
      {
         _delegate.creationTime = value;
      }
      
      override public function get creationTime ():Number
      {
         return _delegate.creationTime;
      }
      override public function set title (value:String):void
      {
         _delegate.title = value;
      }
      
      override public function get title ():String
      {
         return _delegate.title;
      }
      
      override public function makeNode(pageNode:BroPage):BroPageNode {
         return _delegate.makeNode(pageNode);
      }
      
      override public function addToRoot(node:BroPTNode, index:int=-1):void {
         _delegate.addToRoot(node,index);
      }  
      
      override public function removeBranch(branchRoot:BroPTNode):void{
         _delegate.removeBranch(branchRoot);
      }
      
      override public function importBranch(newBranchParent:BroPTNode, branchStart:BroPTNode, index:int = -1):void{
         _delegate.importBranch(newBranchParent, branchStart, index);
      }
      override public function addToNode(nodeFrom:BroPTNode, nodeTo:BroPTNode, index:int=-1):void {
         _delegate.addToNode(nodeFrom, nodeTo,index);
      }  
      override public function getRootNode():BroPTRootNode{
         return _delegate.getRootNode();
      }
      override internal function notifyPearlTreeChanged():void {
         _delegate.notifyPearlTreeChanged();
      }
      
      override public function notifyPearlTreeSaved():void {
         _delegate.notifyPearlTreeSaved();
      }
      
      override public function shouldBeSaved():Boolean{
         return _delegate.shouldBeSaved();
      }
      
      override public function isCurrentUserAuthor():Boolean{
         return _delegate.isCurrentUserAuthor();        
      }
      
      override internal function notifyNewNeighbour():void {
         _delegate.notifyNewNeighbour();
      }     
      override internal function notifyNewNote():void {
         _delegate.notifyNewNote();
      }
      override public function notifyNotificationUnvalidated():void {
         _delegate.notifyNotificationUnvalidated();
      }     
      override public function hasNotesNotificationInDescendant(descendant:Boolean=true):Boolean{
         return  _delegate.hasNotesNotificationInDescendant(descendant);
      }
      override public function hasCrossNotificationInDescendant(descendant:Boolean=true):Boolean{
         return  _delegate.hasCrossNotificationInDescendant(descendant);
      }
      
      override public function notifyHierarchyChanged():void {
         _delegate.notifyHierarchyChanged();
      }
      override public function getPearl(id:int, clientId:int =0):BroPTNode {
         return _delegate.getPearl(id,clientId);
      }
      override internal function notifyPearlTitleChange(node:BroPTNode):void {
         _delegate.notifyPearlTitleChange(node);
      }
      
      override internal function notifyPearlRemoved(node:BroPTNode):void {
         _delegate.notifyPearlRemoved(node);
      }                  
      override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
         _delegate.addEventListener(type, listener, useCapture, priority, useWeakReference);
      }
      override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
         _delegate.removeEventListener(type, listener, useCapture);
      }
      override public function get avatarHash():String {
         return _delegate.avatarHash;
      }
      override public function isAssociationRoot():Boolean {
         return _delegate.isAssociationRoot();
      }
      override public function getAssociationId():int {
         return _delegate.getAssociationId();
      }
      
      override public function hasSubTeam(descendant:Boolean = true):Boolean {
         return _delegate.hasSubTeam(descendant);
      }
      override public function hasRequestOrSubRequest(descendant:Boolean = true):Boolean {
         return _delegate.hasRequestOrSubRequest(descendant);
      }
      override public function hasTeamRequestsToAccept():Boolean {
         return _delegate.hasTeamRequestsToAccept();
      }
      /*override public function hasParentsWithTeamRequestsToAccept():Boolean {
      return _delegate.hasParentsWithTeamRequestsToAccept();
      }*/
      
      override public function isPrivate():Boolean {
         return _delegate.isPrivate();    
      }
      
      override public function isForeignPrivateInvisiblePearltree():Boolean {
         return _delegate.isForeignPrivateInvisiblePearltree();
      }
      
      override public function get treeEdito():TreeEdito {
         return _delegate.treeEdito;
      }
   }
}

