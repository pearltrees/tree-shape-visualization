package com.broceliand.util.error
{
   public class ErrorConst
   {
      public static const INTERNAL_ERROR:int=0; 
      public static const ERROR_LOADING_USER_HIERARCHY:int = 1; 
      public static const ERROR_LOADING_PEARLTREES_NEIGHBOUR:int = 2; 
      public static const ERROR_UPLOADING:int = 3; 
      public static const ERROR_SAVING_SETTINGS:int = 4; 
      public static const ERROR_CREATING_ACCOUNT:int = 5; 
      public static const ERROR_ADDING_A_FRIEND:int=6; 
      public static const ERROR_INVITE_A_FRIEND:int=7; 
      public static const ERROR_LOADING_TREE_TO_MERGE:int=8; 
      public static const ERROR_UPDATING_TREE:int=9; 
      public static const ERROR_LOADING_DELETED_TREE:int =11; 
      public static const ERROR_LOADING_UNKNOWN_TREE:int =12; 
      public static const ERROR_LOADING_TREE:int =13; 
      public static const ERROR_SAVING_TREE:int =14; 
      public static const ERROR_WRONG_LOGIN:int =15; 
      public static const ERROR_PEARL_SENT:int=16; 
      public static const ERROR_SAVING_A_NOTE:int=17; 
      public static const ERROR_DELETING_A_NOTE:int=18; 
      public static const ERROR_VALIDATING_NOTIFICATION:int=19; 
      public static const ERROR_LOADING_NOTES:int=20; 
      public static const ERROR_TREE_NOT_IN_HIERARCHY:int=21; 
      public static const ERROR_BAD_INITIAL_URL:int=22; 
      public static const ERROR_SEND_LOST_PASSWORD_EMAIL:int=23; 
      public static const ERROR_LOADING_USER_HISTORY:int=24; 
      public static const ERROR_LOADING_USER:int=25; 
      public static const ERROR_SAVING_NOTE_MODE:int=26; 
      public static const ERROR_CREATING_TREE:int=27; 
      public static const ERROR_INTERNAL_GIVING_TREE:int=28; 
      public static const ERROR_LOADING_SETTINGS_MODULE:int=29; 
      public static const ERROR_CONNECTION_LOST:int=30;
      public static const ERROR_LOADING_NEIGHBOURS:int = 31; 
      public static const ERROR_LOADING_OUR_DROPZONE_TREE:int = 32; 
      public static const INFO_DELICIOUS_BOOKMARKS_LOADED_ROOT:int = 33; 
      public static const INFO_DELICIOUS_BOOKMARKS_LOADED_DROPZONE:int = 34; 
      public static const ERROR_SEARCHING_FOR_PEARLTREES_TREE:int = 35; 
      public static const ERROR_GETTING_AUTHENTIFICATION_ELEMENT:int = 36; 
      public static const ERROR_CONFIRMING_TWITTER_AUTHENTIFICATION:int = 37; 
      public static const ERROR_UPDATING_A_NOTE:int = 38;
      public static const ERROR_SYNCHRONIZING:int = 39;
      public static const ERROR_LOGGING_NO_COOKIES:int = 40; 
      public static const ERROR_LOADING_PRIVATE_MSG_CONTACTS:int = 41; 
      public static const ERROR_SETTING_AVATAR_HASH:int=42; 
      public static const ERROR_PRIVATE_MSG_CHECK:int = 43; 
      public static const ERROR_LOADING_NOVELTIES:int = 44; 
      
      public static function isInconsistentSaveError(msg:String):Boolean {
         return msg.lastIndexOf("InconsistentSyncInputException")>=0;
      } 
      public static function isNotLoggedUserException(msg:String):Boolean {
         return msg.lastIndexOf("UserNotLoggedException")>=0;
      }
   }
}
