package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.util.UrlNavigationController;
   
   import mx.managers.IHistoryManagerClient;
   
   public class Url2Pearlbar implements IHistoryManagerClient
   {
      private static const PEARLBAR_CLIENT_NAME:String="Pearlbar";
      private static const HIGHLIGHT_FIELD:String="samba";
      
      private static var highlight:Boolean;
      
      public function Url2Pearlbar() {
         UrlNavigationController.registerHistory(PEARLBAR_CLIENT_NAME, this);     
      }
      public function saveState():Object {
         var state:Object= new Object();
         if(Url2Pearlbar.highlight){
            state[HIGHLIGHT_FIELD] = "1";
            return state;
         }
         return null;
      }
      
      public static function highlightPearlbar():void{
         Url2Pearlbar.highlight = true;
         UrlNavigationController.save();
      }
      public static function unhighlightPearlbar():void{
         Url2Pearlbar.highlight = false;
         UrlNavigationController.save();
      }
      
      public function loadState(state:Object):void{}
      public function toString():String{
         return PEARLBAR_CLIENT_NAME;
      }            
   }
}