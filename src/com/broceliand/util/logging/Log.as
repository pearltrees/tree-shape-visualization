package com.broceliand.util.logging
{
   import com.broceliand.pearlTree.model.notification.NotifPublicType;
   import com.broceliand.pearlTree.model.notification.NotifState;
   import com.broceliand.pearlTree.model.notification.NotifType;
   import com.broceliand.pearlTree.model.team.TeamRequest;
   import com.broceliand.pearlTree.model.team.TeamRequestState;
   import com.broceliand.pearlTree.model.team.TeamRequestType;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.util.Assert;
   import com.broceliand.util.error.ErrorConst;
   
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   import mx.logging.ILogger;
   import mx.logging.ILoggingTarget;
   import mx.logging.LogEventLevel;
   import mx.logging.errors.InvalidCategoryError;
   
   public class Log
   {
      private static var NONE:int = int.MAX_VALUE;
      private static var _targetLevel:int = NONE;
      private static var _loggers:Array;
      private static var _targets:Array = [];

      public static function isFatal():Boolean
      {
         return (_targetLevel <= LogEventLevel.FATAL) ? true : false;
      }
      
      public static function isError():Boolean
      {
         return (_targetLevel <= LogEventLevel.ERROR) ? true : false;
      }

      public static function isWarn():Boolean
      {
         return (_targetLevel <= LogEventLevel.WARN) ? true : false;
      }

      public static function isInfo():Boolean
      {
         return (_targetLevel <= LogEventLevel.INFO) ? true : false;
      }
      
      public static function isDebug():Boolean
      {
         return (_targetLevel <= LogEventLevel.DEBUG) ? true : false;
      }
      
      public static function addTarget(target:ILoggingTarget):void
      {
         if (target)
         {
            var filters:Array = target.filters;
            var logger:ILogger;

            for (var i:String in _loggers)
            {
               if (categoryMatchInFilterList(i, filters))
                  target.addLogger(ILogger(_loggers[i]));
            }

            _targets.push(target);
            
            if (_targetLevel == NONE)
               _targetLevel = target.level
            else if (target.level < _targetLevel)
               _targetLevel = target.level;
         }
         else
         {
            var message:String = "invalidTarget";
            throw new ArgumentError(message);
         }
      }
      
      public static function removeTarget(target:ILoggingTarget):void
      {
         if (target)
         {
            var filters:Array = target.filters;
            var logger:ILogger;
            
            for (var i:String in _loggers)
            {
               if (categoryMatchInFilterList(i, filters))
               {
                  target.removeLogger(ILogger(_loggers[i]));
               }                
            }
            
            for (var j:int = 0; j<_targets.length; j++)
            {
               if (target == _targets[j])
               {
                  _targets.splice(j, 1);
                  j--;
               }
            }
            resetTargetLevel();
         }
         else
         {
            var message:String = "invalidTarget"
            throw new ArgumentError(message);
         }
      }
      
      public static function getClassLogger(object:Object):BroLogger {
         return getLogger(getQualifiedClassName(object).replace(/::/g, "."));
      }
      public static function getLogger(category:String):BroLogger
      {
         checkCategory(category);
         if (!_loggers)
            _loggers = [];

         var result:BroLogger= _loggers[category];
         if (result == null)
         {
            result = new BroLogger(category);
            _loggers[category] = result;
         }

         var target:ILoggingTarget;
         for (var i:int = 0; i < _targets.length; i++)
         {
            target = ILoggingTarget(_targets[i]);
            if (categoryMatchInFilterList(category, target.filters))
               target.addLogger(result);
         }
         
         return result;
      }
      
      public static function flush():void
      {
         _loggers = [];
         _targets = [];
         _targetLevel = NONE;
      }
      
      public static function hasIllegalCharacters(value:String):Boolean
      {
         return value.search(/[\[\]\~\$\^\&\\(\)\{\}\+\?\/=`!@#%,:;'"<>\s]/) != -1;
      }

      private static function categoryMatchInFilterList(category:String, filters:Array):Boolean
      {
         var filter:String;
         var index:int = -1;
         for (var i:uint = 0; i < filters.length; i++)
         {
            filter = filters[i];

            index = filter.indexOf("*");
            
            if (index == 0)
               return true;
            
            index = index < 0 ? index = category.length : index -1;
            
            if (category.substring(0, index) == filter.substring(0, index))
               return true;
         }
         return false;
      }
      
      private static function checkCategory(category:String):void
      {
         var message:String;
         
         if (category == null || category.length == 0)
         {
            message = "invalidLen";
            throw new InvalidCategoryError(message);
         }
         
         if (hasIllegalCharacters(category) || (category.indexOf("*") != -1))
         {
            message = "invalidChars";
            throw new InvalidCategoryError(message);
         }
      }
      
      private static function resetTargetLevel():void
      {
         var minLevel:int = NONE;
         for (var i:int = 0; i < _targets.length; i++)
         {
            if (minLevel == NONE || _targets[i].level < minLevel)
               minLevel = _targets[i].level;
         }
         _targetLevel = minLevel;
      }
      
      private static function pad(n:int, len:int) : String {
         var res:String = n.toString();
         while (res.length < len) {
            res = "0" + res;
         }
         return res;
      }
      
      public static function dateToString(date:Date, includeMilliSeconds : Boolean = true):String
      {
         var dateString:String = ""
            + date.fullYear          + "-"
            + pad(date.month+1,2)    + "-"
            + pad(date.date,2)       + " "
            + pad(date.hours,2)      + ":"
            + pad(date.minutes,2)    + ":"
            + pad(date.seconds,2);
         if (includeMilliSeconds) {
            dateString += "." + pad(date.milliseconds, 3);
         }
         return dateString;
      }
      
      private static function date(): String {
         var date:Date  = new Date();
         var str:String = dateToString(date);
         return str;
      }
      
      public static function debug(msg:String, prefix:String = "") : void {
         trace(date() + ": " + prefix + msg);
      }
      
      private static function decimalToHex(n:int, len:int = 2) : String {
         var res:String = n.toString(16);
         while (res.length < len) {
            res = "0" + res;
         }
         return res;
      }
      
      public static function dumpTeamRequest(teamRequest : TeamRequest) : void {
         debug("Dumping teamRequest...");
         debug("             requestId: "   + teamRequest.requestId);
         debug("               aliasId: "   + teamRequest.aliasId);
         debug("     aliasParentTreeId: "   + teamRequest.aliasParentTreeId);
         debug("             guestAsso: "   + teamRequest.guestAsso);
         debug("              hostAsso: "   + teamRequest.hostAsso);
         debug("             guestUser: "   + teamRequest.guestUser);
         debug("              hostUser: "   + teamRequest.hostUser);
         debug("          targetTreeId: "   + teamRequest.targetTreeId);
         debug("       targetTreeTitle: "   + teamRequest.targetTreeTitle);
         debug("                 state: "   + TeamRequestStateName(teamRequest.state));
         debug("              realType: "   + TeamRequestTypeName(teamRequest.realType));
         debug("                  type: "   + TeamRequestTypeName(teamRequest.type));
         debug("       lastStateChange: "   + teamRequest.lastStateChange);
         debug("               message: \"" + teamRequest.message + "\"");
         debug(" isRequestCreatingTeam: "   + teamRequest.isRequestCreatingTeam);
         debug("         lastErrorCode: "   + ErrorConstName(teamRequest.lastErrorCode));
         debug("            notifState: "   + NotifStateName(teamRequest.notifState));
      }
      
      public static function dumpByteArray(input:flash.utils.ByteArray) : String {
         if (input == null) return "";
         var res:String = "0x";
         var savePos:uint = input.position;
         var n:uint = input.bytesAvailable;
         var len:uint = input.length;
         var i:uint;
         input.position = 0;
         for (i=0; i<len; i++) {
            var val:uint   = input.readUnsignedByte();
            var hex:String = decimalToHex(val);
            res += hex;
         }
         input.position = savePos;
         return res;
      }
      
      public static function ErrorConstName(t: int): String {
         switch(t) {
            case ErrorConst.INTERNAL_ERROR:                            return "INTERNAL_ERROR";
            case ErrorConst.ERROR_LOADING_USER_HIERARCHY:              return "ERROR_LOADING_USER_HIERARCHY";
            case ErrorConst.ERROR_LOADING_PEARLTREES_NEIGHBOUR:        return "ERROR_LOADING_PEARLTREES_NEIGHBOUR";
            case ErrorConst.ERROR_UPLOADING:                           return "ERROR_UPLOADING";
            case ErrorConst.ERROR_SAVING_SETTINGS:                     return "ERROR_SAVING_SETTINGS";
            case ErrorConst.ERROR_CREATING_ACCOUNT:                    return "ERROR_CREATING_ACCOUNT";
            case ErrorConst.ERROR_ADDING_A_FRIEND:                     return "ERROR_ADDING_A_FRIEND";
            case ErrorConst.ERROR_INVITE_A_FRIEND:                     return "ERROR_INVITE_A_FRIEND";
            case ErrorConst.ERROR_LOADING_TREE_TO_MERGE:               return "ERROR_LOADING_TREE_TO_MERGE";
            case ErrorConst.ERROR_UPDATING_TREE:                       return "ERROR_UPDATING_TREE";
            case ErrorConst.ERROR_LOADING_DELETED_TREE:                return "ERROR_LOADING_DELETED_TREE";
            case ErrorConst.ERROR_LOADING_UNKNOWN_TREE:                return "ERROR_LOADING_UNKNOWN_TREE";
            case ErrorConst.ERROR_LOADING_TREE:                        return "ERROR_LOADING_TREE";
            case ErrorConst.ERROR_SAVING_TREE:                         return "ERROR_SAVING_TREE";
            case ErrorConst.ERROR_WRONG_LOGIN:                         return "ERROR_WRONG_LOGIN";
            case ErrorConst.ERROR_PEARL_SENT:                          return "ERROR_PEARL_SENT";
            case ErrorConst.ERROR_SAVING_A_NOTE:                       return "ERROR_SAVING_A_NOTE";
            case ErrorConst.ERROR_DELETING_A_NOTE:                     return "ERROR_DELETING_A_NOTE";
            case ErrorConst.ERROR_VALIDATING_NOTIFICATION:             return "ERROR_VALIDATING_NOTIFICATION";
            case ErrorConst.ERROR_LOADING_NOTES:                       return "ERROR_LOADING_NOTES";
            case ErrorConst.ERROR_TREE_NOT_IN_HIERARCHY:               return "ERROR_TREE_NOT_IN_HIERARCHY";
            case ErrorConst.ERROR_BAD_INITIAL_URL:                     return "ERROR_BAD_INITIAL_URL";
            case ErrorConst.ERROR_SEND_LOST_PASSWORD_EMAIL:            return "ERROR_SEND_LOST_PASSWORD_EMAIL";
            case ErrorConst.ERROR_LOADING_USER_HISTORY:                return "ERROR_LOADING_USER_HISTORY";
            case ErrorConst.ERROR_LOADING_USER:                        return "ERROR_LOADING_USER";
            case ErrorConst.ERROR_SAVING_NOTE_MODE:                    return "ERROR_SAVING_NOTE_MODE";
            case ErrorConst.ERROR_CREATING_TREE:                       return "ERROR_CREATING_TREE";
            case ErrorConst.ERROR_INTERNAL_GIVING_TREE:                return "ERROR_INTERNAL_GIVING_TREE";
            case ErrorConst.ERROR_LOADING_SETTINGS_MODULE:             return "ERROR_LOADING_SETTINGS_MODULE";
            case ErrorConst.ERROR_CONNECTION_LOST:                     return "ERROR_CONNECTION_LOST";
            case ErrorConst.ERROR_LOADING_NEIGHBOURS:                  return "ERROR_LOADING_NEIGHBOURS";
            case ErrorConst.ERROR_LOADING_OUR_DROPZONE_TREE:           return "ERROR_LOADING_OUR_DROPZONE_TREE";
            case ErrorConst.INFO_DELICIOUS_BOOKMARKS_LOADED_ROOT:      return "INFO_DELICIOUS_BOOKMARKS_LOADED_ROOT";
            case ErrorConst.INFO_DELICIOUS_BOOKMARKS_LOADED_DROPZONE:  return "INFO_DELICIOUS_BOOKMARKS_LOADED_DROPZONE";
            case ErrorConst.ERROR_SEARCHING_FOR_PEARLTREES_TREE:       return "ERROR_SEARCHING_FOR_PEARLTREES_TREE";
            case ErrorConst.ERROR_GETTING_AUTHENTIFICATION_ELEMENT:    return "ERROR_GETTING_AUTHENTIFICATION_ELEMENT";
            case ErrorConst.ERROR_CONFIRMING_TWITTER_AUTHENTIFICATION: return "ERROR_CONFIRMING_TWITTER_AUTHENTIFICATION";
            case ErrorConst.ERROR_UPDATING_A_NOTE:                     return "ERROR_UPDATING_A_NOTE";
            case ErrorConst.ERROR_SYNCHRONIZING:                       return "ERROR_SYNCHRONIZING";
            case ErrorConst.ERROR_LOGGING_NO_COOKIES:                  return "ERROR_LOGGING_NO_COOKIES";
            case ErrorConst.ERROR_LOADING_PRIVATE_MSG_CONTACTS:        return "ERROR_LOADING_PRIVATE_MSG_CONTACTS";
            case ErrorConst.ERROR_SETTING_AVATAR_HASH:                 return "ERROR_SETTING_AVATAR_HASH";
            case ErrorConst.ERROR_PRIVATE_MSG_CHECK:                   return "ERROR_PRIVATE_MSG_CHECK";
            default:                                                   return "???";
         }
         
      }
      
      public static function TeamRequestStateName(t: int): String {
         switch(t) {
            case TeamRequestState.NOT_SENT:       return "NOT_SENT";
            case TeamRequestState.PENDING:        return "PENDING";
            case TeamRequestState.CANCELED:       return "CANCELED";
            case TeamRequestState.CONFIRMED:      return "CANCELED";
            case TeamRequestState.REFUSED:        return "REFUSED";
            case TeamRequestState.FROZEN_UNSEEN:  return "FROZEN_UNSEEN";
            case TeamRequestState.FROZEN_SEEN:    return "FROZEN_SEEN";
            default:                              return "???";
         }
         
      }
      
      public static function TeamRequestTypeName(t: int): String {
         switch(t) {
            case TeamRequestType.INVITATION:                 return "INVITATION";
            case TeamRequestType.CANDIDACY:                  return "CANDIDACY";
            case TeamRequestType.MIXED:                      return "MIXED";
            case TeamRequestType.UNFOLLOWED_INVITATION:      return "MIXED";
            default:                                         return "???";
         }
         
      }

      public static function NotifStateName(t: int): String {
         switch (t) {
            case NotifState.UNREAD: return "UNREAD";
            case NotifState.READ:   return "READ";
            default:                return "???";
         }
         
      }
      
      public static function NotifBoolName(t: Boolean): String {
         switch (t) {
            case true:  return "TRUE";
            case false: return "false";
            default:    return "???";
         }
      }
      
      public static function NotifClickName(t: Boolean): String {
         switch (t) {
            case true: return "CLICKED";
            case false: return "unclicked";
            default: return "_null_";
         }
         return "NotifClickName: Unknown type " + t;
         
      }

      public static function NotifPublicTypeName(t: int): String {
         switch (t) {
            case NotifPublicType.GENERIC:                        return "GENERIC";                         
            case NotifPublicType.NOTE:                           return "NOTE";                            
            case NotifPublicType.TEAM_DISCUSSION:                return "TEAM_DISCUSSION";                 
            case NotifPublicType.PRIVATE_MSG:                    return "PRIVATE_MSG";                     
            case NotifPublicType.PRIVATE_MSG_ATTACHMENT:         return "PRIVATE_MSG_ATTACHMENT";          
            case NotifPublicType.PRIVATE_MSG_INVITE:             return "PRIVATE_MSG_INVITE";              
            case NotifPublicType.TREE_EDITO:                     return "TREE_EDITO";                      
            case NotifPublicType.PICK:                           return "PICK";                            
            case NotifPublicType.TEAM_APPLICATION:               return "TEAM_APPLICATION";                
            case NotifPublicType.FREEZE_OTHER:                   return "FREEZE_OTHER";                    
            case NotifPublicType.TEAM_INVITATION:                return "TEAM_INVITATION";                 
            case NotifPublicType.TEAM_APPLICATION_ACCEPTED:      return "TEAM_APPLICATION_ACCEPTED";       
            case NotifPublicType.TEAM_APPLICATION_ACCEPTED_INFO: return "TEAM_APPLICATION_ACCEPTED_INFO";  
            case NotifPublicType.TEAM_INVITATION_ACCEPTED:       return "TEAM_APPLICATION_ACCEPTED";       
            case NotifPublicType.TEAM_APPLICATION_REFUSED_INFO:  return "TEAM_APPLICATION_REFUSED_INFO";   
            case NotifPublicType.TEAM_INVITE_EXTERNAL:           return "TEAM_INVITE_EXTERNAL";            
            default:                                             return "NotifPublicTypeTypeName: Unknown type " + t; 
         }
         
      }

      public static function NotifTypeName(t: int): String {
         switch(t) {
            case NotifType.RESERVED_MARKER:                return "RESERVED_MARKER";                 
            case NotifType.NOTE:                           return "NOTE";                            
            case NotifType.NOTE_ALIAS:                     return "NOTE_ALIAS";                      
            case NotifType.NOTE_REPLY:                     return "NOTE_REPLY";                      
            case NotifType.NOTE_DIRECT_REPLY:              return "NOTE_DIRECT_REPLY";               
            case NotifType.TEAM_DISCUSSION:                return "TEAM_DISCUSSION";                 
            case NotifType.PRIVATE_MSG:                    return "PRIVATE_MSG";                     
            case NotifType.PRIVATE_MSG_ATTACHMENT:         return "PRIVATE_MSG_ATTACHMENT";          
            case NotifType.PRIVATE_MSG_INVITE:             return "PRIVATE_MSG_INVITE";              
            case NotifType.TREE_EDITO_CREATION:            return "TREE_EDITO_CREATION";             
            case NotifType.TREE_EDITO_UPDATE:              return "TREE_EDITO_UPDATE";               
            case NotifType.TREE_EDITO_ALIAS_CREATION:      return "TREE_EDITO_ALIAS_CREATION";       
            case NotifType.TREE_EDITO_ALIAS_UPDATE:        return "TREE_EDITO_ALIAS_UPDATE";         
            case NotifType.PICK:                           return "PICK";                            
            case NotifType.CROSSING:                       return "CROSSING";                        
            case NotifType.GENERIC_MESSAGE:                return "GENERIC_MESSAGE";                 
            case NotifType.TEAM_APPLICATION_TREE:          return "TEAM_APPLICATION_TREE";           
            case NotifType.TEAM_APPLICATION_TEAM:          return "TEAM_APPLICATION_TEAM";           
            case NotifType.TEAM_APPLICATION_SUBTEAM:       return "TEAM_APPLICATION_SUBTEAM";        
            case NotifType.TEAM_INVITATION_USER:           return "TEAM_INVITATION_USER";            
            case NotifType.TEAM_INVITATION_TEAM:           return "TEAM_INVITATION_TEAM";            
            case NotifType.TEAM_APPLICATION_ACCEPT_INFO:   return "TEAM_APPLICATION_ACCEPT_INFO";    
            case NotifType.TEAM_INVITATION_ACCEPTED:       return "TEAM_INVITATION_ACCEPTED";        
            case NotifType.TEAM_INVITATION_ACCEPTED_TEAM:  return "TEAM_INVITATION_ACCEPTED_TEAM";   
            case NotifType.TEAM_APPLICATION_ACCEPTED:      return "TEAM_APPLICATION_ACCEPTED";       
            case NotifType.TEAM_APPLICATION_ACCEPTED_TEAM: return "TEAM_APPLICATION_ACCEPTED_TEAM";  
            case NotifType.TEAM_FREEZE_YOU:                return "TEAM_FREEZE_YOU";                 
            case NotifType.TEAM_FREEZE_OTHER:              return "TEAM_FREEZE_OTHER";               
            case NotifType.TEAM_APPLICATION_REFUSED_INFO:  return "TEAM_APPLICATION_REFUSED_INFO";   
            case NotifType.TEAM_INVITATION_EXTERNAL:       return "TEAM_INVITATION_EXTERNAL";        
            case NotifType.PAGE_PEARL_PICK:                return "PAGE_PEARL_PICK";                 
            case NotifType.PRIVATE_MSG_FRIEND_ARRIVAL_EXTERNAL: return "PRIVATE_MSG_FRIEND_ARRIVAL_EXTERNAL"; 
            case NotifType.PRIVATE_MSG_SEE_PRIVATE:        return "PRIVATE_MSG_SEE_PRIVATE";         
            case NotifType.TEAM_INVITATION_USER_PRIVATE:   return "TEAM_INVITATION_USER_PRIVATE";    
            case NotifType.NOTE_CROSS:                     return "NOTE_CROSS";                      
            case NotifType.IMPORT_DONE:                    return "IMPORT_DONE";                     
            case NotifType.PREMIUM_MESSAGE:                return "PREMIUM_MESSAGE";                 
               
         }
         return "NotifTypeName: Unknown type " + t;
         
      }
      
      public static function PWModelConstName(t : uint) : String {
         switch(t) {
            case PWModel.NO_PANEL:                    return "NO_PANEL";
            case PWModel.CONTENT_PANEL:               return "CONTENT_PANEL";
            case PWModel.CROSS_PANEL:                 return "CROSS_PANEL";
            case PWModel.CONNECTION_PANEL:            return "CONNECTION_PANEL"; 
            case PWModel.NOTE_PANEL:                  return "NOTE_PANEL";
            case PWModel.SHARE_PANEL:                 return "SHARE_PANEL";
            case PWModel.HELP_EMPTY_PANEL:            return "HELP_EMPTY_PANEL";

            case PWModel.MOVE_PANEL:                  return "MOVE_PANEL";
            case PWModel.MOVE_PRIVATE_PANEL:          return "MOVE_PRIVATE_PANEL";
            case PWModel.COPY_PANEL:                  return "COPY_PANEL";
            case PWModel.PICK_PANEL:                  return "PICK_PANEL";
            case PWModel.TREE_EDITO_PANEL:            return "TREE_EDITO_PANEL";
            case PWModel.CUSTOMIZATION_AVATAR_PANEL:  return "CUSTOMIZATION_AVATAR_PANEL";
            case PWModel.CUSTOMIZATION_LOGO_PANEL:    return "CUSTOMIZATION_LOGO_PANEL";
            case PWModel.AUTHOR_PANEL:                return "AUTHOR_PANEL";
            case PWModel.TEAM_CANDIDACY_LOGGED_PANEL: return "TEAM_CANDIDACY_LOGGED_PANEL";
            case PWModel.TEAM_ACCEPT_CANDIDACY_PANEL: return "TEAM_ACCEPT_CANDIDACY_PANEL";
            case PWModel.TEAM_SHARING_POINT_PANEL:    return "TEAM_SHARING_POINT_PANEL";
            case PWModel.CREATE_ACCOUNT_PANEL:        return "CREATE_ACCOUNT_PANEL";
            case PWModel.TEAM_INFO_PANEL:             return "TEAM_INFO_PANEL";
            case PWModel.TEAM_LIST_PANEL:             return "TEAM_LIST_PANEL";
            case PWModel.TEAM_HISTORY_PANEL:          return "TEAM_HISTORY_PANEL";
            case PWModel.TEAM_DISCUSSION_PANEL:       return "TEAM_DISCUSSION_PANEL";
            case PWModel.REORGANISATION_PANEL:        return "REORGANISATION_PANEL";
            case PWModel.LIST_PRIVATE_MSG_PANEL:      return "LIST_PRIVATE_MSG_PANEL";
            case PWModel.SEND_PRIVATE_MSG_PANEL:      return "SEND_PRIVATE_MSG_PANEL";
            case PWModel.TEAM_FREEZE_MEMBER_PANEL:    return "TEAM_FREEZE_MEMBER_PANEL";
            case PWModel.TEAM_NOTIFICATION_PANEL:     return "TEAM_NOTIFICATION_PANEL";
               /*case PWModel.MAKE_PRIVATE_PANEL:          return "MAKE_PRIVATE_PANEL";
               case PWModel.MOVE_PUBLIC_PANEL:           return "MOVE_PUBLIC_PANEL";*/
         }
         return "PWModelConstName: Unknown type " + t;
         
      }
      
      public static function WindowControllerConstName(t : uint) : String {
         switch(t) {
            case WindowController.NO_WINDOW:                return "NO_WINDOW";
            case WindowController.PEARL_WINDOW:             return "PEARL_WINDOW";
            case WindowController.SOCIAL_SYNC_WINDOW:       return "SOCIAL_SYNC_WINDOW";
            case WindowController.IMPORT_WINDOW:            return "IMPORT_WINDOW";
            case WindowController.ERROR_WINDOW:             return "ERROR_WINDOW";
            case WindowController.INVITE_WINDOW:            return "INVITE_WINDOW";
            case WindowController.PEARL_URL_WINDOW:         return "PEARL_URL_WINDOW";
            case WindowController.NEW_PEARLTREE_WINDOW:     return "NEW_PEARLTREE_WINDOW";
            case WindowController.NOTIF_PANEL_WINDOW:       return "NOTIF_PANEL_WINDOW";
            case WindowController.SETTINGS_PANEL_WINDOW:    return "NAVIGATION_PANEL_WINDOW";
            case WindowController.UPDATE_ADDON_WINDOW:      return "UPDATE_ADDON_WINDOW";
            case WindowController.STARTUP_MESSAGE_WINDOW:   return "STARTUP_MESSAGE_WINDOW";
            case WindowController.SEARCH_MODE_PANEL_WINDOW: return "SEARCH_MODE_PANEL_WINDOW";
               
            case WindowController.NOVELTY_FEED_WINDOW:      return "NOVELTY_FEED_WINDOW";
            case WindowController.INFO_PANEL_WINDOW:        return "INFO_PANEL_WINDOW";
            case WindowController.DELETION_RECOVERY_WINDOW: return "DELETION_RECOVERY_WINDOW";
            case WindowController.EVENT_PROMO_WINDOW:       return "EVENT_PROMO_WINDOW";
            case WindowController.CLEAR_DROPZONE_WINDOW:    return "CLEAR_DROPZONE_WINDOW";

            case WindowController.BIG_ACTION_WINDOW:    return "BIG_ACTION_WINDOW";
         }
         return "WindowControllerConstName: Unknown type " + t;
         
      }

      public static function hashToString(o:Object) : String {
         var res      : String = "";
         var firstKey : Boolean = true;
         for (var k:String in o) {
            if (!firstKey) res += ", ";
            res += k + ":" + o[k]
            firstKey = false;
         }
         res = "{" + res + "}";
         return res;
      }
   }
}
