package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.IFlexUrlBuilder;
   import com.broceliand.player.PlayerUtils;
   
   public class FlexUrlBuilderImpl implements IFlexUrlBuilder {
      
      public function buildUserUrl(user:User, pwTab:uint=0):String {
         if(!user) return null;
         var rootTree:BroTreeRefNode = user.userWorld;
         var url:String = getRootUrl() + 
            getFocusAssociationParam(user.getAssociation().associationId) + "&" +
            getUserParam(user.persistentDbId, user.persistentId) + "&" +
            getFocusParam(rootTree.treeDB, rootTree.treeId) + "&" +
            getSelectionParam(rootTree.treeDB, rootTree.treeId) + "&" +
            getPearlParam(user.rootPearlDb, user.rootPearlId);
         if(pwTab != 0) url += "&"+getPearlwindowParam(pwTab);
         return url;
      }
      public function buildPearlUrl(node:BroPTNode, focusedTree:BroPearlTree=null, pwTab:uint=0, addOverlayUrl:Boolean=false):String{
         if(!node) return null;
         var tree:BroPearlTree = node.owner;
         var pearlId:int = node.persistentID;
         var pearlDb:int = node.persistentDbID;
         
         if(node is BroPTWDistantTreeRefNode) {
            tree = BroPTWDistantTreeRefNode(node).refTree;
            pearlId = tree.getRootNode().persistentID;
            pearlDb = tree.getRootNode().persistentDbID;
         }
         
         if(!focusedTree) focusedTree = tree;
         var user:User = tree.getMyAssociation().preferredUser;
         
         var url:String = getRootUrl() + 
            getFocusAssociationParam(focusedTree.getMyAssociation().associationId) + "&" +
            getUserParam(user.persistentDbId, user.persistentId) + "&" +
            getFocusParam(focusedTree.dbId, focusedTree.id) + "&" +
            getSelectionParam(tree.dbId, tree.id) + "&" +
            getPearlParam(pearlDb, pearlId);
         if(pwTab != 0) url += "&"+getPearlwindowParam(pwTab);
         if(addOverlayUrl && node is BroPageNode) {
            var playableUrl:String = PlayerUtils.getPlayableUrl(node as BroPageNode);
            if(!playableUrl) playableUrl = "";
            url += "&"+getOverlayUrlParam(playableUrl);   
         }
         return url;
      }
      
      private function getRootUrl():String{
         return ApplicationManager.getInstance().getWebSiteUrl()+"#/";
      }
      private function getFocusAssociationParam(associationId:uint):String{
         var paramId:String = Url2NavigationSynchronizer.HISTORY_CLIENT_NAME+"-"+Url2NavigationSynchronizer.FOCUS_ASSOCIATION_FIELD+"=";
         var paramValue:String = associationId.toString();
         return paramId + paramValue;
      }
      private function getUserParam(userDb:uint, userId:uint):String{
         var paramId:String = Url2NavigationSynchronizer.HISTORY_CLIENT_NAME+"-"+Url2NavigationSynchronizer.USER_FIELD+"=";
         var paramValue:String = userDb+"_"+userId;
         return paramId + paramValue;
      }
      private function getPearlParam(pearlDb:uint, pearlId:uint):String{
         var paramId:String = Url2NavigationSynchronizer.HISTORY_CLIENT_NAME+"-"+Url2NavigationSynchronizer.PEARL_FIELD+"=";
         var paramValue:String = pearlId.toString();
         return paramId + paramValue;
      }
      private function getFocusParam(treeDb:uint, treeId:uint):String{
         var paramId:String = Url2NavigationSynchronizer.HISTORY_CLIENT_NAME+"-"+Url2NavigationSynchronizer.FOCUS_FIELD+"=";
         var paramValue:String = treeDb+"_"+treeId;
         return paramId + paramValue;
      }
      private function getSelectionParam(treeDb:uint, treeId:uint):String{
         var paramId:String = Url2NavigationSynchronizer.HISTORY_CLIENT_NAME+"-"+Url2NavigationSynchronizer.SELECT_FIELD+"=";
         var paramValue:String = treeDb+"_"+treeId;
         return paramId + paramValue;
      }                  
      private function getPearlwindowParam(pwTab:uint):String{
         var paramId:String = Url2NavigationSynchronizer.HISTORY_CLIENT_NAME+"-"+Url2NavigationSynchronizer.PEARL_WINDOW_FIELD+"=";
         var paramValue:String = pwTab.toString();
         return paramId + paramValue;
      }
      private function getOverlayUrlParam(url:String):String {
         var paramId:String = Url2Overlay.OVERLAY_CLIENT_NAME+"-"+Url2Overlay.URL_FIELD+"=";
         var paramValue:String = encodeURIComponent(url);
         return paramId + paramValue;
      }
      
   }
}