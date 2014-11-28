package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.InvokeAfterCreationCompleted;
   import com.broceliand.util.UrlNavigationController;
   
   import flash.utils.setTimeout;
   
   import mx.managers.IHistoryManagerClient;
   
   public class Url2Error implements IHistoryManagerClient
   {
      public static const ERROR_CLIENT_NAME:String="Error";
      public static const  TYPE_FIELD:String="t";
      
      public function Url2Error()
      {
         UrlNavigationController.registerHistory(ERROR_CLIENT_NAME, this);
         
      }
      public function saveState():Object {
         return null;
      }
      
      public function loadState(state:Object):void {
         if (state && state[TYPE_FIELD] != null) {
            var errorCode:int = parseInt(state[TYPE_FIELD]);
            if (!isNaN(errorCode)) {
               var am:ApplicationManager = ApplicationManager.getInstance();
               if (!am.components.topPanel) {
                  setTimeout(loadState, 300, state);
                  return;
               } else if (!am.components.topPanel.processedDescriptors) {
                  InvokeAfterCreationCompleted.performActionAfterCreationCompleted(am.components.topPanel, loadState, this, state);
                  return;
               }
               am.components.windowController.openErrorWindow(errorCode);
               return ;
            }
         }         
      }
      public function toString():String {
         return ERROR_CLIENT_NAME;
      }
      
   }
}