package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.util.GenericAction;
   
   import flash.geom.Point;
   
   public class BroPTWPageNode extends BroPageNode  implements IBroPTWNode 
   {
      private var _isSearchCenter:Boolean;
      private var _isSearchNode:Boolean;
      private var _absolutePosition:Point;
      private var _position:BroRadialPosition;
      
      public function BroPTWPageNode(p:BroPage, owner:BroPearlTree)
      {
         super(p);
         _owner = owner;
      }
      
      public function get preferredRadialPosition():BroRadialPosition {
         return _position;
      }
      
      public function set preferredRadialPosition(pos:BroRadialPosition ):void {
         _position= pos;
      }     
      
      public function get absolutePosition():Point {
         if(!_absolutePosition){
            _absolutePosition = new Point();
         }
         return _absolutePosition;
      }
      public function set absolutePosition(value:Point):void {
         _absolutePosition = value;
      }      
      
      override public function set owner (value:BroPearlTree):void {}
      
      public function set isSearchCenter (value:Boolean):void {
         _isSearchCenter = value;
      }      
      public function get isSearchCenter ():Boolean {
         return _isSearchCenter;
      }
      
      public function set isSearchNode (value:Boolean):void {
         _isSearchNode = value;
      }      
      
      public function get isSearchNode ():Boolean {
         return _isSearchNode;
      }
      
      public function get indexKey():String { 
         return "p:"+this.persistentID;
      }
      
      public function navigateToPearl(selectedNode:IPTNode):void {
         var navigationModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         ApplicationManager.getInstance().visualModel.selectionModel.saveCrossingBusinessNode(selectedNode);
         var navDesc:NavigationDescription = NavigationDescription.goToPearl(this);
         navDesc.withRevealState(NavigationEvent.ADD_ON_CROSS_ANIMATION);
         var sm:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
         var ga:GenericAction = new GenericAction(null, this, openScreenLineAfterNavigation, navigationModel, false);
         sm.addEventListener(SelectionModel.NEW_NODE_SELECTED_EVENT, ga.performActionOnFirstEvent);
         navigationModel.navigate(navDesc);
      }
      
      private function openScreenLineAfterNavigation(navModel:INavigationManager, onNewSelection:Boolean):void {
         if (navModel.getSelectedPearl() && !navModel.isShowingPearlTreesWorld() && this.persistentID == navModel.getSelectedPearl().persistentID) {
            var sm:SelectionModel = ApplicationManager.getInstance().visualModel.selectionModel;
            var pearlNode:IPTNode = sm.getSelectedNode();
            if (!onNewSelection) {
               if (!pearlNode || !pearlNode.getBusinessNode() || pearlNode.getBusinessNode().persistentID != this.persistentID || pearlNode.getBusinessNode() == this) {
                  var ga:GenericAction = new GenericAction(null, this, openScreenLineAfterNavigation, navModel, true);
                  sm.addEventListener(SelectionModel.NEW_NODE_SELECTED_EVENT, ga.performActionOnFirstEvent);
                  return;
               }
            }
            navModel.setPlayState(NavigationEvent.PLAY_STATE_SCREEN);
         }
      }
      
      override public function isTitleEditable():Boolean {
         return false;
      }
      
      override public function canBeCopy():Boolean {
         return false;
      }
      
   }
}
