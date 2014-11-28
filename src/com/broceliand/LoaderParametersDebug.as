package com.broceliand
{
   public class LoaderParametersDebug implements ILoaderParameters
   {
      public function getClientLang():String {
         return "en_US";
      } 
      
      public function getEmbedId():String {
         
         return "pt-embed-1";
      }   
      
      public function setEmbedId(value:String):void {}
      
      public function getWebSiteUrl():String {

         return "YOUR_WEBSITE_URL";
      }    
      
      public function getStartLocation():String { 
         return "N-f=1_2";
      }
      
      public function isInPearltrees():Boolean {
         return false;
      }
      
      public function getAppVersion():String {
         return "";
      }
   }
}