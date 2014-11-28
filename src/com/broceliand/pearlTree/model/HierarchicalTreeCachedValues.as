package com.broceliand.pearlTree.model
{
   public class HierarchicalTreeCachedValues
   {
      private static var TOTAL_COMMENTS_COUNT:String = "totalCommentsCount"; 
      private static var TOTAL_NEIGHBOURS_COUNT:String = "totalNeighboursCount"; 
      private static var TOTAL_PEARLS_COUNT:String = "totalPearlsCount";
      private static var TOTAL_PAGE_COUNT:String = "totalPageCount";
      private static var TOTAL_TREE_COUNT:String = "totalTreeCount";
      private static var TOTAL_DISTANT_TREE_COUNT:String = "totalDistantTreeCount";
      private static var TOTAL_PEARLS_COUNT_WITHOUT_ALIAS:String = "totalPearlsCountWithoutAlias";
      private static var TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO:String = "totalPearlsCountWithoutAliasLimitedToAsso";
      private static var TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO_WITHOUT_PRIVATE:String = "totalPearlsCountWithoutAliasLimitedToAssoWithoutPrivate";
      private static var TOTAL_HIT_COUNT:String = "totalHitCount";
      private static var TOTAL_MEMBERSHIP_COUNT:String = "totalMembershipCount";
      private static var HAS_CROSS_NOTIFICATIONS:String = "crossNotification";
      private static var HAS_NEW_NOTES_NOTIFICATIONS:String = "notesNotification";
      private static var HAS_STRUCTURE_CHANGED_NOTIFICATIONS:String = "structureNotification";
      private static var HAS_SUB_TEAM:String = "containsTeam";
      private static var HAS_SUB_TEAM_REQUEST:String = "containsRequest";
      
      private  var _cachedValues:Object=new Object();
      private var _isResetted:Boolean = false;
      public function HierarchicalTreeCachedValues()
      {
         resetCache(null);
      }
      
      public function resetCache(owner:BroPearlTree):void {
         if (!_isResetted) {
            if (owner) {
               var path:Array = owner.treeHierarchyNode.getTreePath();
               for each (var tree:BroPearlTree in path) {
                  tree.cachedValues.resetCache(null);
               }
            }
            resetValue(TOTAL_COMMENTS_COUNT); 
            resetValue(TOTAL_NEIGHBOURS_COUNT);
            resetValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS);
            resetValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO);
            resetValue(TOTAL_PEARLS_COUNT); 
            resetValue(TOTAL_HIT_COUNT);
            resetValue(HAS_CROSS_NOTIFICATIONS);
            resetValue(HAS_NEW_NOTES_NOTIFICATIONS);
            resetValue(HAS_STRUCTURE_CHANGED_NOTIFICATIONS);
            resetValue(HAS_SUB_TEAM);
            resetValue(HAS_SUB_TEAM_REQUEST);
            resetValue(TOTAL_MEMBERSHIP_COUNT);
            
         }
         _isResetted = true;
      }

      internal function getTotalHitCount():Number {
         return getValue(TOTAL_HIT_COUNT) as Number;
      }      
      internal function resetTotalHitCount(owner:BroPearlTree):void {
         resetValue(TOTAL_HIT_COUNT, owner, true);
      }
      internal function saveTotalHitCount(count:Number):void {
         saveValue(TOTAL_HIT_COUNT, count);
      }

      internal function getTotalMembershipCount():Number {
         return getValue(TOTAL_MEMBERSHIP_COUNT) as Number;
      }      
      internal function resetTotalMembershipCount(owner:BroPearlTree):void {
         resetValue(TOTAL_MEMBERSHIP_COUNT, owner, true);
      }
      internal function saveTotalMembershipCount(count:Number):void {
         saveValue(TOTAL_MEMBERSHIP_COUNT, count);
      }

      internal function getTotalCommentsCount():Number {
         return getValue(TOTAL_COMMENTS_COUNT) as Number;
      }      
      internal function resetTotalCommentsCount(owner:BroPearlTree):void {
         resetValue(TOTAL_COMMENTS_COUNT, owner, true);
      }
      internal function saveTotalCommentsCount(count:Number):void {
         saveValue(TOTAL_COMMENTS_COUNT, count);
      }

      internal function getTotalNeighboursCount():Number {
         return getValue(TOTAL_NEIGHBOURS_COUNT) as Number;
      }     
      internal function resetTotalNeighboursCount(owner:BroPearlTree):void {
         resetValue(TOTAL_NEIGHBOURS_COUNT, owner, true);
      }
      internal function saveTotalNeighboursCount(count:Number):void {
         saveValue(TOTAL_NEIGHBOURS_COUNT, count);
      }      

      internal function getTotalPearlsCount():Number {
         return getValue(TOTAL_PEARLS_COUNT) as Number;
      }     
      internal function resetTotalPearlsCount(owner:BroPearlTree):void {
         resetValue(TOTAL_PEARLS_COUNT, owner, true);
      }
      internal function saveTotalPearlsCount(count:Number):void {
         saveValue(TOTAL_PEARLS_COUNT, count);
      }
      
      internal function getTotalPageCount():Number {
         return getValue(TOTAL_PAGE_COUNT) as Number;
      }     
      internal function resetTotalPageCount(owner:BroPearlTree):void {
         resetValue(TOTAL_PAGE_COUNT, owner, true);
      }
      internal function saveTotalPageCount(count:Number):void {
         saveValue(TOTAL_PAGE_COUNT, count);
      }
      
      internal function getTotalTreeCount():Number {
         return getValue(TOTAL_TREE_COUNT) as Number;
      }
      internal function resetTotalTreeCount(owner:BroPearlTree):void {
         resetValue(TOTAL_TREE_COUNT, owner, true);
      }
      internal function saveTotalTreeCount(count:Number):void {
         saveValue(TOTAL_TREE_COUNT, count);
      }
      
      internal function getTotalDistantTreeCount():Number {
         return getValue(TOTAL_DISTANT_TREE_COUNT) as Number;
      }
      internal function resetTotalDistantTreeCount(owner:BroPearlTree):void {
         resetValue(TOTAL_DISTANT_TREE_COUNT, owner, true);
      }
      internal function saveTotalDistantTreeCount(count:Number):void {
         saveValue(TOTAL_DISTANT_TREE_COUNT, count);
      }      
      
      internal function getTotalPearlsCountWithoutAlias():Number {
         return getValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS) as Number;
      }      
      internal function saveTotalPearlsCountWithoutAlias(count:Number):void {
         saveValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS, count);
      }
      internal function resetTotalPearlsCountWithoutAlias(owner:BroPearlTree):void {
         resetValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS, owner, true);
      }
      
      internal function getTotalPearlsCountWithoutAliasLimitedToAsso():Number {
         return getValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO) as Number;
      }      
      internal function saveTotalPearlsCountWithoutAliasLimitedToAsso(count:Number):void {
         saveValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO, count);
      }
      internal function resetTotalPearlsCountWithoutAliasLimitedToAsso(owner:BroPearlTree):void {
         resetValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO, owner, true);
      }
      
      internal function getTotalPearlsCountWithoutAliasLimitedToAssoWithoutPrivate():Number {
         return getValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO_WITHOUT_PRIVATE) as Number;
      }      
      internal function saveTotalPearlsCountWithoutAliasLimitedToAssoWithoutPrivate(count:Number):void {
         saveValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO_WITHOUT_PRIVATE, count);
      }
      internal function resetTotalPearlsCountWithoutAliasLimitedToAssoWithoutPrivate(owner:BroPearlTree):void {
         resetValue(TOTAL_PEARLS_COUNT_WITHOUT_ALIAS_LIMITED_TO_ASSO_WITHOUT_PRIVATE, owner, true);
      }

      internal function resetHasCrossNotification(owner:BroPearlTree):void {
         resetValue(HAS_CROSS_NOTIFICATIONS, owner, true);
      }
      internal function saveHasCrossNotification(count:Boolean):void {
         if (count) 
            saveValue(HAS_CROSS_NOTIFICATIONS, 1);
         else 
            saveValue(HAS_CROSS_NOTIFICATIONS, 0);
      }      

      internal function hasCrossNotification():Number {
         return getValue(HAS_CROSS_NOTIFICATIONS) as Number;
      }

      internal function resetHasNotesNotification(owner:BroPearlTree):void {
         resetValue(HAS_NEW_NOTES_NOTIFICATIONS, owner, true);
      }
      internal function saveHasNotesNotification(count:Boolean):void {
         if (count) 
            saveValue(HAS_NEW_NOTES_NOTIFICATIONS, 1);
         else 
            saveValue(HAS_NEW_NOTES_NOTIFICATIONS, 0);
      }      

      internal function hasNotesNotification():Number {
         return getValue(HAS_NEW_NOTES_NOTIFICATIONS) as Number;
      }
      
      internal function resetHasStructureNotification(owner:BroPearlTree):void {
         resetValue(HAS_STRUCTURE_CHANGED_NOTIFICATIONS, owner, true);
      }
      internal function saveHasStructureNotification(value:Number):void {
         saveValue(HAS_STRUCTURE_CHANGED_NOTIFICATIONS, value);
      }      

      internal function hasStructureNotification():Number {
         return getValue(HAS_STRUCTURE_CHANGED_NOTIFICATIONS) as Number;
      }

      internal function resetHasSubTeam(owner:BroPearlTree):void {
         resetValue(HAS_SUB_TEAM, owner, true);
      }
      internal function saveHasSubTeam(value:Number):void {
         saveValue(HAS_SUB_TEAM, value);
      }

      internal function hasSubTeam():Number {
         return getValue(HAS_SUB_TEAM) as Number;
      }
      
      internal function resetHasSubTeamRequest(owner:BroPearlTree):void {
         resetValue(HAS_SUB_TEAM_REQUEST, owner, true);
      }
      internal function saveHasSubTeamRequest(value:Number):void {
         saveValue(HAS_SUB_TEAM_REQUEST, value);
      }

      internal function hasSubTeamRequest():Number {
         return getValue(HAS_SUB_TEAM_REQUEST) as Number;
      }

      private function getValue(name:String):Object {
         return _cachedValues[name];
      }
      private function resetValue(name:String, owner:BroPearlTree=null, resetHierarchyValues:Boolean=false ):void{
         if (resetHierarchyValues && owner) {
            var path:Array = owner.treeHierarchyNode.getTreePath();
            for each (var tree:BroPearlTree in path) {
               tree.cachedValues.resetValue(name, tree, false);
            } 
         } else {
            _cachedValues[name]= -1;
         }
      }
      private function saveValue(name:String, value:Object):void{
         _isResetted = false;
         _cachedValues[name] = value;
      }
   }
}