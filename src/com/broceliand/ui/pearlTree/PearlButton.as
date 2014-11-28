package com.broceliand.ui.pearlTree
{
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.renderers.IRepositionable;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   import mx.core.UIComponent;
   
   public class PearlButton extends PearlComponentAddOn implements IRepositionable
   {
      protected var _focusImage:ExcitableImage;
      
      public function PearlButton(){}
      
      override protected function createChildren():void{
         super.createChildren();
         
         if (!_focusImage) {
            _focusImage= makeExcitableImage();
            _focusImage.smoothBitmapContent = true;
            addChild(_focusImage);
            addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            addEventListener(MouseEvent.ROLL_OUT, onMouseOut);  
            addEventListener(MouseEvent.CLICK, performAction);
         }
      }     

      protected function makeExcitableImage():ExcitableImage {
         return null;
      }
      private function onMouseOver(event:Event):void {
         excite();
      }
      private function onMouseOut(event:Event):void {
         relax();
      }
      
      public function excite():void {
         if(_focusImage) {
            _focusImage.excite();
         }
      }
      public function relax():void {
         if(_focusImage) {
            _focusImage.relax();
         }
      }
      protected function performAction(event:Event=null):void {
      }
      override public function end():void {
         super.end();
         removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
         removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);  
         removeEventListener(MouseEvent.CLICK, performAction);
         removeAllChildren();
         _focusImage = null;   
      }
      public static function isActionEvent(event:Event):Boolean {
         var target:UIComponent = event.target as UIComponent;
         return (target && target.parent is PearlButton);
      }
      
      protected function get isImageVisible():Boolean {
         return _focusImage && _focusImage.visible;
      }

   }
   
}
