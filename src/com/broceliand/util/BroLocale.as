package com.broceliand.util {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.SharedObject;
   import flash.utils.Timer;
   
   import mx.resources.ResourceManager;
   
   public class BroLocale extends EventDispatcher {
      public static const ENGLISH:int = 1;
      public static const FRENCH:int = 2;
      public static const LANG_NOT_DEFINED:int = 0;
      public static const DEFAULT_LANG:int = ENGLISH;
      public static const DEFAULT_BUNDLE:String = "message";
      public static const BUNDLE_FAQ:String = "faq";
      public static const BUNDLE_PREMIUM:String = "premium";
      public static const LANG_CHANGED_EVENT:String = "langueChanged";
      
      public static const FAQ_URL_EN:String = "faq/en";
      public static const FAQ_URL_FR:String = "faq/fr";
      public static const DEFAULT_FAQ_URL:String = "faq/";
      
      public static const PREMIUM_URL_EN:String = "premium/presentation?l=EN_US";
      public static const PREMIUM_URL_FR:String = "premium/presentation?l=FR_FR";
      public static const DEFAULT_PREMIUM_URL:String = "premium/presentation/";
      
      private var firstTime:Boolean = true; 
      private var langChanged:Boolean = false;
      private var mySO:SharedObject = null;
      private var oldSO:SharedObject = null;
      private var _needReload:Boolean;
      
      [Bindable]
      protected static var myLocale:BroLocale;
      
      private var _lang:int;
      
      public function BroLocale(language:int = LANG_NOT_DEFINED) {
         try {
            mySO = SharedObject.getLocal("myLangue", ApplicationManager.getInstance().getWebSiteUrl(), false);
         }
         catch (e:Error) {
         }
         try {
            oldSO = SharedObject.getLocal("myLangue");
         }
         catch (e:Error) {
         }      
         
         selectAndSaveLang(language, false);
         _needReload = false;
      }
      
      public function getLangAsString():String {
         if(lang == ENGLISH) {
            return "en_US";
         }
         else if(lang == FRENCH) {
            return "fr_FR";
         }
         else {
            return null;
         }
      }
      
      private function selectLang(language:int, reloadNow:Boolean) : void {
         if (!firstTime && language != lang) {
            langChanged = true;
         }
         
         firstTime = false;
         
         _lang = language;
         if(_lang == ENGLISH || _lang == FRENCH) {
            ResourceManager.getInstance().localeChain = [ getLangAsString() ];
         }
         else {
            selectLang(DEFAULT_LANG,reloadNow);
         }
         
         if(langChanged) {
            langChanged = false;
            saveLang(_lang);
            reloadPage(reloadNow);
         }
      }
      
      public static function languageIsFrench():Boolean{
         return (myLocale.lang == FRENCH);
      }
      
      private function reloadPage(reloadNow:Boolean):void{
         if (reloadNow) {
            delayReload();
         }
         else {
            _needReload = true;
         }
      }
      
      private function delayReload():void {
         ApplicationManager.getInstance().getExternalInterface().reloadPageWithDelay();
      }
      
      public function needReload():Boolean{
         return _needReload;
      }
      
      public function reloadIfNeed():Boolean{
         if (_needReload) {
            reloadPage(true);
            return true;
         }
         return false;
      }
      
      private function selectAndSaveLang(language:int, reloadNow:Boolean = true) : void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var lang:int = DEFAULT_LANG;
         
         if(am.isEmbed() || am.isEmbedWindowMode() || am.isOverlay()) {
            lang = am.getClientLang();
            reloadNow = false;
         }
         else if(!langIsDefined(language)) {
            var lastLang:int = takeLastLang();
            var userLang:int = am.getExternalInterface().getUserLang();
            if (langIsDefined(userLang)){
               lang = userLang
            }
            else {
               if(langIsDefined(lastLang)){
                  lang = lastLang;
               }
               else {
                  var clientLang:int = am.getClientLang();
                  if(langIsDefined(clientLang)) {
                     lang = clientLang;
                  }
                  else {
                     lang = DEFAULT_LANG;
                  }
               }
            }
            saveLang(lang);
         }
         else {
            lang = language;
         }
         
         selectLang(lang, reloadNow);
      }
      
      private function langIsDefined(lang:int):Boolean{
         return (lang == ENGLISH || lang == FRENCH);
      }
      
      public function takeLastLang() : int{
         if(mySO && mySO.data.lang){
            return mySO.data.lang;
         }      
         
         if (oldSO && oldSO.data.lang){
            return oldSO.data.lang;
         }      
         return LANG_NOT_DEFINED;
      }
      
      private function saveLang(language:int) : void {
         if (mySO && language != mySO.data.lang){
            mySO.data.lang = language;
            try {
               mySO.flush();
            } catch (e:Error) {
            }
         } else if (!mySO && oldSO && language != oldSO.data.lang) {
            oldSO.data.lang = language;
            try {
               oldSO.flush(); 
            } catch (e:Error) {
               e.getStackTrace();
            }
         }      
         
         var currentUser:User = ApplicationManager.getInstance().currentUser;
         if(currentUser.isAnonymous()) {
            currentUser.locale = language;
         }
      }
      
      public static function getInstance(language:int = LANG_NOT_DEFINED):BroLocale {
         if( BroLocale.myLocale == null ){
            BroLocale.myLocale = new BroLocale(language);
         }
         return BroLocale.myLocale;
      }
      
      [Bindable(event="langueChanged")]
      public static function getText(key:String, params:Array=null, bundle:String=null):String {
         return BroLocale.getInstance().getText(key, params, bundle);
      }
      
      [Bindable(event="langueChanged")]
      public function getText(key:String, params:Array=null, bundle:String=null):String {
         if(!bundle) {
            bundle = DEFAULT_BUNDLE;
         }
         
         var text:String = ResourceManager.getInstance().getString(bundle, key);

         if (text == null) {
            return key;
         }
         
         return BroLocale.formatMessage(text, params);
      }
      
      public static function formatMessage(text:String, params:Array):String {
         
         if (params) {
            for (var i:int=0; i< params.length; i++) {
               text = text.replace("{"+i+"}", params[i]);
            }
         }
         return text;
      }

      public function getTextForBusinessNode(key:String, node:BroPTNode, params:Array=null, bundle:String=null):String {
         if(node is BroPageNode) {
            key += ".pearl";
         }else{
            key += ".tree";
         }
         return getText(key, params, bundle);
      }
      
      public function getTextForBusinessNodeCheckRoot(key:String, node:BroPTNode, params:Array=null, bundle:String=null):String {
         if(node is BroPageNode) {
            key += ".pearl";
         }
         else {
            var tree:BroPearlTree;
            if (node is BroPTRootNode) {
               tree = node.owner;
            }
            else if (node is BroTreeRefNode) {
               tree = (node as BroTreeRefNode).refTree;
            }
            if (tree.isAssociationRoot()) {
               if (tree.getMyAssociation().isUserRootAssociation()) {
                  key += ".userroot";
               }
               else {
                  key += ".assoroot";
               }
            }
            else {
               key += ".tree";
            }
         }
         return getText(key, params, bundle);
      }
      
      public function getTextForCount(key:String, count:int, params:Array=null, bundle:String=null):String {
         if(count > 1) {
            key += ".plural";
         }else{
            key += ".singular";
         }
         return getText(key, params, bundle);
      }
      
      override public function toString(): String {
         if (lang == ENGLISH )
            return "english";
         else if (lang == FRENCH)
            return "french";
         else
            return "langue not defined";
      }
      
      public function get lang():int {
         return this._lang;
      }
      
      [Bindable(event="langueChanged")]
      public function setLangNotReload(lang:int):void{
         this.selectAndSaveLang(lang, false);
         var e:Event = new Event("langueChanged");
         this.dispatchEvent(e);
      }
      
      [Bindable(event="langueChanged")]
      public function set lang (language:int):void {
         if( this._lang != language ){
            this.selectAndSaveLang(language);
            var e:Event = new Event("langueChanged");
            this.dispatchEvent(e);
         }
      }
   }
}