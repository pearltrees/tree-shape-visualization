package com.broceliand.pearlTree.navigation
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   
   public interface IFlexUrlBuilder {
      
      function buildUserUrl(user:User, pwTab:uint=0):String;
      function buildPearlUrl(node:BroPTNode, focusedTree:BroPearlTree=null, pwTab:uint=0, addOverlayUrl:Boolean=false):String;
   }
}