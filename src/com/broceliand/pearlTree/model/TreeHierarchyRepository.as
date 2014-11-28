package com.broceliand.pearlTree.model
{
   import flash.utils.Dictionary;
   
   public class TreeHierarchyRepository
   {
      private var _user2TreeHierarchy:Dictionary = new Dictionary;
      public function TreeHierarchyRepository()
      {
         
      }
      
      public function getTree(user:User, treeDb:int, treeId:int):BroPearlTree{
         var treeHierarchy:TreeHierarchy = _user2TreeHierarchy[user];
         if (treeHierarchy==null) {
            throw new Error("Internal Error : trees hierarchy for "+user.name+ "not loaded yet.");
         }
         return treeHierarchy.getTree(treeDb, treeId);
      }

      public function registerTreeHierarchy(user:User, hierarchy:TreeHierarchy):void {
         _user2TreeHierarchy[user] = hierarchy;
      }  
      public function isUserHierarchyRegistered(user:User):Boolean {
         return _user2TreeHierarchy[user]!=null;
         
      } 
   }
}