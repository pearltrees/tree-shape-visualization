package com.broceliand.util.logging
{
   import mx.logging.LogEventLevel;
   import mx.logging.targets.LineFormattedTarget;

   public class LoggingParameters
   {
      private static var _initialized:Boolean = false;
      
      private static var _inMemoryLogger:InMemoryActionLogger= null;
      
      public static function init():void {
         if (!_initialized) {
            _initialized = true;
            initLogginParameters();
         }
      }
      
      public static function get inMemoryActionLogger():InMemoryActionLogger {
         return _inMemoryLogger;
      }
      
      private static function initLogginParameters():void {         
         var target:LineFormattedTarget = new BroFormattedTarget();

         target.level = LogEventLevel.INFO; 

         target.filters = new Array(
            "com.broceliand.ui.util.profiler",
            "com.broceliand.ui.screenwindow.*",
            "com.broceliand.ui.util*"
            
         );
         
         target.includeTime = true;
         target.includeCategory = true;
         Log.addTarget(target);
         addInMemoryLogger();
      }
      
      private static function addInMemoryLogger():void {    
         _inMemoryLogger = new InMemoryActionLogger();
         var target:LineFormattedTarget =  _inMemoryLogger;

         target.level = LogEventLevel.INFO;
         target.filters = new Array(
            "*"
         );

         target.includeTime = true;
         target.includeCategory = true;
         Log.addTarget(target);
      }
      
   }
}
