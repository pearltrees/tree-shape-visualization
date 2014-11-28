package com.broceliand.ui.assemblerinfotip
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.model.SelectionModel;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class PTInfotipManager extends EventDispatcher implements IPTInfotipManager {
      
      private static const SHOW_DELAY:Number = 35;
      
      public static const INFOTIP_CHANGED_EVENT:String = "InfotipChanged";
      
      private var _currentMessage:uint;
      private var _currentComponent:uint;
      private var _currentNode:IPTNode;
      private var _timer:uint;
      
      public function PTInfotipManager() {
         _currentMessage = PTInfotipMessage.INFOTIP_MESSAGE_NONE;
         _timer = 0;
         
      }
      
      public function clearMessage():void {
         if (_timer != 0) {
            clearTimeout(_timer);
         }
         if (_currentMessage != PTInfotipMessage.INFOTIP_MESSAGE_NONE) {
            _currentMessage = PTInfotipMessage.INFOTIP_MESSAGE_NONE;
            dispatchChangeEvent();
         }
      }
      
      public function enterPearlWithNews(node:IPTNode):void {
         enterComponent(PTInfotipType.INFOTIP_TYPE_PEARLWITHNEWS, node);
      }
      
      public function exitPearlWithNews():void {
         exitComponent(PTInfotipType.INFOTIP_TYPE_PEARLWITHNEWS);
      }
      
      public function enterNextNewsButton(node:IPTNode):void {
         enterComponent(PTInfotipType.INFOTIP_TYPE_NEXTNEWSBUTTON, node);
      }
      
      public function exitNextNewsButton():void {
         exitComponent(PTInfotipType.INFOTIP_TYPE_NEXTNEWSBUTTON);
      }
      
      public function get currentMessage():uint {
         return _currentMessage;
      }
      
      private function enterComponent(component:uint, node:IPTNode):void {
         if (_timer != 0) {
            clearTimeout(_timer);
         }
         _currentComponent = component;
         _currentNode = node;
         _timer = setTimeout(showMessageAfterDelay, SHOW_DELAY);
      }
      
      private function exitComponent(component:uint):void {
         if (component != _currentComponent) {
            return;
         }
         clearMessage();
      }
      
      private function showMessageAfterDelay():void {
         _timer = 0;
         var _newMessage:uint;
         if (_currentComponent == PTInfotipType.INFOTIP_TYPE_PEARLWITHNEWS) {
            _newMessage = PTInfotipMessage.INFOTIP_MESSAGE_PEARLWITHNEWS;
         }
         else if (_currentComponent == PTInfotipType.INFOTIP_TYPE_NEXTNEWSBUTTON) {
            _newMessage = PTInfotipMessage.INFOTIP_MESSAGE_NEXTNEWSBUTTON;
         }
         if (_newMessage != _currentMessage) {
            _currentMessage = _newMessage;
            var selectionModel:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
            if (selectionModel.getSelectedNode() != _currentNode) {
               
               if (ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.updateSelectionOnOver) {
                  selectionModel.selectNode(_currentNode);
               } else {
                  return;
               }
            }
            dispatchChangeEvent();
         }
         
      }
      
      private function dispatchChangeEvent():void {
         dispatchEvent(new Event(INFOTIP_CHANGED_EVENT));
      }
      
   }
}