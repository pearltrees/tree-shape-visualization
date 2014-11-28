package com.broceliand.pearlTree.model
{
   public class BroAnonymousTreeRefNode extends BroDistantTreeRefNode
   {
      private static var _singleton:BroAnonymousTreeRefNode; 
      private static var _home:BroAnonymousTreeRefNode;
      private var _isHome:Boolean = false;
      public function BroAnonymousTreeRefNode()
      {
         super(new BroPearlTree(), User.GetWhatsHotUser());
         refTree.id=0;
         refTree.dbId=0;
         refTree.title="What's hot";
      }
      public static function GetAnonymousTreeRefNode(isHome:Boolean):BroAnonymousTreeRefNode {
         if (isHome) {
            if (!_home) {
               _home= new BroAnonymousTreeRefNode();
               _home._isHome = true;
            } 
            return _home;
         } else {
            if (!_singleton) {
               _singleton = new BroAnonymousTreeRefNode();
            } 
            return _singleton;
         }
      }
      public function get isHome():Boolean {
         return _isHome;
      }
      
      override public function get user():User {
         return User.GetWhatsHotUser();
      }      
   }
}