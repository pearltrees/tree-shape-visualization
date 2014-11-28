package com.broceliand.util.logging
{
   import com.broceliand.util.BroLocale;
   
   public class LogAction {
      private var _date:Date;
      private var _actionName:String;
      private var _args:Array;
      
      private var _category:String;
      
      public function LogAction(actionName:String, args:Array, category:String=null) {
         _category = category;
         _date = new Date();
         _actionName = actionName;
         _args = args;
         if (_args) {
            for (var i:int = 0; i<_args.length ; i++) {
               
               if (_args[i]!= null && !(args[i] is Number)) {
                  _args[i] = _args[i].toString();
               }
            }
         }
      }
      public function toString():String {
         return BroLocale.formatMessage(_actionName, _args);
      }
      public function get date():Date {
         return _date;
      }
      public function get category ():String
      {
         return _category;
      }
      
   }
}
