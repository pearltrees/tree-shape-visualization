
package com.broceliand.ui.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.OpenTreeAnimation;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.pearlTree.BackFromAliasButton;
   import com.broceliand.ui.pearlTree.CloseButton;
   import com.broceliand.ui.pearlTree.OpenTreeButton;
   import com.broceliand.ui.pearlTree.UnfocusButton;
   import com.broceliand.ui.renderers.pageRenderers.PTRootPearlRenderer;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import flash.geom.Point;
   
   public class UIRootPearl extends PTRootPearlRenderer 
   {
      private static const DEFAULT_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_NORMAL;
      private static const MAX_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_EXCITED;
      
      private var _closeButtonConnector:PearlButtonConnector;
      private var _openTreeButtonConnector:PearlButtonConnector;
      
      private var _unfocusButton:UnfocusButton;
      private var _backFromAliasButton:BackFromAliasButton;
      private var _needToRecycleButtons:Boolean = false;
      
      private var  _isFocusButton:Boolean = false;
      private var  _isSelectedTree:Boolean = false;
      public function UIRootPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager)
      {
         super(stateManager, remoteResourceManager);
         if (hasCloseButton()) {
            _closeButtonConnector = new PearlButtonConnector(this, new CloseButton(), CloseButton.X_OFFSET, CloseButton.Y_OFFSET);
            _openTreeButtonConnector = new PearlButtonConnector(this, new OpenTreeButton(), OpenTreeButton.X_OFFSET, OpenTreeButton.Y_OFFSET);
         }  
      }

      public function set unfocusButton(value:UnfocusButton):void
      {
         if (value) {
            value.addMask(this);
            value.setInSelection(_pearl.isInSelection());
         } else if (_unfocusButton) {
            _unfocusButton.setInSelection(true);
            _unfocusButton.removeMask(this);
         }
         _unfocusButton = value;
      }
      
      public function set backFromAliasButton(value:BackFromAliasButton):void
      {
         if (value) {
            value.setInSelection(_pearl.isInSelection());
         } else if (_backFromAliasButton) {
            _backFromAliasButton.setInSelection(true);
         }
         _backFromAliasButton = value;
      }
      
      protected function hasCloseButton():Boolean {
         return true;
      }
      override protected function createChildren():void {
         
         if (hasCloseButton()) {
            _closeButtonConnector.createChildren();
            _openTreeButtonConnector.createChildren();
         }
         super.createChildren();
      }
      
      override protected function commitProperties():void{
         super.commitProperties(); 

         if(!node || !node.getBusinessNode()) {
            return;
         }
         
         if (hasCloseButton() && node != _closeButtonConnector.button.node) {
            _closeButtonConnector.button.bindToNode(node, this);
            _openTreeButtonConnector.button.bindToNode(node, this);
         }
         var businessNode:BroPTNode = node.getBusinessNode();
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         _isFocusButton =  navModel.getFocusedTree() != null && navModel.getFocusedTree().getRootNode()== businessNode;
         var selectedTree:BroPearlTree = ApplicationManager.getInstance().visualModel.selectionModel.getHighlightedTree();
         if (!selectedTree) {
            selectedTree = navModel.getSelectedTree();
         }
         _isSelectedTree = selectedTree!=null && selectedTree.getRootNode()== businessNode;
         updateButtonsVisibility();
         
      }
      private function updateButtonsVisibility():void {
         if (hasCloseButton()) {
            var isDisappearing:Boolean = pearl && pearl.markAsDisappearing;
            if (_isFocusButton || isDisappearing) {
               _closeButtonConnector.forceVisibilityValue(false);
               _openTreeButtonConnector.forceVisibilityValue(false);
               
            }              
            else {
               if (node && node.getBusinessNode() is BroPTRootNode) {
                  if (_isSelectedTree) {
                     
                     if (ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.draggedPearl != this) {
                        _closeButtonConnector.forceVisibilityValue(true);
                     } else {
                        _closeButtonConnector.updateButtonVisibility();
                     }
                  } else {
                     _closeButtonConnector.updateButtonVisibility();
                  }                   
               } else {
                  if (_closeButtonConnector != null){
                     _closeButtonConnector.forceVisibilityValue(false);
                  }
               }
               if ((_closeButtonConnector!= null && _closeButtonConnector.isButtonVisible()) || ApplicationManager.getInstance().currentUser.isAnonymous()) {
                  _openTreeButtonConnector.forceVisibilityValue(false);
               } else {
                  _openTreeButtonConnector.updateButtonVisibility();
               }

            }
         }
      }

      public function setButtonVisible(value:Boolean):void{
         if (hasCloseButton() && !_needToRecycleButtons) {
            _closeButtonConnector.setComponentAddOnTemporaryVisible(value);
            _openTreeButtonConnector.setComponentAddOnTemporaryVisible(value);
            
         }
         updateButtonsVisibility();
      }
      
      public function exciteCloseButton():void {
         if (hasCloseButton()) {
            _closeButtonConnector.button.excite();
            _closeButtonConnector.setComponentAddOnTemporaryVisible(true);
         }
      }
      
      public function relaxCloseButton():void {
         if (hasCloseButton()) {
            _closeButtonConnector.button.relax();
            _closeButtonConnector.setComponentAddOnTemporaryVisible(false);
         }
      }
      
      override public function isPointOnPearlOrAddon(point:Point):Boolean {
         if (super.isPointOnPearl(point)) {
            return true;
         } else {
            return isPointOnButton(point);
         }
         
      } 
      public function isPointOnButton(point:Point):Boolean {
         return (hasCloseButton() && _closeButtonConnector.isPointOnComponentAddOn(point));

      }
      
      override protected function get pearlDefaultWidth():Number {
         return DEFAULT_PEARL_WIDTH;
      }
      override public function get pearlMaxWidth():Number {
         return MAX_PEARL_WIDTH;
      }
      
      override public function set visible(value:Boolean):void {
         if (value && !visible) {
            invalidateProperties();
         } 
         super.visible = value;
      }  
      
      override public function relax():void {
         super.relax();
         setButtonVisible(false);
      }
      override protected function clearMemory():void {
         super.clearMemory();
         if (hasCloseButton()) {
            _closeButtonConnector.end();
            _closeButtonConnector = null;
         }
      }
      override public function setInSelection(value:Boolean):void {
         super.setInSelection(value);
         if (_unfocusButton) {
            _unfocusButton.setInSelection(value);
         }
         if (_backFromAliasButton) {
            _backFromAliasButton.setInSelection(value);
         }
      }
      override public function end():void {
         super.end();
         _needToRecycleButtons = true;
      }
      override protected function setVNode(vnode:IPTVisualNode):void {
         super.setVNode(vnode);
         if (_needToRecycleButtons) {
            _needToRecycleButtons  = false;
            if (hasCloseButton()) {
               _openTreeButtonConnector.restoreState();
               _closeButtonConnector = new PearlButtonConnector(this, new CloseButton(), CloseButton.X_OFFSET, CloseButton.Y_OFFSET);
            }  
         }
      }
   }
}