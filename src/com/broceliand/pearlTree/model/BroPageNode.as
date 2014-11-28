package com.broceliand.pearlTree.model {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.LazyValueAccessor;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.ui.model.NoteModel;

   public class BroPageNode extends BroPTNode {
      
      private var _refPage:BroPage;
      private var _createdFromHistory:Boolean;
      private var _lastEditorAccessor:LastEditorAccessor;
      
      public function BroPageNode(p:BroPage) {
         super();
         _refPage=p;
         _noteMode = 0;
         _lastEditorAccessor = null;
      }
      
      public override function set title (value:String):void{
         if(_refPage) {
            _refPage.title = value;
         }
         super.title = title;
      }
      public override function get title ():String {
         if(_refPage) {
            return _refPage.title;
         }
         return super.title;
      }
      
      public function get refPage():BroPage {
         return _refPage;
      }      
      public function set refPage(value:BroPage):void {
         _refPage = value;
      }
      
      public function get createdFromHistory ():Boolean {
         return _createdFromHistory;
      }		
      public function set createdFromHistory (value:Boolean):void {
         _createdFromHistory = value;
      }
      
      public override function toString():String {
         return _refPage.toString();
      }
      public function isWelcomePage():Boolean {
         return _refPage.isWelcomePage(); 
      }
      override public function makeCopy():BroPTNode {
         var newBroPageNode:BroPageNode = new BroPageNode(refPage.clone());
         newBroPageNode.serverFullFeedNoteCount = serverFullFeedNoteCount;
         newBroPageNode.neighbourCount = neighbourCount;
         return newBroPageNode;
      }          		
      override public function get noteMode():uint{
         if (_noteMode == 0) {
            if (WelcomePearlsExceptions.isWelcomePage(_refPage) && !WelcomePearlsExceptions.isWelcomePearlFromPearltreesAccount(this)) {
               _noteMode = NoteModel.MODE_LOCAL;
            } else {
               _noteMode = NoteModel.MODE_PAGE_DEFAULT;
            }
         } 
         return super.noteMode;
      }
      override public function isRefTreePrivate():Boolean {
         return isOwnerPrivate();
      }
      
      override public function canBeCopy():Boolean {
         if (isRefTreePrivate() && refPage.isUserContent()) {
            if (!isCurrentUserOwner()) {
               return false;
            } 
         }
         return true;
      }
      
      public function setCurrentUserAsLastEditor():void {
         (getLastEditorAccessor() as LastEditorAccessor).setLastEditor(ApplicationManager.getInstance().currentUser);
      }
      
      public function getLastEditor():User{
         return (getLastEditorAccessor() as LastEditorAccessor).getLastEditor();
      }
      
      public function getLastEditorAccessor():LazyValueAccessor {
         if (_lastEditorAccessor == null) {
            _lastEditorAccessor = new LastEditorAccessor();
            _lastEditorAccessor.owner = this;
         }        
         return _lastEditorAccessor;
      }
   }
}

import com.broceliand.ApplicationManager;
import com.broceliand.pearlTree.io.object.tree.AssociationData;
import com.broceliand.pearlTree.io.object.user.UserData;
import com.broceliand.pearlTree.io.services.AmfTreeService;
import com.broceliand.pearlTree.io.services.AmfUserService;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetUserCallback;
import com.broceliand.pearlTree.model.BroPage;
import com.broceliand.pearlTree.model.BroPageNode;
import com.broceliand.pearlTree.model.User;
import com.broceliand.pearlTree.model.UserFactory;
import com.broceliand.util.logging.Log;
import com.broceliand.pearlTree.io.LazyValueAccessor;

import mx.collections.ArrayCollection;

class LastEditorAccessor extends LazyValueAccessor implements IAmfRetUserCallback {
   
   public function getLastEditor():User {
      var result:User= super.internalValue as User;
      return result;
   }
   
   public function setLastEditor(user:User):void {
      
      super.internalValue = user;
   }
   
   override protected function launchLoadValue():void {
      if (_owner) {
         var page:BroPageNode = _owner as BroPageNode;
         ApplicationManager.getInstance().distantServices.amfUserService.getAuthorForEditedContent(page.persistentID, this);
      } else {
         Log.getLogger("com.broceliand.pearlTree.model.BroPage").error("No pearl author to load !");
         super.onError(null);
      }
   }
   
   public function onReturnValue(value:UserData):void {
      super.internalValue= AmfUserService.makeUser(value);
      super.notifyValueAvailable();
   }
}
