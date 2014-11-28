package com.broceliand.util
{
   import com.broceliand.util.logging.Log;
   
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   
   import mx.core.UIComponent;
   
   public class PTKeyboardListener extends EventDispatcher
   {
      public static const ENTER_KEY_CODE:uint = Keyboard.ENTER;
      public static const ESCAPE_KEY_CODE:uint = Keyboard.ESCAPE;
      public static const PLUS_KEY_CODE:uint = 43;
      public static const MINUS_KEY_CODE:uint = 45;
      public static const UP_ARROW_CODE:uint = 38;
      public static const DOWN_ARROW_CODE:uint = 40;
      public static const LEFT_ARROW_CODE:uint = 37;
      public static const RIGHT_ARROW_CODE:uint = 39;
      
      private var _keyListeners:Array;
      private var _stage:Stage;
      private var _keyDownDelegate:Object;
      
      public function PTKeyboardListener(value:Stage=null) {
         _keyListeners = new Array();
         listenStage(value);
      }
      
      public function addKeyDownDelegate(delegateKeyDown:Function):void {
         if (_keyDownDelegate != null) {
            Log.getLogger("com.broceliand.util").warn("Warning replacing keydownDelegate");
         }
         _keyDownDelegate = delegateKeyDown;    
      }
      public function removeKeyDownDelegate(delegateKeyDown:Function):void {
         if (_keyDownDelegate == delegateKeyDown) {
            _keyDownDelegate = null;
         }
      }

      public function listenStage(value:Stage):void {
         if(value != _stage) {
            if(_stage) {
               _stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
               _stage = null;               
            }
            if(value) {
               _stage = value;
               _stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            }
         }
      }
      
      public function listenComponent(value:UIComponent):void {
         value.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      }
      
      public function stopListeningComponent(value:UIComponent):void {
         value.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      }

      public function addKeyboardListener(listener:Function, keyCode:uint, ctrlKey:Boolean=false, shiftKey:Boolean=false):void {
         var keyListener:KeyCodeListener = new KeyCodeListener();
         keyListener.listener = listener;
         keyListener.keyCode = keyCode;
         keyListener.ctrlKey = ctrlKey;
         keyListener.shiftKey = shiftKey;
         
         _keyListeners.push(keyListener);
      }
      
      public function removeKeyboardListener(listener:Function, keyCode:uint, ctrlKey:Boolean=false, shiftKey:Boolean=false):void {
         var keyListener:KeyCodeListener = new KeyCodeListener();
         keyListener.listener = listener;
         keyListener.keyCode = keyCode;
         keyListener.ctrlKey = ctrlKey;
         keyListener.shiftKey = shiftKey;
         removeKeyListener(keyListener);
      }
      
      private function removeKeyListener(keyListener:KeyListener):void {
         for (var i:int =0; i< _keyListeners.length; ++i) {
            var k:KeyListener = _keyListeners[i];
            if (keyListener.equalsTo(k)) {
               _keyListeners.splice(i,1);
               i--;
            }
         }
         
      }
      
      public function addCharKeyListener(listener:Function, charCode:uint, ctrlKey:Boolean=false):void  {
         var keyListener:CharListener= new CharListener();
         keyListener.listener = listener;
         keyListener.charCode = charCode;
         keyListener.ctrlKey = ctrlKey;
         _keyListeners.push(keyListener);
      }
      
      public function removeCharKeyListener(listener:Function, charCode:uint, ctrlKey:Boolean=false):void  {
         var keyListener:CharListener= new CharListener();
         keyListener.listener = listener;
         keyListener.charCode = charCode;
         keyListener.ctrlKey = ctrlKey;
         removeKeyListener(keyListener);
      }
      
      private function onKeyDown(event:KeyboardEvent):void {
         for each(var ketListener:KeyListener in _keyListeners) {
            if(ketListener.matchEvent(event)) {
               ketListener.listener.apply();
            }
         }
         if (_keyDownDelegate != null) {
            _keyDownDelegate.apply(null, [event]);
         }
         event.stopImmediatePropagation();
      }
      
      public static function charToKeyCode(char:String):int {
         var strNums:String = "0123456789";
         var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
         
         if (strNums.indexOf(char) != -1) {
            return strNums.indexOf(char) + 48;
         } 
         else if (strCaps.indexOf(char) != -1) {
            return strCaps.indexOf(char) + 65;
         }
         else {
            return -1;
         }
      }
      
      public static function keyCodeToChar(keyCode:int):String {
         if (keyCode > 47 && keyCode < 58) {
            var strNums:String = "0123456789";
            return strNums.charAt(keyCode - 48);
         } 
         else if (keyCode > 64 && keyCode < 91) {
            var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            return strCaps.charAt(keyCode - 65);
         }
         else {
            return null;
         }
      }
   }
}
import flash.events.KeyboardEvent;

internal class KeyListener {
   public var listener:Function;
   public var ctrlKey:Boolean;
   
   public function matchEvent(ev:KeyboardEvent):Boolean {
      return ev.ctrlKey == ctrlKey;
   }
   public function equalsTo(keyListener:KeyListener):Boolean {
      return listener == keyListener.listener && ctrlKey == keyListener.ctrlKey;
   }
}

internal class KeyCodeListener extends KeyListener {
   public var keyCode:uint;
   public var shiftKey:Boolean;
   public override function matchEvent(ev:KeyboardEvent):Boolean {
      return super.matchEvent(ev) && ev.keyCode == keyCode && shiftKey == ev.shiftKey;	
   }
   override public function equalsTo(k:KeyListener):Boolean {
      if (super.equalsTo(k) &&  k is KeyCodeListener) {
         return keyCode == (k as KeyCodeListener).keyCode && shiftKey == (k as KeyCodeListener).shiftKey;
      }
      return false;
   }
   
}

internal class CharListener extends KeyListener {
   public var charCode:uint;
   public override function matchEvent(ev:KeyboardEvent):Boolean {
      return super.matchEvent(ev) && ev.charCode == charCode;
   }
   
   override public function equalsTo(k:KeyListener):Boolean {
      if (super.equalsTo(k) && k is CharListener) {
         return charCode == (k as CharListener).charCode;
      }
      return false;
   }
}
