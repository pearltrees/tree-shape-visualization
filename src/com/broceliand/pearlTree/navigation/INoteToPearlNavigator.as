package com.broceliand.pearlTree.navigation
{
   import com.broceliand.pearlTree.model.BroComment;
   
   public interface INoteToPearlNavigator
   {
      function goToPearl(note:BroComment):void;
      function goToUser(userkey:String):void;
   }
}