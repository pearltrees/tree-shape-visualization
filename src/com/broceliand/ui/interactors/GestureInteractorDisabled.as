package com.broceliand.ui.interactors {
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   public class GestureInteractorDisabled implements IGestureInteractor {
      
      private var _log:BroLogger = Log.getLogger('com.broceliand.ui.interactors.gesture');
      
      public function GestureInteractorDisabled() {
         _log.info(" Gesture disabled");
      }
      
      public function isTouchScreen():Boolean {
         return false;
      }
   }
}