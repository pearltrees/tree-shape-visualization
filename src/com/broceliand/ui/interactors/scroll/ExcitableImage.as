package com.broceliand.ui.interactors.scroll
{
   import mx.controls.Image;
   
   public class ExcitableImage extends Image
   {
      private var _isDisabled:Boolean;
      private var _excited:Boolean;
      private var _excitedChanged:Boolean;
      private var _relaxedSource:Class;
      private var _excitedSource:Class;
      private var _disableSource:Class;
      
      public function ExcitableImage(relaxedSource:Class, excitedSource:Class, disableSource:Class = null)
      {
         super();
         _excited = false;
         _excitedChanged = true;
         _relaxedSource = relaxedSource;
         _excitedSource = excitedSource;
         _disableSource = disableSource;
      }
      
      public function excite():void { 
         if(!_excited){
            _excitedChanged = true;
            _excited = true;
            invalidateProperties();
         }
      }
      
      public function relax():void{
         if(_excited){
            _excitedChanged = true;
            _excited = false;
            invalidateProperties();
         }
      }
      
      override protected function commitProperties():void{
         if(_excitedChanged){
            _excitedChanged = false;
            var oldSmooth:Boolean = smoothBitmapContent;
            smoothBitmapContent = false;
            if(_excited){
               source = _excitedSource;
            }else{
               if (_isDisabled) {
                  source = _disableSource;
               } else {
                  source = _relaxedSource;
               }
            }
            smoothBitmapContent = oldSmooth;
         }
         super.commitProperties();

      }
      
      public function setDisabled(value:Boolean):void  {
         if (_isDisabled != value) {
            _isDisabled = value;
            if (!_excited) {
               _excitedChanged = true;
               invalidateProperties();
            }
         }
      }     
      public function get relaxedSource():Class
      {
         return _relaxedSource;
      }
      
      public function set relaxedSource(value:Class):void
      {
         if (_relaxedSource != value) {
            _relaxedSource = value;
            _excitedChanged = true;
            invalidateProperties();
         }
      }

   }
}