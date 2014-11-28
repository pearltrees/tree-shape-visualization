package com.broceliand.ui.util.upload
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.IJavascriptInterface;
   import com.broceliand.pearlTree.io.object.url.UrlData;
   import com.broceliand.pearlTree.io.object.user.UserData;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.util.MultiUploadProgressEvent;
   
   import flash.events.Event;
   
   import mx.rpc.events.FaultEvent;

   public class FileUploadRequestJS extends FileUploadRequest implements IAmfRetArrayCallback
   {
      
      public static const FILE_API_SUPPORT_YES:uint = 1;
      public static const FILE_API_SUPPORT_NO:uint = 2;
      public static const FILE_API_SUPPORT_UNKNOWN:uint = 0;
      public static const SEPARATOR_ENCODED_EVENT : String = "%%";
      private static var singleton:FileUploadRequestJS;
      private static var fileApiSupported:uint = FILE_API_SUPPORT_UNKNOWN;
      
      private var _externalInterface : IJavascriptInterface;
      private var _fileSize : int;
      private var _urlDataArrayByBatch : Array;
      private var _fileInfoArrayByBatch : Array;
      
      public function FileUploadRequestJS()
      {
         _externalInterface = ApplicationManager.getInstance().getExternalInterface();
         _maxSize = 300 * FileUploadRequest.MEGABYTE;
         _fileInfoArrayByBatch = new Array();
         _urlDataArrayByBatch = new Array();
         addListeners();
      }
      
      public static function getInstance():FileUploadRequestJS {
         if (!singleton) {
            singleton = new FileUploadRequestJS();
         }
         return singleton;
      }
      
      private function addListeners():void {
         _externalInterface.addEventListener(UPLOAD_FILES_SELECTED_JS, onFilesSelect);
         _externalInterface.addEventListener(UPLOAD_ALL_FILES_COMPLETE_JS, throwEvent);
         _externalInterface.addEventListener(UPLOAD_BATCH_COMPLETE_JS, throwEvent);
         _externalInterface.addEventListener(PROCESSING_ERROR_JS, throwEvent);
         _externalInterface.addEventListener(UPLOAD_START_EVENT, throwEvent);
         _externalInterface.addEventListener(MultiUploadProgressEvent.PROGRESS, throwMultiUploadProgressEvent);
         _externalInterface.addEventListener(UPLOAD_CURRENT_FILE_COMPLETE_JS, throwEvent);
      }
      
      private function onFilesSelect(e:Event):void {
         var raw:Array = FileUploadRequest.tempFileInfoArray;
         makeFileInfoArrayFromRaw(raw, getBatchNumber());
         requestUrlDatasForDocuments();
         dispatchEvent(e);
      }
      
      private function makeFileInfoArrayFromRaw(raw:Array, batchPosition:int):void {
         var newBatchInfoArray:Array = new Array();
         var targetTree:BroPearlTree = ApplicationManager.getInstance().visualModel.navigationModel.getSelectedTree();
         for (var i:int = 0; i < raw.length; i ++) {
            newBatchInfoArray[i] = new FileInfo(raw[i].fileName, raw[i].fileSize, targetTree, i);
         }
         fileInfoArrayByBatch[batchPosition] = newBatchInfoArray;
      }
      
      override public function cancelUpload():void {
         if (_externalInterface) {
            _externalInterface.cancelUpload();
         }
      }
      
      public function requestUrlDatasForDocuments():void {
         var fileInfoArray:Array = getLastFileInfoArray() as Array;
         var originalFileNames:Array = new Array();
         for (var i:int = 0; i < fileInfoArray.length; i++) {
            originalFileNames[i] = (fileInfoArray[i] as FileInfo).originalFileName;
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         var treeServices:AmfTreeService = am.distantServices.amfTreeService;
         var user:UserData = AmfUserService.makeDataFromBUser(am.currentUser);
         treeServices.createMultipleFiles(user, originalFileNames, getTargetTree().visibility == BroPearlTree.PRIVATE, this);
      }
      
      public function onReturnValue(value:Array):void {
         if (value != null) {
            urlDataArrayByBatch[fileInfoArrayByBatch.length - 1] = value;
            applyUrlIdsToFiles();
            
         }
      }
      
      private function applyUrlIdsToFiles():void {
         var urlDatas:Array = urlDataArrayByBatch[getBatchNumber() - 1] as Array;
         if (urlDatas && urlDatas.length > 0) {
            var urlIds:Array = new Array();
            for (var i:int = 0; i < urlDatas.length; i++) {
               urlIds[i] = (urlDatas[i] as UrlData).id.toString();
            }
            _externalInterface.applyUrlIdToUploadingFiles(urlIds);
         }
      }
      
      public function onError(message:FaultEvent):void {
         urlDataArrayByBatch[fileInfoArrayByBatch.length] = null;
         dispatchEvent(new Event(FileUploadRequest.SERVER_ERROR_UNVALID_FILE));
      }
      
      private function getTargetTree():BroPearlTree {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         var targetTree:BroPearlTree  = null;
         if (!navModel.isShowingPearlTreesWorld()) {
            targetTree = navModel.getSelectedTree();
            if (!targetTree) {
               targetTree= navModel.getFocusedTree();
            }
            if (targetTree && !targetTree.getMyAssociation().isMyAssociation()) {
               targetTree= null;
            }
         }
         return targetTree;
      }
      
      public function removeFileAt(filePosition:uint, batchPosition:uint):void {
         if (_externalInterface) {
            _externalInterface.removeUploadFile(filePosition, batchPosition);
         }
      }
      
      private function throwMultiUploadProgressEvent(event:MultiUploadProgressEvent):void {
         dispatchEvent(event);
      }
      
      private function throwEvent(event:Event):void {
         dispatchEvent(event);
      }
      
      override public function selectAndUploadFile():Boolean {
         _externalInterface.uploadDocument();
         return true;
      }
      
      override public function getFileSize():int {
         return _fileSize;
      }
      
      override protected function baseFilename(fileName:String):String {
         var dotPosition:int = fileName.lastIndexOf(".");
         if (dotPosition != -1) {
            return fileName.substr(0, dotPosition);
         }
         else {
            return fileName;
         }
      }
      
      override public function get filename():String {
         return _cleanFilename;
      }
      
      public function get fileInfoArrayByBatch():Array
      {
         return _fileInfoArrayByBatch;
      }
      
      public function set fileInfoArrayByBatch(value:Array):void
      {
         _fileInfoArrayByBatch = value;
      }
      
      public function getLastFileInfoArray():Array {
         return fileInfoArrayByBatch[fileInfoArrayByBatch.length - 1] as Array;
      }
      
      public function getLastUrlDataArray():Array {
         return urlDataArrayByBatch[getBatchNumber() - 1] as Array;
      }
      
      public function get urlDataArrayByBatch():Array
      {
         return _urlDataArrayByBatch;
      }
      
      public function set urlDataArrayByBatch(value:Array):void
      {
         _urlDataArrayByBatch = value;
      }
      
      public function getBatchNumber():int {
         return fileInfoArrayByBatch.length;
      }
      
      public static function isAbleToUploadByJS():Boolean {
         if (fileApiSupported == FILE_API_SUPPORT_UNKNOWN) {
            var eI:IJavascriptInterface = ApplicationManager.getInstance().getExternalInterface();
            fileApiSupported = eI.isFileApiSupported() ? FILE_API_SUPPORT_YES : FILE_API_SUPPORT_NO;
         }
         return fileApiSupported == FILE_API_SUPPORT_YES;
      }
      
      public static function encodeFileBatchPositionInString(filePosition:int, batchPosition:int):String {
         return filePosition.toString() + SEPARATOR_ENCODED_EVENT + batchPosition.toString();
      }
      
      public static function decodeFileBatchPositionFromString(data:String):Array {
         return data.split(SEPARATOR_ENCODED_EVENT);
      }
      
   }      
}