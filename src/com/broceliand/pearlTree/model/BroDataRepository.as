package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.util.Assert;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.utils.Dictionary;
   
   import mx.events.FlexEvent;

	public class BroDataRepository implements IDataRepository
   {
      private var _myWorldAssociation:BroAssociation;
      private var _associationId2Association:Dictionary = new Dictionary();
      private var _userId2Association:Dictionary = new Dictionary();
      private var _id2Trees:Dictionary = new Dictionary();

	public function BroDataRepository()
      {
      }
      public function getTree(treeId:Number):BroPearlTree {
         return _id2Trees[treeId];
      }
      public function getOrMakeAssociation(associationId:Number):BroAssociation {
         var result:BroAssociation = _associationId2Association[associationId];
         if (!result) {
            result = new BroAssociation();
            result.associationId = associationId;
            _associationId2Association[associationId] = result;
         }
         return result;
      }
      public function getMyRootAssociation():BroAssociation {
         if (!_myWorldAssociation) {
            var user:User = ApplicationManager.getInstance().currentUser;
            
            Assert.assert(user.isInit(), "user must have been init by now !");
            if (user.isInit()) {
               _myWorldAssociation = getOrMakeAssociation(user.userWorld.treeId);
            } 
            _myWorldAssociation.preferredUser = user;
         }
         return _myWorldAssociation;
      }
      public function registerAssociation(association:BroAssociation):Boolean {
         Assert.assert(association.associationId>0, "bad association Id:"+association.associationId);
         
         if (_associationId2Association[association.associationId] == null) {
            _associationId2Association[association.associationId]  = association;
            return true;
         } else {
            return false;
         }
      }
      public function getUserAssociation(user:User):BroAssociation {
         if (user.isInit()) {
            var result:BroAssociation =  getOrMakeAssociation(user.userWorld.treeId);
            result.preferredUser = user;
            return result;
         } else {
            return getUserAssociationFromUnloadedUser(user);
         }
      }
      
      private function getUserAssociationFromUnloadedUser(user:User):BroAssociation {
         var result:BroAssociation = _userId2Association[user.persistentId];
         if (!result) {
            result = new BroAssociation();
            result.preferredUser = user;
            _userId2Association[user.persistentId] = result;
            user.addEventListener(FlexEvent.INIT_COMPLETE, new GenericAction(null, this, updateUserAssociationOnLoad, user).performActionOnFirstEvent);
         }
         return result;
         
      }
      private function updateUserAssociationOnLoad(user:User):void {
         var association:BroAssociation = _userId2Association[user.persistentId];
         delete _userId2Association[user.persistentId];
         var oldAsso:BroAssociation = _associationId2Association[user.userWorld.treeId];
         if (oldAsso && oldAsso.treeHierarchy != null && oldAsso != association) {
            Log.getLogger("com.broceliand.pearlTree.model").warn("User Association defined several time");
         } else {
            _associationId2Association[user.userWorld.treeId]= association;
         }
      }
      public function registerUniqueTreeInstance(broTree:BroPearlTree):Boolean{
         
         if (broTree.isOwner) {
            var oldTree:BroPearlTree =  _id2Trees[broTree.id];
            Log.getLogger("com.broceliand.pearlTree.model.BroDataRepository").info("register tree in dataRepository {0} {1}({2})", broTree.traceId(), broTree.title, broTree.id);
            
            if ( oldTree != null && oldTree != broTree) {
               _id2Trees[broTree.id] = broTree;
               Log.getLogger("com.broceliand.pearlTree.model.BroDataRepository").warn("replacing old tree was {0} {1}({2})", oldTree.traceId(), oldTree.title, oldTree.id);
               return false;
               
            }
            
            _id2Trees[broTree.id] = broTree;
            return true;
         } 
         return false;
         
      }
      public function changeTreeAssociation(tree:BroPearlTree, targetAssocation:BroAssociation):void {
         
         tree.owner = targetAssocation;
      }
      public function releaseTree(tree:BroPearlTree):void {
         var l:BroLogger = Log.getLogger("com.broceliand.pearlTree.model"); 
         l.info("Release tree {0} {1}({2})", tree.traceId(), tree.title, tree.id);
         if (getTree(tree.id) == tree) {
            delete _id2Trees[tree.id];
         } else {
            l.warn("tree {0} {1}({2}) is not in the same in the repository ", tree.traceId(), tree.title, tree.id);
         }
      }
      public function removeInstanceTreeFromHierarchyAndRepository(tree:BroPearlTree, withDescendant:Boolean):Boolean {
         if (tree.isOwner) {
            if (withDescendant) {
               var treestoRemove:Array = tree.treeHierarchyNode.getDescendantTrees(true, false);
               for each (var t:BroPearlTree in treestoRemove) {
                  removeInstanceTreeFromHierarchyAndRepository(t, false);
               }
            } else {
               tree.treeHierarchyNode.removeFromParent();
               tree.hierarchyOwner.treeHierarchy.removeTreeFromHierarchy(tree);
               releaseTree(tree);
            }
            return true;
         }  else {
            tree.treeHierarchyNode.removeFromParent();
         }
         return false;
      }
   }
}