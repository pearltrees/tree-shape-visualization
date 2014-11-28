package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NavigationDescription;
   
   public class BroPTWAliasNode extends BroPTWDistantTreeRefNode
   {
      public function BroPTWAliasNode(refTree:BroPearlTree, owner:BroPearlTree)
      {
         super(refTree);
         super._owner = owner;
      }
      
      override public function navigateToPearl(selectedNode:IPTNode):void {
         var navigationModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         ApplicationManager.getInstance().visualModel.selectionModel.saveCrossingBusinessNode(selectedNode);
         var navDesc:NavigationDescription = NavigationDescription.goToPearl(this);
         navDesc.withRevealState(NavigationEvent.ADD_ON_CROSS_ANIMATION);
         
         navigationModel.navigate(navDesc);
      }
      
      override public function canBeCopy():Boolean {
         return false;
      }
   }
}