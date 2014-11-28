package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.pearlBar.Footer;
   import com.broceliand.ui.pearlBar.IFooter;

   public class TrashInteractor 
   {     
      private var _interactorManager:InteractorManager = null;
      
      public function TrashInteractor(interactorManager:InteractorManager)
      {
         _interactorManager = interactorManager;
      }

      public function set isPearlDragged(pearlDragged:Boolean):void {
         var footer:IFooter = ApplicationManager.getInstance().components.footer;
         if(footer) {
            footer.isPearlDraggedOverTrashBox = pearlDragged;
         }
      }

      public function trashNode(node:IPTNode):void{
         
      }
      
   }
}