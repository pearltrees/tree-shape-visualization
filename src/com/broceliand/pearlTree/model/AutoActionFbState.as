package com.broceliand.pearlTree.model
{
   public class AutoActionFbState
   {
      public static const DISABLED:int                            = 0;
      public static const ALL_NEW_PEARLS:int                      = 7;   
      public static const DISCOVERIES:int                         = 8;
      public static const ALL_NEW_PEARLS_AND_DISCOVERIES:int      = 15;
      
      public static function changeAutoActionFbState(oldState:int, actionType:int, isOn:Boolean):int {
         var result:int = oldState;
         if (isOn) {
            if (oldState != actionType && oldState != ALL_NEW_PEARLS_AND_DISCOVERIES) {
               result = oldState + actionType;
            }
         } else {
            if (oldState == actionType || oldState == ALL_NEW_PEARLS_AND_DISCOVERIES) {
               result = oldState - actionType;
            }
         }
         return result;
      }
      
      public static function isAutoActionEnabled(state:int, actionType:int):Boolean {
         if (state == ALL_NEW_PEARLS_AND_DISCOVERIES || state == actionType) {
            return true;
         }
         return false;
      }
   }
}