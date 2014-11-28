package com.broceliand.ui.interactors.scroll
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.ApplicationMessageBroadcaster;
   import com.broceliand.pearlTree.io.exporter.PearlTreeAmfExporter;
   import com.broceliand.ui.button.PTArrowButton;
   import com.broceliand.ui.navBar.NavBar;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.ui.util.NullSkin;
   import com.broceliand.ui.util.SkinHelper;
   import com.broceliand.ui.window.WindowController;
   
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   import mx.containers.Canvas;
   import mx.core.Application;
   import mx.core.ScrollPolicy;
   
   public class ScrollUi extends Canvas
   {
      public static const NONE_BUTTON:uint = 0;
      public static const TOP_BUTTON:uint = 1;
      public static const RIGHT_BUTTON:uint = 2;
      public static const BOTTOM_BUTTON:uint = 3;
      public static const LEFT_BUTTON:uint = 4;
      
      private static const PEARLTREES_ARROW_SIZE:Number = 40;
      private static const EMBED_ARROW_SIZE:Number = 20;
      private static const PEARLTREES_ARROW_PADDING:Number = 15;
      private static const EMBED_ARROW_PADDING:Number = 4;
      public static const GROW_EFFECT_DURATION:Number = 3500;
      private static const GROW_EFFECT_ARROW_SCALE:Number = 2;
      
      private var _topButton:PTArrowButton;
      private var _leftButton:PTArrowButton;
      private var _rightButton:PTArrowButton;
      private var _bottomButton:PTArrowButton;
      
      private var _buttons:Vector.<PTArrowButton>;
      
      private var _excitedButtonId:uint;
      private var _excitedButtonIdChanged:Boolean = true;
      
      private var _growEffectTimer:Timer;
      private var _effectStartTime:Number;
      
      function ScrollUi() {
         _growEffectTimer = new Timer(0);
         _growEffectTimer.addEventListener(TimerEvent.TIMER, onTimeToUpdateArrowSize);
      }
      
      public function playGrowEffect():void {
         if(!_growEffectTimer.running) {
            _effectStartTime = new Date().getTime();
            _growEffectTimer.start();
         }
      }
      
      private function onTimeToUpdateArrowSize(event:TimerEvent):void {
         var duration:Number = new Date().getTime() - _effectStartTime;
         var normalToBig:Number = (GROW_EFFECT_ARROW_SCALE * PEARLTREES_ARROW_SIZE) - PEARLTREES_ARROW_SIZE;
         var newArrowSize:Number = PEARLTREES_ARROW_SIZE;
         
         if(duration > GROW_EFFECT_DURATION) {
            newArrowSize = PEARLTREES_ARROW_SIZE;
            _growEffectTimer.stop();
         }
         else if((GROW_EFFECT_DURATION / 2.0) > duration) {
            newArrowSize += (normalToBig * (duration / (GROW_EFFECT_DURATION / 2.0)));
         }else{
            newArrowSize += (normalToBig * (1 - ((duration - (GROW_EFFECT_DURATION / 2.0))  / (GROW_EFFECT_DURATION / 2.0))));
         }
         
         var excitedButton:PTArrowButton = getButton(_excitedButtonId);
         
         for each(var button:PTArrowButton in _buttons) {
            button.maxWidthAndHeight = newArrowSize;
            button.isRoundCorner = true;
            
            if(button != excitedButton) {
               button.unhighlight();
            }
            else {
               button.highlight();
            }
         }
         
         invalidateDisplayList();
         event.updateAfterEvent();
      }
      
      override protected function createChildren():void{
         super.createChildren();
         horizontalScrollPolicy = ScrollPolicy.OFF;
         verticalScrollPolicy = ScrollPolicy.OFF; 
         _buttons = new Vector.<PTArrowButton>();
         
         var isEmbed:Boolean = ApplicationManager.getInstance().isEmbed();
         
         _topButton = new PTArrowButton();
         _topButton.direction = PTArrowButton.TOP;
         this.setArrowStyle(_topButton);
         addChild(_topButton);
         _buttons.push(_topButton);
         
         _rightButton = new PTArrowButton();
         _rightButton.direction = PTArrowButton.RIGHT;
         this.setArrowStyle(_rightButton);
         addChild(_rightButton);
         _buttons.push(_rightButton);
         
         _bottomButton = new PTArrowButton();
         _bottomButton.direction = PTArrowButton.BOTTOM;
         this.setArrowStyle(_bottomButton);
         addChild(_bottomButton);
         _buttons.push(_bottomButton);
         
         _leftButton = new PTArrowButton();
         _leftButton.direction = PTArrowButton.LEFT;
         this.setArrowStyle(_leftButton);
         
         addChild(_leftButton);
         _buttons.push(_leftButton);
         
         ApplicationManager.getInstance().visualModel.applicationMessageBroadcaster.addEventListener(ApplicationMessageBroadcaster.WHITE_MARK_CHANGED_EVENT, onWhiteMarkChanged);
      }
      
      private function onWhiteMarkChanged(event:Event):void {
         invalidateDisplayList();
      }
      
      private function setArrowStyle(arrow:PTArrowButton):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var cp:ColorPalette = ColorPalette.getInstance();
         arrow.setStyle('borderThickness', 0);
         if (am.isEmbed()) {
            arrow.setStyle('fillColor', "#bebebe");
            arrow.setStyle('fillColorOver', "#0092e7");
            arrow.customFilter = new DropShadowFilter(2.5, 90, 0x000000, 0.34, 1.2, 1.2, 1, BitmapFilterQuality.HIGH, true, false);
         }
         else {
            arrow.setStyle('borderColor', cp.backgroundColor);
         }
         arrow.displayShadow = true;
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         var padding:Number = PEARLTREES_ARROW_PADDING;

         var heightOffsetIfAnonymous:int = ApplicationManager.getInstance().components.windowController.offsetHeightDueToSignupBanner();
         
         var realHeight:Number = height - heightOffsetIfAnonymous;
         
         if(ApplicationManager.getInstance().isEmbed()) {
            padding = EMBED_ARROW_PADDING;
         }
         _topButton.move((width - _topButton.width) / 2, padding + heightOffsetIfAnonymous);
         _leftButton.move(padding, heightOffsetIfAnonymous + (realHeight - _leftButton.height) / 2 );
         _rightButton.move(width - _rightButton.width - padding, heightOffsetIfAnonymous + (realHeight - _rightButton.height) / 2);
         _bottomButton.move((width - _bottomButton.width) / 2, height - _bottomButton.height - padding);
      }
      
      override protected function commitProperties():void{
         if(_excitedButtonIdChanged) {
            _excitedButtonIdChanged = false;
            
            var excitedButton:PTArrowButton = getButton(_excitedButtonId);
            var isEmbed:Boolean = ApplicationManager.getInstance().isEmbed();
            
            for each(var button:PTArrowButton in _buttons) {
               if(!_growEffectTimer.running) {
                  if(isEmbed) {
                     button.maxWidthAndHeight = EMBED_ARROW_SIZE;
                  }else{
                     button.maxWidthAndHeight = PEARLTREES_ARROW_SIZE;
                  }
                  button.isRoundCorner = true;
               }
               
               if(button != excitedButton) {
                  button.unhighlight();
               }
               else {
                  button.highlight();
               }
            }
         }
      }
      
      public function set excitedButtonId(value:uint):void {
         if(value != _excitedButtonId) {
            _excitedButtonId = value;
            _excitedButtonIdChanged = true;
            invalidateProperties();
            invalidateDisplayList();
         }
      }
      public function get excitedButtonId():uint {
         return _excitedButtonId;
      }
      
      public function getButton(buttonId:uint):PTArrowButton {
         if(buttonId == TOP_BUTTON) {
            return _topButton;
         }else if(buttonId == RIGHT_BUTTON) {
            return _rightButton;
         }else if(buttonId == BOTTOM_BUTTON) {
            return _bottomButton;
         }else if(buttonId == LEFT_BUTTON) {
            return _leftButton;
         }else{
            return null;
         }
      }
      
      public function isPointOverExcitedButton(point:Point):Boolean {
         var excitedButton:PTArrowButton = getButton(_excitedButtonId);
         return (excitedButton)?excitedButton.hitTestPoint(point.x, point.y):false;
      }
   }
}