package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.INeighbourLoader;
   import com.broceliand.util.Assert;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.Dictionary;
   
   public class MyWorldAssociations
   {
      private var _treeHierarchy:TreeHierarchy;
      private var _subAssociations:Dictionary = new Dictionary();
      private var _subAssociationList:Array;
      private var _currentUser:User;
      private var _isReadyForSynchro:Boolean 
      
      public function MyWorldAssociations(currentUser:User)
      {
         _treeHierarchy = currentUser.getAssociation().treeHierarchy
         _currentUser = currentUser;
         _subAssociationList = new Array();
         addAssociation(currentUser.getAssociation());
      }
      
      public function get treeHierarchy():TreeHierarchy
      {
         return _treeHierarchy;
      }
      public function getSubAssociationsLength():int {
         return _subAssociationList.length;
      }
      public function getSubAssociationAt(index:int):BroAssociation {
         return _subAssociationList[index] as BroAssociation;
      }
      public function addAssociation(association:BroAssociation):void {
         if (association.myWorldAssociations != null) {
            Assert.assert(association.myWorldAssociations == this, "Only one my world association");
         } else {
            _subAssociations[association.associationId] = _subAssociationList.length;
            _subAssociationList.push(association);
            association.setMyWorldAssociations(this);
            var treesToEnter:TreeHierarchy = association.treeHierarchy;
            if (treesToEnter) {
               treeHierarchy.addSubHierarchy(treesToEnter);
            }

            association.setTreeHierarchy(_treeHierarchy);
            association.preferredUser = _currentUser;
         }
      }
      public function isSubAssociation(associationId:int):Boolean {
         return _subAssociations[associationId] != null;
      }
      public function getSubAssociationIndex(associationId:int):int {
         if (isSubAssociation(associationId)) {
            return _subAssociations[associationId] as int;
         }
         return -1;
      }
      public function removeAssociation(associationId:Number):void {
         
         var index:int = getSubAssociationIndex(associationId);
         if (index>=0) {
            var association:BroAssociation = getSubAssociationAt(index);
            _subAssociationList.splice(index,1);
            for (var i:int = index; i< _subAssociationList.length; i ++) {
               _subAssociations[BroAssociation(_subAssociationList[i]).associationId] = i;
            }
            delete _subAssociations[associationId];
            association.setMyWorldAssociations(null);

            association.setTreeHierarchy(new TreeHierarchy(association));
            ApplicationManager.getInstance().pearlTreeLoader.loadedTreeMemoryReleaser.unloadAssociationTreeHierarchy(associationId);
            
         }
      }
      public function getRootAssociation():BroAssociation {
         return _subAssociationList[0];
      }
      public function setReadyForSynchro():void {
         _isReadyForSynchro = true;
      }
      public function isReadyForSynchro():Boolean {
         return _isReadyForSynchro;
         
      }
      
   }
}