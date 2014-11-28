package com.broceliand.pearlTree.model {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.object.tree.AssociationData;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   import mx.rpc.events.FaultEvent;
   
   public class BroAssociationParents extends EventDispatcher implements IAmfRetArrayCallback {
      
      public static const ASSOCIATION_PARENTS_STATE_NOTLOADED:int = 0;
      public static const ASSOCIATION_PARENTS_STATE_LOADING:int = 1;
      public static const ASSOCIATION_PARENTS_STATE_LOADED:int = 2;
      
      public static const ASSOCIATION_PARENTS_LOADED_EVENT:String = "AssociationParentsLoaded";
      public static const ASSOCIATION_PARENTS_NOT_LOADED_EVENT:String = "AssociationParentsNotLoaded";
      
      private var _state:int = ASSOCIATION_PARENTS_STATE_NOTLOADED;
      private var _association:BroAssociation;
      private var _parentList:Array;
      
      public function BroAssociationParents(assoValue:BroAssociation) {
         _association = assoValue;
      }
      
      public function loadParents():void {
         if (_state != ASSOCIATION_PARENTS_STATE_LOADING && _association.associationId != -1) {
            _state = ASSOCIATION_PARENTS_STATE_LOADING;
            ApplicationManager.getInstance().distantServices.amfTreeService.getParentAssociations(_association.associationId, this);
         }
      }
      
      public function isLoaded():Boolean {
         return _state == ASSOCIATION_PARENTS_STATE_LOADED;  
      }         
      
      public function get parentList():Array {
         if (_parentList) {
            return _parentList;
         }
         return new Array();
      }
      
      public function get state():int {
         return _state;
      }
      
      public function get association():BroAssociation {
         return _association;
      }
      
      public function onReturnValue(value:Array):void {
         if (value) {
            _parentList = processParentAssociations(value);
            _state = ASSOCIATION_PARENTS_STATE_LOADED;
            
            var event:Event = new Event(ASSOCIATION_PARENTS_LOADED_EVENT);
            dispatchEvent(event);
         }
         else {
            onError(null);
         }
      }
      
      public function onError(message:FaultEvent):void {
         _state = ASSOCIATION_PARENTS_STATE_NOTLOADED;
         var event:Event = new Event(ASSOCIATION_PARENTS_NOT_LOADED_EVENT);
         dispatchEvent(event);
      }
      
      private function processParentAssociations(parentAssos:Array):Array {
         var parents:Array = new Array();
         if (!_association.info || parentAssos == null || parentAssos.length == 0) {
            return parents;
         }
         
         _association.info.ownerCount = parentAssos.length;
         var otherAssos:Array = new Array();
         var asso:BroAssociation;
         for (var i:int = 0 ; i < parentAssos.length ; i++) {
            asso = AmfTreeService.getOrMakeAssociation(parentAssos[i] as AssociationData);
            if (_association.info.foundingAsso == asso) {
               parents.push(asso);
            }
            else {
               otherAssos.push(asso);
            }
         }
         parents = parents.concat(otherAssos);
         return parents;
      }
      
      public function cleanCache():void {
         if (_state == ASSOCIATION_PARENTS_STATE_LOADED) {
            _state = ASSOCIATION_PARENTS_STATE_NOTLOADED;
            _parentList = null;
         }
      }
   }
   
}