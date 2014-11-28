package com.broceliand.ui.interactors.drag
{
   import mx.containers.Canvas;
   import mx.controls.Image;
   
   public class ImageWithMask extends Canvas
   {
      
      private var _imageToMask:Image;
      private var _maskImage:Image;

      public function ImageWithMask()
      {
         super();
         _imageToMask = new Image();
         _maskImage = new Image();
         
         _imageToMask.cacheAsBitmap = true;
         _maskImage.cacheAsBitmap = true;
         _imageToMask.mask = _maskImage;
      }
      
      override protected function createChildren():void{
         super.createChildren();
         addChild(_imageToMask);
         addChild(_maskImage);
      }
      public function get imageToMask():Image {
         return _imageToMask;
      }

      public function get maskImage():Image {
         return _maskImage;
      }
      
   }
}