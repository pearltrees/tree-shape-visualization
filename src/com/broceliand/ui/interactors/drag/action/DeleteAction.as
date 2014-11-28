package  com.broceliand.ui.interactors.drag.action
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.effects.TrashPearlEffect;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.undo.IUndoableAction;
   
   import flash.utils.setTimeout;
   
   import mx.effects.Move;
   import mx.effects.Zoom;
   import mx.events.EffectEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class DeleteAction extends CutBNodeAction implements IUndoableAction   {
      
      private var _forceNoSelectionUpdate:Boolean;
      
      public function DeleteAction(pearltreeViewer:IPearlTreeViewer, node:IPTNode, forceNoSelectionUpdate:Boolean = false)
      {  
         _forceNoSelectionUpdate = forceNoSelectionUpdate;
         super(pearltreeViewer, node);
      }
      
      override protected function changePearlInBusinessModel(node:IPTNode):void {
         var endNode:IVisualNode = _pearltreeViewer.pearlTreeEditionController.detachEndNode(node.containingPearlTreeModel);
         _pearltreeViewer.pearlTreeEditionController.deleteBranch(node);
         if (endNode) {
            _pearltreeViewer.pearlTreeEditionController.reattachEndNode(endNode);
         }
      }
      override  protected function sendNodeToDestination(node:IPTNode):void {
         if (node.vnode) { 
            var pearlRenderer:IUIPearl= node.vnode.view as IUIPearl;
            pearlRenderer.pearl.blacken();
         }
      }
      override protected function updateSelection(node:IPTNode):void {
         if (_forceNoSelectionUpdate) {
            return;
         }
         var am:ApplicationManager = ApplicationManager.getInstance();
         var nodeToSelect:IPTNode = getParentNode();
         var selectionDelay:uint = 0;
         if (_fromDock) {
            
            var nodeIndex:int = _fromDock.findItemIndexFromNode(node);
            if(nodeIndex != -1) {
               
               nodeToSelect = _fromDock.getNodeAt(nodeIndex + 1);
               if(!nodeToSelect) {
                  nodeToSelect = _fromDock.getNodeAt(nodeIndex - 1);
               }               
            } else {
               
               nodeToSelect = _fromDock.getNodeAt(_originalIndex);
               if(!nodeToSelect) {
                  nodeToSelect = _fromDock.getNodeAt(_originalIndex - 1);
               }
            }
            if(nodeToSelect) {
               selectionDelay = TrashPearlEffect.DURATION;
            }else{
               am.components.windowController.closeAllWindows();
            }
            
         } else {
            if (nodeToSelect && nodeToSelect.successors.length>0) {
               if (_originalIndex<nodeToSelect.successors.length) {
                  nodeToSelect = nodeToSelect.successors[_originalIndex];
               } else if (_originalIndex-1<nodeToSelect.successors.length) {
                  nodeToSelect = nodeToSelect.successors[_originalIndex-1];
               }
            }
         }
         if(selectionDelay > 0) {
            setTimeout(am.visualModel.selectionModel.selectNode, selectionDelay, nodeToSelect);
         }else{
            am.visualModel.selectionModel.selectNode(nodeToSelect);
         }
      }
      override protected function closeTreeOnDescendantNodesDisappeared(event:EffectEvent = null):void{
      } 
      override protected function disappearEffect(renderer:IUIPearl, duration:int):Zoom {
         renderer.pearl.blacken();
         return super.disappearEffect(renderer, duration);
      }
      override protected function moveEffect(renderer:IUIPearl, x:Number, y:Number, duration:int):Move {
         return null;
      }

   }
}