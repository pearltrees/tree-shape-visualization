package com.broceliand.pearlTree.navigation.impl {
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class ApplicationDisplayedPageModel extends EventDispatcher {
      
      public static const DISPLAYED_PAGE_CHANGE:String = "displayedPageChanged";
      
      public static const NO_PAGE_DEFINED:uint = 0;
      public static const SETTINGS_PAGE:uint = 1;
      public static const TUNNEL_PAGE:uint = 2;
      public static const GETTING_STARTED_PAGE:uint = 3;
      
      private var _pageDisplayed:uint = NO_PAGE_DEFINED;
      
      public function ApplicationDisplayedPageModel(target:IEventDispatcher=null)
      {
         super(target);
      }
      
      public function setPageDisplayedState(pageId:uint, isDisplayed:Boolean):void {
         if(!isDisplayed && pageId == _pageDisplayed) {
            _pageDisplayed = NO_PAGE_DEFINED;
            dispatchEvent(new Event(DISPLAYED_PAGE_CHANGE));
         }
         else if(isDisplayed && pageId != _pageDisplayed) {
            _pageDisplayed = pageId;
            dispatchEvent(new Event(DISPLAYED_PAGE_CHANGE));
         }
      }
      public function getPageDisplayed():uint {
         return _pageDisplayed;
      }
   }
}