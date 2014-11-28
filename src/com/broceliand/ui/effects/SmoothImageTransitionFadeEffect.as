package com.broceliand.ui.effects {

   import com.broceliand.util.externalServices.Facebook;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   import mx.controls.Image;
   import mx.core.UIComponent;
   import mx.effects.Fade;
   import mx.effects.Parallel;
   import mx.effects.easing.Sine;
   import mx.events.EffectEvent;
   
   public class SmoothImageTransitionFadeEffect extends EventDispatcher {
      
      public static const TRANSITION_EFFECT_END_EVENT:String = "transitionEffectEndEvent";
      
      private var _duration:Number;
      private var _finalAlpha:Number;
      private var _imageDisappearing:Image;
      private var _imageAppearing:Image;
      
      private var _appearingEffect:Fade;
      private var _disappearingEffect:Fade;
      private var _filter:UIComponent;
      private var _isFilterAppearing:Boolean;
      public function SmoothImageTransitionFadeEffect(disappearingImage:Image, appearingImage:Image, duration:Number, finalAlpha:Number, filter:UIComponent, disappearingWithFilter:Boolean, appearingWithFilter:Boolean) {
         _imageAppearing = appearingImage;
         _imageDisappearing = disappearingImage;
         _duration = duration;
         _finalAlpha = finalAlpha;
         if (disappearingWithFilter != appearingWithFilter) {
            if (appearingWithFilter) {
               _isFilterAppearing = true;
            } else {
               _isFilterAppearing = false;
            }
            _filter = filter;
         }
         
      }
      
      public function play():void {
         initEffect();
         addListener();
         var p : Parallel = new Parallel();
         if (_disappearingEffect != null) {
            p.addChild(_disappearingEffect);
         }
         if (_appearingEffect != null) {
            p.addChild(_appearingEffect);
         }
         if (_filter) {
            var f:Fade= new Fade(_filter);
            f.alphaFrom = _isFilterAppearing ? 0 : 1;
            f.alphaTo =  _isFilterAppearing ? 1:0;
            _filter.alpha = f.alphaFrom; 
            p.addChild(f);
         }
         if (_appearingEffect == null && _disappearingEffect == null) {
            dispatchEvent(new Event(TRANSITION_EFFECT_END_EVENT));
         }
         p.play();
      }
      
      private function initEffect():void {
         initAppearingEffect();
         initDisappearingEffect();
      } 
      
      private function initAppearingEffect():void {
         if (_imageAppearing != null) {
            _appearingEffect = new Fade();
            _appearingEffect.target = _imageAppearing;
            _appearingEffect.duration = _duration;
            _appearingEffect.alphaFrom = 0;
            _appearingEffect.alphaTo = _finalAlpha;
            _imageAppearing.alpha = 0;
            _imageAppearing.visible = _imageAppearing.includeInLayout = true;
         } else {
            _appearingEffect = null;
         }
      }
      
      private function initDisappearingEffect():void {
         if (_imageDisappearing != null) {
            _disappearingEffect = new Fade();
            _disappearingEffect.target = _imageDisappearing;
            _disappearingEffect.duration = _duration;
            _disappearingEffect.alphaFrom = _finalAlpha;
            _disappearingEffect.alphaTo = 0;
            _imageDisappearing.visible = _imageDisappearing.includeInLayout = true;
         } else {
            _disappearingEffect = null;
         }
      } 
      
      private function onTransitionEffectEnd(event:Event):void {
         if (_imageDisappearing != null) {
            _imageDisappearing.visible = _imageDisappearing.includeInLayout = false;
         }
         dispatchEvent(new Event(TRANSITION_EFFECT_END_EVENT));
         removeListener();
      }
      
      private function addListener():void {
         if (_appearingEffect != null) {
            _appearingEffect.addEventListener(EffectEvent.EFFECT_END, onTransitionEffectEnd);
         } else if (_disappearingEffect != null) {
            _disappearingEffect.addEventListener(EffectEvent.EFFECT_END, onTransitionEffectEnd);
         }
      }
      
      private function removeListener():void {
         if (_appearingEffect != null) {
            _appearingEffect.removeEventListener(EffectEvent.EFFECT_END, onTransitionEffectEnd);
         } else if (_disappearingEffect != null) {
            _disappearingEffect.removeEventListener(EffectEvent.EFFECT_END, onTransitionEffectEnd);
         }
      }
      
   }
}