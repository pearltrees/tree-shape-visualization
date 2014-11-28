package com.broceliand.util.error
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.window.ui.error.ErrorWindowModel;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.IErrorReporter;
   import com.broceliand.util.InvokeAfterCreationCompleted;
   
   public class DefaultErrorReporter implements IErrorReporter {
      
      private var _hasBlockerError:Boolean =false;
      
      public function DefaultErrorReporter() {

      }
      
      public function onError(errorType:int, ...context):void {
         if (!ApplicationManager.getInstance().components.topPanel.processedDescriptors) {
            InvokeAfterCreationCompleted.performActionAfterCreationCompleted(ApplicationManager.getInstance().components.topPanel, onError, this, errorType, context);
            return;
         }
         if(errorType == ErrorConst.ERROR_CREATING_ACCOUNT){
            
            if(context && context[0] && (context[0].toString().indexOf("username already exist") != -1)){
               return;
            }
         }
         
         var msg:String = makeMessage(errorType, context); 
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         
         if(errorType == ErrorConst.ERROR_LOADING_DELETED_TREE ) {
            wc.openErrorWindow(ErrorWindowModel.ERROR_PEARL_DELETED);                   
         } else if(errorType == ErrorConst.ERROR_BAD_INITIAL_URL) {           
            wc.openErrorWindow(ErrorWindowModel.ERROR_BAD_INITIAL_URL);
         } else if(errorType == ErrorConst.ERROR_CONNECTION_LOST) {
            wc.openErrorWindow(ErrorWindowModel.ERROR_CONNECTION_LOST);
         } else if (errorType == ErrorConst.ERROR_LOADING_OUR_DROPZONE_TREE) {
            wc.openErrorWindow(ErrorWindowModel.ERROR_TREE_IN_DROPZONE);
         } else if (errorType == ErrorConst.INFO_DELICIOUS_BOOKMARKS_LOADED_ROOT) {
            wc.openErrorWindow(ErrorWindowModel.INFO_DELICIOUS_BOOKMARKS_LOADED_ROOT);
         } else if (errorType == ErrorConst.INFO_DELICIOUS_BOOKMARKS_LOADED_DROPZONE) {
            wc.openErrorWindow(ErrorWindowModel.INFO_DELICIOUS_BOOKMARKS_LOADED_DROPZONE);
         } else if(errorType == ErrorConst.ERROR_UPLOADING) {
            
            trace("Error uploading avatar: "+msg);
         } else {
            wc.openErrorWindow(ErrorWindowModel.ERROR_EXPLICIT_MESSAGE, false, msg);   
         }
      }      
      
      public function onWarning(errorType:int, ...context):void {
         var msg:String = makeMessage(errorType, context); 
         trace("warning :"+msg);        
      }
      
      public function onInfo(errorType:int, ...context):void {
         var msg:String = makeMessage(errorType, context); 
         trace("Info :"+msg);         
      }
      
      private function makeMessage(errorType:int, context:Array):String{
         if (errorType ==ErrorConst.ERROR_TREE_NOT_IN_HIERARCHY) {
            return BroLocale.getText("error.treeNotInHiearchy", context);   
         } else {
            var msg:String =  "";
            msg = "Error Type :#"+errorType+"\n";
            if (errorType == ErrorConst.ERROR_LOADING_UNKNOWN_TREE) {
               msg = BroLocale.getText("pw.panel.error.wrongURL.title");
            } else {
               
               for each (var i:Object in context){
                  if (i!=null) 
                     msg += i+"\n";
               }
            }
            return msg;
         }
      }
      public function set hasBlockerError(value:Boolean):void
      {
         _hasBlockerError = value;
      }
      
      public function get hasBlockerError ():Boolean
      {
         return _hasBlockerError;
      }

   }
}