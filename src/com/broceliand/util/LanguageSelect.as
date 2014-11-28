package com.broceliand.util
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.exporter.IUserExporter;
   import com.broceliand.pearlTree.io.exporter.UserExporter;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.UserSettings;
   
   public class LanguageSelect
   {
      
      public function LanguageSelect(){ 
      }
      
      public function setLanguage(value:int, reloadNow:Boolean = true):void{
         if (value != BroLocale.getInstance().lang){
            setUserLangAndSave(value);
            setLang(value, reloadNow);
         }
      }
      
      private function setUserLangAndSave(lang:int):void{
         
         var currentUser:User = ApplicationManager.getInstance().currentUser;
         
         if(!currentUser.userSettings){
            currentUser.userSettings = new UserSettings();
         }
         
         var currentUserSettings:UserSettings = currentUser.userSettings;
         
         currentUserSettings.locale = lang;
         
         var userExporter:IUserExporter = new UserExporter();
         userExporter.saveCurrentUserSettings();
      }
      
      private function setLang(lang:int, reloadNow:Boolean):void{
         if  (reloadNow) 
            BroLocale.getInstance().lang = lang;
         else
            BroLocale.getInstance().setLangNotReload(lang);  
      }
      
   }
}