package com.broceliand.ui.assemblerinfotip {
   import com.broceliand.graphLayout.model.IPTNode;
   
   import flash.events.IEventDispatcher;

   public interface IPTInfotipManager extends IEventDispatcher {
      function clearMessage():void;
      function enterPearlWithNews(node:IPTNode):void;
      function exitPearlWithNews():void;
      function enterNextNewsButton(node:IPTNode):void;
      function exitNextNewsButton():void;
      function get currentMessage():uint;
   }
}