package com.broceliand.ui
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ui.button.PTLinkButton;
   import com.broceliand.ui.button.PTRoundButton;
   import com.broceliand.ui.button.PTTextButton;
   import com.broceliand.ui.list.ListShadow;
   import com.broceliand.ui.pearlWindow.ui.base.PWNavLink;
   import com.broceliand.ui.pearlWindow.ui.base.PWOptionLinkButton;
   import com.broceliand.ui.textInput.PTTextArea;
   import com.broceliand.ui.textInput.PTTextInput;
   
   import flash.events.IEventDispatcher;
   
   import mx.core.Application;
   import mx.events.StyleEvent;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.IStyleManager;
   import mx.styles.StyleManager;
   
   public class PTStyleManager extends StyleManager
   {
      private var _defaultStylesApplied:Boolean;
      private static var _singleton:PTStyleManager;
      public static const SYSTEM_FONT_FAMILY:String = "Arial, Arial Unicode MS, Helvetica, sans-serif";
      public static const SYSTEM_FONT_FAMILY_TIMES_NEW_ROMAN:String = "Times New Roman, Arial, Arial Unicode MS, Helvetica, sans-serif";
      public static const DEFAULT_FONT_FAMILY:String = "PTArial";
      
      public static const SCRAP_LENGTH_FOR_BIG:uint = 200;
      public static const SCRAP_FONTSIZE_FOR_BIG:uint = 42;
      public static const SCRAP_LENGTH_FOR_MEDIUM:uint = 600;
      public static const SCRAP_FONTSIZE_FOR_MEDIUM:uint = 30;
      
      public static const SCRAP_FONTSIZE_FOR_SMALL:uint = 20; 
      public static const SCRAP_FONTSIZE_NON_USER_CONTENT:uint = 18;
      
      public var H1_STYLE:Object = new Object();
      public var H2_STYLE:Object = new Object();
      public var H3_STYLE:Object = new Object();
      public var H4_STYLE:Object = new Object();
      public var H5_STYLE:Object = new Object();
      public var H6_STYLE:Object = new Object();
      public var A_STYLE:Object = new Object();
      
      public function PTStyleManager() {
         super();
      }
      
      public static function getInstance():PTStyleManager {
         if(!_singleton) {
            _singleton = new PTStyleManager();
            _singleton.defineTitleStyles();
            _singleton.defineLinkStyle();
         }
         return _singleton;
      }
      
      public function applyDefaultStyles():void {
         PTLinkButton.constructDefaultStyle(false);
         PTTextButton.constructDefaultStyle(false);
         PTRoundButton.constructDefaultStyle(false);
         ListShadow.constructDefaultStyle(false);
         PWNavLink.constructDefaultStyle(false);
         PTTextArea.constructDefaultStyle(false);
         PTTextInput.constructDefaultStyle(false);
         
         PWOptionLinkButton.constructDefaultStyle(true);
         _defaultStylesApplied = true;
      }
      
      public function hasStyleDeclaration(selector:String):Boolean {
         return (getStyleDeclaration(selector) != null);
      }
      
      public function getStyleDeclaration(selector:String):CSSStyleDeclaration {
         
         return StyleManager.getStyleDeclaration(selector);
      }
      
      public function addStyleDeclaration(selector:String, styleDeclaration:CSSStyleDeclaration, update:Boolean):void {
         if(!_defaultStylesApplied) update = false;
         
         StyleManager.setStyleDeclaration(selector, styleDeclaration, update);
      }
      
      public function defineTitleStyles():void {
         var styles:Array = new Array(H5_STYLE, H4_STYLE, H3_STYLE);
         var currentSize:uint = PTStyleManager.SCRAP_FONTSIZE_FOR_SMALL;
         var currentStyle:Object;
         
         for (var i:int = 0; i < styles.length; i++) {
            
            currentStyle = styles[i];
            currentStyle.fontSize = currentSize;
            
            currentSize = currentSize + 2;
         }         
      }
      
      public function defineLinkStyle():void {
         A_STYLE.color = '#424a79';
         
      }
      
   }
}