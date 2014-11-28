package com.broceliand.ui.util.upload
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.util.BroLocale;
   
   import mx.utils.StringUtil;
   
   public class FileInfo
   {
      private var _originalFileName:String;
      private var _fileSize:int;
      private var _extension:String;
      private var _cleanFileName:String;
      private var _baseFileName:String;
      private var _targetTree:BroPearlTree;
      private var _position:int;
      private var _sizeError:Boolean = false;
      private var _hasError:Boolean = false;
      
      public function FileInfo(originalFileNameValue:String, fileSizeValue:int, targetTree:BroPearlTree, position:int){
         _originalFileName = originalFileNameValue;
         _fileSize = fileSizeValue;
         _baseFileName = removeExtension(_originalFileName);
         _cleanFileName = nameCleanUp(_baseFileName);
         _targetTree = targetTree;
         _position = position;
         _sizeError = _fileSize > 300 * FileUploadRequest.MEGABYTE;
         _hasError = _sizeError;
      }
      
      public static function removeExtension(original:String):String {
         var dotPosition:int = original.lastIndexOf(".");
         if (dotPosition != -1) {
            return original.substr(0, dotPosition);
         }
         else {
            return original;
         }
      }
      
      public function getFileErrorMessage():String {
         var result:String = "";
         if (_sizeError) {
            result = BroLocale.getText('pearlDoc.maxSizeError.shortMessage');
         }
         return result;
      }
      
      public static function hasAtLeastOneValidFileInBatch(fileInfoArray:Array):Boolean {
         for (var i:int = 0; i < fileInfoArray.length; i++) {
            var fi:FileInfo = fileInfoArray[i] as FileInfo;
            if (fi && !fi.hasError) {
               return true; 
            }
         }
         return false;
      }
      
      public static function nameCleanUp(name0:String):String {
         return name0;
      }
      
      public function get originalFileName():String
      {
         return _originalFileName;
      }
      
      public function get fileSize():int
      {
         return _fileSize;
      }
      
      public function get cleanFileName():String
      {
         return _cleanFileName;
      }
      
      public function get targetTree():BroPearlTree
      {
         return _targetTree;
      }
      
      public function get position():int
      {
         return _position;
      }
      
      public function get sizeError():Boolean
      {
         return _sizeError;
      }
      
      public function get hasError():Boolean
      {
         return _hasError;
      }
      
      public function set hasError(value:Boolean):void
      {
         _hasError = value;
      }

   }
}