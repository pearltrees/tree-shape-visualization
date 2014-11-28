package com.broceliand.util
{
   import com.broceliand.pearlTree.model.ArchiveManager;
   
   public class ArchiveInfo
   {
      private var _url:String;
      private var _date:String;
      private var _mode:int;
      private var _pearlTitle:String;
      
      public function ArchiveInfo(urlValue:String, modeValue:int, dateValue:String, pearlTitle:String="") {
         _url = urlValue;
         _mode = modeValue;
         _date = dateValue;
         _pearlTitle = pearlTitle;
      }
      
      public function get url():String
      {
         return _url;
      }
      
      public function set url(value:String):void
      {
         _url = value;
      }
      
      public function get date():String
      {
         return _date;
      }
      
      public function set date(value:String):void
      {
         _date = value;
      }
      
      public function get mode():int
      {
         return _mode;
      }
      
      public function set mode(value:int):void
      {
         _mode = value;
      }
      
      public function get pearlTitle():String
      {
         return _pearlTitle;
      }
      
      public function set pearlTitle(value:String):void
      {
         _pearlTitle = value;
      }

   }
}