package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PageNode;
   import com.broceliand.util.BroLocale;
   
   import flash.utils.Dictionary;

   public class NodeTitleModel implements INodeTitleModel
   {
      public static const NO_MESSAGE:int = 0;
      public static const MESSAGE_TOO_MANY_NODES_IN_CLOSED_MAP:int = 1;
      public static const MESSAGE_TOO_MANY_NODES_IN_OPEN_MAP:int = 2;
      public static const MESSAGE_TOO_MANY_IMMEDIATE_DESCENDANTS:int = 3;
      public static const MESSAGE_NO_TEAM_IN_TEAM:int = 4;
      public static const MESSAGE_NO_TEAM_TO_THE_ROOT_TEAM:int = 5;
      public static const MESSAGE_NO_TEAM_IN_DROPZONE:int = 6;
      public static const MESSAGE_NO_PRIVATE_IN_PUBLIC_TEAM:int = 7;
      public static const MESSAGE_NO_PUBLIC_TEAM_IN_PRIVATE:int = 8;
      public static const MESSAGE_NO_PENDING_REQUESTS:int = 9;
      public static const MESSAGE_NOT_IN_PENDING_REQUESTS:int = 10;
      public static const MESSAGE_PRIVATE_EXPIRED_PREMIUM:int =11;
      public static const MESSAGE_NO_ALLOW_DELETE_PEARL:int = 12;
      public static const MESSAGE_NO_MOVE_PEARL_OUTSIDE_TEAM:int = 13;
      public static const MESSAGE_NO_COPY_PEARL_WHEN_FULL_STORAGE:int = 14;
      private var _node2NodeMessage:Dictionary;
      public function NodeTitleModel()
      {
         _node2NodeMessage = new Dictionary(true);
      }
      
      public function getNodeTitle(node:IPTNode):String{
         var storedMessageCode:int = getMessageType(node);
         if(storedMessageCode == NO_MESSAGE){
            if(node && node.getBusinessNode()){
               return node.getBusinessNode().title;   
            }
         }else{
            return getLocalizedMessage(storedMessageCode, node);
         }
         
         return "";
      }
      
      public function getMessageType(node:IPTNode):int{
         return _node2NodeMessage[node];
         
      }
      
      public function setNodeMessageType(node:IPTNode, code:int):void {
         var oldMessageType:int = _node2NodeMessage[node]; 
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(code == NO_MESSAGE){
            delete _node2NodeMessage[node];
         }else{
            _node2NodeMessage[node] = code;
         }      
         if((code != oldMessageType) && node.renderer){
            node.renderer.refresh();
            node.renderer.titleRenderer.reposition();
         }            
      }
      
      private function getLocalizedMessage(code:int, node:IPTNode):String{
         if (node is PageNode) {
            switch(code){
               case MESSAGE_TOO_MANY_NODES_IN_CLOSED_MAP:
                  return BroLocale.getText("nodeTitle.tooManyNodesInClosedMap.page");
               case MESSAGE_TOO_MANY_NODES_IN_OPEN_MAP:
                  return BroLocale.getText("nodeTitle.tooManyNodesInOpenMap.page");
               case MESSAGE_TOO_MANY_IMMEDIATE_DESCENDANTS:
                  return BroLocale.getText("nodeTitle.tooManyImmediateDescendants");
               case MESSAGE_NO_TEAM_TO_THE_ROOT_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMoveToRootTeam");
               case MESSAGE_NO_TEAM_IN_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMoveInsideTeam");
               case MESSAGE_NO_TEAM_IN_DROPZONE:
                  return BroLocale.getText("nodeTitle.forbidMoveToDropZone");
               case MESSAGE_NO_ALLOW_DELETE_PEARL:
                  return BroLocale.getText("nodeTitle.forbidDeletePearl");
               case MESSAGE_NO_PRIVATE_IN_PUBLIC_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMoveToPublicTeam");
               case MESSAGE_NO_PUBLIC_TEAM_IN_PRIVATE:
                  return BroLocale.getText("nodeTitle.forbidMoveToPrivateZone");
               case MESSAGE_PRIVATE_EXPIRED_PREMIUM:
                  return BroLocale.getText("nodeTitle.privateExpiredPremium");
               case MESSAGE_NO_MOVE_PEARL_OUTSIDE_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMovePearlOutsideTeam");
               case MESSAGE_NO_COPY_PEARL_WHEN_FULL_STORAGE:
                  return BroLocale.getText("nodeTitle.forbidCopyWhenFullStorage");
            }
         } else {
            switch(code){
               case MESSAGE_TOO_MANY_NODES_IN_CLOSED_MAP:
                  return BroLocale.getText("nodeTitle.tooManyNodesInClosedMap");
               case MESSAGE_TOO_MANY_NODES_IN_OPEN_MAP:
                  return BroLocale.getText("nodeTitle.tooManyNodesInOpenMap");
               case MESSAGE_TOO_MANY_IMMEDIATE_DESCENDANTS:
                  return BroLocale.getText("nodeTitle.tooManyImmediateDescendants");
               case MESSAGE_NO_TEAM_TO_THE_ROOT_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMoveToRootTeam");
               case MESSAGE_NO_TEAM_IN_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMoveInsideTeam");
               case MESSAGE_NO_TEAM_IN_DROPZONE:
                  return BroLocale.getText("nodeTitle.forbidMoveToDropZone");
               case MESSAGE_NO_PRIVATE_IN_PUBLIC_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMoveToPublicTeam");
               case MESSAGE_NO_PUBLIC_TEAM_IN_PRIVATE:
                  return BroLocale.getText("nodeTitle.forbidMoveToPrivateZone");
               case MESSAGE_NO_PENDING_REQUESTS:
                  return BroLocale.getText("nodeTitle.forbidMovePendingRequests");
               case MESSAGE_NOT_IN_PENDING_REQUESTS:
                  return BroLocale.getText("nodeTitle.forbidMoveInPendingRequests");
               case MESSAGE_PRIVATE_EXPIRED_PREMIUM:
                  return BroLocale.getText("nodeTitle.privateExpiredPremium");
               case MESSAGE_NO_ALLOW_DELETE_PEARL:
                  return BroLocale.getText("nodeTitle.forbidDeletePearl");
               case MESSAGE_NO_MOVE_PEARL_OUTSIDE_TEAM:
                  return BroLocale.getText("nodeTitle.forbidMovePearlOutsideTeam");
            }
         }
         trace("unknown message for node title " + code);
         return "";
      }
      
   }
}