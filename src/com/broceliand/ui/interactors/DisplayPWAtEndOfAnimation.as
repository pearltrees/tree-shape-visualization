package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.impl.NavigationManagerImpl;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.window.ui.WindowSlowEffectManager;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.setTimeout;
   
   public class DisplayPWAtEndOfAnimation implements IAction
   {
      
      private var _node:IPTNode
      private var _selectedPanel:uint;
      private var _playOpenEffect:Boolean;
      private var _undockPearlWindow:Boolean;
      private var _isRunning:Boolean;
      private var _highlightUnseenNotes:Boolean;
      private var _actionToPerform : IAction;
      private var _notForAnonymous: Boolean;
      
      private static const DEBUG:Boolean = false;
      private function debug(msg:String): void {
         if (DEBUG) {
            Log.debug(msg);
         }
      }
      
      function DisplayPWAtEndOfAnimation(node:IPTNode=null, selectedPanel:uint=0, playOpenEffect:Boolean=false, undockPearlWindow:Boolean=false, highlightUnseenNotes:Boolean=false, actionToPerform:IAction=null, notForAnonymous:Boolean = true) {
         _node = node;
         _selectedPanel = selectedPanel;
         _playOpenEffect = playOpenEffect;
         _undockPearlWindow = undockPearlWindow;
         _isRunning = true;
         _highlightUnseenNotes = false;
         if (DEBUG) debug("DisplayPWAtEndOfAnimation(): selectedPanel=" + selectedPanel + " _actionToPerform=" + actionToPerform);
         _actionToPerform = actionToPerform;
         _notForAnonymous = notForAnonymous;
      }
      
      public function performAction():void {
         var arp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         displayNodeInPearlWindowInternal();
         
         if(_playOpenEffect) {
            setTimeout(arp.notifyEndAction, WindowSlowEffectManager.OPEN_EFFECT_DURATION, this);
         } else {
            arp.notifyEndAction(this);
         }
      }
      
      public function displayNodeInPearlWindow():void {
         var arp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         if (arp.isBusy || _playOpenEffect) {
            arp.postActionRequest(this, 500);
         }
         else {
            displayNodeInPearlWindowInternal();
         }
      }
      
      public function displayNodeInPearlWindowNow():void {
         displayNodeInPearlWindowInternal();
      }
      
      public function isRunning():Boolean {
         return _isRunning;
      }
      
      public function set selectedPanel(selectedPanel:uint):void {
         _selectedPanel = selectedPanel;
      }
      
      public function set highlightUnseenNotes(value:Boolean):void {
         _highlightUnseenNotes = value;
      }
      
      public function set actionToPerform(value : IAction):void {
         _actionToPerform = value;
      }
      
      private function displayNodeInPearlWindowInternal():void {
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         if (navModel.willShowPlayer) return;
         if (!navModel.isFirstSelectionPerformed) {
            var ga:GenericAction = new GenericAction(null, this, displayNodeInPearlWindowInternal);
            navModel.addEventListener(NavigationManagerImpl.FIRST_FOCUS_HAS_BEEN_PERFORMED_EVENT, ga.performActionOnFirstEvent);
            return;
         }
         
         _isRunning = false;
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         if (_selectedPanel == PWModel.CROSS_PANEL) {
            wc.displayNodeCrosses(_node);
         } else if (_selectedPanel == PWModel.CONNECTION_PANEL) {
            wc.displayConnectionList(_node);
         } else if (_selectedPanel == PWModel.HELP_EMPTY_PANEL) {
            wc.displayNodeEmptyContent(_node);
         } else if (_selectedPanel == PWModel.AUTHOR_PANEL) {
            wc.displayOrHideAuthorInfo(_node, false, _undockPearlWindow);
         } else if (_selectedPanel == PWModel.NOTE_PANEL) {
            wc.displayNodeNotes(_node, false, false, _highlightUnseenNotes);
         } else if (_selectedPanel == PWModel.SHARE_PANEL) {
            wc.displayNodeShare(_node);
         } else if (_selectedPanel == PWModel.MOVE_PANEL) {
            wc.displayMoveNode(_node);
         } else if (_selectedPanel == PWModel.MOVE_PRIVATE_PANEL) {
            wc.displayMovePrivateNode(_node);
         } else if (_selectedPanel == PWModel.COPY_PANEL) {
            wc.displayCopyNodeTo(_node, false, _undockPearlWindow);
         } else if (_selectedPanel == PWModel.TEAM_ACCEPT_CANDIDACY_PANEL) {
            if (DEBUG) debug("performing action " + _actionToPerform + " (_selectedPanel=" + _selectedPanel + ")"); 
            _actionToPerform.performAction();
         } else if (_selectedPanel == PWModel.PICK_PANEL) {
            wc.displayPickNodeTo(_node, false, _undockPearlWindow);
         } else if (_selectedPanel == PWModel.TEAM_SHARING_POINT_PANEL) {
            wc.displayTeamSharingPoint(_node, false, false, 0, false, _undockPearlWindow, false, false, false);
         } else if (_selectedPanel == PWModel.TEAM_INFO_PANEL) {
            wc.displayOrHideTeamInfo(_node, false);
         } else if (_selectedPanel == PWModel.TEAM_FREEZE_MEMBER_PANEL) {
            wc.displayOrHideTeamInfo(_node, false);
         } else if (_selectedPanel == PWModel.TEAM_LIST_PANEL) {
            wc.displayAuthorTeamList(_node, null, -1, false, _undockPearlWindow);
         } else if (_selectedPanel == PWModel.TEAM_HISTORY_PANEL) {
            wc.displayOrHideTeamHistory(_node, false, _undockPearlWindow, true);
         } else if (_selectedPanel == PWModel.TEAM_DISCUSSION_PANEL) {
            wc.displayTeamDiscussion(_node, false, false, _highlightUnseenNotes);
         } else if (_selectedPanel == PWModel.REORGANISATION_PANEL) {
            wc.displayReorganizationPanel(_node, _node.getBusinessNode().owner.organize);
         } else if (_selectedPanel == PWModel.LIST_PRIVATE_MSG_PANEL) {
            wc.displayPrivateMessages(_node);
         } else if (_selectedPanel == PWModel.TREE_EDITO_PANEL) {
            wc.displayTreeEdito(_node);
         } else if (_selectedPanel == PWModel.CUSTOMIZATION_AVATAR_PANEL) {
            wc.displayCustomizeAvatar(_node);
         }  else if (_selectedPanel == PWModel.CUSTOMIZATION_LOGO_PANEL) {
            wc.displayCustomizeLogo(_node);
         }  else if (_selectedPanel == PWModel.CUSTOMIZATION_BACKGROUND_PANEL) {
            wc.displayCustomizeBackground(_node);
         } else if (_selectedPanel == PWModel.IMAGES_BIBLI_PANEL) {
            wc.displayImagesBibli(null, null, _node);
         } else if (_selectedPanel == PWModel.TEAM_FREEZE_MEMBER_PANEL) {
            wc.displayOrHideFreezeTeamMember(_node, false);
         } else if (_selectedPanel == PWModel.TEAM_NOTIFICATION_PANEL) {

         } else {
            if (wc.toUndockPWImediatelyForAnonymousUser() || !_notForAnonymous || !ApplicationManager.getInstance().currentUser.isAnonymous()) {
               wc.displayNodeInfo(_node, false, _undockPearlWindow);   
            }
         }
      }
   }
}
