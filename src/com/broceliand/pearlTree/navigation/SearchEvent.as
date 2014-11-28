package com.broceliand.pearlTree.navigation
{
   import com.broceliand.pearlTree.model.discover.SpatialTree;
   
   import flash.events.Event;
   
   public class SearchEvent extends Event
   {
      public static const SEARCH_EVENT:String  = "SearchEvent";
      public static const SEARCH_EVENT_ERROR:String  = "SearchErrorEvent";
      private var _keyword:String;
      private var _resultCount:int;
      private var _hasMoreResult:Boolean;
      private var _searchPeople:Boolean;
      private var _spatialTreeList:Vector.<SpatialTree>;
      private var _searchUserId:Number;
      
      public function SearchEvent(keyword:String, resultCount:int, hasMore:Boolean, searchUserId:Number, searchPeople:Boolean, spatialTreeList:Vector.<SpatialTree>=null, isError:Boolean = false)
      {
         super(isError?SEARCH_EVENT_ERROR:SEARCH_EVENT);
         _keyword = keyword;
         _resultCount = resultCount;
         _hasMoreResult = hasMore;
         _searchPeople = searchPeople;
         _spatialTreeList = spatialTreeList;
         _searchUserId = searchUserId;
      }
      public function get resultCount ():int
      {
         return _resultCount;
      }
      public function get hasMoreResult ():Boolean
      {
         return _hasMoreResult;
      }
      public function get keyword ():String
      {
         return _keyword;
      }
      public function get isPeopleSearched():Boolean {
         return _searchPeople;
      }
      public function get spatialTreeList():Vector.<SpatialTree> {
         return _spatialTreeList;
      }
      
      public function get searchUserId():Number {
         return _searchUserId;
      }
   }
}