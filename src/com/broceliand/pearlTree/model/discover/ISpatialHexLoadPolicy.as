package com.broceliand.pearlTree.model.discover {

   public interface ISpatialHexLoadPolicy {
      
      function findAndloadMoreHex(model:DiscoverModel, hexFocused:SpatialHex, deltaX:int, deltaY:int, maxHexToLoad:int=-1, showBusyCursor:Boolean = false):void;
   }
}