package com.broceliand.ui.interactors.drag.action
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.extra.delegates.OnlineEditorsPanelDelegate;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.io.object.tree.OnlineEditorData;
   import com.broceliand.pearlTree.model.notification.OnlineEditor;
   import com.broceliand.pearlTree.model.notification.OnlineEditorsModel;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.model.INodeTitleModel;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.panel.MainPanel;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.util.GenericAction;
   
   import flash.utils.setTimeout;
   
   public class PearlTemporaryMessageDisplayer
   {
      private var _nodeTitleModel:INodeTitleModel;
      private var _node:IPTNode;
      private var _hasBeenCleared:Boolean = false;
      public function  PearlTemporaryMessageDisplayer(nodeTitleModel:INodeTitleModel, node:IPTNode) {
         _nodeTitleModel = nodeTitleModel;
         _node = node;
      }
      public function setTemporaryMessage(msgId:int):void {
         _nodeTitleModel.setNodeMessageType(_node, msgId);
         setTimeout(clearMessageOnNextEvent, 1000);
      }
      private function clearMessageOnNextEvent():void {
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         navModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, new GenericAction(null, this, clearMessage).performActionOnFirstEvent);
         setTimeout(clearMessage, 3000);
      }
      private function clearMessage():void {
         if (!_node.isEnded() && !_hasBeenCleared) {
            _hasBeenCleared = true;
            _nodeTitleModel.setNodeMessageType(_node, NodeTitleModel.NO_MESSAGE);
         }
      }
   }
}