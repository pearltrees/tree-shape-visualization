package com.broceliand.util.flexWorkaround
{
   import com.broceliand.ApplicationManager;
   
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   import mx.controls.Alert;
   import mx.core.Application;
   import mx.events.BrowserChangeEvent;
   import mx.managers.IBrowserManager;

   [Event(name="urlChange", type="flash.events.Event")]

   [Event(name="browserURLChange", type="mx.events.BrowserChangeEvent")]

   [Event(name="applicationURLChange", type="mx.events.BrowserChangeEvent")]

   public class BrowserManagerImpl extends EventDispatcher implements IBrowserManager
   {
      private static var instance:IBrowserManager;
      
      private var _defaultFragment:String = "";
      
      public static function getInstance():IBrowserManager
      {
         if (!instance)
            instance = new BrowserManagerImpl();
         
         return instance;
      }
      
      public function BrowserManagerImpl()
      {
         super();
         
         try
         {
            var am:ApplicationManager = ApplicationManager.getInstance();
            if(am.getExternalInterface().isInterfaceReady() && !am.isEmbed()) {
               ExternalInterface.addCallback("browserURLChange", browserURLChangeBrowser);
            } else {
               browserMode = false;
            }
         }
         catch(e:Error)
         {
            Alert.show("browser mode set to false : "+e);
            
            browserMode = false;
         }
      }
      private var browserMode:Boolean = true;
      private var _base:String;
      
      [Bindable("urlChange")]
      
      public function get base():String
      {
         return _base;
      }
      private var _fragment:String;
      
      [Bindable("urlChange")]
      
      public function get fragment():String
      {
         if (_fragment && _fragment.length)
            return _fragment;
         
         return _defaultFragment;
      }
      private var _title:String;
      
      [Bindable("urlChange")]
      
      public function get title():String
      {
         return _title;
      }
      private var _url:String;
      
      [Bindable("urlChange")]
      
      public function get url():String
      {
         return _url;
      }
      
      public function init(defaultFragment:String = "", defaultTitle:String = ""):void
      {
         if(ApplicationManager.flexApplication) {
            ApplicationManager.flexApplication.historyManagementEnabled = false;
         }
         
         setup(defaultFragment, defaultTitle);
      }

      public function initForHistoryManager():void
      {
         setup("", "");
      }
      
      private function setup(defaultFragment:String, defaultTitle:String):void
      {
         if (!browserMode)
            return;
         
         _defaultFragment = defaultFragment;
         
         _url = ExternalInterface.call("BrowserHistory.getURL");
         
         if (!_url) {
            return;
         }

         var pos:int = _url.indexOf('#');
         if (pos == -1 || pos == _url.length - 1)
         {
            _base = _url;
            _fragment = '';
            _title = defaultTitle;
            ExternalInterface.call("BrowserHistory.setDefaultURL", defaultFragment);
            setTitle(defaultTitle);
         }
         else
         {
            _base = _url.substring(0, pos);
            _fragment = _url.substring(pos + 1);
            _title = ExternalInterface.call("BrowserHistory.getTitle");
            ExternalInterface.call("BrowserHistory.setDefaultURL", _fragment);
            
            if (_fragment != _defaultFragment)
               browserURLChange(_fragment, true);
         }
      }

      public function setFragment(value:String):void
      {

         var lastURL:String = _url;
         var lastFragment:String = _fragment;
         
         _url = base + '#' + value;
         _fragment = value;
         if (dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.APPLICATION_URL_CHANGE, false, true, _url, lastURL)))
         {
            if(browserMode) {
               ExternalInterface.call("BrowserHistory.setBrowserURL", value, ExternalInterface.objectID);
            }
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.URL_CHANGE, false, false, _url, lastURL));
         }
         else
         {
            _fragment = lastFragment;
            _url = lastURL;
         }
      }

      public function setTitle(value:String):void
      {
         if (!browserMode)
            return;
         ExternalInterface.call("BrowserHistory.setTitle", value);
         _title = ExternalInterface.call("BrowserHistory.getTitle");
      }
      
      public function browserURLChangeBrowser(fragment:String):void
      {
         browserURLChange(fragment, false);
      }
      
      private function browserURLChange(fragment:String, force:Boolean = false):void
      {
         if ((_fragment != fragment) || force)
         {
            _fragment = fragment;
            
            var lastURL:String = url;
            
            _url = _base + '#' + fragment;
            
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.BROWSER_URL_CHANGE, false, false, url, lastURL));
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.URL_CHANGE, false, false, url, lastURL));
         }
      }
   }
   
}
