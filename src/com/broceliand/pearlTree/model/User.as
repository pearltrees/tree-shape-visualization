package com.broceliand.pearlTree.model {
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.LazyValueAccessor;
   import com.broceliand.pearlTree.io.sync.DateThresholdWithMarginAndException;
   import com.broceliand.util.BroLocale;
   
   import flash.events.EventDispatcher;
   
   import mx.events.FlexEvent;

   public class User extends EventDispatcher {
      private var _association:BroAssociation;
      private var _name:String;
      private var _persistentId:int;
      private var _persistentDbId:int;
      private var _userWorld:BroLocalTreeRefNode;
      private var _userSettings:UserSettings;
      private var _avatarHash:String;
      private var _location:String; 
      private var _realName:String; 
      private var _website:String; 
      private var _bio:String; 
      private var _rootPearlId:int;
      private var _rootPearlDb:int;
      private var _anonymous:Boolean=false;
      private var _lastVisit:Number;
      private var _creationDate:Number; 
      private var _locale:int;
      private var _feedNotifAck:Number;
      private var _feedNotifLastSeenAck:Number;
      private var _noveltyPreviousLastSeenAck:Number;
      private var _lastRightsVersionDate:DateThresholdWithMarginAndException; 
      private var _dropZoneTree:BroLocalTreeRefNode;
      private var _teamCountAccessor:TeamCountAccessor;
      private var _isPremium:int;
      private var _premiumLevel:int;
      
      private static var _currentUser:CurrentUser;
      private static var _WhatsHotUser:User;
      
      public static const UNDEFINED_AVATAR_HASH:String = "UndefinedAvatarHash";

      public function User(persistentDbId:int =0, persistentId:int=0, userName:String=null) {
         _persistentId = persistentId;
         _persistentDbId = persistentDbId;
         _name = userName;
      }
      
      public function get premiumLevel():int
      {
         return _premiumLevel;
      }
      
      public function set premiumLevel(value:int):void
      {
         _premiumLevel = value;
      }
      
      public static function GetWhatsHotUser():User {
         if (!_WhatsHotUser){
            _WhatsHotUser= new User();
            _WhatsHotUser._anonymous = true;
            _WhatsHotUser._name="What\'s hot";
         }
         return _WhatsHotUser;
      }
      
      public function isAdminAccount():Boolean {
         var adminAccountNames:Array = new Array(
            'about',
            'help',
            'aide',
            'team'
         );
         return (adminAccountNames.indexOf(name) != -1);
      }
      
      public static function MakeCurrentUser():CurrentUser {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (!_currentUser){
            _currentUser = new CurrentUser();
            _currentUser._anonymous = true;
         }
         return _currentUser;
      }
      
      public static function MakeCurrentUserAnonymous():CurrentUser {
         if(!_currentUser) {
            _currentUser = new CurrentUser();
         }
         _currentUser._anonymous = true;
         return _currentUser;
      }
      
      public function isInit():Boolean {
         return _userWorld !=null;
      }
      public function isAnonymous():Boolean {
         return _anonymous;
      }
      public function get userWorld ():BroLocalTreeRefNode {
         return _userWorld;
      }
      
      public function getAssociation():BroAssociation {
         if (!_association) {
            var result:BroAssociation  = ApplicationManager.getInstance().visualModel.dataRepository.getUserAssociation(this);
            if(result.associationId<=0) {
               return result;
            } else {
               _association = result;
            }
         }
         return _association;
      }
      
      public function get name ():String {
         return _name;
      }
      public function nameWithPremiumSymbol(inUTF8:Boolean = false, forArial:Boolean = false):String {
         if (isPremium == 1) {
            if (inUTF8) {
               if (forArial) {
                  return name + "\u2009\u2605";
               } else {
                  return name + "\u202F\u2605";
               }
            }
            return name + "&#8239;&#9733;";
         }
         return name;
      }
      public function get realName ():String {
         return _realName;
      }
      public function get website ():String {
         return _website;
      }
      public function get bio ():String {
         return _bio;
      }
      public function get rootPearlId ():int {
         return _rootPearlId;
      }
      public function get rootPearlDb ():int {
         return _rootPearlDb;
      }
      
      public function get location ():String {
         return _location;
      }
      
      public function get avatarHash ():String {
         return _avatarHash;
      }
      
      public function set avatarHash (value:String):void {
         _avatarHash = value;
         if(userWorld && userWorld.refTree) {
            userWorld.refTree.avatarHash = _avatarHash;
         }
      }
      public function set username(userName:String):void {
         _name = userName;
      }
      
      public function get feedNotifAck():Number {
         return _feedNotifAck;
      }
      
      public function get feedNotifLastSeenAck():Number {
         return _feedNotifLastSeenAck;
      }
      
      public function set feedNotifLastSeenAck(value:Number):void {
         _feedNotifLastSeenAck = value;
      }
      
      public function get noveltyPreviousLastSeenAck():Number {
         return _noveltyPreviousLastSeenAck;
      }
      
      public function set noveltyPreviousLastSeenAck(value:Number):void {
         _noveltyPreviousLastSeenAck = value;
      }
      
      public function get userSettings ():UserSettings {
         return _userSettings;
      }
      
      public function set userSettings (value:UserSettings):void {
         if(value && (value.creationDate == 0) && _userSettings && (_userSettings.creationDate > 0)){
            value.creationDate = _userSettings.creationDate;
         }
         _userSettings = value;
      }
      
      public function applyUserSettingsToPublicProfile():void{
         _location = _userSettings.location;
         _realName = _userSettings.realname;
         _website = _userSettings.website;
         _bio = _userSettings.bio;
         if (_userSettings.locale != BroLocale.LANG_NOT_DEFINED) {
            _locale = _userSettings.locale;
         }
      }
      
      public function get persistentId ():int {
         return _persistentId;
      }
      
      public function onLoadedInit(username:String,
                                   userDB:int,
                                   userID :int,
                                   roottreeDB:int,
                                   roottreeID:int,
                                   rootPearlDB:int,
                                   rootPearlID:int,
                                   location:String,
                                   avatarHash:String,
                                   realName:String,
                                   website:String,
                                   bio:String,
                                   dropZoneTreeid:int,
                                   lastVisitValue:Number,
                                   creationDate:Number,
                                   locale:int,
                                   isPremium:int,
                                   premiumLevel:int,
                                   feedNotifAck:Number=0,
                                   feedNotifLastSeenAck:Number=0,
                                   noveltyLastSeenAck:Number=0
      ):void{
         _anonymous=false;
         _name = username;
         _persistentDbId =userDB;
         _persistentId = userID;
         _location = location;
         _avatarHash = avatarHash;
         _realName = realName;
         _website = website;
         _bio = bio;
         _lastVisit = lastVisitValue;
         _rootPearlId = rootPearlID;
         _rootPearlDb = rootPearlDB;
         _creationDate = creationDate;
         _locale = locale;
         _feedNotifAck = feedNotifAck;
         _feedNotifLastSeenAck = feedNotifLastSeenAck;
         _noveltyPreviousLastSeenAck = noveltyLastSeenAck;
         _isPremium = isPremium;
         _premiumLevel = premiumLevel;
         _userWorld = new BroLocalTreeRefNode(roottreeDB, roottreeID);
         
         if (!_dropZoneTree) {
            _dropZoneTree = new BroLocalTreeRefNode(roottreeDB,dropZoneTreeid);
         }
         dispatchEvent(new FlexEvent(FlexEvent.INIT_COMPLETE));
      }
      
      public function get locale():int{
         return _locale;
      }
      
      public function set locale(value:int):void{
         _locale = value;
      }
      
      public function get dropZoneTreeRef ():BroLocalTreeRefNode
      {
         return _dropZoneTree;
      }
      public function isDropZoneTree(tree:BroPearlTree):Boolean {
         return (_dropZoneTree && tree && _dropZoneTree.treeId == tree.id && _dropZoneTree.treeDB == tree.dbId);
      }
      
      public function get creationDate():Number {
         return _creationDate;
      }
      
      public function get persistentDbId ():int
      {
         return _persistentDbId;
      }
      public override function toString():String {
         return _persistentId+"_"+name;
      }
      public static function areUsersSame(user1:User, user2:User):Boolean{
         
         return (user1 && user2 && (user1.name == user2.name) &&
            (user1.persistentDbId == user2.persistentDbId) &&
            (user2.persistentId == user1.persistentId));
      }
      
      static public function getUserKey(userDB:Number, userId:Number):String {
         return ""+userDB+"_"+userId;
      }
      static public function parseUserKey(key:String):Array {
         if (key == null) {
            return null;
         }
         var stringIds:Array=   key.split("_");
         if (stringIds.length!=2) { return null;};
         var result:Array = new Array(2);
         result[0] = parseInt(stringIds[0]);
         result[1] = parseInt(stringIds[1]);
         if (isNaN(result[0]) || isNaN(result[1])) {
            return null;
         }
         return result;
      }
      
      public function get lastVisit():Number {
         return _lastVisit;
      }
      public function get lastRightsVersionDate():DateThresholdWithMarginAndException
      {
         if (!_lastRightsVersionDate) {
            _lastRightsVersionDate = new DateThresholdWithMarginAndException(5);
         }
         return _lastRightsVersionDate;
      }
      
      public function isCurrentUser():Boolean {
         return areUsersSame(ApplicationManager.getInstance().currentUser, this);
      }
      
      public function getTeamCountAccessor():LazyValueAccessor {
         if (!_teamCountAccessor) {
            _teamCountAccessor = new TeamCountAccessor();
            _teamCountAccessor.owner = this;
         }
         return _teamCountAccessor;
      }
      
      public function get teamList():Array {
         getTeamCountAccessor();
         if (_teamCountAccessor) {
            return _teamCountAccessor.getTeamList();
         }
         return [];
      }
      
      public function get totalTeamCount():Number {
         getTeamCountAccessor();
         if (_teamCountAccessor) {
            return _teamCountAccessor.getTotalTeamCount();
         }
         return -1;
      }
      
      public function get connectionCount():Number {
         getTeamCountAccessor();
         if (_teamCountAccessor) {
            return _teamCountAccessor.getConnectionCount();
         }
         return -1;
      }

      public function get isPremium():int {
         return _isPremium;
      }
      
      public function set isPremium(value:int):void {
         _isPremium = value;
      }   
      
   }
}

import com.broceliand.ApplicationManager;
import com.broceliand.pearlTree.io.LazyValueAccessor;
import com.broceliand.pearlTree.io.object.tree.AssociationData;
import com.broceliand.pearlTree.io.services.AmfTreeService;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
import com.broceliand.pearlTree.model.User;
import com.broceliand.util.logging.Log;

import mx.collections.ArrayCollection;

class TeamCountAccessor extends LazyValueAccessor implements IAmfRetArrayCallback
{
   public function getTotalTeamCount():Number {
      var result:Array = super.internalValue as Array;
      if (result) {
         return result[1];
      }
      return -1;
   }
   
   public function getTeamList():Array {
      var result:Array = super.internalValue as Array;
      if (result) {
         var amfAssociations:ArrayCollection = result[0];
         var teamAssociations:Array = new Array();
         for each(var amfAsso:AssociationData in amfAssociations) {
            teamAssociations.push(AmfTreeService.getOrMakeAssociation(amfAsso));
         }
         return teamAssociations;
      }
      return [];
   }
   
   public function getConnectionCount():int {
      var result:Array = super.internalValue as Array;
      if (result) {
         return result[2] as int;
      }
      else return -1;
   }
   
   override protected function launchLoadValue():void {
      if (_owner) {
         var user:User = _owner as User;
         ApplicationManager.getInstance().distantServices.amfUserService.getUserBadges(user.persistentId, this);
         
      } else {
         Log.getLogger("com.broceliand.pearlTree.model.User").error("No user to load !");
         super.onError(null);
      }
   }
   public function onReturnValue(value:Array):void {
      super.internalValue = value;
      super.notifyValueAvailable();
   }
}

