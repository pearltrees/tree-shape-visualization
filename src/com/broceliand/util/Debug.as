package com.broceliand.util {
   import com.broceliand.util.DebugStackDepth;
   import com.broceliand.pearlTree.io.object.note.NotifData;
   import flash.utils.ByteArray;
   
   public class Debug {

      public static function pad(n:int, len:int) : String {
         var res:String = n.toString();
         while (res.length < len) {
            res = "0" + res;
         }
         return res;
      }
      
      public static function dateToString(date:Date):String
      {
         var dateString:String = ""
            + date.fullYear          + "-"
            + pad(date.month+1,2)           + "-"
            + pad(date.date,2)       + " "
            + pad(date.hours,2)      + ":"
            + pad(date.minutes,2)    + ":"
            + pad(date.seconds,2)    + "."
            + pad(date.milliseconds, 3)
            ;
         return dateString;
      }
      
      private static const _prefixStep:String = "  ";
      
      private static const NOFLAG:String = "";
      
      private static const BEGIN:String = "BEGIN";
      
      private static const END:String = "END";
      
      private static function prefix():String {
         var prefix:String = "";
         var i:int;
         var _stackDepth:int = DebugStackDepth.getInstance().get();
         for (i = 0; i < _stackDepth; i++) {
            prefix += _prefixStep;
         }
         return prefix;
      }
      
      private static function date(): String {
         var date:Date  = new Date();
         var str:String = dateToString(date);
         return str;
      }
      
      private static function isBeginStep(flag:String): Boolean {
         return (false
            || flag.toLowerCase() == BEGIN.toLowerCase()
            || false);
      }
      
      private static function isEndStep(flag:String): Boolean {
         return (false
            || flag.toLowerCase() == END.toLowerCase()
            || false);
      }
      
      private static function _T(msg:String, flag:String) : void {
         DebugStackDepth.getInstance().add(isBeginStep(flag));
         trace(date() + ": " + prefix() + msg);
         DebugStackDepth.getInstance().sub(isEndStep(flag));
      }
      
      public static function T(msg:String) : void {
         _T("    " + msg, NOFLAG);
      }
      
      public static function T0(msg:String) : void {
         _T("BEGIN: " + msg, BEGIN);
      }
      
      public static function T1(msg:String) : void {
         _T("..END: " + msg, END);
      }
      
      public static function dumpNotif(notif:NotifData, msg:String = ""):void {
         return;
         var prefix:String = "  ";
         T0(msg);
         if (notif.id)               T(prefix + "id: " + notif.id)
         if (notif.date)             T(prefix + "date: " + notif.date)
         if (notif.state)            T(prefix + "state: " + notif.state)
         if (notif.type)             T(prefix + "type: " + notif.type)
         if (notif.message)          T(prefix + "message: " + notif.message)
         if (notif.avatarHash)       T(prefix + "avatarHash: " + notif.avatarHash)
         if (notif.mainId)           T(prefix + "mainId: " + notif.mainId)
         if (notif.userId)           T(prefix + "userId: " + notif.userId)
         if (notif.assoId)           T(prefix + "assoId: " + notif.assoId)
         if (notif.treeId)           T(prefix + "treeId: " + notif.treeId)
         if (notif.pearlId)          T(prefix + "pearlId: " + notif.pearlId)
         if (notif.user2Id)          T(prefix + "user2Id: " + notif.user2Id)
         if (notif.asso2Id)          T(prefix + "asso2Id: " + notif.asso2Id)
         if (notif.navAssoId)        T(prefix + "navAssoId: " + notif.navAssoId)
         if (notif.navTreeId)        T(prefix + "navTreeId: " + notif.navTreeId)
         if (notif.navPearlId)       T(prefix + "navPearlId: " + notif.navPearlId)
         if (notif.navTeamRequestId) T(prefix + "navTeamRequestId: " + notif.navTeamRequestId)
         if (notif.navType)          T(prefix + "navType: " + notif.navType)
         if (notif.folded)           T(prefix + "folded: " + notif.folded)
         T1(msg)
      }
      
      private static function decimalToHex(n:int, len:int = 2) : String {
         var res:String = n.toString(16);
         while (res.length < len) {
            res = "0" + res;
         }
         return res;
      }
      
      public static function dumpByteArray(input:flash.utils.ByteArray) : String {
         if (input == null) return "";
         var res:String = "0x";
         var savePos:uint = input.position;
         var n:uint = input.bytesAvailable;
         var len:uint = input.length;
         var i:uint;
         input.position = 0;
         if (false) {
            T("dumpByteArray: n=" + n + " len=" + len);
            for (i=0; i<len; i++) {
               var val:uint   = input.readUnsignedByte();
               var hex:String = decimalToHex(val);
               T("dumpByteArray:   byte[" + i + "]=" + val + " hex[" + i + "]=" + hex);
            }
         }
         for (i=0; i<len; i++) {
            var val:uint   = input.readUnsignedByte();
            var hex:String = decimalToHex(val);
            res += hex;
         }
         input.position = savePos;
         return res;
      }

      public static function dumpNotifNavType(t: int): String{
         switch (t) {
            case 0: return "GENERIC";
            case 1: return "NOTE";
            case 2: return "TEAM_DISCUSSION";
            case 3: return "PRIVATE_MSG";
            case 4: return "TREE_EDITO";
            case 5: return "PICK";
            case 6: return "TEAM_CANDIDACY";
            default: return "???";
         }
      }

      public static function dumpNotifType(t: int): String{
         switch(t) {
            case 0: return "RESERVED_MARKER";
            case 1: return "NOTE";
            case 2: return "NOTE_REPLY";
            case 3: return "NOTE_DIRECT_REPLY";
            case 4: return "TEAM_DISCUSSION";
            case 5: return "PRIVATE_MSG";
            case 6: return "PRIVATE_MSG_ATTACHMENT";
            case 7: return "PRIVATE_MSG_INVITE";
            case 8: return "TREE_EDITO_CREATION";
            case 9: return "TREE_EDITO_UPDATE";
            case 10: return "TREE_EDITO_ALIAS_CREATION";
            case 11: return "TREE_EDITO_ALIAS_UPDATE";
            case 12: return "PICK";
            case 13: return "CROSSING";
            case 14: return "GENERIC_MESSAGE";
            case 15: return "TEAM_APPLICATION_TREE";
            case 16: return "TEAM_APPLICATION_TEAM";
            case 17: return "TEAM_APPLICATION_SUBTEAM";
            case 18: return "TEAM_INVITATION_USER";
            case 19: return "TEAM_INVITATION_TEAM";
            case 20: return "TEAM_APPLICATION_ACCEPT_INFO";
            case 21: return "TEAM_INVITATION_ACCEPTED";
            case 22: return "TEAM_INVITATION_ACCEPTED_TEAM";
            case 23: return "TEAM_APPLICATION_ACCEPTED";
            case 24: return "TEAM_APPLICATION_ACCEPTED_TEAM";
            case 25: return "TEAM_FREEZE_YOU";
            case 26: return "TEAM_FREEZE_OTHER";
            case 100: return "PLACEHOLDER_MORENOTIFICATIONS";
            default: return "???";
         }
      }
      
   }
}
