package com.broceliand.pearlTree.model {
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.object.tree.AssociationData;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.ui.util.HexaHelper;
   import com.broceliand.util.BroLocale;
   
   import flash.utils.ByteArray;
   
   public class BroAssociationInfo {
      
      private var _title:String;
      private var _avatarHash:String;
      private var _backgroundHash:String;
      private var _preferredUser:User;
      private var _versionId:Number;
      private var _chiefUser:User;
      private var _foundingAsso:BroAssociation;
      private var _foundingUser:User;
      private var _ownerCount:int;
      private var _rootAssoOfUserId:int;
      private var _teamDiscussionCount:int;
      
      public function BroAssociationInfo(associationData:AssociationData) {
         _versionId = associationData.assoTreesVersion;
         _title = associationData.title;
         if (associationData.avatarHash) {
            _avatarHash = HexaHelper.byteArrayToHexString(associationData.avatarHash);
         } else {
            _avatarHash = null;
         }
         if (associationData.backgroundHash) {
            _backgroundHash = HexaHelper.byteArrayToHexString(associationData.backgroundHash);
         } else {
            _backgroundHash = null;
         }
         var uf:UserFactory= ApplicationManager.getInstance().userFactory;
         if (associationData.chiefUser) {
            _preferredUser = AmfUserService.makeUser(associationData.chiefUser, associationData.chiefUser.id);
            _chiefUser = _preferredUser;
         } else if (associationData.chiefUserId > 0)  {
            _preferredUser = uf.getOrMakeUser(1, associationData.chiefUserId);
            _chiefUser = _preferredUser;
         }
         if (associationData.memberCount > 0) {
            _ownerCount = associationData.memberCount;
         }
         
         if (_ownerCount == 0) {
            _ownerCount = 2;
         }
         if (associationData.foundingAssoId > 0) {
            _foundingAsso = ApplicationManager.getInstance().visualModel.dataRepository.getOrMakeAssociation(associationData.foundingAssoId);
         } else {
            _foundingAsso = null;
         }
         if (associationData.foundingUserId > 0) {
            _foundingUser = uf.getOrMakeUser(1, associationData.foundingUserId);
         }
         else {
            _foundingUser = null;
         }
         
         _rootAssoOfUserId = associationData.rootAssoOfUserId;
         _teamDiscussionCount = associationData.teamDiscussionCount;
      }
      
      public function set avatarHash(value:String):void {
         _avatarHash = value;
      }
      
      public function set backgroundHash(value:String):void {
         _backgroundHash = value;
      }
      
      public function get versionId():Number {
         return _versionId;
      }
      
      public function set versionId(value:Number):void {
         _versionId = value;
      }
      
      public function get title():String {
         if (BroPearlTree.isDefaultPrivateName(_title)) {
            return BroPearlTree.foreignInvisiblePrivateTeamName();
         }
         return _title; 
      }
      
      public function get titleForTeam():String {
         if (BroPearlTree.isDefaultPrivateName(_title)) {
            return BroPearlTree.foreignInvisiblePrivateTeamName();
         }
         return BroLocale.getInstance().getText("team.prefixedname", [_title]); 
      }
      
      public function set title(value:String):void { 
         _title = value; 
      }
      
      public function get avatarHash():String { 
         return _avatarHash; 
      }
      
      public function get backgroundHash():String { 
         return _backgroundHash; 
      }
      
      internal function get preferredUser():User {
         return _preferredUser;         
      }
      
      public function get chiefUser():User {
         return _chiefUser;
      }
      
      public function get foundingAsso():BroAssociation {
         return _foundingAsso;
      }
      
      public function get foundingUser():User {
         return _foundingUser;
      }
      
      public function get ownerCount():int {
         return _ownerCount;
      }
      
      public function set ownerCount(value:int):void {
         _ownerCount = value;
      }
      
      public function get rootAssoOfUserId():int {
         return _rootAssoOfUserId;
      }
      
      public function updateFromAssociationData(associationData:AssociationData):void {
         if (associationData.memberCount > 0) {
            _ownerCount = associationData.memberCount;
         }
      }
      
      public function get teamDiscussionCount():int {
         return _teamDiscussionCount;
      }
      
      public function set teamDiscussionCount(value:int):void {
         _teamDiscussionCount = value;
      }     
   }
}