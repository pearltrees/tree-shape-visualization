package com.broceliand.ui.util.upload
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.IJavascriptInterface;
   import com.broceliand.pearlTree.io.object.url.UrlData;
   import com.broceliand.util.BroLocale;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   import mx.utils.StringUtil;
   
   public class FileUploadRequest extends EventDispatcher
   {
      public static const MINUTE:uint = 60 * 1000;
      public static const MEGABYTE:uint = 1024 * 1024;
      public static const KILOBYTE:uint = 1024;
      
      public static const WRONG_FILE_SIZE_EVENT:String = "FileUploadWrongFileSize";
      public static const WRONG_FILE_TYPE_EVENT:String = "FileUploadWrongFileType";
      public static const UPLOAD_START_EVENT:String = "FileUploadUploadStart";
      public static const UPLOAD_FILE_COMPLETE_EVENT:String = "FileUploadUploadComplete";
      public static const PROCESSING_COMPLETE_EVENT:String = "FileUploadProcessingComplete";
      public static const PROCESSING_ERROR:String = "FileUploadProcessingError";
      public static const PROCESSING_TIMEOUT_EVENT:String = "FileUploadProcessingTimeout";
      public static const UPLOAD_TIMEOUT_EVENT:String = "FileUploadUploadTimeout";
      
      public static const PROCESSING_ERROR_JS:String = "FileUploadProcessingErrorJS";
      public static const UPLOAD_ALL_FILES_COMPLETE_JS:String = "UploadAllFilesCompleteJS";
      public static const UPLOAD_BATCH_COMPLETE_JS:String = "UploadBatchComplete";
      public static const UPLOAD_CURRENT_FILE_COMPLETE_JS:String = "MultiUploadCurrentFileComplete";
      public static const UPLOAD_FILES_SELECTED_JS:String = "UploadFilesSelectedJS";
      
      protected static const SERVER_COMPLETE:String = '0';
      protected static const SERVER_ERROR_UNVALID_FILE: String = '1';
      protected static const SERVER_ERROR_UNKNOWN:String = '2';
      protected static const SERVER_SIZE_OR_WEIGHT_INVALID:String = '3';
      
      private static var _tempFileInfoArray:Array;
      private static var _tempFileInfoArrayRead:Boolean = true;;
      
      protected var _filename: String;
      protected var _baseFilename: String;
      protected var _cleanFilename: String;
      protected var _isCancelled:Boolean = false;
      protected var _uploadUrl:String;
      protected var _maxUploadTime:uint;
      protected var _maxProcessingTime:uint;
      protected var _maxSize:int;
      protected var _fileType:String;
      
      public function FileUploadRequest()
      {
      }
      
      public function selectAndUploadFile():Boolean {
         return true;
         
      }
      
      public function get filename():String {
         return "myFile";
         
      }
      
      public function getFileSize():int {
         return 0;
         
      }
      
      public function cancelUpload(): void {
         
      }
      
      public function cancel():void {
         
      }
      
      public function isCancelled():Boolean {
         return _isCancelled;
      }
      
      override public function dispatchEvent(event:Event):Boolean{
         if (!_isCancelled) {
            return super.dispatchEvent(event);
         }
         return true;
      }
      
      protected function baseFilename(fileName:String):String {
         
         return "";
      }
      
      public function get originalFileName():String {
         return _filename;
      }
      
      protected function cleanFilenameWithoutExtension(name0:String) : String {
         var pattern1:RegExp = /_/g;
         var pattern2:RegExp = /\s+/g;
         var name1 : String = name0.replace(pattern1, " ");
         var name2 : String = name1.replace(pattern2, " ");
         var name3 : String = StringUtil.trim(name2);
         if (name3.length>0) {
            return name2;
         } else {
            return name0;
         }
      }
      
      public static function computeSizeInString(size:int):String {
         var sizeInMb:Number = size / MEGABYTE;
         var sizeInKb:Number = size / KILOBYTE;
         var unit:String = sizeInMb < 0.1 ? BroLocale.getText('kilobyte') : BroLocale.getText('megabyte');
         var result:String =  sizeInMb < 0.1 ? sizeInKb.toString() : sizeInMb.toString();
         var dotPosition: int = result.indexOf(".");
         if (dotPosition == -1) {
            
         } else if (dotPosition + 2 > result.length) {
            
         } else {
            result = result.substr(0, dotPosition + 2);
         }
         result = result + unit;
         return result;
      }
      
      public static function getProgressInString(progress:Number):String {
         return Math.round(progress * 100).toString() + " %";
      }
      
      public static function get tempFileInfoArray():Array
      {
         if (_tempFileInfoArrayRead) {
            return null;
         } else {
            return _tempFileInfoArray;
         }
      }
      
      public static function set tempFileInfoArray(value:Array):void
      {
         _tempFileInfoArray = value;
         _tempFileInfoArrayRead = false;
      }
      
      public function get urlDatas():Array { 
         return null;
      }
   }
}