package com.broceliand.util
{
   public interface IErrorReporter
   {
      function onError(errorType:int, ...context):void;      
      function onWarning(errorType:int, ...context):void;
      function onInfo(errorType:int, ...context):void;
      function set hasBlockerError(isBlock:Boolean):void;
      function get hasBlockerError ():Boolean;
   }
}