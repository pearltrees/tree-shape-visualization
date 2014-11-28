package com.broceliand.util.flexWorkaround
{
   import com.broceliand.ApplicationManager;
   
   import flash.events.MouseEvent;
   
   import mx.controls.TextArea;
   import mx.controls.scrollClasses.ScrollBar;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDirection;
   
   public class SafariMouseWheelTextArea extends TextArea
   {
      private var _safariMouseWheelEnabled:Boolean = false;
      public function SafariMouseWheelTextArea()
      {
      }
      
      public function get safariMouseWheelEnabled():Boolean
      {
         return _safariMouseWheelEnabled;
      }
      
      public function set safariMouseWheelEnabled(value:Boolean):void
      {
         if (_safariMouseWheelEnabled != value) {
            _safariMouseWheelEnabled = value;
            if (_safariMouseWheelEnabled) {
               addEventListener(MouseEvent.MOUSE_WHEEL, safariMouseWheelHandler,false,1);
            } else {
               removeEventListener(MouseEvent.MOUSE_WHEEL, safariMouseWheelHandler);
            }
         }
         
      }
      
      override protected function createChildren():void {
         super.createChildren();
         var browser:String = ApplicationManager.getInstance().getBrowserName();
         var os:String = ApplicationManager.getInstance().getOS();
         if (os == ApplicationManager.OS_NAME_MAC && browser == ApplicationManager.BROWSER_NAME_SAFARI) {
            safariMouseWheelEnabled = true;
         }
      }
      
      private function safariMouseWheelHandler(event:MouseEvent):void
      {
         var vsb:ScrollBar =  verticalScrollBar;
         if (vsb && vsb.visible) {
            var scrollDirection:int = event.delta <= 0 ? 1 : -1;
            var scrollAmount:Number;
            scrollAmount = vsb.lineScrollSize;
            var oldPosition:Number = verticalScrollPosition;				
            
            var newScrollPosition:Number = verticalScrollPosition + scrollAmount * scrollDirection;
            if (newScrollPosition < vsb.minScrollPosition) {
               newScrollPosition = vsb.minScrollPosition;
            } 
            else if (newScrollPosition > vsb.maxScrollPosition) {
               newScrollPosition = vsb.maxScrollPosition;
            }
            var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
            verticalScrollPosition = newScrollPosition;
            scrollEvent.direction = ScrollEventDirection.VERTICAL;
            scrollEvent.position = newScrollPosition;
            scrollEvent.delta = newScrollPosition - oldPosition;
            if (scrollEvent.delta != 0) {
               dispatchEvent(scrollEvent);
            }
         }
      }
      
   }
}