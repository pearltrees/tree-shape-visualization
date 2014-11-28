package com.broceliand.ui.model
{
   import com.broceliand.graphLayout.model.IPTNode;
   
   public interface INodeTitleModel
   {
      function getMessageType(node:IPTNode):int;
      function getNodeTitle(node:IPTNode):String;
      function setNodeMessageType(node:IPTNode, code:int):void;      
   }
}