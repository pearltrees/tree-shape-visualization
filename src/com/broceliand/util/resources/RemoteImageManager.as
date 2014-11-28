package com.broceliand.util.resources
{
   public class RemoteImageManager extends DisposingRemoteResourceManager
   {
      public function RemoteImageManager(maxNumElements:uint=DEFAULT_MAX_NUM_ELEMENTS, numToFlushAtATime:uint=DEFAULT_NUM_ELEMENTS_TO_FLUSH_AT_A_TIME)
      {
         super(maxNumElements, numToFlushAtATime);
      }
      
   }
}