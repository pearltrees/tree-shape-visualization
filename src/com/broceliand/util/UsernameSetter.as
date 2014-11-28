package com.broceliand.util
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.AccountManager;
   import com.broceliand.ui.textInput.InputValidator;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class UsernameSetter extends EventDispatcher {
      
      public static const OK:int=0;
      public static const NOT_CHECKED:int=1;
      public static const CHECKING_AVAILIBILITY:int=2;
      public static const ERROR_USERNAME_TAKEN:int=4;
      
      public static const PRECHECK_OK:int=0;
      public static const PRECHECK_TOO_SHORT:int=1;
      public static const PRECHECK_TOO_LONG:int=2;
      public static const PRECHECK_UNCHANGED:int=3;
      
      public static const AVAILABILITY_CHECKED_EVENT:String = "UsernamesetterAvailabilityChecked";
      
      private var _wantedUsername:String = null;
      private var _accountManager:AccountManager = ApplicationManager.getInstance().accountManager;
      private var _status:int = NOT_CHECKED;

      public function UsernameSetter() {
         
      }
      
      public function get status():int {
         return _status;
      }
      
      public function setWantedUsername(wantedName:String):int {
         if (!_wantedUsername || _wantedUsername != wantedName) {
            _wantedUsername = wantedName;
            var testUsernameValid:int = InputValidator.checkUserName(_wantedUsername);
            if (testUsernameValid < 0) {
               _status = NOT_CHECKED;
               if (testUsernameValid == InputValidator.TOO_SHORT){
                  return PRECHECK_TOO_SHORT;
               }
               else if (testUsernameValid == InputValidator.TOO_LONG) {
                  return PRECHECK_TOO_LONG;
               }
            }
            _status = CHECKING_AVAILIBILITY;
            _accountManager.addEventListener(AccountManager.ACCOUNT_NAME_AVAILABLE_EVENT, onUserNameAvailable);
            _accountManager.addEventListener(AccountManager.ACCOUNT_NAME_TAKEN_EVENT, onUserNameTaken);
            _accountManager.checkIsUsernameTaken(_wantedUsername);
            return PRECHECK_OK;
         }
         return PRECHECK_UNCHANGED;
      }
      
      public function isWantedUsernameDifferent(newWantedName:String):Boolean {
         return !_wantedUsername || _wantedUsername != newWantedName;
      }
      
      private function onUserNameAvailable(event:Event):void {
         _accountManager.removeEventListener(AccountManager.ACCOUNT_NAME_AVAILABLE_EVENT, onUserNameAvailable);
         _accountManager.removeEventListener(AccountManager.ACCOUNT_NAME_TAKEN_EVENT, onUserNameTaken);
         _status = OK;
         dispatchEvent(new Event(AVAILABILITY_CHECKED_EVENT));
      }
      
      private function onUserNameTaken(event:Event):void {
         _accountManager.removeEventListener(AccountManager.ACCOUNT_NAME_AVAILABLE_EVENT, onUserNameAvailable);
         _accountManager.removeEventListener(AccountManager.ACCOUNT_NAME_TAKEN_EVENT, onUserNameTaken);
         _status = ERROR_USERNAME_TAKEN;
         dispatchEvent(new Event(AVAILABILITY_CHECKED_EVENT));
      }
      
   }
}