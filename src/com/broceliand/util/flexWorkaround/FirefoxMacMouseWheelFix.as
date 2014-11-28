package com.broceliand.util.flexWorkaround
{	
   import com.broceliand.ApplicationManager;
   
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   
   import mx.controls.scrollClasses.ScrollBar;
   import mx.core.Container;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDirection;
   
   public class FirefoxMacMouseWheelFix
   {
      private var _myContainer:Container;

      static public function fixFirefoxMacWheelOnScroll(container:Container):FirefoxMacMouseWheelFix {
         var browser:String = ApplicationManager.getInstance().getBrowserName();
         var os:String = ApplicationManager.getInstance().getOS();
         
         var result:FirefoxMacMouseWheelFix = null
         if (os == ApplicationManager.OS_NAME_MAC && browser == ApplicationManager.BROWSER_NAME_FIREFOX) {
            result=  new FirefoxMacMouseWheelFix(container);
            result.registerListener();
         }
         return result;
      }
      
      public function FirefoxMacMouseWheelFix(myContainer:Container)
      {
         super();
         _myContainer = myContainer;
         
      }
      
      private function registerListener():void {

         _myContainer.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler,false,1);
      }
      
      private function mouseWheelHandler(event:MouseEvent):void
      {
         if (event.delta != 0) {
            return;
         }
         if (_myContainer.verticalScrollBar && _myContainer.verticalScrollBar.visible)
         {

            var scrollDirection:int = event.delta < 0 ? 1 : -1;
            var scrollAmount:Number;
            scrollAmount = Math.max(Math.abs(event.delta), _myContainer.verticalScrollBar.lineScrollSize);				
            
            var oldPosition:Number = _myContainer.verticalScrollPosition;
            _myContainer.verticalScrollPosition += 3 * scrollAmount * scrollDirection;
            
            var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
            scrollEvent.direction = ScrollEventDirection.VERTICAL;
            scrollEvent.position = _myContainer.verticalScrollPosition;
            scrollEvent.delta = _myContainer.verticalScrollPosition - oldPosition;
            _myContainer.dispatchEvent(scrollEvent);
         }
      }
   }
}