package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.EmbedManager;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.net.SharedObject;
   
   import mx.events.FlexEvent;
   
   public class ZoomModelPersistency
   {
      private static const DEFAULT_VISIBILITY:Boolean = true;
      
      private var _zoomModel:ZoomModel;
      private var _so:SharedObject;
      private var _zoomLevel:Object;
      private var _zoomVisible:Boolean = DEFAULT_VISIBILITY;
      
      public function ZoomModelPersistency(model:ZoomModel) {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(!am.isEmbed()) {
            model.addEventListener(FlexEvent.DATA_CHANGE, zoomChanged);
            _zoomModel = model;
            try {
               _so = SharedObject.getLocal("zoom");
               _zoomLevel = _so.data["zoomLevel2"];
               _zoomVisible = (_so.data["zoomVisible"] === undefined)?DEFAULT_VISIBILITY:_so.data["zoomVisible"] as Boolean;
            } catch (e:Error) {
            }
         }
         if (_zoomLevel== null) {
            _zoomLevel = ZoomModel.ZOOM_DEFAULT;
         }
      }
      
      public function get zoomValue():Number {
         return _zoomLevel as Number;
      }
      
      public function saveZoomValue(value:Number):void {

         if (_zoomLevel != value) {
            _zoomLevel = value;
            _so.data["zoomLevel2"] = _zoomLevel;
            try {
               _so.flush();
            } catch (e:Error) {
               Log.getLogger("com.broceliand.ui.model.ZoomModelPersistency").error("error saving zoom level {0}",e);
            }
         }
      }
      private function zoomChanged(event:Event):void {
         saveZoomValue(_zoomModel.zoomValue);
      }  
      
      public function saveVisibleValue(value:Boolean):void {
         if (_zoomVisible != value) {
            _zoomVisible = value;
            _so.data["zoomVisible"] = value;
            try {
               _so.flush();
            } catch (e:Error) {
            }
         }
      }
      public function getLoggedZoomVisibility():Boolean {
         return _zoomVisible;
      }
   }
}