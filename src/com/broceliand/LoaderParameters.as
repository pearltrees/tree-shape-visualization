package com.broceliand
{
   import com.broceliand.util.Assert;
   
   import flash.display.Loader;
   import flash.events.Event;
   
   import mx.core.Application;
   import mx.utils.StringUtil;
   
   public class LoaderParameters implements ILoaderParameters
   {
      private var _parameters:Object;
      private var _isInitialized:Boolean;
      private var _embedId:String;
      
      public function LoaderParameters() {
         if(ApplicationManager.flexApplication.stage) {
            init();
         }else {
            ApplicationManager.flexApplication.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
         }
      }
      
      private function onAddedToStage(event:Event):void {
         init();
      }
      
      private function init():void {
         _parameters = ApplicationManager.flexApplication.stage.loaderInfo.parameters;
         
         if(_parameters) {
            setEmbedId(_parameters.embedId);
         }
         
         _isInitialized = true;         
      }
      
      public function isInPearltrees():Boolean {
         return (getParamValue("inPearltrees") == "true");
      }
      
      public function getClientLang():String {
         return getParamValue("lang");
      }
      
      public function getEmbedId():String {
         if(!_embedId) _embedId = getParamValue("embedId");
         return _embedId;
      }
      public function setEmbedId(value:String):void {
         _embedId = value;
      }
      
      public function getWebSiteUrl():String {
         var webSiteUrl:String = getParamValue("site");
         return (webSiteUrl)?("http://"+decodeURIComponent(webSiteUrl)):null;
      }
      
      public function getStartLocation():String {
         var treeId:String = getParamValue("treeId");
         if(treeId && StringUtil.trim(treeId) != "" && !isNaN(parseInt(treeId))) {
            return "N-f=1_"+treeId;
         }else{
            return null;
         }
      }
      
      public function getAppVersion():String {
         return getParamValue(ApplicationManager.SWF_VERSION_PARAM);
      }
      
      private function getParamValue(param:String):String {
         Assert.assert(_isInitialized, "LoaderParameters is not initialized");
         
         var value:String = null;
         
         if(!_parameters) {
            value = null;
         }
            
         else if(_parameters[param]) {
            value = _parameters[param];
         }
         else {
            for(var key:String in _parameters) {               
               if(key.indexOf(param) != -1) {
                  value = _parameters[key];
                  break;
               }
            }
         }
         
         return value;         
      }
   }
}