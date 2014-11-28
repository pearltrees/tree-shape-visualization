package com.broceliand.ui.util {
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   
   import mx.controls.Text;
   import mx.controls.textClasses.TextRange;
   import mx.core.UITextField;
   
   public class NonScrollableText extends Text {
      private var _attachListener:Boolean = true;
      
      public function NonScrollableText() {
      }
      
      override protected function commitProperties():void {
         if(hasFontContextChanged()) {
            
            _attachListener = true;
            textField.removeEventListener(Event.SCROLL, onTextScroll);
         }
         super.commitProperties();
         if (_attachListener) {
            textField.addEventListener(Event.SCROLL, onTextScroll);
            _attachListener = false;
         }
      }
      private function onTextScroll(event:Event):void {
         if(textField.scrollV > 1)
            textField.scrollV = 1
      }
      
      override public function set selectable(pSelectable:Boolean):void {
         super.selectable = pSelectable;
         if (textField) {
            textField.selectable = pSelectable;
         }
         else {

            callLater(function(pSelectable:Boolean):void {
               textField.selectable = pSelectable;
            }, [pSelectable]);
         }
         if (!pSelectable) {
            addEventListener(MouseEvent.CLICK, onSpecialClick);
         }
         else {
            removeEventListener(MouseEvent.CLICK, onSpecialClick);
         }
      }
      
      protected function onSpecialClick(pEvent:MouseEvent):void {
         
         var index:int = textField.getCharIndexAtPoint(pEvent.localX, pEvent.localY);
         if (index != -1) {
            
            var range:TextRange = new TextRange(this, false, index, index + 1);
            
            if (range.url.length > 0) {

               var url:String = range.url;
               if (url.substr(0, 6) == 'event:') {
                  url = url.substring(6);
               }
               
               dispatchEvent(new TextEvent(TextEvent.LINK, false, false, url));
            }
         }
      }
      
      public function updateHeight():void {

         validateNow();
         setActualSize(width, measuredHeight + 3);
         validateSize();
      }
      
   }
}