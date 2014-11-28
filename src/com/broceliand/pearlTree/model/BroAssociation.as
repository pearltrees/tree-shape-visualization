package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.LazyValueAccessor;
   import com.broceliand.pearlTree.io.sync.BusinessTreeMerger;
   import com.broceliand.ui.customization.avatar.AvatarManager;
   import com.broceliand.util.Alert;
   import com.broceliand.util.Assert;
   import com.broceliand.util.logging.Log;

   public class BroAssociation
   {
      private var _associationId:Number;
      private var _treeHierarchy:TreeHierarchy;
      private var _info:BroAssociationInfo;
      private var _myWorldAssociations:MyWorldAssociations;
      private var _myWorldAssociationsLoaded : Boolean = false;
      private var _preferredUser:User;
      private var _parentAssociations:BroAssociationParents;
      private var _businessTreeMerger:BusinessTreeMerger;
      private var _isDissolvedAssociation:Boolean = false;
      private var _totalHitsAndPearlsAccessor:PearlAndHitsAccessor;
      private var _assoInfoAccessor:AssoInfoAccessor;
      
      public static const CURRENT_USER_MEMBERSHIP_TYPE_NONE:int = 0;
      public static const CURRENT_USER_MEMBERSHIP_TYPE_FOUNDER:int = 1;
      public static const CURRENT_USER_MEMBERSHIP_TYPE_DIRECT_MEMBER:int = 2;
      public static const CURRENT_USER_MEMBERSHIP_TYPE_MEMBER_THROUGH_TEAM:int = 3;
      
      public function BroAssociation() {
         _associationId = -1;
      }
      
      public function get myWorldAssociationsLoaded() : Boolean {
         return _myWorldAssociationsLoaded;
      }
      
      public function get myWorldAssociations():MyWorldAssociations {
         return _myWorldAssociations;
      }
      
      internal function setMyWorldAssociations(value:MyWorldAssociations):void {
         _myWorldAssociations = value;
         _myWorldAssociationsLoaded = true;
      }
      
      public function get treeHierarchy():TreeHierarchy {
         if (!_treeHierarchy) {
            _treeHierarchy = new TreeHierarchy(this);
         }
         return _treeHierarchy;
      }
      public function setTreeHierarchy(value:TreeHierarchy):void {
         if (!value && _treeHierarchy) {
            Log.getLogger("com.broceliand.pearlTree.model").info("Releasing tree hierarchy from association {0}({1})", traceName(), associationId);
         }
         
         _treeHierarchy = value;
         
      }
      
      public function get associationId():Number {
         return _associationId;
      }
      public function set associationId(value:Number):void {
         _associationId = value;
      }
      
      public function get versionId():Number {
         if (_info) return _info.versionId;
         return -1;
      }
      public function set versionId(value:Number):void {
         if (_info) {
            _info.versionId = value;
         } else {
            Log.getLogger("com.broceliand.pearlTree.model").error("setting version id {0}  to association {1} without info", value ,associationId);
         }
      }
      
      private var debug_UserRootAssociationAlertShown:Boolean; 
      public function isUserRootAssociation():Boolean {
         if (info) {
            return info.rootAssoOfUserId != 0;
         }
         else {
            if (preferredUser && preferredUser.userWorld) {
               return (preferredUser && preferredUser.userWorld && preferredUser.userWorld.treeId == _associationId);
            }
         }
         if(!debug_UserRootAssociationAlertShown && ApplicationManager.getInstance().isDebug) {
            Alert.show("isUserRootAssociation() pour '"+((info==null)?("assoID="+associationId):(info.title+"' - Erreur : pas assez d'info disponible sur le preferredUser")));
            debug_UserRootAssociationAlertShown = true;
         }
         return false;
      }
      
      public function isMyAssociation():Boolean {
         return _myWorldAssociations != null;
      }
      
      public function isTreeHierarchyLoaded():Boolean {
         return false;
      }
      
      public function amIFounder():Boolean {
         return _info && _info.foundingUser == ApplicationManager.getInstance().currentUser;
      }

      public function get info():BroAssociationInfo {
         return _info;
      }
      public function set info(value:BroAssociationInfo):void {
         Assert.assert(_info == null, "Error setting an association info twice");
         _info = value;
      }
      
      public function get preferredUser():User {
         return (_preferredUser)? _preferredUser : (_info)?_info.preferredUser:null;
      }
      
      public function set preferredUser(value:User):void {
         _preferredUser = value;
      }
      
      public function isPreferredUserPremium():Boolean {
         return preferredUser && (preferredUser.isPremium == 1);
      }
      
      public function get parentAssociations():BroAssociationParents {
         if (!_parentAssociations) {
            _parentAssociations = new BroAssociationParents(this);
         }
         return _parentAssociations;
      }
      
      public function cleanParentAssociationsCache():void {
         if (_parentAssociations) {
            _parentAssociations.cleanCache();
         }
      }
      public function moveTreeFromOtherAssociationWithDescendant(tree:BroPearlTree, updateDescendant:Boolean = true):void {
         var originAssociation:BroAssociation = tree.getMyAssociation();
         var subTrees:Array = tree.treeHierarchyNode.getDescendantTrees(true);
         var isAvatarChanged:Boolean = info && originAssociation.info.avatarHash != info.avatarHash;
         var avararManager:AvatarManager = ApplicationManager.getInstance().avatarManager;
         
         for each (var t:BroPearlTree in subTrees) {
            if (t.getMyAssociation() == originAssociation) {
               t.owner = this;
               if (t.hierarchyOwner == originAssociation) {
                  t.hierarchyOwner = this;
               }
               
               if (originAssociation.treeHierarchy) {
                  originAssociation.treeHierarchy.moveTreeToHierarchy(tree, treeHierarchy);
               }
               if (t.avatarHash == null && isAvatarChanged) {
                  avararManager.notifyAvatarChanged(t);
               }
            }
            if (!updateDescendant) {
               break;
            }
         }
         
      }
      public function getBusinessTreeMerger():BusinessTreeMerger {
         if (!_businessTreeMerger && _treeHierarchy) {
            _businessTreeMerger = new BusinessTreeMerger(this);
         }
         return _businessTreeMerger;
      }
      
      public function get isDissolvedAssociation():Boolean
      {
         return _isDissolvedAssociation;
      }
      
      public function set isDissolvedAssociation(value:Boolean):void
      {
         _isDissolvedAssociation = value;
      }
      public function traceName():String {
         if (info) {
            return info.title;
         } else {
            return ""+_associationId;
         }
      }

      public function getCurrentUserMembershipType(mbType:Array):void {
         var cuser:User = ApplicationManager.getInstance().currentUser;
         if (cuser.isAnonymous() || !info || !isMyAssociation()) {
            mbType[0] = CURRENT_USER_MEMBERSHIP_TYPE_NONE;
            mbType[1] = null;
            return;
         }
         else {
            if (info && info.foundingUser.persistentId == cuser.persistentId) {
               mbType[0] =  CURRENT_USER_MEMBERSHIP_TYPE_FOUNDER;
               mbType[1] = null;
               return;
            }
            var rootTree:BroPearlTree = treeHierarchy.getTree(associationId);
            var rootParentTree:BroPearlTree = rootTree == null ? null: rootTree.treeHierarchyNode.parentTree;
            if (rootParentTree) {
               if (rootParentTree.getMyAssociation() == cuser.getAssociation()) {
                  mbType[0] =  CURRENT_USER_MEMBERSHIP_TYPE_DIRECT_MEMBER;
                  mbType[1] = null;
                  return;
               }
               else {
                  mbType[0] = CURRENT_USER_MEMBERSHIP_TYPE_MEMBER_THROUGH_TEAM;
                  mbType[1] = rootParentTree.getMyAssociation();
                  return;
               }
            }
            else {
               mbType[0] = CURRENT_USER_MEMBERSHIP_TYPE_NONE;
               mbType[1] = null;
               return;
            }
         }
      }
      
      public function isSubTeam():Boolean {
         if (!isMyAssociation()) return false;
         var rootTree:BroPearlTree = treeHierarchy ? treeHierarchy.getTree(associationId) : null;
         var rootParentTree:BroPearlTree = rootTree ? rootTree.treeHierarchyNode.parentTree : null;
         var parentAsso:BroAssociation = rootParentTree ? rootParentTree.getMyAssociation() : null;
         return (parentAsso)? !parentAsso.isUserRootAssociation() : false;
      }
      public function getSubTeamParent():BroAssociation {
         var rootTree:BroPearlTree = treeHierarchy ? treeHierarchy.getTree(associationId) : null;
         var rootParentTree:BroPearlTree = rootTree ? rootTree.treeHierarchyNode.parentTree : null;
         var parentAsso:BroAssociation = rootParentTree ? rootParentTree.getMyAssociation() : null;
         return (parentAsso)? parentAsso : null;
      }
      
      public function getRootTree():BroPearlTree {
         return treeHierarchy ? treeHierarchy.getTree(associationId) : null;
      }
      
      public function isPrivate():Boolean {
         if (treeHierarchy) {
            var tree:BroPearlTree = treeHierarchy.getTree(associationId);
            if (tree) {
               return tree.isPrivate();
            }
         }
         return false;
      }
      
      public function toString():String {
         if (info) {
            return info.title;
         } else {
            return super.toString();
         }
      }
      public function getHitsAndPearlsLoader():LazyValueAccessor {
         if (!_totalHitsAndPearlsAccessor) {
            _totalHitsAndPearlsAccessor = new PearlAndHitsAccessor();
            _totalHitsAndPearlsAccessor.owner = this;
         }
         return _totalHitsAndPearlsAccessor;
      }
      
      public function getAssoInfoLoader():LazyValueAccessor {
         if (!_assoInfoAccessor) {
            _assoInfoAccessor = new AssoInfoAccessor();
            _assoInfoAccessor.owner = this;
         }
         return _assoInfoAccessor;
      }
      
      public function get totalHits():Number {
         if (_treeHierarchy) {
            var tree:BroPearlTree = _treeHierarchy.getTree(_associationId);
            return tree.totalDescendantHitCount;
         }
         else if (_totalHitsAndPearlsAccessor) {
            return _totalHitsAndPearlsAccessor.getTotalHits();
         }
         return -1;
      }
      public function get totalPearlCount():Number {
         if (_treeHierarchy) {
            var tree:BroPearlTree = _treeHierarchy.getTree(_associationId);
            return tree.totalDescendantPearlCount;
         }
         else if (_totalHitsAndPearlsAccessor) {
            return _totalHitsAndPearlsAccessor.getTotalPearlsCount();
         }
         return -1;
      }
      
   }
}
import com.broceliand.ApplicationManager;
import com.broceliand.pearlTree.io.LazyValueAccessor;
import com.broceliand.pearlTree.io.object.tree.AssociationData;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
import com.broceliand.pearlTree.model.BroAssociation;
import com.broceliand.pearlTree.model.BroAssociationInfo;
import com.broceliand.util.logging.Log;

class PearlAndHitsAccessor extends LazyValueAccessor implements IAmfRetArrayCallback
{
   public function getTotalHits():Number {
      var result:Array =  super.internalValue as Array;
      if (result) {
         return result[0];
      }
      return -1;
   }
   public function getTotalPearlsCount():Number {
      var result:Array =  super.internalValue as Array;
      if (result) {
         return result[1];
      }
      return -1;
   }
   
   override protected function launchLoadValue():void {
      if (super._owner) {
         var asso:BroAssociation =  super._owner as BroAssociation; 
         ApplicationManager.getInstance().distantServices.amfTreeService.getAssociationTotalHitsAndPearlCount(asso.associationId, this);
      }
      else {
         Log.getLogger("com.broceliand.pearlTree.model.BroAssociation").error("No association to load !");
         super.onError(null);
      }
   }
   public function onReturnValue(value:Array):void {
      super.internalValue = value;
      super.notifyValueAvailable();
   }
}

import com.broceliand.pearlTree.io.services.callbacks.IAmfRetAssoCallback;

class AssoInfoAccessor extends LazyValueAccessor implements IAmfRetAssoCallback
{
   
   override protected function launchLoadValue():void {
      if (super._owner) {
         var asso:BroAssociation =  super._owner as BroAssociation; 
         ApplicationManager.getInstance().distantServices.amfTreeService.getAssociationInfo(asso.associationId, this);
      }
      else {
         Log.getLogger("com.broceliand.pearlTree.model.BroAssociation").error("No association to load !");
         super.onError(null);
      }
   }
   
   public function onReturnValue(value:AssociationData):void {
      if (!value) {
         onError(null);
         return;
      }
      var asso:BroAssociation =  super._owner as BroAssociation;
      asso.info = new BroAssociationInfo(value);
      super.notifyValueAvailable();
   }
}
