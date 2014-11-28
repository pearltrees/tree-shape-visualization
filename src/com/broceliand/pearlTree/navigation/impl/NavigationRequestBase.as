package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.pearlTree.navigation.NavigationEvent;

   internal class NavigationRequestBase 
   {
      protected var _event:NavigationEvent;
      protected var _navigator:NavigationManagerImpl;
      protected var _startTime:Number;
      protected var _navDesc:NavigationDescription;
      
      public function NavigationRequestBase(navDesc:NavigationDescription) {
         _navDesc = navDesc;
      }
      
      public function startProcessingRequest(navigator:NavigationManagerImpl, eventToPropagateWhenFinished:NavigationEvent):void {
         _event = eventToPropagateWhenFinished;
         _navigator = navigator;
         initEvent(_event);
      }
      protected function initEvent(event:NavigationEvent):void {
         event.newNavigationDescription = _navDesc;
      }
      
      public function onEndProcessing():void {
         _navigator.notifyNavigation(this, _event);
      }
      
      public function onNavigationForbidden():void {
         _navigator.notifyNavigationForbidden(this, _event);
      }
      
   }
}