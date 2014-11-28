package com.broceliand.pearlTree.navigation.impl {
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.interactors.SelectInteractor;
   
   public class AuthorNavigationHelper{
      
      public static function navigateOrCenterToAssociation(assoId:int, arrivalPWPanel:int=0):Boolean{
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navigationModel:INavigationManager = am.visualModel.navigationModel;
         
         if(!navigationModel.getFocusedTree() ||
            navigationModel.getFocusedTree().id != assoId ||
            !navigationModel.getSelectedTree() ||
            navigationModel.getSelectedTree().id != assoId)
         {
            navigationModel.goTo(assoId, -1, -1, -1, -1, -1, -1, arrivalPWPanel, false, NavigationEvent.ADD_ON_RESET_GRAPH);
            return true;
         }            
         else { 
            am.visualModel.selectionModel.selectNode(am.components.pearlTreeViewer.vgraph.currentRootVNode.node as IPTNode);
            var selectInteractor:SelectInteractor = am.components.pearlTreeViewer.interactorManager.getSelectInteractor();
            selectInteractor.closeAllSubFocusTreesAndCenterAfter();
            return false;
         }                  
      }
      
      public static function navigateOrCenterToAuthorAccount(author:User):Boolean {
         if (!author || !author.getAssociation())
            return false;
         return navigateOrCenterToAssociation(author.getAssociation().associationId);            
      }   
   }
}