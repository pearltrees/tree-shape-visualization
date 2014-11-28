package com.broceliand.pearlTree.model {
   import com.broceliand.ApplicationManager;
   import com.broceliand.ApplicationMessageBroadcaster;
   import com.broceliand.assets.pearlWindow.PWPreviewAssets;
   import com.broceliand.pearlTree.io.LazyValueAccessor;
   import com.broceliand.pearlTree.io.object.content.PearlArchiveData;
   import com.broceliand.ui.customization.logo.LogoManager;
   import com.broceliand.ui.model.VisualModel;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.ui.util.HexaHelper;
   import com.broceliand.util.ArchiveInfo;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.DateManager;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.utils.ByteArray;

   public class BroPage {
      
      public static const PREVIEW_ORIGIN:uint = 100;
      public static const PREVIEW_NORMAL:uint = 0;
      public static const PREVIEW_BIG:uint = 1;
      public static const PREVIEW_WIDE:uint = 2;
      public static const PREVIEW_THIN:uint = 3;
      public static const PREVIEW_LARGE:uint = 4;
      public static const PREVIEW_SQUARE:uint = 5;
      public static const PREVIEW_MINI:uint = 6;
      
      public static const PAGE_LOGO_TYPE_UPDATED:String = "pageLogoTypeUpdated";
      
      private static const STATE_READY:uint = 0;
      private static const STATE_BUILDING:uint = 1;
      private static const STATE_IGNORE:uint = 2;
      
      private static const EDITED_CONTENT_URL:String = "pearl/webEditedContent";
      private static const SCRAP_URL:String = "url/webUrl";
      private static const DEFAULT_UGC_NOTE:String = "60680c366ccfa6263afef4539a8863b6";
      
      private var _url:String;
      private var _pageLayout:BroPageLayout;
      private var _title:String;
      private var _playerUrl:String;
      private var _logoHash:ByteArray;
      private var _logoUrlHash:ByteArray;
      private var _urlHash:ByteArray;
      private var _logoType:int;
      private var _originalLogoTypeIfCustom:int;
      private var _previewHash:ByteArray;
      private var _logoUrl:String;
      private var _previewUrl:String;
      private var _previewUrlFull:String;   
      private var _previewUrlWide:String;
      private var _previewUrlSquare:String;
      private var _previewUrlLarge:String;
      private var _id:Number;
      private var _badFrame:int = -1;
      private var _urlId:int = -1;
      private var _extension:String = "";
      private var _sourceFileName:String;
      private var _archivesCapture:Array;
      private var _archivesPage:Array;
      private var _archiveLoaded:Boolean = false;
      
      private var _authorAccessor:AuthorAccessor;
      private var _hasArchive:Boolean = false;
      
      public function BroPage() {
      }

      private function cloneBroPage() : BroPage {
         var broNotePage : BroNotePage = this as BroNotePage;
         if (broNotePage) {
            var res : BroNotePage = new BroNotePage();
            res.noteText = broNotePage.noteText;
            return res; 
         }
         return new BroPage();
      }
      
      public function clone():BroPage {
         var result:BroPage = this.cloneBroPage();
         result._url = _url;
         result._title = _title;
         result._pageLayout = _pageLayout;
         result._playerUrl = _playerUrl;
         result._logoHash =_logoHash;
         result._previewHash = _previewHash;
         result._logoType =_logoType;
         result._id = _id;
         result._badFrame= _badFrame;
         result._urlId = _urlId;
         result.extension = _extension;
         return result;
      }
      
      public function set badFrame(value:int):void{
         _badFrame = value;
      }
      public function get badFrame():int{
         return _badFrame;
      }
      
      public function isBadFrame():Boolean{
         return (_badFrame >= 1);
      }
      public function isBadScript():Boolean{
         return (_badFrame >=2);
      }
      
      public function get url():String {
         return _url;
      }
      public function set url(val:String):void {
         _url = val;
      }
      
      public function get urlId():int {
         return _urlId;
      }
      public function set urlId(value:int):void {
         _urlId = value;
      }
      
      public function set title(val:String):void {
         _title = val;
      }
      public function get title():String {
         return _title;
      }
      
      public function set playerUrl(val:String):void {
         _playerUrl = val;
      }
      public function get playerUrl():String {
         return _playerUrl;
      }
      
      public function setType(value:int, urlValue:int):void {
         pageLayout.setType(value, urlValue);
      }
      public function get type():int {
         return pageLayout.type;
      }
      public function set type(value:int):void {
         pageLayout.type = value;
      }
      
      public function get editedLayout():int {
         return pageLayout.editedLayout;
      }
      public function set editedLayout(value:int):void {
         pageLayout.editedLayout = value;
      }
      
      public function get logoType(): int {
         return _logoType;
      }
      
      public function set logoType(value:int):void {
         if (value != _logoType) {
            _logoType = value;
            
            _previewUrl  = null;
            _logoUrl = createLogoUrl();
            if (value == LogoManager.THUMBSHOT_TYPE || value == LogoManager.SERVER_TYPE) {
               broadcastPageLogoTypeUpdated();
            }
         }
      }
      
      public function isWithSynthesis():Boolean {
         return pageLayout.isWithSynthesis();
      }
      
      public function isWithDetail():Boolean {
         return pageLayout.isWithDetail();
      }
      
      private function hasScrap():Boolean {
         return pageLayout.hasScrap();
      }
      
      public function isNote():Boolean {
         return pageLayout.isNote();
      }
      
      public function isNoteDeleted():Boolean {
         return pageLayout.isNoteDeleted();
      }
      
      public function isPhoto():Boolean {
         return pageLayout.isPhoto();
      }
      
      public function isPhotoDeleted():Boolean {
         return pageLayout.isPhotoDeleted();
      }
      
      public function isPhotoUploading():Boolean {
         return pageLayout.isPhotoUploading();
      }
      
      public function isPhotoNotReady():Boolean {
         return pageLayout.isPhotoNotReady();
      }
      
      public function isDoc():Boolean {
         return pageLayout.isDoc();
      }
      
      public function isDocNotFetchedYet():Boolean {
         var isDoc:Boolean = isDoc();
         var isFetched:Boolean = isDocFetched();
         return isDoc && !isFetched;
      }
      
      public function isLogoCustomized():Boolean {
         return logoType == LogoManager.CUSTOM_TYPE;
      }
      
      private function getOriginalDocLogoType():uint {
         if (isLogoCustomized()) {
            return originalLogoTypeIfCustom;
         }
         else {
            return logoType;
         }
      }
      
      public function isDocNotFetchable():Boolean {
         return isDoc() && getOriginalDocLogoType() == LogoManager.SERVER_TYPE;
      }
      
      public function isDocUploading():Boolean {
         return pageLayout.isDocUploading();
      }
      
      public function isDocFetching():Boolean {
         return getOriginalDocLogoType() == LogoManager.FAVICO_TYPE && !isDocUploading();
      }
      
      public function isDocFetched():Boolean {
         return getOriginalDocLogoType() == LogoManager.THUMBSHOT_TYPE;
      }
      
      public function isDocDeleted():Boolean {
         return pageLayout.isDocDeleted();
      }
      
      public function isDocRestricted():Boolean {
         return pageLayout.isDocRestricted();
      }
      
      public function isNoteRestricted():Boolean {
         return pageLayout.isNoteRestricted();
      }
      
      public function isPhotoRestricted():Boolean {
         return pageLayout.isPhotoRestricted();
      }
      
      public static function isUserContentRestrictedOnCreation():Boolean {
         return ApplicationManager.getInstance().isPremium != 0;  
      }
      
      public function isRestrictedContent():Boolean {
         return pageLayout.isRestrictedContent();
      }
      
      public function isEditedContent():Boolean {
         return pageLayout.isEditedContent();
      }
      
      public function isScrapLayout():Boolean {
         return pageLayout.isScrapLayout();
      }
      
      public function setEditedContent(value:Boolean):void {
         return pageLayout.setEditedContent(value);
      }
      
      public function getPreviewUrlForSW():String {
         return getPreviewUrl(PREVIEW_SQUARE);
      }
      
      public function getPreviewUrl(type:uint=0, requestServer:Boolean=false, isOnCdn:Boolean = true):String {
         if(!_previewHash) return null;
         var am:ApplicationManager = ApplicationManager.getInstance();
         requestServer = isPhotoRestricted() ? true : requestServer;
         if (isUserContent()) {
            var specialPreview:String = null;
            if (isPhotoDeleted() || isNoteDeleted() || isDocDeleted()) { 
               specialPreview = AssetsManager.getRemoteAssetUrl(PWPreviewAssets.UGC_THUMB_CONTENT_ERASED);
            } else if (isPhotoNotReady() || isPhotoUploading()) {
               specialPreview = AssetsManager.getRemoteAssetUrl(PWPreviewAssets.UGC_THUMB_BUILDING_CONTENT);
            } else if (isNote()) {
               specialPreview = AssetsManager.getRemoteAssetUrl(PWPreviewAssets.UGC_NOTE);
            } 
            else if (isPhoto() && type == PREVIEW_LARGE) {
               if (isOnCdn && !isRestrictedContent() && !requestServer) {
                  specialPreview = am.getMediaUrl()+buildPreviewPath(HexaHelper.byteArrayToHexString(_previewHash), type, 3);
               } else {
                  specialPreview = am.getServicesUrl()+ "preview/media/" +buildPreviewPath(HexaHelper.byteArrayToHexString(_previewHash), type, 3);
               }
            } else if (isPhoto() && type == PREVIEW_ORIGIN) {
               specialPreview = am.getServicesUrl()+ "image/origin/" +buildPreviewPath(HexaHelper.byteArrayToHexString(_previewHash), type, 3);
            }
            if (specialPreview) {
               specialPreview += ApplicationManager.getInstance().getInvalidatedCdnSuffix();
               return specialPreview;
            }
         }    
         
         if(type == PREVIEW_BIG) {
            if(!_previewUrlFull || requestServer) {
               _previewUrlFull = createPreviewUrl(type, requestServer);
            }
            return _previewUrlFull;
         }else if (type == PREVIEW_NORMAL) {
            if(!_previewUrl || requestServer) {
               _previewUrl = createPreviewUrl(type, requestServer);
            }
            return _previewUrl;
         }
         else if (type == PREVIEW_WIDE) {        
            if (!_previewUrlWide || requestServer) {
               _previewUrlWide = createPreviewUrl(type, requestServer);
            }
            return _previewUrlWide;
         }
         else if (type == PREVIEW_SQUARE) {        
            if (!_previewUrlSquare || requestServer) {
               _previewUrlSquare = createPreviewUrl(type, requestServer);
            }
            return _previewUrlSquare;
         }
         else if (type == PREVIEW_LARGE) {        
            if (!_previewUrlLarge || requestServer) {
               _previewUrlLarge = createPreviewUrl(type, requestServer);
            }
            return _previewUrlLarge;
         }
         else if (type == PREVIEW_THIN) {        
            return createPreviewUrl(type, requestServer);
         }
         else if (type == PREVIEW_MINI) {
            return createPreviewUrl(type, requestServer);
         }
         return null;
      }
      
      public function resetPreviewUrls():void {
         _previewUrl = _previewUrlFull = _previewUrlLarge = _previewUrlSquare = _previewUrlWide = null;
      }
      
      private function getUnfetchedDocumentUrl(type:uint):String {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var service:String = am.getServicesUrl() + "preview/";
         var isNotFetchable:Boolean = logoType == LogoManager.SERVER_TYPE;
         var isUploading:Boolean = logoType != LogoManager.THUMBSHOT_TYPE && pageLayout.type == BroPageLayout.TYPE_DOCUMENT_UPLOADING;
         var isFetching:Boolean = logoType != LogoManager.THUMBSHOT_TYPE;
         var isEnglish:Boolean = BroLocale.getInstance().lang == BroLocale.ENGLISH;
         if (isNotFetchable) {
            return service + getTypeString(type) + "?ext="+extension;
         }
         else if (isUploading) {
            return service + getTypeString(type) + "?state=uploading" + "&lang=" + (isEnglish ? "en" : "fr");
         }
         else if (isFetching) {
            return service + getTypeString(type) + "?state=processing" + "&lang=" + (isEnglish ? "en" : "fr");
         }
         return service + getTypeString(type) + "?urlId="+this.urlId;
      }
      
      private function getTypeString(type:uint):String {
         if (type == PREVIEW_NORMAL) {
            return "normal";   
         } else if (type == PREVIEW_BIG) {
            return "big";
         } else if (type == PREVIEW_WIDE) {
            return "wide";
         } else if (type == PREVIEW_THIN) {
            return "thin";
         } else if (type == PREVIEW_LARGE) {
            return "large";
         } else if (type == PREVIEW_MINI) {
            return "mini";
         } else {
            return "square";
         }
      }
      
      private function createPreviewUrl(type:uint, requestServer:Boolean):String {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var service:String = "preview/image/";      
         var previewUrl:String;
         if (isDocNotFetchedYet()) {
            
            previewUrl = getUnfetchedDocumentUrl(type);
            return  previewUrl;
         }
         else if (requestServer) {
            previewUrl = am.getServicesUrl()+service;
         }
         else {
            if (type == PREVIEW_NORMAL) {
               if (_logoType == LogoManager.SCRAP_TYPE) {
                  previewUrl = am.getScrapLogoUrl();
               } else if (_logoType == LogoManager.META_TYPE) {
                  previewUrl = am.getMetaLogoUrl();
               } else {
                  previewUrl = am.getThumbshotUrl();
               }
            } else {
               previewUrl = am.getThumbshotUrl();
            }
         }
         previewUrl += buildPreviewPath(HexaHelper.byteArrayToHexString(_previewHash), type);
         previewUrl += ApplicationManager.getInstance().getInvalidatedCdnSuffix();
         return previewUrl;      
      }
      
      public function isUnfetchedDocument():Boolean {
         return isDoc() && _logoType != LogoManager.THUMBSHOT_TYPE;
      }
      
      private function buildPreviewPath(hash:String, previewType:uint=0, prefixCount:int = 2):String {
         if(!hash) return null;
         var previewPath:String = "";
         for (var i:int = 0; i <prefixCount ;i ++) {
            previewPath += hash.substr(i*2,2) +"/";
         }
         previewPath+=  hash;      
         if(previewType == PREVIEW_BIG) {
            previewPath += "-full.jpg";
         }else if (previewType == PREVIEW_WIDE) {
            previewPath += "-wide.jpg";
         }else if (previewType == PREVIEW_THIN) {
            previewPath += "-thin.jpg";
         }else if (previewType == PREVIEW_SQUARE) {
            previewPath += "-square.jpg";
         } else if (previewType == PREVIEW_LARGE) {
            previewPath += "-l.jpg";
         } else if (previewType == PREVIEW_ORIGIN) {
            previewPath += "";
         } else if (previewType == PREVIEW_MINI) {
            previewPath += "-mini.jpg";
         } else {
            previewPath += ".jpg";
         }
         return previewPath;
      }
      
      public function set id(val:Number):void {
         _id = val;
      }
      public function get id():Number {
         return _id;
      }
      
      public function get logoHash():ByteArray {
         return _logoHash;
      }
      public function set logoHash(val:ByteArray):void {
         _logoHash = val;
         _logoUrl = createLogoUrl();
      }
      
      public function get urlHash():ByteArray {
         return _urlHash;
      }
      public function set urlHash(val:ByteArray):void {
         _urlHash = val;
         _logoUrl = createLogoUrl();
      }
      
      public function set previewHash(val:ByteArray):void {
         _previewHash = val;
      }
      
      public function get previewHash():ByteArray {
         return _previewHash;
      }

      public function get logoUrl():String {
         if(!_logoUrl) {
            _logoUrl = createLogoUrl();
         }
         return _logoUrl;
      }
      
      private function createLogoUrl():String {
         if (isDocNotFetchedYet()) {
            if (logoType == LogoManager.FAVICO_TYPE) {
               logoType = LogoManager.TEMPORARY_TYPE;
            }
            return createLogoUrlForDocNotFetched();
         }
         else if (isNote() && (_logoHash== null || HexaHelper.byteArrayToHexString(_logoHash) == DEFAULT_UGC_NOTE)) {
            return LogoManager.getNoteLogoUrl();
         } 
         else if (logoType == LogoManager.FAVICO_TYPE || logoType == LogoManager.TEMPORARY_TYPE) {
            logoType = LogoManager.TEMPORARY_TYPE;
            return LogoManager.getTemporaryLogoUrl(this);
         } 

         var h:String = getUsedLogoHashHex();         
         var typeSuffix:String ;
         if (isNote() && (logoType != LogoManager.CUSTOM_TYPE || _logoHash== null)) {
            typeSuffix = LogoManager.PEARL_IOS_HD;
         }
         else {
            typeSuffix = LogoManager.getTypeSuffixFromLogoType(logoType);
         }
         var url:String = LogoManager.getLogoUrlFromHash(h, typeSuffix, logoType);
         return url;
      }
      
      private function createLogoUrlForDocNotFetched():String {
         if (isDocNotFetchable()) {
            return LogoManager.getDocNotFetchableLogoUrl(extension);
         }
         else if (isDocUploading()) {
            return LogoManager.getDocUploadingLogoUrl();
         }
         else if (isDocFetching()) {
            return LogoManager.getDocFetchingLogoUrl();
         }
         else {
            return LogoManager.getDocFetchingLogoUrl();
         }
      }
      
      public function getUsedLogoHashHex():String {
         var h:String;
         
         if (_logoHash != null && logoType == LogoManager.CUSTOM_TYPE) {
            
            h = HexaHelper.byteArrayToHexString(_logoHash);
         } 
         else if (_previewHash != null && (logoType == LogoManager.THUMBSHOT_TYPE || logoType == LogoManager.SCRAP_TYPE || logoType == LogoManager.META_TYPE))  {
            
            h = HexaHelper.byteArrayToHexString(_previewHash);
         }
         else if (_logoHash != null && !isNote() && !_logoHash == LogoManager.TEMPORARY_TYPE) {
            
            h = HexaHelper.byteArrayToHexString(_logoHash);
         }
         else if (isNote() && (logoType != LogoManager.CUSTOM_TYPE || _logoHash== null)) {
            
            h = HexaHelper.byteArrayToHexString(_logoHash);
         }
         else {
            return null;
         }
         return h;
      }
      
      public function toString():String {
         return "Page : "+title+ " ( id = "+_id+ ", url = "+url + ")";
      }
      public function isWelcomePage():Boolean {
         return WelcomePearlsExceptions.isWelcomePage(this);
      }
      
      public function isUserContent():Boolean {
         return isNote() || isPhoto() || isDoc(); 
      }
      
      public function getContentUrl(isPremiumExpired:Boolean = false):String {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var servicesUrl:String = this.shouldUseCdn() ? am.getCachableServicesUrl(): am.getServicesUrl();
         var cdnLocationName:String = am.getCdnLocationName();
         if (cdnLocationName.length > 0) {
            cdnLocationName = "&l="+cdnLocationName;
         }
         
         var contentUrl:String;
         if (isEditedContent()) {
            contentUrl = servicesUrl + EDITED_CONTENT_URL + "?pearlId=" + id;
            
         } else {
            contentUrl = servicesUrl + SCRAP_URL + "?urlId=" + urlId + cdnLocationName;
         }
         if (isPremiumExpired) {
            contentUrl +="&premium=no&loc="+BroLocale.getInstance().lang;
         }
         if (am.currentUser.isAnonymous()) {
            contentUrl+="&u=0";
         }
         return contentUrl;
      }
      
      private function shouldUseCdn():Boolean {
         return ((this.isPhoto() && ! this.isRestrictedContent()) || !this.isUserContent());
      }
      
      public function getAuthorAccessor():LazyValueAccessor {
         if (_authorAccessor == null) {
            _authorAccessor = new AuthorAccessor();
            _authorAccessor.owner = this;
         }        
         return _authorAccessor;
      }
      
      public function getAuthor():User {
         if (_authorAccessor) {
            return _authorAccessor.getAuthor();
         }
         return null;
      }
      
      public function getDate():Date {
         if (_authorAccessor) {
            return _authorAccessor.getDate();
         }
         return null;
      }
      
      public function getVisibility():uint {
         if (_authorAccessor) {
            return _authorAccessor.getVisibility();
         }
         return null;
      }
      
      public function getVisibilityAsAString():String {
         var visible:uint = getVisibility();
         return BroLocale.getInstance().getText("sw.notestatus." + ((visible == 0) ? "public" : "private"));
      }
      
      public function get originalLogoTypeIfCustom():int {
         return _originalLogoTypeIfCustom;
      }
      
      public function set originalLogoTypeIfCustom(value:int):void {
         _originalLogoTypeIfCustom = value;
      }
      
      public function get logoUrlHash():ByteArray {
         return _logoUrlHash;
      }
      
      public function set logoUrlHash(value:ByteArray):void {
         _logoUrlHash = value;
      }
      
      public function get pageLayout():BroPageLayout {
         if (!_pageLayout) {
            _pageLayout = new BroPageLayout();
         }
         return _pageLayout;
      }
      
      public function set pageLayout(value:BroPageLayout):void {
         _pageLayout = value;
      }
      
      public function registerNewArchive(pearlArchiveData:PearlArchiveData):void {
         archiveLoaded = true;
         hasArchive = true;
         var mode:int = pearlArchiveData.mode;
         if (mode == ArchiveManager.ARCHIVE_CAPTURE_MODE) {
            registerNewArchiveCapture(pearlArchiveData);
         } else if (mode == ArchiveManager.ARCHIVE_BOTH_MODE) {
            registerNewArchivePage(pearlArchiveData);
            registerNewArchiveCapture(pearlArchiveData);
         } else if (mode == ArchiveManager.ARCHIVE_WEBPAGE_MODE) {
            registerNewArchivePage(pearlArchiveData);
         }
      }
      
      public function loadArchives(pearlArchiveDatas:Array):void {
         _archivesCapture = new Array();
         _archivesPage = new Array();
         for each (var p:PearlArchiveData in pearlArchiveDatas) {
            registerNewArchive(p);
         }
      }
      
      private function registerNewArchivePage(p:PearlArchiveData):void {
         if (!_archivesPage) _archivesPage = new Array();
         var mode:int = ArchiveManager.ARCHIVE_WEBPAGE_MODE;
         var url:String = ArchiveManager.buildUrlFromArchiveData(p.pearlId, p.key, mode);
         var date:String = DateManager.formatDate(DateManager.timestampToDate(p.date));
         var archiveInfo:ArchiveInfo = new ArchiveInfo(url, mode, date, title);
         _archivesPage.push(archiveInfo);         
      }
      
      private function registerNewArchiveCapture(p:PearlArchiveData):void {
         if (!_archivesCapture) _archivesCapture = new Array();
         var mode:int = ArchiveManager.ARCHIVE_CAPTURE_MODE;
         var url:String = ArchiveManager.buildUrlFromArchiveData(p.pearlId, p.key, mode);
         var date:String = DateManager.formatDate(DateManager.timestampToDate(p.date));
         var archiveInfo:ArchiveInfo = new ArchiveInfo(url, mode, date, title);
         _archivesCapture.push(archiveInfo);
      }
      
      public function getFileExtension():String {
         var extension:String = "";
         if (_sourceFileName) {
            var dotPosition:int = _sourceFileName.lastIndexOf(".");
            if (dotPosition < _sourceFileName.length - 1 && dotPosition != -1) {
               extension = _sourceFileName.substr(dotPosition + 1, _sourceFileName.length - dotPosition - 1);
            }
         }
         return extension;
      }
      
      public function getUrlToVisualizeDocument():String {
         if (isDoc()) {
            return ApplicationManager.getInstance().getServicesUrl() + "file/preview/" + urlId + "/" + title;
         }
         return null;
      }
      
      public function getUrlToVisualizeOriginalDocument():String {
         if (isDoc()) {
            return ApplicationManager.getInstance().getServicesUrl() + "file/view/" + urlId + "/" + title + "." + extension;
         }
         return null;
      }
      
      public function getUrlToDownloadDocument():String {
         if (isDoc()) {
            return ApplicationManager.getInstance().getServicesUrl() + "file/download/" + urlId + "/" + title + "." + extension;
         }
         return null;
      }
      
      private function broadcastPageLogoTypeUpdated():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var visualModel:VisualModel = am.visualModel;
         var broadcaster:ApplicationMessageBroadcaster = visualModel.applicationMessageBroadcaster;
         broadcaster.dispatchEvent(new Event(PAGE_LOGO_TYPE_UPDATED));
      }
      
      public function get archivesCapture():Array
      {
         return _archivesCapture;
      }
      
      public function set archivesCapture(value:Array):void
      {
         _archivesCapture = value;
      }
      
      public function get archivesPage():Array
      {
         return _archivesPage;
      }
      
      public function set archivesPage(value:Array):void
      {
         _archivesPage = value;
      }
      
      public function get archiveLoaded():Boolean
      {
         return _archiveLoaded;
      }
      
      public function set archiveLoaded(value:Boolean):void
      {
         _archiveLoaded = value;
      }
      
      public function get hasArchive():Boolean
      {
         return _hasArchive;
      }
      
      public function set hasArchive(value:Boolean):void
      {
         _hasArchive = value;
      }
      
      public function get sourceFileName():String
      {
         return "default";
         
      }
      
      public function set sourceFileName(value:String):void
      {
         _sourceFileName = value;
      }
      
      public function get extension():String
      {
         return _extension;
      }
      
      public function set extension(value:String):void
      {
         _extension = value;
      }
      
   }
}

import com.broceliand.ApplicationManager;
import com.broceliand.pearlTree.io.LazyValueAccessor;
import com.broceliand.pearlTree.io.services.AmfUserService;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
import com.broceliand.pearlTree.model.BroPage;
import com.broceliand.pearlTree.model.User;
import com.broceliand.util.logging.Log;

class AuthorAccessor extends LazyValueAccessor implements IAmfRetArrayCallback {
   
   public function getAuthor():User {
      var result:Array= super.internalValue as Array;
      if (result) {
         return result[0] as User;
      }
      return null;
   }
   
   public function getDate():Date {
      var result:Array= super.internalValue as Array;
      if (result) {
         return result[2] as Date;
      }
      return null;
   }
   
   public function getVisibility():uint {
      var result:Array= super.internalValue as Array;
      if (result) {
         return result[1] as uint;
      }
      return null;
   }
   
   override protected function launchLoadValue():void {
      if (_owner) {
         var page:BroPage = _owner as BroPage;
         ApplicationManager.getInstance().distantServices.amfTreeService.getPearlMeta(page, this);
      } else {
         Log.getLogger("com.broceliand.pearlTree.model.BroPage").error("No pearl author to load !");
         super.onError(null);
      }
   }
   
   public function onReturnValue(value:Array):void {
      value[0]= AmfUserService.makeUser(value[0]);
      super.internalValue = value; 
      super.notifyValueAvailable();
   }
   
}
