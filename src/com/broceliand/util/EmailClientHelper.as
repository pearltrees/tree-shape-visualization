package com.broceliand.util {
   
   import com.broceliand.ApplicationManager;
   
   public class EmailClientHelper {
      
      public static function openNewEmail(toEmail:String="", subject:String="", body:String=""):void {
         ApplicationManager.getInstance().getExternalInterface().openWindow('mailto:'+toEmail+'?subject='+encodeURI(subject)+'&body='+encodeURI(body), "_top");
      }
   }
}