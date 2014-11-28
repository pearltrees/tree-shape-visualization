package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.interactors.InteractorManager;
   
   import flash.events.MouseEvent;
   
   public class DragEditInteractorBase implements IDragInteractor
   {
      
      protected var _interactorManager:InteractorManager = null;
      
      public function DragEditInteractorBase(interactorManager:InteractorManager){
         _interactorManager = interactorManager;
         
      }

      public function dragBegin(ev:MouseEvent):void{
         _interactorManager.draggedPearl = _interactorManager.pearlRendererUnderCursor;
         var isPearlInDropZone:Boolean = _interactorManager.pearlRendererUnderCursor.node && _interactorManager.pearlRendererUnderCursor.node.isDocked;
         if(isPearlInDropZone){
            _interactorManager.pearlTreeViewer.vgraph.controls.scrollControl.hideWhileNotOncePassedBottomLine();
         }
         _interactorManager.depthInteractor.movePearlAboveAllElse(_interactorManager.draggedPearl);
         
      }
      
      public function handleDrag(ev:MouseEvent):void{
         
      }

      public function dragEnd(ev:MouseEvent):void{
         
         _interactorManager.draggedPearl = null;
         _interactorManager.trashInteractor.isPearlDragged = false;
         
         ApplicationManager.getInstance().visualModel.mouseManager.update();
      }
   }
}