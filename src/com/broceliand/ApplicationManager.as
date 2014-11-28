package com.broceliand {
   
   import com.broceliand.graphLayout.controller.PearlContextMenu;
   import com.broceliand.io.IPearlTreeLoaderManager;
   import com.broceliand.pearlTree.io.exporter.AmfTreePersistencyQueue;
   import com.broceliand.pearlTree.io.exporter.Exporters;
   import com.broceliand.pearlTree.io.exporter.IPearlTreeQueue;
   import com.broceliand.pearlTree.io.loader.AccountManager;
   import com.broceliand.pearlTree.io.loader.PearlTreeLoaderManager;
   import com.broceliand.pearlTree.io.loader.PromoLoader;
   import com.broceliand.pearlTree.io.loader.SessionHelper;
   import com.broceliand.pearlTree.io.loader.UserLoader;
   import com.broceliand.pearlTree.model.BroDataRepository;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.CurrentUser;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.UserFactory;
   import com.broceliand.pearlTree.model.notification.NotificationCenter;
   import com.broceliand.pearlTree.model.premium.PremiumRightManager;
   import com.broceliand.pearlTree.navigation.impl.Url2EmbedWindow;
   import com.broceliand.pearlTree.navigation.impl.Url2Overlay;
   import com.broceliand.ui.ComponentsAccessPoint;
   import com.broceliand.ui.PTStyleManager;
   import com.broceliand.ui.controller.IMenuActions;
   import com.broceliand.ui.controller.startPolicy.EmbedWindowStartPolicy;
   import com.broceliand.ui.customization.avatar.AvatarManager;
   import com.broceliand.ui.customization.background.BackgroundManager;
   import com.broceliand.ui.customization.logo.LogoManager;
   import com.broceliand.ui.embed.EmbedJavascriptInterface;
   import com.broceliand.ui.model.VisualModel;
   import com.broceliand.ui.panel.MenuActions;
   import com.broceliand.ui.window.ui.eventpromo.EventPromoHelper;
   import com.broceliand.util.ApplicationLoadingInfo;
   import com.broceliand.util.Assert;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.IErrorReporter;
   import com.broceliand.util.LanguageSelect;
   import com.broceliand.util.PTKeyboardListener;
   import com.broceliand.util.UrlNavigationController;
   import com.broceliand.util.error.DefaultErrorReporter;
   import com.broceliand.util.logging.Log;
   import com.broceliand.util.resources.RemoteResourceManagers;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.SharedObject;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.ui.Multitouch;
   import flash.ui.MultitouchInputMode;
   import flash.utils.getTimer;
   
   import mx.controls.Text;
   import mx.core.Application;
   import mx.managers.ToolTipManager;
   import mx.utils.StringUtil;
   
   public class ApplicationManager extends EventDispatcher {
      
      private static const TRACE_DEBUG:Boolean = false;
      
      public static const USE_DISCOVER:Boolean = true;
      
      public static const CLOSING_EVENT:String = "applicationClosing";
      public static const FOCUS_CHANGE_EVENT:String = "applicationFocusChange";
      
      public static const BROWSER_NAME_CHROME:String = "Chrome";
      public static const BROWSER_NAME_FIREFOX:String = "Firefox";
      public static const BROWSER_NAME_MSIE:String = "Explorer";
      public static const BROWSER_NAME_OPERA:String = "Opera";
      public static const BROWSER_NAME_SAFARI:String = "Safari";
      
      public static const OS_NAME_WINDOWS:String = "Windows";
      public static const OS_NAME_MAC:String = "Mac";
      public static const OS_NAME_LINUX:String = "Linux";
      
      public static const FULL_MODE:uint = 0;
      public static const EMBED_MODE:uint = 1;
      public static const OVERLAY_MODE:uint = 2;
      public static const EMBED_WINDOW_MODE:uint = 3;
      
      public static const EMBED_TYPE_UNKNOWN:uint = 0;
      public static const EMBED_TYPE_SUPER_EMBED:uint = 1;
      public static const EMBED_TYPE_PEARL_EMBED:uint = 2;
      
      private static const DEFAULT_SHORTENER:String = "";
      private static const SWF_RELATIVE_PATH:String = "flash/main.swf";
      public static const SWF_VERSION_PARAM:String = "v";
      private static const SERVICE_PATH:String = "";
      private static const PHOTO_PEARL_PATH:String = "";
      private static const NOTE_PEARL_PATH:String = "";
      public static const DEFAULT_DOMAIN:String = "";
      public static const DEFAULT_STATIC_CONTENT_DOMAIN:String = "";
      public static const DEFAULT_LOGO_URL:String =  "";
      public static const DEFAULT_THUMBLOGO_URL:String =  "";
      public static const DEFAULT_SCRAPLOGO_URL:String =  "";
      public static const DEFAULT_METALOGO_URL:String =  "";
      public static const DEFAULT_AVATAR_URL:String =  "";
      public static const DEFAULT_BACKGROUND_URL:String =  "";
      public static const DEFAULT_THUMBSHOT_URL:String =  "";
      public static const DEFAULT_MEDIA_URL:String =  "";
      public static const DEFAULT_BIBLIO_URL:String =  "";
      public static const DEFAULT_PHOTO_PEARL_DOMAIN:String = "";
      public static const DEFAULT_DOCUMENT_PEARL_DOMAIN:String = "";
      public static const DEFAULT_NOTE_PEARL_DOMAIN:String = "";
      public static const MAX_NOTE_LENGTH : int = 25000; 
      
      public static const MANAGER_INITIALIZED_EVENT:String = "managerInitializedEvent";

      private var _isManagerInitialized:Boolean;
      private static var _singleton:ApplicationManager;
      
      private var _applicationId:String;
      private var _isApplicationFocused:Boolean;
      private var _userFactory:UserFactory;
      private var _externalInterface:IJavascriptInterface;
      private var _applicationLoadingInfo:ApplicationLoadingInfo;
      private var _persistencyQueue:IPearlTreeQueue;
      private var _service:ApplicationDistantServices;
      private var _urlNavigationController:UrlNavigationController;
      private var _pearlTreeLoader:PearlTreeLoaderManager;
      private var _notificationCenter:NotificationCenter;
      private var _visualModel:VisualModel;
      private var _feed:Text;
      private var _components:ComponentsAccessPoint;
      private var _exporter:Exporters;
      private var _isClosing:Boolean;
      private var _avatarManager:AvatarManager;
      private var _logoManager:LogoManager;
      private var _backgroundManager:BackgroundManager;
      private var _errorReporter:IErrorReporter;
      private var _accountManager:AccountManager;
      private var _premiumRightManager:PremiumRightManager;
      private var _remoteResourceManagers:RemoteResourceManagers;
      private var _menuActions:IMenuActions;
      private var _keyboardListener:PTKeyboardListener;
      private var _pearlContextMenu:PearlContextMenu;
      private var _languageSelect:LanguageSelect;
      private var _loaderParameters:ILoaderParameters;
      private var _applicationMode:Number=-1;
      private var _overlayStartUrl:String;
      private var _overlayParentUrl:String;
      private var _overlayEmbedType:uint;
      private var _embedWindowParentUrl:String;
      private var _currentOS:String;
      private var _currentOSVersion:String;
      private var _currentBrowserName:String;
      private var _currentBrowserVersion:String;
      private var _embedManager:EmbedManager;
      private var _htmlStartTime:Number;
      private var _appVersion:String;
      private var _previousAppVersion:String;
      private var _webSiteUrl:String;
      private var _staticContentUrl:String;
      private var _logoUrl:String;
      private var _thumbLogoUrl:String;
      private var _metaLogoUrl:String;
      private var _scrapLogoUrl:String;
      private var _avatarUrl:String;
      private var _thumbshotUrl:String;
      private var _servicesUrl:String;
      private var _mediaUrl:String;
      private var _backgroundUrl:String;
      private var _biblioUrl:String;
      private var _promoUrl:String;
      private var _photoPearlDomain:String;
      private var _notePearlDomain:String;
      private var _isFlashSupportingMultitouch:Boolean;
      private var _isFlashSupportingUncaughtErrorEvents:Boolean;
      private var _playerStartUrl:String;
      private var _origin:String;
      private var _clientId:String;
      private var _applicationDomain:ApplicationDomain;
      private var _hideNextRelease:Boolean = false;
      private var _userLoader:UserLoader;
      private var _cdnLocationName:String = null;
      private var _promoHelper:EventPromoHelper = new EventPromoHelper();
      private var _promoLoader:PromoLoader = new PromoLoader();
      private var _isWhiteMark:Boolean = false;
      private var _hasUsedSlideshow:Boolean = false;
      private var _sessionHelper:SessionHelper;

      public function getCustomStartLocation():String {
         var startLocation:String = null;
         return startLocation;
      }
      
      private function getCustomLoaderParameters():ILoaderParameters {
         var customParameters:ILoaderParameters = null;
         
         return customParameters;
      }
      
      public static function getInstance(createInstance:Boolean=false):ApplicationManager {
         if (!_singleton) {
            Assert.assert(createInstance, "ApplicationManager instance should not be created right now");
            _singleton = new ApplicationManager();
            _singleton.init();
         }
         return _singleton;
      }
      
      public static function get flexApplication():Application {
         return Application.application as Application;
         
      }
      
      private function init():void {
         _applicationDomain = ApplicationDomain.currentDomain;
         if(isDebug) {
            _loaderParameters = getCustomLoaderParameters();
         }
         if(!_loaderParameters) {
            _loaderParameters = new LoaderParameters();
         }
         getPreviousAppVersionAndSaveCurrentVersion();
         _isApplicationFocused = !isEmbed();
         if(isEmbed()) {
            _externalInterface = new EmbedJavascriptInterface(_loaderParameters);
         }else{
            _externalInterface = new ExternalJavascriptInterface(_loaderParameters);
         }
         getHtmlStartTime();
         var forceStartLocation:String = (isDebug)?getCustomStartLocation():null;
         _urlNavigationController= new UrlNavigationController(_externalInterface, _loaderParameters, forceStartLocation);
         var dataRepository:BroDataRepository = new BroDataRepository();
         initCapabilities();
         _userFactory = new UserFactory(this);
         _exporter = new Exporters();
         _avatarManager = new AvatarManager();
         _logoManager = new LogoManager();
         _backgroundManager = new BackgroundManager();
         _accountManager = new AccountManager();
         _premiumRightManager = new PremiumRightManager();
         _languageSelect = new LanguageSelect();
         _applicationId = Math.round(10*Math.random())+"-"+new Date().toTimeString();
         _keyboardListener = new PTKeyboardListener();
         _errorReporter = new DefaultErrorReporter();
         _visualModel = new VisualModel(_keyboardListener, getBrowserName(), getOS(), dataRepository);
         _remoteResourceManagers = new RemoteResourceManagers(_visualModel.navigationModel);
         _components = new ComponentsAccessPoint(_visualModel.animationRequestProcessor);          
         _persistencyQueue = new AmfTreePersistencyQueue();
         _service = new ApplicationDistantServices();
         _applicationLoadingInfo = new ApplicationLoadingInfo();
         _pearlTreeLoader = new PearlTreeLoaderManager(dataRepository);
         _notificationCenter = new NotificationCenter();
         if(unfocusOnMouseLeaveApplication()) {
            flexApplication.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveApplication);
         }
         setIsInvalidatedCdn(false);
         
         currentUser.updateFacebookToken();
         _isManagerInitialized = true;
         _sessionHelper = new SessionHelper();
         dispatchEvent(new Event(MANAGER_INITIALIZED_EVENT));
      }   
      
      private function initCapabilities():void {
         try {
            var inputMode:String = Multitouch.inputMode;
            _isFlashSupportingMultitouch = (inputMode != null);
            Multitouch.inputMode = MultitouchInputMode.GESTURE;
         }catch(e:Error) {
            _isFlashSupportingMultitouch = false;
         }
         
         try {
            _isFlashSupportingUncaughtErrorEvents = (flexApplication.loaderInfo.uncaughtErrorEvents != null);
         }catch(e:Error) {
            _isFlashSupportingUncaughtErrorEvents = false;
         }
      }
      
      private function onSettingsLoaded(event:Event):void {
         if (_userLoader) {
            _userLoader.removeEventListener(UserLoader.SETTINGS_LOADED_EVENT, onSettingsLoaded);
            _userLoader.removeEventListener(UserLoader.SETTINGS_NOT_LOADED_EVENT, onSettingsLoaded);
            _userLoader = null;
            
         }
      }
      
      private function unfocusOnMouseLeaveApplication():Boolean {
         return (isEmbed() || getBrowserName() == BROWSER_NAME_CHROME);
      }
      
      public function get isFlashSupportingMultitouch():Boolean {
         return _isFlashSupportingMultitouch;
      }
      public function get isFlashSupportingUncaughtErrorEvents():Boolean {
         return _isFlashSupportingUncaughtErrorEvents;
      }
      
      public function get isDebug():Boolean {
         
         return flexApplication.stage.loaderInfo.parameters['isDebug'];
      }
      
      public function get isManagerInitialized():Boolean {
         return _isManagerInitialized;
      }
      
      public function get languageSelect():LanguageSelect{
         return _languageSelect;
      }
      
      public function set isApplicationFocused(value:Boolean):void {
         if (value != _isApplicationFocused) {
            _isApplicationFocused = value;
            if(_isApplicationFocused) {
               currentUser.updateFacebookToken();
            }
            dispatchEvent(new Event(FOCUS_CHANGE_EVENT));
         }
      }
      public function get isApplicationFocused():Boolean {
         return _isApplicationFocused;
      }
      
      private function onMouseLeaveApplication(event:Event):void {
         if(unfocusOnMouseLeaveApplication()) {
            isApplicationFocused = false;
         }
      }
      
      public function get urlNavigationController():UrlNavigationController {
         return _urlNavigationController;
      }
      
      public function get pearlContextMenu():PearlContextMenu{
         return _pearlContextMenu;
      }
      
      public function set pearlContextMenu(value:PearlContextMenu):void{
         _pearlContextMenu = value;
      }
      
      public function get notificationCenter():NotificationCenter{
         return _notificationCenter;
      }
      
      public function get currentUser():CurrentUser {
         return (_accountManager)?_accountManager.getCurrentUser():null;
      }
      
      public function get userFactory():UserFactory {
         return _userFactory;
      }
      
      public function notifyApplicationClosing():void {
         if(!_isClosing) {
            _isClosing = true;
            dispatchEvent(new  Event(CLOSING_EVENT));
         }
      }
      
      public function addCloseApplicationListener(listener:Function):void {
         addEventListener(CLOSING_EVENT, listener);
      }
      
      public function get applicationDomain():ApplicationDomain {
         return _applicationDomain;
      }
      
      public function get distantServices ():ApplicationDistantServices
      {
         return _service;
      }
      
      public function get persistencyQueue():IPearlTreeQueue {
         return _persistencyQueue;
      }
      
      public function get keyboardListener():PTKeyboardListener {
         return _keyboardListener;
      }
      
      public function get applicationLoadingInfo():ApplicationLoadingInfo {
         return _applicationLoadingInfo;
      }
      
      public function get pearlTreeLoader():IPearlTreeLoaderManager{
         return _pearlTreeLoader;
      }
      
      private function getApplicationMode():uint {
         if(_applicationMode < 0) {
            if(_loaderParameters.isInPearltrees()) {
               if(Url2Overlay.hasOverlayUrl()) {
                  setApplicationMode(OVERLAY_MODE);
               }else if(Url2EmbedWindow.hasEmbedWindowUrl()) {
                  setApplicationMode(EMBED_WINDOW_MODE);
               }else{
                  setApplicationMode(FULL_MODE);
               }
            }
            else {
               setApplicationMode(EMBED_MODE);
               _embedManager = new EmbedManager(this);
            }
         }
         return _applicationMode;
      }
      
      public function setApplicationMode(value:uint):void {
         if(_applicationMode != value) {
            
            if(_applicationMode < 0) {
               _applicationMode = value;
            }else{
               
               _applicationMode = value;
               if(isOverlay()) {
                  if(components.windowController) {
                     components.windowController.closeAllWindows();
                  }
                  if(components.mainPanel && components.mainPanel.borderContainer) {
                     components.mainPanel.borderContainer.visible = false;
                     components.mainPanel.borderContainer.includeInLayout = false;
                  }
               }
               else if(isEmbedWindowMode()) {
                  components.pearlTreePlayer.hidePlayer();
                  EmbedWindowStartPolicy.displayCurrentNodeInfoInWindow();
                  components.mainPanel.borderContainer.visible = true;
                  components.mainPanel.borderContainer.includeInLayout = true;
               }
            }
         }
      }
      
      public function get embedManager():EmbedManager {
         return _embedManager;
      }
      
      private function getPreviousAppVersionAndSaveCurrentVersion():void {
         try {
            var so:SharedObject = SharedObject.getLocal("appVersion","/");
            _previousAppVersion = so.data['version'];
            so.data['version'] = null;
            so.data['version'] = getAppVersion();
            so.flush();
         } catch (e:Error) {
         } 
      }
      
      public function getAppVersion():String {
         if(!_appVersion) {
            _appVersion = loaderParameters.getAppVersion();
         }
         return _appVersion;
      }

      public function isAppLoadedFromClientCache():Boolean {
         return (getAppVersion() == _previousAppVersion);
      }
      
      public function getPreviousAppVersion():String {
         return _previousAppVersion;
      }
      
      public function getPreloaderExplicitParam(param:String):Object {
         var explicitParams:Object = (flexApplication.loaderInfo.loader)?flexApplication.loaderInfo.loader['parameters']:null;
         return (explicitParams)?explicitParams[param]:null;
      }
      
      public function setOverlayStartUrl(value:String):void {
         setApplicationMode(OVERLAY_MODE);
         _overlayStartUrl = value;
      }
      public function getOverlayStartUrl():String {
         return _overlayStartUrl;
      }
      
      public function setOverlayParentUrl(value:String):void {
         _overlayParentUrl = value;
      }
      public function getOverlayParentUrl():String {
         return _overlayParentUrl;
      }
      
      public function setOverlayEmbedType(value:uint):void {
         _overlayEmbedType = value;
      }
      public function getOverlayEmbedType():uint {
         return _overlayEmbedType;
      }
      
      public function notifyEmbedWindowInitialized():void {
         if(!_embedWindowParentUrl) return;
         _externalInterface.changeParentUrl(_embedWindowParentUrl+"#/pts/wi/");
      }
      
      public function closeWindowAndOpenOverlay():void {
         if(!_embedWindowParentUrl) return;
         _externalInterface.changeParentUrl(_embedWindowParentUrl+"#/pts/cwoo/");
      }
      
      public function closeOverlayAndDisplayShare():void {
         if(!_overlayParentUrl) return;
         _externalInterface.changeParentUrl(_overlayParentUrl+"#/pts/coas/");
      }
      
      public function closeOverlayAndSelectNode(user:User, focusedTree:BroPearlTree, selectedTree:BroPearlTree, node:BroPTNode):void {
         if(!_overlayParentUrl) return;
         var userId:Number = user.persistentId;
         var focusedTreeId:Number = focusedTree.id;
         var selectedTreeId:Number = selectedTree.id;
         if (node == null) {
            node = selectedTree.getRootNode();
         }
         var pearlId:Number = node.persistentID;
         
         var url:String = _overlayParentUrl+"#/pts/cosn-"+userId+"-"+focusedTreeId+"-"+selectedTreeId+"-"+pearlId+"/";
         _externalInterface.changeParentUrl(url);
      }
      
      public function setEmbedWindowParentUrl(value:String):void {
         setApplicationMode(EMBED_WINDOW_MODE);
         _embedWindowParentUrl = value;
      }
      public function getEmbedWindowParentUrl():String {
         return _embedWindowParentUrl;
      }
      
      public function selectNodeInEmbed(user:User, focusedTree:BroPearlTree, selectedTree:BroPearlTree, node:BroPTNode):void {
         if(!_overlayParentUrl) return;
         var userId:Number = user.persistentId;
         var focusedTreeId:Number = focusedTree.id;
         var selectedTreeId:Number = selectedTree.id;
         var pearlId:Number = ((!node)?-1:node.persistentID);
         var url:String = _overlayParentUrl+"#/pts/sn-"+userId+"-"+focusedTreeId+"-"+selectedTreeId+"-"+pearlId+"/";
         _externalInterface.changeParentUrl(url)
      }
      
      public function isEmbed():Boolean {
         return (getApplicationMode() == EMBED_MODE);
      }
      
      public function isOverlay():Boolean {
         return (getApplicationMode() == OVERLAY_MODE);
      }
      
      public function isEmbedWindowMode():Boolean {
         return (getApplicationMode() == EMBED_WINDOW_MODE);
      }
      
      public function isDefaultMode():Boolean {
         return (getApplicationMode() == FULL_MODE);
      }
      
      public function getWebSiteUrl():String {
         if(!_webSiteUrl) {
            _webSiteUrl = _externalInterface.getWebSiteUrl();
            if(!_webSiteUrl) {
               _webSiteUrl = _loaderParameters.getWebSiteUrl();
            }
         }
         if(!_webSiteUrl) {
            return DEFAULT_DOMAIN;
         }else{
            return _webSiteUrl;
         }
      }
      
      public function getStaticContentUrl():String {
         if(!_staticContentUrl) {
            _staticContentUrl = _externalInterface.getStaticContentUrl();
            if(!_staticContentUrl) {
               _staticContentUrl = getWebSiteUrl();
               if(_staticContentUrl == DEFAULT_DOMAIN) {
                  _staticContentUrl = DEFAULT_STATIC_CONTENT_DOMAIN;
               }
            }
         }
         return _staticContentUrl;
      }
      
      public function getThumbLogoUrl():String {
         if (!_thumbLogoUrl) {
            _thumbLogoUrl = _externalInterface.getThumbLogoUrl();
         }
         if(!_thumbLogoUrl) {
            if(getWebSiteUrl() == DEFAULT_DOMAIN) {
               _thumbLogoUrl = DEFAULT_THUMBLOGO_URL;
            }else{
               _thumbLogoUrl = getServicesUrl()+"thumblogo/image/";
            }
         }
         return _thumbLogoUrl;
         
      }
      
      public function getLogoUrlForType(logoType:int):String {
         if (logoType == LogoManager.THUMBSHOT_TYPE) {
            return getThumbLogoUrl();
         } else if (logoType == LogoManager.SCRAP_TYPE) {
            return getScrapLogoUrl();
         } else if (logoType == LogoManager.META_TYPE) {
            return getMetaLogoUrl();
         } else {
            return getLogoUrl();
         }
      }
      
      public function getMetaLogoUrl():String {
         if (!_metaLogoUrl) {
            _metaLogoUrl = _externalInterface.getMetaLogoUrl();
         }
         if(!_metaLogoUrl) {
            if(getWebSiteUrl() == DEFAULT_DOMAIN) {
               _metaLogoUrl = DEFAULT_METALOGO_URL;
            }else{
               _metaLogoUrl = getServicesUrl()+"metalogo/image/";
            }
         }
         return _metaLogoUrl;
      }
      
      public function getScrapLogoUrl():String {
         if (!_scrapLogoUrl) {
            _scrapLogoUrl = _externalInterface.getScrapLogoUrl();
         }
         if (!_scrapLogoUrl) {
            if(getWebSiteUrl() == DEFAULT_DOMAIN) {
               _scrapLogoUrl = DEFAULT_SCRAPLOGO_URL;
            }else{
               _scrapLogoUrl = getServicesUrl()+"scraplogo/image/";
            }
         }
         return _scrapLogoUrl;
      }
      
      public function getLogoUrl():String {
         if(!_logoUrl) {
            _logoUrl = _externalInterface.getLogoUrl();
            if(!_logoUrl) {
               if(getWebSiteUrl() == DEFAULT_DOMAIN) {
                  _logoUrl = DEFAULT_LOGO_URL;
               }else{
                  _logoUrl = getServicesUrl()+"logo/image/";
               }
            }
         }
         return _logoUrl;
      }
      
      public function getAvatarUrl():String {
         if(!_avatarUrl) {
            _avatarUrl = _externalInterface.getAvatarUrl();
            if(!_avatarUrl) {
               if(getWebSiteUrl() == DEFAULT_DOMAIN) {
                  _avatarUrl = DEFAULT_AVATAR_URL;
               }else{
                  _avatarUrl = getServicesUrl()+"avatar/image/";
               }
            }
         }
         return _avatarUrl;
      }
      
      public function getBackgroundUrl():String {
         if(!_backgroundUrl) {
            _backgroundUrl = _externalInterface.getBackgroundUrl();
            if(!_backgroundUrl) {
               if(getWebSiteUrl() == DEFAULT_DOMAIN) {
                  _backgroundUrl = DEFAULT_BACKGROUND_URL;
               }else{
                  _backgroundUrl = getServicesUrl()+"background/image/";
               }
            }
         }
         return _backgroundUrl;
      }
      
      public function getThumbshotUrl():String {
         if(!_thumbshotUrl) {
            _thumbshotUrl = _externalInterface.getThumbshotUrl();
            if(!_thumbshotUrl) {
               if(getWebSiteUrl() == DEFAULT_DOMAIN) {
                  _thumbshotUrl = DEFAULT_THUMBSHOT_URL;
               }else{
                  _thumbshotUrl = getServicesUrl()+"preview/image/";
               }
            }
         }
         return _thumbshotUrl;
      }
      
      public function getBiblioUrl():String {
         if(!_biblioUrl) {
            _biblioUrl = _externalInterface.getBiblioUrl();
            if(!_biblioUrl) {
               if(getWebSiteUrl() == DEFAULT_DOMAIN) {
                  _biblioUrl = DEFAULT_BIBLIO_URL;
               } else {
                  _biblioUrl = getServicesUrl()+"biblio/image/";
               }
            }
         }
         return _biblioUrl;
      }
      
      public function getPromoUrl():String {
         if(!_promoUrl) {
            _promoUrl = _externalInterface.getPromoUrl();
            if(!_promoUrl) {
               _promoUrl = getServicesUrl() + "premium/promo/";
            }
         }
         return _promoUrl;
      }
      
      public function getServicesUrl():String {
         if(!_servicesUrl) {
            _servicesUrl = _externalInterface.getServicesUrl();
            if(!_servicesUrl) {
               _servicesUrl = getWebSiteUrl()+SERVICE_PATH;
            }
         }
         return _servicesUrl;
      }
      
      public function getMediaUrl():String {
         if(!_mediaUrl) {
            _mediaUrl = _externalInterface.getMediaUrl();
            if(!_mediaUrl) {
               _mediaUrl = DEFAULT_MEDIA_URL;
            }
         }
         return _mediaUrl;
      }
      
      public function getCachableServicesUrl():String {
         return getStaticContentUrl()+SERVICE_PATH;
      }
      
      public function getShortenerDomain():String {
         var shortenerDomain:String = _externalInterface.getShortenerDomain();
         if(!shortenerDomain) {
            shortenerDomain = DEFAULT_SHORTENER;
         }
         return shortenerDomain;
      }
      
      public function getPhotoPearlDomain():String {
         if (!_photoPearlDomain) {
            if (getWebSiteUrl() == DEFAULT_DOMAIN ) {
               _photoPearlDomain = DEFAULT_PHOTO_PEARL_DOMAIN;
            }
            else {
               _photoPearlDomain = getWebSiteUrl() + SERVICE_PATH + PHOTO_PEARL_PATH;
            }
         }
         return _photoPearlDomain;
      }
      
      public function getNotePearlDomain():String {
         if (!_notePearlDomain) {
            if (getWebSiteUrl() == DEFAULT_DOMAIN ) {
               _notePearlDomain = DEFAULT_NOTE_PEARL_DOMAIN;
            }
            else {
               _notePearlDomain = getWebSiteUrl() + SERVICE_PATH + NOTE_PEARL_PATH;
            }
         }
         return _notePearlDomain;
      }
      
      public function getPlayerStartUrl():String {
         if(!_playerStartUrl) {
            _playerStartUrl = _externalInterface.getPlayerStartUrl();
         }
         return _playerStartUrl;
      }
      
      public function getClientId():String {
         if(!_clientId) _clientId = _externalInterface.getClientId();
         if(!_clientId) _clientId = "unknown";
         return _clientId;
      }
      
      public function getClientLang():int {
         var clientLang:String = _externalInterface.getClientLang();
         if(!clientLang) {
            clientLang = _loaderParameters.getClientLang();
         }
         if (clientLang == 'en_US')
            return BroLocale.ENGLISH;
         else if (clientLang == 'fr_FR')
            return BroLocale.FRENCH;
         else
            return BroLocale.LANG_NOT_DEFINED;
      }
      
      public function getOrigin():String {
         if(!_origin) {
            _origin = _externalInterface.getOrigin();
         }
         return _origin;
      }
      public function getBrowserName():String {
         if(!_currentBrowserName) {
            _currentBrowserName = _externalInterface.getBrowserName();
            if(TRACE_DEBUG) trace("[ApplicationManager] Browser name: "+_currentBrowserName);
         }
         return _currentBrowserName;
      }
      public function getBrowserVersion():String {
         if(!_currentBrowserVersion) {
            _currentBrowserVersion = _externalInterface.getBrowserVersion();
         }
         return _currentBrowserVersion;
      }
      public function getOS():String {
         if(!_currentOS) {
            var osFullName:String = flash.system.Capabilities.os;
            if(osFullName.indexOf("Windows") != -1) {
               _currentOS = OS_NAME_WINDOWS;
            }else if(osFullName.indexOf("Mac OS") != -1) {
               _currentOS = OS_NAME_MAC;
            }else if(osFullName.indexOf("Linux") != -1) {
               _currentOS = OS_NAME_LINUX;
            }else{
               trace("[ApplicationManager] Unknown OS: "+osFullName+". Application might have a compatibility issue here.");
            }
            if(TRACE_DEBUG) trace("[ApplicationManager] OS: "+_currentOS);
         }
         return _currentOS;
      }
      public function getOSVersion():String {
         if(!_currentOSVersion) {
            var osFullName:String = flash.system.Capabilities.os;
            var splitedName:Array;
            if(osFullName.indexOf("Windows") != -1) {
               splitedName = osFullName.split("Windows");
               if(splitedName.length > 0) {
                  _currentOSVersion = StringUtil.trim(splitedName[1] as String);
               }
            }else if(osFullName.indexOf("Mac OS") != -1) {
               splitedName = osFullName.split("Mac OS");
               if(splitedName.length > 0) {
                  _currentOSVersion = StringUtil.trim(splitedName[1] as String);
               }
            }else if(osFullName.indexOf("Linux") != -1) {
               splitedName = osFullName.split("Linux");
               if(splitedName.length > 0) {
                  _currentOSVersion = StringUtil.trim(splitedName[1] as String);
               }
            }else{
               trace("[ApplicationManager] Unknown OS: "+osFullName+". Application might have a compatibility issue here.");
            }
            if(TRACE_DEBUG) trace("[ApplicationManager] OS Version: "+_currentOSVersion);         
         }
         return _currentOSVersion;
      }
      
      public function getUserName():String {
         return _externalInterface.getUserName();
      }
      public function getHtmlStartTime():Number {
         if(isNaN(_htmlStartTime)) {
            _htmlStartTime = _externalInterface.getStartTime();
            if(isNaN(_htmlStartTime)) {
               _htmlStartTime = getTimer();
            }
         }
         return _htmlStartTime;
      }
      public function getSessionID():String {

         return _externalInterface.getSessionID();
      }
      public function hideWaitingPanel():void {
         return _externalInterface.hideWaitingPanel();
      }
      public function get visualModel():VisualModel {
         return _visualModel;
      }
      
      public function get feed():Text {
         return _feed;
      }
      
      public function set feed(o:Text):void {
         _feed = o;
      }
      
      public function get exporter():Exporters {
         return _exporter;
      }

      public function get components():ComponentsAccessPoint {
         return _components;
      }
      
      public function setWindowStatus(title:String):void{
         _externalInterface.setWindowStatus(title);
      }
      
      public function get errorReporter ():IErrorReporter
      {
         return _errorReporter;
      }
      
      public function get avatarManager():AvatarManager {
         return _avatarManager;
      }
      
      public function get logoManager():LogoManager {
         return _logoManager;
      }
      
      public function get backgroundManager():BackgroundManager {
         return _backgroundManager;
      }
      
      public function get accountManager():AccountManager {
         return _accountManager;
      }
      
      public function get remoteResourceManagers():RemoteResourceManagers {
         return _remoteResourceManagers;
      }
      
      public function get sessionHelper():SessionHelper {
         return _sessionHelper;
      }
      
      public function get styleManager():PTStyleManager {
         return PTStyleManager.getInstance();
      }
      
      public function get menuActions():IMenuActions {
         if(!_menuActions) {
            _menuActions = new MenuActions();
         }
         return _menuActions;
      }
      
      public function set menuActions(value:IMenuActions):void { 
         _menuActions = value;
      }
      
      public function getExternalInterface():IJavascriptInterface {
         return _externalInterface;
      }
      
      public function get loaderParameters():ILoaderParameters {
         return _loaderParameters;
      }
      
      public function get applicationUID():String {
         return _applicationId;
      }
      
      public function useDiscover():Boolean {
         return (USE_DISCOVER && !isEmbed());
      }
      public function get isPremium():Number {
         return _premiumRightManager.isPremium;
      }
      
      public function set premiumStatus(value:Number):void {
         _premiumRightManager.premiumStatus = value;
      }
      
      public function get hideNextRelease():Boolean {
         return _hideNextRelease;
      }
      public function set hideNextRelease(value:Boolean):void {
         _hideNextRelease = value;
      }
      
      public function isWebsiteUrlDefaultDomain():Boolean {
         return getWebSiteUrl() == DEFAULT_DOMAIN;
      }
      
      public function getCdnLocationName():String {
         if (_cdnLocationName == null) {
            _cdnLocationName = getExternalInterface().getLocationName();
         }
         return _cdnLocationName;
      }
      
      public function setIsInvalidatedCdn(value:Boolean):void {
         var _isInvalidatedCdn:SharedObject = SharedObject.getLocal("isInvalidatedCdn");
         _isInvalidatedCdn.data["value"] = value as Boolean;
         try {
            _isInvalidatedCdn.flush();
         } catch (e:Error) {
            Log.getLogger("com.broceliand.ApplicationManager").error("error saving IsInvalidatedCdn state {0}",e);
         }
      }
      
      public function getInvalidatedCdnSuffix():String {
         var _isInvalidatedCdn:SharedObject;
         var _invalidatedCdnSuffix:String = "";
         var _isInvalidatedCdnState:Boolean = false;
         try {
            _isInvalidatedCdn = SharedObject.getLocal("isInvalidatedCdn");
            _isInvalidatedCdnState = (_isInvalidatedCdn.data["value"] === undefined)?false:_isInvalidatedCdn.data["value"] as Boolean;
         } catch (e:Error) {
         }
         if (_isInvalidatedCdnState) {
            var time:Date = new Date();
            _invalidatedCdnSuffix = "?v=" + time.time;
         }
         return _invalidatedCdnSuffix;
      }
      
      public function set enableTooltip(value:Boolean):void {
         ToolTipManager.enabled = value;
      }
      
      public function get premiumRightManager():PremiumRightManager {
         return _premiumRightManager;
      }
      
      public function get promoHelper():EventPromoHelper {
         return _promoHelper;
      }
      
      public function set promoHelper(value:EventPromoHelper):void {
         _promoHelper = value;
      }
      
      public function get promoLoader():PromoLoader {
         return _promoLoader;
      }
      
      public function set promoLoader(value:PromoLoader):void {
         _promoLoader = value;
      }
      
      public function setWhiteMark(value:Boolean):void {
         if (value != _isWhiteMark) {
            _isWhiteMark = value;
            visualModel.applicationMessageBroadcaster.broadcastMessage(new Event(ApplicationMessageBroadcaster.WHITE_MARK_CHANGED_EVENT));
         }
      }
      
      public function isWhiteMark():Boolean  {
         return _isWhiteMark;
      }

      public function get hasUsedSlideshow():Boolean{
         return _hasUsedSlideshow;
      }
      
      public function set hasUsedSlideshow(value:Boolean):void{
         _hasUsedSlideshow = value;
      }
      
      public function getRightAbModel():Number {
         if (BroLocale.languageIsFrench()) {
            return ApplicationManager.getInstance().getExternalInterface().getAbModel() + 5;
         }
         return ApplicationManager.getInstance().getExternalInterface().getAbModel();
      }
   }
}
