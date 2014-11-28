package com.broceliand.util {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.window.ui.error.ErrorWindowModel;
   import com.broceliand.util.error.ErrorConst;
   
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   
   import mx.events.ModuleEvent;
   import mx.modules.ModuleLoader;

   public class PTModuleLoader extends ModuleLoader implements IPTModule {
      
      public static const LOADED_EVENT:String = "moduleLoadedEvent";
      
      private var _moduleURL:String;
      private var _isLoaded:Boolean;  
      private var _isLoading:Boolean;
      private var _showBusyCursorOnLoad:Boolean;
      protected var _moduleName:String = "";
      
      public function PTModuleLoader(moduleRelativePath:String) {
         super();
         super.visible = false;
         addEventListener(ModuleEvent.READY, onReady);
         addEventListener(ModuleEvent.ERROR, onError);
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var swfUrl:String = ApplicationManager.flexApplication.url;
         
         if(swfUrl.indexOf("file://") != -1) {
            _moduleURL = moduleRelativePath+"?"+ApplicationManager.SWF_VERSION_PARAM+"="+am.getAppVersion(); 
         }else{
            var siteURL:String = ApplicationManager.getInstance().getStaticContentUrl();
            _moduleURL = siteURL+moduleRelativePath+"?"+ApplicationManager.SWF_VERSION_PARAM+"="+am.getAppVersion();
         }
      }
      
      private function onReady(event:ModuleEvent):void {
         _isLoaded = true;
         _isLoading = false;
         if(_showBusyCursorOnLoad) {
            ApplicationManager.getInstance().visualModel.mouseManager.showBusy(false);
         }
         dispatchEvent(new Event(LOADED_EVENT));
      }
      
      private function onError(event:ModuleEvent):void {
         _isLoading = false;
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(_showBusyCursorOnLoad) {
            am.visualModel.mouseManager.showBusy(false);
         }
         am.errorReporter.onError(ErrorConst.ERROR_LOADING_SETTINGS_MODULE, event.errorText);
      }
      
      public function load(showBusyCursor:Boolean=true):void {
         if(!_isLoaded && !_isLoading) {
            _isLoading = true;
            _showBusyCursorOnLoad = showBusyCursor;
            var am:ApplicationManager = ApplicationManager.getInstance();
            if(_showBusyCursorOnLoad) {
               am.visualModel.mouseManager.showBusy(true);
            }
            url = _moduleURL;
            applicationDomain = am.applicationDomain;
            loadModule();
         }

         else if(_isLoading && showBusyCursor && !_showBusyCursorOnLoad) {
            _showBusyCursorOnLoad = true;
            ApplicationManager.getInstance().visualModel.mouseManager.showBusy(true);
         }
      }
      
      public function isLoaded():Boolean {
         return _isLoaded;
      }
      
      public function createClassInstance(classPath:String):Object {
         var result:Object = null;
         try {
            var classDefinition:Class = ApplicationDomain.currentDomain.getDefinition(classPath) as Class;
            result = new classDefinition();
         } catch(error:Error) {
            var errorMessage:String = "Can't find Class ["+classPath+"] in "+_moduleName+" module: error is: " + error;
            ApplicationManager.getInstance().components.windowController.openErrorWindow(ErrorWindowModel.ERROR_EXPLICIT_MESSAGE,false,errorMessage);
         }
         return result;
      }
   }
}