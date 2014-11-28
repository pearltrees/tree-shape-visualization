package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   
   public class BrowserScrollLocker
   {
      private var _scrollLocker:Boolean;
      
      public function BrowserScrollLocker()
      {
         _scrollLocker = false;
      }
      
      public function setBrowserScrollLocker (isLocked:Boolean):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (_scrollLocker != isLocked) {
            _scrollLocker = isLocked;
            am.getExternalInterface().setisScrollableWindow(isLocked);
         }
      }
   }
}