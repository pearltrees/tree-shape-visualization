package com.broceliand {
   
   import com.broceliand.pearlTree.model.BroPageNode;
   
   import flash.events.IEventDispatcher;
   
   public interface IJavascriptInterface extends IEventDispatcher {
      function decodeJSON(data:String):Object;
      function isInterfaceReady():Boolean;
      function addEmbedJS():void;
      function setisScrollableWindow(isLocked:Boolean):void;
      function notifyLogin():void;
      function notifyPearlDeleted(pearl:BroPageNode):void;
      function notifyLogout():void;
      function detectPearlbar():void;
      function changeParentUrl(parentUrl:String):void;
      function getWebSiteUrl():String;
      function getStaticContentUrl():String;
      function getLogoUrl():String;
      function getMetaLogoUrl():String;
      function getScrapLogoUrl():String;
      function getThumbLogoUrl():String;
      function getUserInvitingYou():String;
      function getAvatarUrl():String;
      function getBackgroundUrl():String;
      function getBiblioUrl():String;
      function getThumbshotUrl():String;
      function getPromoUrl():String;
      function getServicesUrl():String;
      function getMediaUrl():String;
      function getShortenerDomain():String;
      function getOrigin():String;
      function getLoginUsername():String;
      function getUserName():String;
      function getUserId():String;
      function getSessionID():String;
      function hideWaitingPanel():void;
      function getLostPasswordToken():String;
      function getInvitationKey():String;
      function getFbRequestId():String;
      function getAbModel():Number;
      function getCountryCode():String;
      function getClientLang():String;
      function getStartTime():Number;
      function getStartupMessage():String;
      function hasPromoBigWindow():Boolean;
      function getPromoBigWindow():Number;
      function getTeaserMode():Number;
      function getAddPearlEmail():String;
      function getPearlWindowStatus():Number;
      function getArrivalTreeId():Number;
      function getBrowserName():String;
      function getBrowserVersion():String;
      function getInvitationEmail():String;
      function setWindowStatus(title:String):void;
      function getLocalLastSaveVersion():Number;
      function setLocalLastSaveVersion(lastSaveDate:Number):void;
      function setPlayerMode(mode:int):void;
      function getPlayerMode():int;
      function getStartLocationFromURL():String;
      function testCookieEnabled():Boolean;
      function reloadPage():void;
      function reloadPageWithDelay():void;
      function loadPageInIFrame(source:String, isBackward:Boolean=false, skipEffect:Boolean=false):void;
      function clearIFrame():void;
      function getUserLang():int;
      function openPopup(url:String, width:Number, height:Number):void;
      function openWindow(url:String, target:String):void;
      function openMonitoredPopup(url:String, width:Number, height:Number):void;
      function closeMonitoredPopup():void;
      function getMonitoredPopupAnswer() : String;
      function openBookmarkletInstallPopup():void;
      function loadPageInCache(url:String, keepUrl:Boolean = false):String;
      function removePageInCache(id:String):void;
      function notifyLoadingEnd():void;
      function getPlayerStartUrl():String;
      function getClientId():String;
      function notifyNewAccountCreated(userId:int):void;
      function notifyUserHasDockedPearlWindow(userId:int):void;
      function savePotentialBadFrameId(pearlId:Number):void;
      
      function openFacepile(z_index:int, banner_width:int, offset_x:int, offset_y:int, width:int, height: int, url:String) : void;
      function resizeFacepile(z_index:int, banner_width:int, offset_x:int, offset_y:int, width:int, height: int) : void;
      function closeFacepile() : void;
      
      function updateFacebookToken(updateUrl:String):void
      function getFacebookId() : String;
      function getFacebookIdIsLoading() : Boolean;
      
      function getLocationName():String;
      function getBackgroundHash():String;
      
      function uploadDocument():void;
      function cancelUpload():void;
      function applyUrlIdToUploadingFiles(urlIds:Array):void;
      function isFileApiSupported():Boolean;
      function downloadUrl(url:String):void;
      function refreshFileSelectorInHtml():void;
      function protectUploadFromTabClosing(message:String):void;
      function unprotectUploadFromTabClosing():void;
      function removeUploadFile(filePosition:int, batchPosition:int):void;
      function get isProtectingUpload():Boolean;
      function isUsingMac():Boolean;
      function listenToFireFoxAddonInstallation():void;
      function openAlert(message: String): void;
   }
}
