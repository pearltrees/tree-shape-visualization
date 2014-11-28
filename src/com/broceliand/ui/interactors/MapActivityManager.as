package com.broceliand.ui.interactors
{
   import com.broceliand.player.IPearlTreePlayer;
   import com.broceliand.player.PlayerModuleLoader;
   import com.broceliand.ui.screenwindow.IScreenLine;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   
   public class MapActivityManager
   {
      private var _map:IActive;
      private var _player:IPearlTreePlayer;
      private var _screenLine:IScreenLine;
      
      public function MapActivityManager()
      {
      }
      
      public function set map(value:IActive):void {
         _map = value;
      }
      
      public function set player(player:IPearlTreePlayer):void {
         if (player != _player) {
            if (_player) {
               _player.removeEventListener(PlayerModuleLoader.DISPLAY_CHANGED_EVENT, onDisplayChangedEvent);
            }
            _player = player;
            onDisplayChangedEvent(null);
            if (_player) {
               _player.addEventListener(PlayerModuleLoader.DISPLAY_CHANGED_EVENT, onDisplayChangedEvent);
            }
         }
      }

      public function set screenLine(screenLine:IScreenLine):void {
         if (screenLine != _screenLine) {
            if (_screenLine) {
               _screenLine.addOrRemoveDisplayEventListener(onDisplayChangedEvent, true, true);
            }
            _screenLine= screenLine;
            onDisplayChangedEvent(null);
            if (_screenLine) {
               _screenLine.addOrRemoveDisplayEventListener(onDisplayChangedEvent, true, false);
            }
         }
      }

      private function onDisplayChangedEvent(event:Event):void{
         var shouldBeActive:Boolean = true;
         if (_player && !_player.isHidden()) {
            shouldBeActive = false;
         }
         if (_screenLine && _screenLine.isScreenLineViewVisible()) {
            shouldBeActive = false;
         }
         if (_map) {
            _map.setActive(shouldBeActive);
         }
      }

   }
}