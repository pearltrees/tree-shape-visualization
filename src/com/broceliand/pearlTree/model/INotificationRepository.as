package com.broceliand.pearlTree.model {
   import com.broceliand.pearlTree.io.object.note.NotifData;
   import com.broceliand.pearlTree.model.notification.PearlNotification;
   import com.broceliand.pearlTree.model.notification.TreeNotification;
   
   public interface INotificationRepository {
      function onNotificationsLoaded(newNotifs:Array):void;
      function getPearlNotifications(value:BroPTNode, owner:BroPearlTree):PearlNotification;
      function getTreeNotifications(value:BroPearlTree):TreeNotification;
      function unvalidateNotification(value:NotifData):void;
   }
}