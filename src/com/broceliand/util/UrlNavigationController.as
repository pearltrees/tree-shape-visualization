package com.broceliand.util {
   import com.broceliand.ApplicationManager;
   import com.broceliand.IJavascriptInterface;
   import com.broceliand.ILoaderParameters;
   import com.broceliand.graphLayout.controller.PearlTreeLoaderCallback;
   import com.broceliand.pearlTree.io.services.AmfService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetNumberCallback;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.IFlexUrlBuilder;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.FlexUrlBuilderImpl;
   import com.broceliand.pearlTree.navigation.impl.PreLoadingRequest;
   import com.broceliand.pearlTree.navigation.impl.Url2DisplayedPage;
   import com.broceliand.pearlTree.navigation.impl.Url2Error;
   import com.broceliand.pearlTree.navigation.impl.Url2NavigationSynchronizer;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.util.flexWorkaround.BrowserManager;
   
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   import mx.events.BrowserChangeEvent;
   import mx.managers.IBrowserManager;
   import mx.managers.IHistoryManagerClient;
   import mx.rpc.events.FaultEvent;
   
   public class UrlNavigationController implements IAmfRetNumberCallback {
      private static const TITILE_PREFIX:String = "pearltrees ";

      private static const DEFAULT_TITLE:String = "Pearltrees";

      private static const ID_NAME_SEPARATOR:String = "-";

      private static const NAME_VALUE_SEPARATOR:String = "=";

      private static const PROPERTY_SEPARATOR:String = "&";
      
      private var _flexUrlBuilder:IFlexUrlBuilder;
      private var _browserManager:IBrowserManager;
      private var _name2HistoryClients:Dictionary = new Dictionary();
      private var _pendingQueryString:String=null ;
      private var _title:String;
      
      public function UrlNavigationController(externalInterface:IJavascriptInterface, loaderParameters:ILoaderParameters, forceStartLocation:String=null) {
         _flexUrlBuilder = new FlexUrlBuilderImpl();
         _browserManager = BrowserManager.getInstance();
         
         var startLocation:String = forceStartLocation;
         if (!startLocation) {
            startLocation = externalInterface.getStartLocationFromURL();
         }
         if (!startLocation) {
            startLocation = loaderParameters.getStartLocation();
         }
         if (!startLocation) {
            startLocation = "";
         }
         
         _browserManager.init(startLocation, DEFAULT_TITLE);
         _browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, onBrowserUrlChange);
         if (startLocation.length>1) {
            _browserManager.setFragment(startLocation);
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.addEventListener(ApplicationManager.FOCUS_CHANGE_EVENT, onApplicationFocusChange);
      }
      
      public function get currentUrl():String{
         return _browserManager.url;
      }
      
      private function onApplicationFocusChange(event:Event):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (am.isApplicationFocused && AmfService.REALTIME_REQUEST) {
            am.distantServices.amfUserService.getArrivalTreeId(this);
         }
      }
      
      public function onReturnValue(value:Number):void {
         if (value && value > 0) {
            var treeId:Number = value;
            var assoId:Number = -1;
            var lastCreatedPearlId:Number = -1;
            var am:ApplicationManager = ApplicationManager.getInstance();
            var tree:BroPearlTree = am.visualModel.dataRepository.getTree(treeId);
            if (tree) {
               assoId = tree.getAssociationId();
               if (tree.pearlsLoaded) {
                  lastCreatedPearlId = tree.getLastCreatedPearlPageId();
               } else {
                  new PreLoadingRequest(treeId, assoId).load();
                  return;
               }
            }
            am.visualModel.navigationModel.goTo(assoId, am.currentUser.persistentId, treeId, treeId, lastCreatedPearlId, -1, -1, 0, false, NavigationEvent.ADD_ON_NAVIGATION_TYPE);
         }
      }
      
      public function onError(message:FaultEvent):void {
         
      }

      static public function initNavigationUrl(navigate:Boolean = true, resetIfHome:Boolean = false):Boolean  {
         var urlNav:UrlNavigationController = ApplicationManager.getInstance().urlNavigationController;
         var fragment:String = urlNav._browserManager.fragment;
         if (fragment.length>1 ) {
            if (resetIfHome && fragment.lastIndexOf("N-w=h")>=0) {
               return false;
            }
            if (navigate) {
               urlNav.parseURLFragment(fragment);
            } else {
               
               if (fragment.lastIndexOf(Url2Error.ERROR_CLIENT_NAME+"-"+Url2Error.TYPE_FIELD)>=0 ||
                  fragment.lastIndexOf(Url2DisplayedPage.DISPLAY_CLIENT_NAME+"-"+Url2DisplayedPage.NAME_FIELD)>=0)  {
                  urlNav.parseURLFragment(fragment);
               }
            }
            if (fragment.lastIndexOf("N-f")>=0 || fragment.lastIndexOf("N-u")>=0) { 
               return true;
            } else if (fragment.lastIndexOf("N-q")>=0) {
               return true;
            } else if (fragment.lastIndexOf("N-play-url")>=0 && fragment.lastIndexOf("N-play=1")>=0) {
               return true;
            }

            return false;
         }
         return false;
      }

      public static function getFromUrl(prefix:String):String{
         var urlNav:UrlNavigationController = ApplicationManager.getInstance().urlNavigationController;
         var fragment:String = urlNav._browserManager.fragment;
         var indexOfPrefix:int = fragment.lastIndexOf(prefix);
         var result:String ="";
         if (indexOfPrefix < 0) {
            return result;
         }
         result = fragment.substr(indexOfPrefix + prefix.length);
         if (result.indexOf("&") >=0) {
            result = result.substr(0, result.indexOf("&"));
         }
         return result;
      }
      
      public static function getIdFromUrl(prefix:String):Number {
         var result:String = getFromUrl(prefix);
         if (result.length > 0) {
            try {
               return Number(result);
            } catch (e:Error) {
            }
         }
         return -1;
      }
      
      public static function getBackgroundHashFromUrl():String {
         var result:String =getFromUrl("N-bg=");
         if (result.length != 32) {
            result =  ApplicationManager.getInstance().getExternalInterface().getBackgroundHash();
         }
         if (result && result.length == 32) { 
            return result;
         }
         return null;
      }

      static public function getPotentialTreeIdFromUser(userId:String):int  {
         var urlNav:UrlNavigationController = ApplicationManager.getInstance().urlNavigationController;
         var fragment:String = urlNav._browserManager.fragment;
         var retValue:int= -1;
         var param:Object = urlFragment2params(fragment);
         if (param[Url2NavigationSynchronizer.HISTORY_CLIENT_NAME] != null && param[Url2NavigationSynchronizer.HISTORY_CLIENT_NAME][Url2NavigationSynchronizer.USER_FIELD]=="1_"+userId) {
            var treeID:String = param[Url2NavigationSynchronizer.HISTORY_CLIENT_NAME][Url2NavigationSynchronizer.FOCUS_FIELD];
            if (treeID) {
               var key:Array = BroPearlTree.parseTreerKey(treeID);
               if (key) {
                  return key[1];
               }
            }
         }
         return retValue;
      }
      
      public static function setBrowserTitle(title:String=null):void {
         ApplicationManager.getInstance().urlNavigationController.title= title;
      }
      
      public function set title(value:String):void {
         if(value) {
            _title = TITILE_PREFIX + value;
            _browserManager.setTitle(_title);
         }else{
            _browserManager.setTitle(DEFAULT_TITLE);
         }
      }
      
      public function get title():String {
         return _title;
      }
      
      public function get flexUrlBuilder():IFlexUrlBuilder{
         return _flexUrlBuilder;
      }
      
      public static function save():void {
         ApplicationManager.getInstance().urlNavigationController.save();
      }
      
      static public function registerHistory(uid:String, obj:IHistoryManagerClient):void {
         ApplicationManager.getInstance().urlNavigationController.registerHistory(uid, obj);
      }
      private function registerHistory(uid:String, obj:IHistoryManagerClient):void {
         if (_name2HistoryClients[uid] != null) {
            throw new Error("History uid "+uid+" is already used");
         }
         _name2HistoryClients[uid] =obj;
      }
      private function save():void {
         var encodedObject:String="";
         
         for (var title:String in  _name2HistoryClients) {
            var obj:Object = (_name2HistoryClients[title] as IHistoryManagerClient).saveState();
            if (obj) {
               encodedObject = append(encodedObject, encodeObject2String(title, obj));
            }
         }

         if (encodedObject.length>0)
         {
            _pendingQueryString = encodedObject;
            ApplicationManager.flexApplication.callLater(this.submitQuery);
         } else {
            if (_browserManager.fragment.length>0) {
               _pendingQueryString = encodedObject;
               submitQuery();
            }
         }
      }
      private function append(msg:String, newObject:String):String {
         if (msg.length>0) {
            return msg+PROPERTY_SEPARATOR+newObject;
         } else return newObject;
      }
      private function encodeObject2String(objectName:String, stateInfo:Object): String {
         
         var queryString:String = "";
         for (var name:String in stateInfo) {
            var value:Object = stateInfo[name];
            if (queryString.length > 0)
               queryString += PROPERTY_SEPARATOR;
            queryString += objectName;
            queryString += ID_NAME_SEPARATOR;
            queryString += encodeURIComponent(name);
            queryString += NAME_VALUE_SEPARATOR;
            queryString += encodeURIComponent(value.toString());
         }
         return queryString;
      }
      
      private function submitQuery():void
      {
         if (_pendingQueryString != null)
         {
            _browserManager.setFragment(_pendingQueryString);
            if(title) {
               _browserManager.setTitle(title);
            }else{
               _browserManager.setTitle(DEFAULT_TITLE);
            }
            _pendingQueryString = null;
            
            ApplicationManager.flexApplication.resetHistory = true;
         }
      }
      
      private function onBrowserUrlChange(event:Event):void {
         parseURLFragment(_browserManager.fragment);
      }
      
      private static function urlFragment2params(urlFragment:String):Object {
         var params:Object = {};
         var p:String;
         var objectName:String;
         var pieces:Array = urlFragment.split(PROPERTY_SEPARATOR);
         var stateVars:Object = {};
         var n:int = pieces.length;
         for (var i:int = 0; i < n; i++)
         {
            var nameValuePair:Array = pieces[i].split(NAME_VALUE_SEPARATOR);
            stateVars[nameValuePair[0]] = parseString(nameValuePair[1]);
         }

         for (p in stateVars)
         {
            var crclen:int = p.indexOf(ID_NAME_SEPARATOR)
            if (crclen > -1)
            {
               objectName = p.substr(0, crclen);
               var name:String = p.substr(crclen + 1, p.length);
               var value:Object = stateVars[p];
               
               if (!params[objectName])
                  params[objectName] = {};
               
               params[objectName][name] = value;
            }
         }
         return params;
      }
      private function parseURLFragment(urlFragment:String):void {
         var params:Object = urlFragment2params(urlFragment);
         
         for  (var objName:String in _name2HistoryClients)
         {
            var registeredObject:IHistoryManagerClient = _name2HistoryClients[objName];
            if (registeredObject) {
               registeredObject.loadState(params[objName]);
            }
            
            delete params[objName];
         }
         if (title) {
            _browserManager.setTitle(title);
         }else{
            _browserManager.setTitle(DEFAULT_TITLE);
         }
      }
      
      private static function parseString(s:String):Object {
         if (s == "true") {
            return true;
         }
         if (s == "false") {
            return false;
         }
         
         var i:int = parseInt(s);
         if (i.toString() == s) {
            return i;
         }
         
         var n:Number = parseFloat(s);
         if (n.toString() == s) {
            return n;
         }
         
         try {
            return decodeURIComponent(s);
         }
         catch(e:Error){
            trace("error decoding string: "+s);
         }
         
         return s;
      }
   }
}
