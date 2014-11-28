package com.broceliand.pearlTree.model
{
   import com.broceliand.graphLayout.model.IPTNode;
   
   import flash.geom.Point;
   
   public interface IBroPTWNode
   {
      
      function get preferredRadialPosition():BroRadialPosition;
      function set preferredRadialPosition(pos:BroRadialPosition ):void;
      
      function get absolutePosition():Point;
      function set absolutePosition(value:Point):void;
      
      function set isSearchCenter (value:Boolean):void;
      function get isSearchCenter ():Boolean;
      
      function set isSearchNode (value:Boolean):void;
      function get isSearchNode ():Boolean;
      
      function get title():String;
      
      function get indexKey():String;
      function navigateToPearl(selectedNode:IPTNode):void;
   }
}