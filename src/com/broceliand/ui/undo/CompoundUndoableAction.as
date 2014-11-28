package com.broceliand.ui.undo
{
   import mx.controls.ComboBase;
   
   public class CompoundUndoableAction implements IUndoableAction
   {
      private var _canUndo:Boolean;
      private var _subActions:Array;
      
      public function CompoundUndoableAction()
      {
         _subActions = new Array();
         _canUndo = true;
      }
      public function addUndoableAction(action:IUndoableAction):void  {
         if (!action.canUndo()) {
            _canUndo =false;
         }
         _subActions.push(action);
      }
      public function getActionCount():int {
         return _subActions.length;
      }

      public function doIt():void  {
         for each (var a:IUndoableAction in _subActions) {
            a.doIt();
         }
      }     
      public function getOpposite():IUndoableAction {
         if (!canUndo()) return null;
         else {
            var ret:CompoundUndoableAction = new CompoundUndoableAction();
            for (var i:int = _subActions.length; i-->0;) {
               ret.addUndoableAction(_subActions[i].getOpposite());
            }
            return ret;
         } 
         
      }
      
      public function canUndo():Boolean {
         return _canUndo;
      }
   }
}