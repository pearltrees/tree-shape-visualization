package com.broceliand.ui.controller {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.model.OpenTreesStateModel;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.sticker.help.IContextualHelp;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   
   public class GoHomeAction  implements IAction {
      
      private var _navigationModel:INavigationManager;
      
      public function GoHomeAction():void  {
         var am:ApplicationManager = ApplicationManager.getInstance();
         _navigationModel = am.visualModel.navigationModel;
      }
      
      public function performAction():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var currentUser:User = am.currentUser;
         if(currentUser.isAnonymous()) {
            ApplicationManager.getInstance().menuActions.signUp();
            return;
         }
         var help:IContextualHelp = am.components.getContextualHelp(false);
         /*if (help) {
         help.hide();
         }*/
         if (_navigationModel.getSelectedUser() != currentUser) {
            var userTree:BroPearlTree = am.pearlTreeLoader.getTreeInAssociationHierarchy(currentUser.userWorld.treeId, currentUser.userWorld.treeId);
            if (userTree) {
               closeSubTreeModel(userTree);
            }
         }
         
         _navigationModel.getAliasNavigationModel().removeAllAliasNavigations();
         _navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, centerAndCloseUserTreeAfterNavEvent);
         _navigationModel.goToUser(currentUser, PWModel.CONTENT_PANEL);
         _navigationModel.getNavigationHistoryModel().clearHistory();
         
      }
      
      private function closeSubTreeModel(userTree:BroPearlTree):void  {
         var openTreeModel:OpenTreesStateModel = ApplicationManager.getInstance().visualModel.openTreesModel;
         var subTrees:Array = userTree.treeHierarchyNode.getChildTrees();
         for each (var t:BroPearlTree in subTrees) {
            if (!t.treeHierarchyNode.isAlias) {
               openTreeModel.closeTree(t.dbId, t.id);
            }
         }
      }
      
      private function centerAndCloseUserTreeAfterNavEvent(event:NavigationEvent):void{
         if(event) {
            _navigationModel.removeEventListener(NavigationEvent.NAVIGATION_EVENT, centerAndCloseUserTreeAfterNavEvent);
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (am.visualModel.animationRequestProcessor.isBusy) {
            am.visualModel.animationRequestProcessor.addEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerAndCloseUserTreeAfterAnimationEnds);
         }
         else {
            centerAndCloseUserTreeAfterAnimationEnds();
         }
      }
      
      private function centerAndCloseUserTreeAfterAnimationEnds(event:Event=null):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (event) {
            am.visualModel.animationRequestProcessor.removeEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerAndCloseUserTreeAfterAnimationEnds);
         }
         am.components.pearlTreeViewer.pearlTreeEditionController.closeAllSubtrees(_navigationModel.getFocusedTree(), true);
         if (am.visualModel.animationRequestProcessor.isBusy) {
            am.visualModel.animationRequestProcessor.addEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerFocusTree);
         }
         else {
            centerFocusTree();
         }
      }
      
      private function centerFocusTree(event:Event=null):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if (event) {
            am.visualModel.animationRequestProcessor.removeEventListener(GraphicalAnimationRequestProcessor.END_PROCESSING_ACTION_EVENT, centerFocusTree);
         }
         var sm:SelectionModel = am.visualModel.selectionModel;
         var vgraph:IVisualGraph = am.components.pearlTreeViewer.vgraph;
         if (sm.getSelectedNode()== vgraph.currentRootVNode.node ) {
            sm.centerGraphOnCurrentSelectionWithPWDisplayed(false, true);
         }
         else {
            sm.selectedFromNavBar= true;
            sm.selectNode(vgraph.currentRootVNode.node as IPTNode);
         }                    
      }
      
   }
}