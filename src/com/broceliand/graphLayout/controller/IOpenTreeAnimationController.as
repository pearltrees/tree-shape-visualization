package com.broceliand.graphLayout.controller
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.IPearlTreeModel;
   
   import flash.events.IEventDispatcher;
   
   public interface IOpenTreeAnimationController extends IEventDispatcher
   {
      function get isAnimating():Boolean;
      
   }
}