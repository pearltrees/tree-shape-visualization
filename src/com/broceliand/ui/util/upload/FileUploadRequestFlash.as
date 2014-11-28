package com.broceliand.ui.util.upload
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.services.AmfService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetVoidCallback;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.ui.customization.common.UploadProcessingCompleteEvent;
   import com.broceliand.util.MultiUploadProgressEvent;
   import com.broceliand.util.error.ErrorConst;
   
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   import mx.rpc.events.FaultEvent;
   import mx.utils.StringUtil;
   
   public class FileUploadRequestFlash extends FileUploadRequest implements IAmfRetVoidCallback{
      
      private var _fileReference:FileReference;
      protected var _extensionAllowed:FileFilter;
      private var _isUploading:Boolean;
      private var _uploadTime:Timer;
      private var _processingTime:Timer;
      private var _totalBytesSent:Number = 0;
      private var _currentTime:int = 0;
      private var _previousTime:int = 0;

      public function FileUploadRequestFlash() {
         
      }
      
      private function initFileFilter():void {
         setExtensionAllowed();
         _fileReference = new FileReference();
         _fileReference.addEventListener(Event.SELECT, onSelectFile);
         _fileReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
         _fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onProcessingCompleteWithMessage);
         _fileReference.addEventListener(IOErrorEvent.IO_ERROR, onProcessingError);
         _uploadTime = new Timer(_maxUploadTime,1);
         _uploadTime.addEventListener(TimerEvent.TIMER, onMaxUploadTime);
         _processingTime = new Timer(_maxProcessingTime,1);
         _processingTime.addEventListener(TimerEvent.TIMER, onMaxProcessingTime);
         _fileReference.addEventListener(Event.CANCEL, onCancel);
      }
      
      protected function setExtensionAllowed():void {
         
         _extensionAllowed = new FileFilter("All files", "*");
      }
      
      override public function selectAndUploadFile():Boolean {
         if(_isUploading) {
            return false;
         }
         try {
            initFileFilter();
            _fileReference.browse(new Array(_extensionAllowed));
            return true;
         }
         catch(error:Error) {
         }
         return false;
      }
      
      protected function endCurrentRequest():void {

      }
      
      protected function validateFileNameExtension(fileName: String) : Boolean {
         
         return false;   
      }
      
      override public function get filename(): String {
         return _cleanFilename;
      }
      
      private function onSelectFile(event:Event):void {
         var fileSize:uint = getFileSize();
         if(fileSize < 0) {
            dispatchEvent(new Event(WRONG_FILE_SIZE_EVENT));
            endCurrentRequest();
         }
         else if(fileSize == 0 || fileSize > _maxSize) {
            dispatchEvent(new Event(WRONG_FILE_SIZE_EVENT));
            endCurrentRequest();
         }
         else if (!validateFileNameExtension(_fileReference.name)) {
            dispatchEvent(new Event(WRONG_FILE_TYPE_EVENT));
            endCurrentRequest();
         }
         else{
            _filename = _fileReference.name;
            _baseFilename = baseFilename(_filename);
            _cleanFilename = cleanFilenameWithoutExtension(_baseFilename);
            if (_cleanFilename.length == 0) {
               _cleanFilename = _fileType;
            }
            uploadFile();
         }
      }
      
      protected function getFileType():String {
         return "All";
      }
      
      protected function onProcessingCompleteWithMessage(event:DataEvent):void {
         dispatchEvent(new UploadProcessingCompleteEvent(PROCESSING_COMPLETE_EVENT, event.data));
      }
      
      protected function dealWithProcessingErrors(status:String, event:DataEvent):void {
         if(status == SERVER_ERROR_UNVALID_FILE) {
            dispatchInvalidFileError();
         } else if (status == SERVER_ERROR_UNKNOWN) {
            dispatchError('Unknown server error');
         } else if (status == SERVER_SIZE_OR_WEIGHT_INVALID) {
            dispatchWrongFileError();
         } else {
            dispatchError(event.data);
         }
      }
      
      protected function getURLVariables():URLVariables {
         var am:ApplicationManager =  ApplicationManager.getInstance();
         var urlVars:URLVariables = new URLVariables();
         var currentUser:User = am.currentUser;
         urlVars.userID = currentUser.persistentId;
         urlVars.userDB = currentUser.persistentDbId;
         urlVars.title = _fileReference.name;
         var cookie:String = am.getSessionID();
         if(cookie && StringUtil.trim(cookie) != "") {
            urlVars.sessionID = cookie;
         }
         urlVars.private = BroPage.isUserContentRestrictedOnCreation();
         return urlVars;
      }
      
      private function uploadFile():void {
         var request:URLRequest = new URLRequest(_uploadUrl);      
         request.method = URLRequestMethod.POST;
         request.data = getURLVariables();
         
         try {
            _fileReference.upload(request);
            dispatchEvent(new Event(UPLOAD_START_EVENT));
            _uploadTime.start();
         }
         catch (error:Error) {
            trace("Unable to upload file: "+error.message);
         }
      }
      
      override public function cancelUpload() : void {
         if (_fileReference) {
            _fileReference.cancel();
         }
      }
      
      override public function getFileSize():int {
         try {
            return _fileReference.size;
         }catch(e:Error) {}
         return -1;
      }
      
      private function onUploadProgress(event:ProgressEvent):void{
         if (event.bytesLoaded == event.bytesTotal) {
            dispatchEvent(new Event(FileUploadRequest.UPLOAD_FILE_COMPLETE_EVENT));
         } else {
            dispatchEvent(event);
         }
      }
      
      private function onMaxProcessingTime(event:TimerEvent):void {
         cancel();
         dispatchEvent(new Event(PROCESSING_TIMEOUT_EVENT));
      }
      private function onMaxUploadTime(event:TimerEvent):void {
         cancel();
         dispatchEvent(new Event(UPLOAD_TIMEOUT_EVENT));
      }
      private function onProcessingError(event:Event):void {
         var text:String = event.toString();
         if (event is IOErrorEvent) {
            text = IOErrorEvent(event).text;
         }
         dispatchError(text);
      }
      protected function dispatchComplete():void{
         if (_processingTime) {
            _processingTime.reset();
         }
         _isUploading = false;
         
         endCurrentRequest();
      }
      private function dispatchError(message:String):void{
         _isUploading = false;
         _processingTime.reset();
         ApplicationManager.getInstance().errorReporter.onError(ErrorConst.ERROR_UPLOADING, message);
         dispatchEvent(new Event(PROCESSING_ERROR));
         endCurrentRequest();
      }
      private function dispatchInvalidFileError():void{
         _isUploading = false;
         _processingTime.reset();
         var message:String = "Processing avatar error. Server can't process this type of file";
         ApplicationManager.getInstance().errorReporter.onInfo(ErrorConst.ERROR_UPLOADING, message);
         dispatchEvent(new Event(PROCESSING_ERROR));
         endCurrentRequest();
      }
      private function dispatchWrongFileError():void{
         _isUploading = false;
         _processingTime.reset();
         var message:String = "WrongFileError";
         ApplicationManager.getInstance().errorReporter.onInfo(ErrorConst.ERROR_UPLOADING, message);
         dispatchEvent(new Event(WRONG_FILE_SIZE_EVENT));
         endCurrentRequest();
      }
      private function onCancel(event:Event):void {
         endCurrentRequest();
      }
      public function onReturnValue():void {
         dispatchComplete();
      }
      public function onError(message:FaultEvent):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var service:AmfService= am.distantServices.amfTreeService;
         if(!service.reportErrorIfKnown(message)) {
            am.errorReporter.onError(ErrorConst.ERROR_SETTING_AVATAR_HASH, message.toString());
         }
      }
      
      override public function cancel():void{
         cancelUpload();
         _isCancelled = true;
         endCurrentRequest();
      }
   }
}