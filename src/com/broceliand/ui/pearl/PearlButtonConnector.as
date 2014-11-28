package com.broceliand.ui.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearlTree.PearlButton;
   
   import mx.containers.Box;
   import mx.core.UIComponent;
   
   public class PearlButtonConnector extends PearlComponentConnector
   {
      protected var _xOffset:int;
      protected var _yOffset:int;      
      
      public function PearlButtonConnector(pearl:UIPearl, button:PearlButton, xOffset:int, yOffset:int) {
         super(pearl, button);
         _xOffset = xOffset;
         _yOffset = yOffset;
      }
      
      override protected function makeMask():void {
         if(!_mask) {
            
            _mask = new Box();
            _mask.name = GeometricalConstants.PEARL_CLOSE_BUTTON_MASK_NAME;
            _mask.x = GeometricalConstants.PEARL_X - _xOffset;
            _mask.y = GeometricalConstants.PEARL_Y - _yOffset - 4;
            _mask.width = _xOffset + 6;
            _mask.height =  36;
            _mask.includeInLayout = true;
         }
         _mask.graphics.clear();
         _mask.graphics.beginFill(0x000000, 0);
         _mask.graphics.drawRect(0,0, _mask.width, _mask.height);
         _mask.graphics.endFill();
      }      
      
      override public function updateButtonVisibility():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var intercatorManager:InteractorManager = am.components.pearlTreeViewer.interactorManager;
         var isDragged:Boolean = (intercatorManager.hasMouseDragged() && intercatorManager.draggedPearl && intercatorManager.draggedPearl.node == _pearl.node);
         var showComponentAddOn:Boolean = !isDragged && _componentTemporaryVisible && _pearl.visible && _pearl.node && !_pearl.node.isDocked;
         setButtonVisible(showComponentAddOn);         
      }
      
      public function isButtonVisible():Boolean {
         return _componentAddOn.visible;
      }
      public function get button():PearlButton {
         return _componentAddOn as PearlButton;
      }
   }
}
