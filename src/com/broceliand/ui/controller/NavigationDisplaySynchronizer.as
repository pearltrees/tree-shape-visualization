package com.broceliand.ui.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.button.PremiumButtonSkin;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.pearlWindow.PremiumWindowHelper;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.utils.getTimer;

   public class NavigationDisplaySynchronizer
   {
      private var _pearlTreeViewer:IPearlTreeViewer = null;
      private var _isFirstNavigation:Boolean = true;
      
      public function NavigationDisplaySynchronizer(pearlTreeViewer:IPearlTreeViewer) {
         _pearlTreeViewer = pearlTreeViewer;
         ApplicationManager.getInstance().visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigate);
      }
      
      public function onNavigate(workaroundEvent:Event):void {
         
         var event:NavigationEvent = NavigationEvent (workaroundEvent);
         if (event.isShowingPTW){
            openPearlTreesWorld(event.newUser, event.newFocusTree, event.newNeighbourTree);
            _isFirstNavigation  = false;
            return;
         }
         var clearGraph:Boolean = event.revealState == NavigationEvent.ADD_ON_RESET_GRAPH_AND_CENTER;

         if (clearGraph /* && event.newPearlWindowPreferredState <=0*/) {
            ApplicationManager.getInstance().visualModel.selectionModel.saveBusinessNodeToCenter(event.newSelectedPearl);
         }
         if (event.newFocusTree || clearGraph) {
            if (event.isNewFocus || _isFirstNavigation  || !_pearlTreeViewer.vgraph.currentRootVNode || clearGraph) {
               var fromPTW:Boolean = event.wasShowingPTW;
               
               if (fromPTW && event.oldSearchUserId>0) {
                  fromPTW = false;
               }
               focusOnTree(event.newFocusTree, fromPTW, event.revealState);
            }  
         }
         _isFirstNavigation = false;
         if (event.newSelectedTree) {
            selectTreeAndPearl(event.newSelectedTree, event.newSelectedPearl, event.selectionOnIntersection, event.playState >=1);
         }
      }
      private function focusOnTree(newFocusTree:BroPearlTree, fromPTW:Boolean, resetGraphOption:int):void {
         _pearlTreeViewer.pearlTreeEditionController.focusOnTree(newFocusTree, fromPTW, resetGraphOption);
         var am:ApplicationManager = ApplicationManager.getInstance();
         var arp:GraphicalAnimationRequestProcessor = am.visualModel.animationRequestProcessor;
         var startTime:Number = getTimer();
         var action:IAction = new GenericAction(arp, this, onFocusTreeEnd, newFocusTree, startTime);
         arp.postActionRequest(action);            
      }
      private function onFocusTreeEnd(treeFocused:BroPearlTree, startTime:Number):void {
         if (StartPolicyLogger.getInstance().setFirstOpenAnimationEnded()) {
            ApplicationManager.getInstance().enableTooltip = true;
         }
         var duration:Number = getTimer() - startTime;
      }
      private function  selectTreeAndPearl(selectedTree:BroPearlTree, pearl:BroPTNode, intersection:int, closeOtherTrees:Boolean):void {
         _pearlTreeViewer.pearlTreeEditionController.showAndSelectPearl(selectedTree, pearl, intersection, closeOtherTrees);
      }
      private function openPearlTreesWorld(treeUser:User, origin:BroPearlTree, neighbourTree:BroPearlTree):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.components.pearlTreePlayer.hidePlayer();
         am.visualModel.selectionModel.selectNode(null);

         var currentVNode:IPTVisualNode = _pearlTreeViewer.vgraph.currentRootVNode as IPTVisualNode;
         if (currentVNode && currentVNode.ptNode.getBusinessNode() is BroNeighbourRootPearl)  {
            _pearlTreeViewer.pearlTreeEditionController.moveInPTWTree(neighbourTree);
         } else {
            _pearlTreeViewer.pearlTreeEditionController.focusOnPTWTree(neighbourTree);
         }
      }
      
   }
}
