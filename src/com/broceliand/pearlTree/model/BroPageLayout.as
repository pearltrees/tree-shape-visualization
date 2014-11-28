package com.broceliand.pearlTree.model
{
   public class BroPageLayout
   {
      public static const TYPE_WIDE:int = 0; 
      public static const TYPE_LONG_AND_TEXT:int = 1; 
      public static const TYPE_LONG:int = 2;               
      public static const TYPE_WIDE_PLACEHOLDER:int = 3;    
      public static const TYPE_LONG_PLACEHOLDER:int = 4;    
      public static const TYPE_LONG_PLACEHOLDER_AND_TEXT:int = 5;   
      public static const TYPE_IMAGE:int = 6;                       
      public static const TYPE_EMBED:int = 7;                       
      public static const TYPE_NOT_FOUND:int = 8;                   
      public static const TYPE_DENIED:int = 9;                      
      public static const TYPE_NSFW:int = 10;                       
      public static const TYPE_PLUGIN_REQUIRED:int = 11;                  
      public static const TYPE_NOTE:int = 12; 
      public static const TYPE_PHOTO:int = 13; 
      public static const TYPE_NOTE_DELETED:int = 14;
      public static const TYPE_PHOTO_DELETED:int = 15;
      public static const TYPE_PHOTO_UPLOADING:int = 16;
      public static const TYPE_NOTE_RESTRICTED:int = 18;
      public static const TYPE_PHOTO_RESTRICTED:int = 19;
      public static const TYPE_USER_EDITED:int = 20;
      public static const TYPE_ONLY_TEXT:int = 21;
      public static const TYPE_DOCUMENT:int = 22;
      public static const TYPE_DOCUMENT_DELETED:int = 23;
      public static const TYPE_DOCUMENT_UPLOADING:int = 24;
      public static const TYPE_DOCUMENT_RESTRICTED:int = 25;
      
      private var _type:int;  
      private var _urlType:int; 
      private var _editedLayout:int; 
      
      public function BroPageLayout() {
      }
      
      public function setType(value:int, urlValue:int):void {
         if (value == TYPE_NOT_FOUND) {
            type = urlValue;
         } else {
            type = value;
         }
         urlType = urlValue;
      }
      public function get type():int {
         return _type;
      }
      public function set type(value:int):void {
         _type = value;
      }
      
      public function get urlType():int {
         return _urlType;
      }
      public function set urlType(value:int):void {
         _urlType = value;
      }
      
      public function get editedLayout():int {
         return _editedLayout;
      }
      public function set editedLayout(value:int):void {
         _editedLayout = value;
      }
      
      public function isWithSynthesis():Boolean {
         if (editedLayout == TYPE_NOT_FOUND) {
            return !isNote();
         }
         return (editedLayout == TYPE_LONG_AND_TEXT || editedLayout == TYPE_WIDE);
      }
      
      public function isWithDetail():Boolean {
         if (editedLayout == TYPE_NOT_FOUND) {
            if (_type == TYPE_USER_EDITED) { 
               return _urlType == TYPE_LONG 
                  || _urlType == TYPE_LONG_AND_TEXT 
                  || _urlType == TYPE_LONG_PLACEHOLDER
                  || _urlType == TYPE_LONG_PLACEHOLDER_AND_TEXT;
            }
            return hasScrap();
         }
         return (editedLayout == TYPE_LONG_AND_TEXT || editedLayout == TYPE_ONLY_TEXT);
      }
      
      public function hasScrap():Boolean {
         return (_type == TYPE_LONG 
            || _type == TYPE_LONG_AND_TEXT 
            || _type == TYPE_LONG_PLACEHOLDER
            || _type == TYPE_LONG_PLACEHOLDER_AND_TEXT
            || isNote());
      }
      
      public function isNote() : Boolean {
         return (type == TYPE_NOTE || type == TYPE_NOTE_DELETED || type == TYPE_NOTE_RESTRICTED); 
      }
      
      public function isNoteDeleted() : Boolean {
         return type == TYPE_NOTE_DELETED;
      }
      
      public function isDoc() : Boolean {
         var t:int = urlType;
         return (t == TYPE_DOCUMENT || t == TYPE_DOCUMENT_DELETED || t == TYPE_DOCUMENT_UPLOADING || t == TYPE_DOCUMENT_RESTRICTED);
      }
      
      public static function isDoc(layoutType:int):Boolean {
         return (layoutType == TYPE_DOCUMENT || layoutType == TYPE_DOCUMENT_DELETED || layoutType == TYPE_DOCUMENT_UPLOADING || layoutType == TYPE_DOCUMENT_RESTRICTED);
      }
      
      public function isDocDeleted():Boolean {
         return urlType == TYPE_DOCUMENT_DELETED;
      }
      
      public function isDocUploading():Boolean {
         return urlType == TYPE_DOCUMENT_UPLOADING;
      }
      
      public function isDocRestricted():Boolean {
         return urlType == TYPE_DOCUMENT_RESTRICTED;
      }
      
      public function isPhoto() : Boolean {
         var t:int = urlType;
         return (t == TYPE_PHOTO || t == TYPE_PHOTO_DELETED || t == TYPE_PHOTO_UPLOADING || t == TYPE_PHOTO_RESTRICTED); 
      }
      
      public function isPhotoDeleted() : Boolean {
         return urlType == TYPE_PHOTO_DELETED;
      }
      
      public function isPhotoUploading() : Boolean {
         return urlType == TYPE_PHOTO_UPLOADING;
      }
      
      public function isPhotoNotReady() : Boolean {
         return isPhotoDeleted() || isPhotoUploading();
      }
      
      public function isNoteRestricted():Boolean {
         return urlType == TYPE_NOTE_RESTRICTED;
      }
      
      public function isPhotoRestricted():Boolean {
         return urlType == TYPE_PHOTO_RESTRICTED;
      }
      
      public function isRestrictedContent():Boolean {
         return isPhotoRestricted() || isNoteRestricted();
      }
      
      public function isEditedContent():Boolean {
         return type == TYPE_USER_EDITED;
      }
      
      public function setEditedContent(value:Boolean):void {
         if (value) {
            type = TYPE_USER_EDITED;
         } 
         else {
            type = urlType;
         }
      }
      
      public function isScrapLayout():Boolean {
         return (type == TYPE_LONG 
            || type == TYPE_LONG_AND_TEXT 
            || type == TYPE_LONG_PLACEHOLDER
            || type == TYPE_LONG_PLACEHOLDER_AND_TEXT
            || isNote()
            || type == TYPE_USER_EDITED);
      }
      
   }
}