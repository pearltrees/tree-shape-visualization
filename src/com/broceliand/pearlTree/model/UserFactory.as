package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   
   import flash.utils.Dictionary;
   
   public class UserFactory
   {
      private static var _isSingleton:Boolean = false;
      private var _userDictionary:Dictionary = new Dictionary();
      
      public function UserFactory(am:ApplicationManager)
      { 
         if (_isSingleton) {
            throw new Error("User Factory should be created only once");
         }
         
         _isSingleton = true;

      }
      
      public function getOrMakeUser(userDb:int, userId:int):User {
         var key:String = User.getUserKey(userDb, userId);
         var ret:User = _userDictionary[key];
         if (ret==null) {
            ret = makeNewUser(userDb, userId);
            _userDictionary[key]= ret;
         } 
         return ret;
      }

      private function makeNewUser(userDb:int, userId:int):User {
         return new User(userDb, userId);
      }

      public function registerCurrentUserInDictionary():void {
         var user:User = ApplicationManager.getInstance().currentUser; 
         _userDictionary[User.getUserKey(user.persistentDbId, user.persistentId)] = user;
      }
      
   }
}
