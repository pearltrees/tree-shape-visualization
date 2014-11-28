package com.broceliand.pearlTree.model.event
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.events.Event;
   
   public class ChangeNodePropertyEvent extends Event
   {
      public static const CHANGE_NODE_EVENT:String ="model.changeNodePropertyEvent";
      public static const NOTE_TEXT_PROPERTY:String ="noteText";
      private var _node:BroPTNode;
      private var _property:String;
      
      public function ChangeNodePropertyEvent(node:BroPTNode, property:String = null) {
         super(CHANGE_NODE_EVENT);
         _node = node;
         _property = property;
      }
      
      public function get property():String {
         return _property;
      }
      
      public function get node():BroPTNode {
         return _node;
      }
   }
}
