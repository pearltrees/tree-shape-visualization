package com.broceliand.ui.interactors {
   import flash.utils.Dictionary;

   public class WindowProtectionManager {
      
      private var _lockRequests:Dictionary = new Dictionary();
      
      public function requestWindowProtection(windowID:int, subPanelID:int = 0):void {
         var identifier:String = getIdentifier(windowID, subPanelID);
         if (!_lockRequests[identifier]) {
            _lockRequests[identifier] = true;
         }
      }
      
      public function requestWindowUnlock(windowID:int, subPanelID:int = 0):void {
         var identifier:String = getIdentifier(windowID, subPanelID);
         if (_lockRequests[identifier]) {
            delete _lockRequests[identifier];
         }
      }
      
      public function isWindowProtected(windowID : int, subPanelID : int = 0) : Boolean {
         var identifier:String = getIdentifier(windowID, subPanelID);
         var res : Boolean = false;
         if (_lockRequests[identifier]) {
            res = true;
         }
         return res;
      }
      
      public function isProtected():Boolean {
         for each (var value:Boolean in _lockRequests) {
            if (value) {
               return true;
            }
         }
         return false;
      }
      
      private function getIdentifier(windowID:int, subPanelID:int = 0):String {
         return "w" + windowID + "p" + subPanelID;
      }
   }
}