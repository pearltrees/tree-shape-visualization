package com.broceliand.util.resources
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.setTimeout;
   
   import mx.controls.Image;
   
   public class ImageFactory
   {
      private static const USE_BUFFER:Boolean = false;
      private static const IMAGE_BUFFER_SIZE:int = 200;
      private static const MAX_IMAGE_CREATED_BY_FRAME:int = 5;
      private static var _imageFactory:ImageFactory = new ImageFactory(false);
      private static var _remoteImageFactory:ImageFactory = new ImageFactory(true);
      
      private var _buffer:Array;
      private var _lastElement:int=-1;
      private var _isRemoteImage:Boolean;
      private var _isFilledScheduled:Boolean = false;
      public function ImageFactory(isRemoteImage:Boolean)
      {
         _isRemoteImage = isRemoteImage;
         if (USE_BUFFER) {
            _buffer = new Array(IMAGE_BUFFER_SIZE);
            fillBuffer();
         }
         
      }
      public static function newImage():Image {
         return _imageFactory.makeImage();
      }
      public static function newRemoteImage():RemoteImage {
         return _remoteImageFactory.makeImage() as RemoteImage;
      }
      private function makeImage():Image {
         if (USE_BUFFER) {
            if (_lastElement>=0) {
               trace("getting image "+ _lastElement);
               var image:Image = _buffer[_lastElement];
               _buffer[_lastElement] = null;
               _lastElement--;
               if (_lastElement==0) {
                  scheduleNextFillBuffer();
               }
               return image;
               
            } else {
               scheduleNextFillBuffer();
            }
         } 
         return makeRemoteImageOrImage();
      } 
      private function makeRemoteImageOrImage():Image {
         if (_isRemoteImage) {
            return new RemoteImage();  
         }
         return new Image();
      }
      public function fillBuffer():void {
         var nbCreatedImage:int =0;
         _isFilledScheduled = false;
         
         while (nbCreatedImage < MAX_IMAGE_CREATED_BY_FRAME && _lastElement < IMAGE_BUFFER_SIZE) {
            
            nbCreatedImage ++;
            _lastElement ++;
            _buffer[_lastElement] = makeRemoteImageOrImage();
         }
         if (_lastElement < IMAGE_BUFFER_SIZE - MAX_IMAGE_CREATED_BY_FRAME) {
            scheduleNextFillBuffer();
         }
         Log.getLogger("com.broceliand.util.resources.ImageFactory").info("Buffer Filled remote?{0}, nb of image in the buffer {1}, nb Created {2}", _isRemoteImage, _lastElement+1, nbCreatedImage )
      }
      
      private function scheduleNextFillBuffer():void {
         if (!_isFilledScheduled) {
            _isFilledScheduled = true;
            setTimeout(runfillAsap, 100);
         }
         
      }
      private function runfillAsap():void {
         var garp:GraphicalAnimationRequestProcessor = ApplicationManager.getInstance().visualModel.animationRequestProcessor;
         if (garp.isBusy) {
            garp.postActionRequest(new GenericAction(garp, this, fillBuffer));  
         } else {
            fillBuffer();
         }
      }
   }
}