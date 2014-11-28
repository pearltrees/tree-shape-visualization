package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.object.tree.PearlData;
   import com.broceliand.pearlTree.io.object.tree.TreeData;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetPearlCallback;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.util.error.ErrorConst;
   
   import mx.rpc.events.FaultEvent;
   
   public class UnfocusTeamNavigationRequest extends NavigationRequestBase implements IAmfRetPearlCallback
   {
      private var _assoId:int;
      
      public function UnfocusTeamNavigationRequest(navDesc:NavigationDescription)
      {
         super(navDesc);
         _assoId = navDesc.associationId;
      }
      
      override public function startProcessingRequest(navigator:NavigationManagerImpl, eventToPropagateWhenFinished:NavigationEvent):void {
         super.startProcessingRequest(navigator, eventToPropagateWhenFinished);
         ApplicationManager.getInstance().pearlTreeLoader.loadParentAssociationPearl(_assoId, true, this);         
      }
      
      public function onReturnNewPearl(pearl:PearlData):void {
         var tree:TreeData = pearl.tree;
         if (_navigator.isCurrentRequest(this)) {
            _navigator.goTo(tree.assoId, -1, tree.id, tree.id, pearl.id);
         }
      }
      public function onError(message:FaultEvent, status:int=0):void {
         if (_navigator.isCurrentRequest(this)) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            am.errorReporter.onError(ErrorConst.ERROR_LOADING_TREE);
         }
      }
   }
}
