package com.broceliand.ui.undo
{
   import com.broceliand.util.UrlNavigationController;
   
   import flash.utils.getTimer;
   
   import mx.managers.IHistoryManagerClient;
   
   public class UndoManager implements IHistoryManagerClient
   {
      private static var _UndoManagerSingleton:UndoManager;
      private static const  HISTORY_CLIENT_NAME:String="U";
      private static const  TIME_FIELD:String="t";
      private static const  HISTORY_INDEX_FIELD:String="i";
      
      [ArrayElementType="com.broceliand.ui.undo.IUndoableAction"]
      private var _undoStack:Array; 
      private var _redoStack:Array;
      private var _historyIndex:int=0;		
      
      private var _historyMaxSize:int=1000;
      private var _lastUndoableEdit:int=-1;
      private var _timeAtCreation:int=0;
      private var _currentAction :CompoundUndoableAction=null;
      private var _startIndex:int=0;
      private var _isPerformingUndoRedoAction:Boolean =false;
      
      public static function getSingleton():UndoManager {
         if (_UndoManagerSingleton ==null) {
            _UndoManagerSingleton = new UndoManager();
            UrlNavigationController.registerHistory(HISTORY_CLIENT_NAME,_UndoManagerSingleton);
            
         }
         return _UndoManagerSingleton; 
      }
      
      public function saveState():Object {
         var state:Object = new Object();
         state[HISTORY_INDEX_FIELD]=_historyIndex;
         state[TIME_FIELD]=_timeAtCreation;
         return state;
      }
      
      public function loadState(state:Object):void {
         
         var newHistoryIndex:int= _historyIndex==1? 0:_historyIndex;
         if (state!= null) {
            if (state.t==_timeAtCreation)
               newHistoryIndex =int(state.hi);
         }
         while (newHistoryIndex < _historyIndex && _undoStack.length>0) {
            undo();
         }
         while (newHistoryIndex >_historyIndex) {
            redo();
         }
         
      }
      
      public function toString():String {
         return "um";
      }
      public function UndoManager()
      {
         _undoStack= new Array();
         _redoStack= new Array();
         _timeAtCreation = getTimer();
      }
      public function addUndoableEdit(edit:IUndoableAction):void {
         if (_isPerformingUndoRedoAction) return;
         if (_currentAction!= null) {
            _currentAction.addUndoableAction(edit);
         } else {
            addUndoableActionInternal(edit);
         }
         
      }
      
      public function addUndoableActionInternal(edit:IUndoableAction):void {
         _historyIndex++;
         if (!edit.canUndo()) {
            _undoStack = new Array();
            _lastUndoableEdit=_historyIndex;
         } else {
            _redoStack =null;
            if (_undoStack.length>=_historyMaxSize) {
               _undoStack.shift();
            }
            _undoStack.push(edit);
            UrlNavigationController.save();
         }
         
      }
      public function startAction():void {
         if (_startIndex == 0) {
            _currentAction = new CompoundUndoableAction();
         }
         _startIndex ++;
         
      }
      public function endAction():void {
         _startIndex--;
         if (_startIndex == 0) {
            if( _currentAction.getActionCount()>0){
               addUndoableActionInternal(_currentAction);
            }
            _currentAction = null;  
         }
         _startIndex ++;
         
      } 

      public function canUndo():Boolean {
         return _undoStack.length>0 && (_undoStack[length-1]as IUndoableAction).canUndo();
      }
      public function canRedo():Boolean {
         return _redoStack != null && _redoStack.length>0;   
      }

      public function undo():void{
         _isPerformingUndoRedoAction = true;
         _historyIndex--;
         
         if (_undoStack.length>0) {
            var edit:IUndoableAction = _undoStack.pop();
            edit = edit.getOpposite();
            edit.doIt();
            if (_redoStack == null) _redoStack = new Array();
            _redoStack.push(edit);
            
         }
         _isPerformingUndoRedoAction = false;   
      }

      public function redo():void{
         _isPerformingUndoRedoAction = true;
         _historyIndex++;
         if (!canRedo()) return;
         var edit:IUndoableAction = _redoStack.pop();
         edit = edit.getOpposite();
         edit.doIt();
         if (_redoStack == null) _redoStack = new Array();
         _undoStack.push(edit);
         if (_undoStack.length>_historyMaxSize) {
            _undoStack.shift();
         }
         _isPerformingUndoRedoAction = false;

      }
      
      public function set historyMaxSize (value:int):void
      {
         _historyMaxSize = value;
      }
      
      public function get historyMaxSize ():int
      {
         return _historyMaxSize;
      }

   }
}