package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ExternalJavascriptInterface;
   import com.broceliand.IJavascriptInterface;
   import com.broceliand.util.externalServices.FacebookAccountSynchronization;
   import com.broceliand.util.externalServices.FacebookAuthenticationState;
   
   import flash.events.Event;
   
   public class CurrentUser extends User
   {
      private var _facebookAccount:FacebookAccount;
      private var _shouldLinkFacebookAccount:Boolean;
      private var _openPWOnNextOver:Boolean;
      private var _userGauge:UserGaugeModel;
      
      public function CurrentUser() {
         super();
         var extInterface:IJavascriptInterface = ApplicationManager.getInstance().getExternalInterface();
         var facebookId:String = extInterface.getFacebookId();

         _facebookAccount = new FacebookAccount(facebookId);
         _shouldLinkFacebookAccount = true;
         
         if (facebookId == null) {
            extInterface.addEventListener(ExternalJavascriptInterface.FACEBOOK_ID_LOADED, onFacebookIdLoaded);
         }
         _userGauge = new UserGaugeModel();
      }
      
      override public function onLoadedInit(username:String,
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
         super.onLoadedInit(username, userDB, userID, rootPearlDB, roottreeID, rootPearlDB, rootPearlID, location, avatarHash, realName,
            website, bio, dropZoneTreeid, lastVisitValue, creationDate, locale,  isPremium, premiumLevel, feedNotifAck, feedNotifLastSeenAck, 
            noveltyLastSeenAck);
         _userGauge.setUserId(userID);
      }           
      
      public function userGaugeModel():UserGaugeModel {
         return _userGauge;
      }
      
      public function get facebookAccount():FacebookAccount {
         return _facebookAccount;
      }
      
      public function updateFacebookToken():void {
         if (_facebookAccount.isLoggedOnFacebook()) {
            _facebookAccount.updateFacebookToken();
         }
      }
      
      public function isLoggedOnFacebook():Boolean {
         return _facebookAccount.isLoggedOnFacebook();
      }
      
      public function shareDiscoveries():Boolean {
         var fbSync:FacebookAccountSynchronization = ApplicationManager.getInstance().distantServices.facebookAccountSynchronisation;
         return ((isLoggedOnFacebook()
            && AutoActionFbState.isAutoActionEnabled(facebookAccount.autoActionFbState, AutoActionFbState.DISCOVERIES))
            || isLoggedUserSharingDiscoveries());
      }
      
      public function isLoggedUserSharingDiscoveries():Boolean {
         if (userSettings == null) {
            return false;
         }
         var isSharingDiscoveries:Boolean = AutoActionFbState.isAutoActionEnabled(userSettings.autoActionFbState, AutoActionFbState.DISCOVERIES);
         return isSharingDiscoveries;
      }
      
      public function get profilePictureUrl():String {
         return _facebookAccount.getProfilePictureUrl();
      }
      
      public function get shouldLinkFacebookAccount():Boolean {
         return _shouldLinkFacebookAccount;
      }
      
      public function set shouldLinkFacebookAccount(value:Boolean):void {
         _shouldLinkFacebookAccount = value;
      }
      
      private function onFacebookIdLoaded(event:Event):void {
         var extInterface:IJavascriptInterface = ApplicationManager.getInstance().getExternalInterface();
         var facebookId:String = extInterface.getFacebookId();
         if (facebookId != null) {
            _facebookAccount = new FacebookAccount(facebookId);
            _shouldLinkFacebookAccount = true;
         }
      }
      
      public function shouldOpenPWOnNextOver(isFirstOne:Boolean):Boolean {
         return (isAnonymous() && isFirstOne) || openPWOnNextOver;
      }
      
      public function get openPWOnNextOver():Boolean {
         return _openPWOnNextOver;
      }
      
      public function set openPWOnNextOver(value:Boolean):void {
         _openPWOnNextOver = value;
      }
   }
}