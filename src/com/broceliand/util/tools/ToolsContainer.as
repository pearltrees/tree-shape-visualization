package com.broceliand.util.tools {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.extra.delegates.UIComponentDelegate;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.util.PTKeyboardListener;
   
   import flash.events.Event;
   
   import mx.containers.VBox;
   
   public class ToolsContainer extends VBox {
      
      private static const KEYBOARD_ACCESS_KEY:String = "O";
      
      private var _isInitialized:Boolean;
      
      public function ToolsContainer() {
         super();
         visible = includeInLayout = false;
         setStyle('right',5);
         setStyle('top',0);
         setStyle('horizontalAlign', "right");
      }
      
      override protected function createChildren():void {
         super.createChildren();
         var am:ApplicationManager = ApplicationManager.getInstance();
         var keyboardAccessKeyCode:int = PTKeyboardListener.charToKeyCode(KEYBOARD_ACCESS_KEY);
         am.keyboardListener.addKeyboardListener(onKeyboardKeyCode, keyboardAccessKeyCode, true, true);        
      }
      
      private function onKeyboardKeyCode():void {
         
         visible = includeInLayout = !visible;
         ApplicationManager.getInstance().feed.visible = visible;
         if(visible && !_isInitialized) {
            _isInitialized = true;
            addChild(new UIComponentDelegate("com.broceliand.util.tools::PerformanceManager"));
            addChild(new UIComponentDelegate("com.broceliand.util.tools::ChangeLayout"));
            addChild(new UIComponentDelegate("com.broceliand.util.tools::ChangeLanguage"));
            addChild(new UIComponentDelegate("com.broceliand.util.tools::ColorChanger"));
            addChild(new UIComponentDelegate("com.broceliand.util.tools::LoggerDisplay"));
            addChild(new UIComponentDelegate("com.broceliand.util.tools::PremiumAvailable"));
            addChild(new UIComponentDelegate("com.broceliand.util.tools::QuickHierarchy"));
            
            addChild(new UIComponentDelegate("com.broceliand.util.tools::ByPassCDN"));
         }
      }
   }
}