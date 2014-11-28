package com.broceliand.ui.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.AccountManager;
   import com.broceliand.pearlTree.io.loader.IUserLoader;
   import com.broceliand.pearlTree.io.loader.UserLoader;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.controller.startPolicy.StartupMessage;
   import com.broceliand.ui.welcome.tunnel.NewTreeDetector;
   import com.broceliand.util.DateManager;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   import mx.core.Application;
   
   public class PearlbarInfo extends EventDispatcher implements IPearlbarInfo 
   {
      public static const PEARLBAR_INFO_CHANGED_EVENT:String = "PearlbarInfoChangedEvent";
      
      private var _pearlbarInfoLoaded:Boolean;
      private var _accountManager:AccountManager;
      private var _userLoader:IUserLoader;
      private var _isPearlbarDetected:Boolean;
      private var _pearlbarVersion:String;

      public function PearlbarInfo() {
         _pearlbarInfoLoaded = false;
         var am:ApplicationManager = ApplicationManager.getInstance();
         _accountManager = am.accountManager;       
         _userLoader = new UserLoader();
         _userLoader.addEventListener(UserLoader.SETTINGS_LOADED_EVENT, onSettingsLoaded);
         StartPolicyLogger.getInstance().addEventListener(StartPolicyLogger.NEXT_STEP_EVENT, onNextStepInStartPolicy);
      }
      
      private function onNextStepInStartPolicy(event:Event):void {
         if(StartPolicyLogger.getInstance().isFirstOpenAnimationEnded() && !NewTreeDetector.getInstance().isNewUserFirstArrival()) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            
            var startupMessage:StartupMessage = StartupMessage.getFromHtmlParameters();
            if(!am.currentUser.isAnonymous() && 
               isPearlbarDetected() && 
               (pearlbarVersion == null || pearlbarVersion == "5.1.9") &&
               am.getBrowserName() == ApplicationManager.BROWSER_NAME_FIREFOX &&
               startupMessage.type == StartupMessage.FIREFOX_519) {
               
               am.components.windowController.openUpdateAddonWindow();
            }
         }
      }
      
      private function onSettingsLoaded(event:Event):void{
         pearlbarInfoLoaded = true;
      }
      
      private function set pearlbarInfoLoaded(value:Boolean):void{
         if(value) {
            _pearlbarInfoLoaded = true;
            dispatchEvent(new Event(PEARLBAR_INFO_CHANGED_EVENT));            
         }
      }

      public function isNotifyingInstallPearlbar():Boolean {
         var user:User = ApplicationManager.getInstance().currentUser;
         return (isPearlbarInstalled() && isAccountLessThanAWeekOld(user) && !userDownloadedPluginButHasNotRestartedYet());
      }
      
      public function isPearlbarInstalled():Boolean {
         var user:User = ApplicationManager.getInstance().currentUser;       
         if(user && user.userSettings && user.userSettings.isPearlbarInstalled()) {
            return true;
         }
         else if(isPearlbarDetected()) {
            return true;
         }
         else {
            return false;
         }
      }
      
      public function isPearlbarInstalledOnThisBrowser():Boolean {         
         var browser:String = ApplicationManager.getInstance().getBrowserName();
         if(browser == ApplicationManager.BROWSER_NAME_FIREFOX
            || browser == ApplicationManager.BROWSER_NAME_SAFARI
            || browser == ApplicationManager.BROWSER_NAME_CHROME) {
            return isPearlbarDetected();  
         }
         else {
            return isPearlbarInstalled();
         }
      }
      
      public function set pearlbarVersion(value:String):void {
         _pearlbarVersion = value;
      }
      public function get pearlbarVersion():String {
         return _pearlbarVersion;
      }
      
      private function isPearlbarDetected():Boolean {
         return _isPearlbarDetected;
      }
      public function detectPearlbar():void {
         ApplicationManager.getInstance().getExternalInterface().detectPearlbar();
      }
      public function set pearlbarDetected(value:Boolean):void {
         _isPearlbarDetected = value;
         pearlbarInfoLoaded = true;         
      }
      
      private function isAccountLessThanAWeekOld(user:User):Boolean {
         if(!user || !user.userSettings) return false;
         var millisecondsPerWeek:int = 1000 * 60 * 60 * 24 * 7;
         var userCreationDate:Date = DateManager.timestampToDate(user.userSettings.creationDate);
         var today:Date = new Date();
         return today.getTime() < (userCreationDate.getTime() + millisecondsPerWeek);     
      }
      
      private function userDownloadedPluginButHasNotRestartedYet():Boolean{
         var newTreeDetector:NewTreeDetector = NewTreeDetector.getInstance();
         return (newTreeDetector.userWasInTunnel && newTreeDetector.userClickedInstallPearlBar);         
      }      
   }
}