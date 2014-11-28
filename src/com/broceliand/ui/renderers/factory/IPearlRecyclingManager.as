package com.broceliand.ui.renderers.factory
{
   import com.broceliand.ui.pearl.IUIPearl;
   
   public interface IPearlRecyclingManager
   {
      
      function recyclePearl(pearl:IUIPearl):Boolean;
      function releaseRecycled(maxSize:int=0):void;
   }
}