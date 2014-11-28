package com.broceliand.pearlTree.model.treeEdito
{
   import com.broceliand.pearlTree.io.object.tree.TreeEditoData;
   import com.broceliand.ui.model.NoteModel;
   import com.broceliand.util.IAction;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class TreeEdito{   
      private var _treeId:int;
      private var _text:String;
      private var _lastUpdate:Number;
      
      private var _accessor:TreeEditoAccessor;
      
      public function TreeEdito() {
      }
      
      public static function makeFromTreeEditoData(editoData:TreeEditoData):TreeEdito {
         if (editoData) {
            var edito:TreeEdito = new TreeEdito();
            edito.treeId = editoData.treeId;
            edito.text = editoData.text;
            edito.lastUpdate = editoData.lastUpdate;
            return edito;
         }
         else {
            return null;
         }
      }
      
      public function get treeId():int {
         return _treeId;
      }
      
      public function set treeId(value:int):void {
         _treeId = value;
      }
      
      public function get text():String {
         return _text;
      }
      
      public function set text(value:String):void {
         _text = value;
      }
      
      public function get lastUpdate():Number {
         return _lastUpdate;
      }
      
      public function set lastUpdate(value:Number):void {
         _lastUpdate = value;
      }
      
      public function getEditoText():String {
         if(_text) {  
            return NoteModel.formatNoteToDisplay(_text);
         }else{
            return "";
         }
      }   
      
      private function get accessor():TreeEditoAccessor {
         if (_accessor == null) {
            _accessor = new TreeEditoAccessor();
            _accessor.owner = this;
         }
         return _accessor;
      }
      
      public function loadEdito(updateCB:IAction):void {
         accessor.loadValue(updateCB);
      }
      
      public function isLoaded():Boolean {
         return accessor.isLoaded() || text != null;
      }       
   }
}

import com.broceliand.ApplicationManager;
import com.broceliand.pearlTree.io.LazyValueAccessor;
import com.broceliand.pearlTree.io.object.tree.TreeEditoData;
import com.broceliand.pearlTree.io.object.user.UserData;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetTreeEditoCallback;
import com.broceliand.pearlTree.model.treeEdito.TreeEdito;
import com.broceliand.util.Assert;
import com.broceliand.util.IAction;

class TreeEditoAccessor extends LazyValueAccessor implements IAmfRetTreeEditoCallback  {   
   private function get edito():TreeEdito {         
      return super._owner as TreeEdito;         
   }
   
   override protected function launchLoadValue():void  {
      if (edito) {
         ApplicationManager.getInstance().distantServices.amfTreeService.getTreeEdito(edito.treeId, this);
      } 
      else {
         super.onError(null);
      }
   }
   
   public function onReturnValue(editoData:TreeEditoData):void {
      Assert.assert(edito.treeId == editoData.treeId, "id of the tree edito must matched");
      super.internalValue = editoData;
      edito.text = editoData.text;
      edito.lastUpdate = editoData.lastUpdate;
      notifyValueAvailable();
   }   
}   

