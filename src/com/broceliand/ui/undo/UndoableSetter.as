package com.broceliand.ui.undo
{
   public class UndoableSetter implements IUndoableAction
   {
      
      static public function SetValue(source:Object, propertyName:String, newValue:Object, doIt:Boolean=true):void {
         var oldValue:Object = source[propertyName];
         var action :IUndoableAction = new UndoableSetter( newValue, oldValue, source, propertyName);
         if (doIt) action.doIt();
         UndoManager.getSingleton().addUndoableEdit(action);
         
      }
      
      private var _propertyName:String;
      private var _source:Object;
      
      private var _newValue:Object;
      private var _oldValue:Object;
      
      public function UndoableSetter(newValue:Object, oldValue:Object , source:Object, propertyName:String ) {
         
         _newValue = newValue;
         _oldValue = oldValue;
         _source = source;
         _propertyName = propertyName;
      }
      public function doIt():void {
         _source[_propertyName]=_newValue;
      }     
      public function getOpposite():IUndoableAction {
         return new UndoableSetter(_oldValue, _newValue, _source, _propertyName);
      }
      public function canUndo():Boolean {
         return true;
      }
      
   } 
}
