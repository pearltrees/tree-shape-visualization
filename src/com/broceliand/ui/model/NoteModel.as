package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.exporter.INoteExporter;
   import com.broceliand.pearlTree.io.exporter.NoteAmfExporter;
   import com.broceliand.pearlTree.io.loader.INoteLoader;
   import com.broceliand.pearlTree.io.loader.NoteAmfLoader;
   import com.broceliand.pearlTree.io.services.AmfService;
   import com.broceliand.pearlTree.io.sync.AbstractRealtimeScheduler;
   import com.broceliand.pearlTree.model.BroComment;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.NoteSavedEvent;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.WelcomePearlsExceptions;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedListItem;
   import com.broceliand.pearlTree.model.paginatedlists.PaginatedList;
   import com.broceliand.pearlTree.model.paginatedlists.PaginatedListItem;
   import com.broceliand.pearlTree.navigation.INoteToPearlNavigator;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NoteToPearlNavigator;
   import com.broceliand.util.Assert;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;

   public class NoteModel extends EventDispatcher
   {

      public static const MODEL_CHANGED_EVENT:String = "NoteModelChanged";

      public static const TYPE_NOTE:uint = 0;
      public static const TYPE_TEAM_DISCUSSION:uint = 1;

      public static const MODE_LOCAL:uint = 1;
      public static const MODE_ALL:uint = 2;

      public static const SENT_THIS_MAP_TO:String = "sentThisMapTo_translate";
      public static const AND_WROTE:String = "andWrote_translate";
      public static const SENT_THIS_PEARL_TO:String = "sentThisPealrTo_translate";

      public static const MODE_PAGE_DEFAULT:uint = 2;
      public static const MODE_TREE_DEFAULT:uint = 1;

      private var _noteType:uint;

      private var isFirstRound:Boolean = true;
      private var _feedKeyToLocalCountNotes:Dictionary;
      private var _feedKeyToAllCountNotes:Dictionary;

      private var _feedKeyToLocalNotes:Dictionary;
      private var _feedKeyToAllNotes:Dictionary;

      private var _feedKeyToIsLocalNotesLoaded:Dictionary;
      private var _feedKeyToIsAllNotesLoaded:Dictionary;

      private var _realTimeNodes:Array;
      private static const REAL_TIME_INTERVAL:Number = AbstractRealtimeScheduler.DEFAULT_UPDATE_INTERVAL;
      private var _realTimeTimer:Timer;

      private var _feedKeyToLastNoteReadDate:Dictionary;

      private var _feedKeyToNotesToSave:Dictionary;
      private var _notesToUpdate:Array;

      private var _feedKeyToCallback:Dictionary;

      private var _feedKeyToNode:Dictionary;

      private var _feedKeyToIsNotesLoading:Dictionary;
      private var _feedKeyToIsNotesLoadingInRealTime:Dictionary;

      private var _nextFeedKeyUniqueId:uint;
      
      private var _noteExporter:INoteExporter;
      private var _noteToPearlNavigator:INoteToPearlNavigator;
      
      private var _noteToShowAtUpdate:int;
      private var _notesToHighlight:Array;
      
      private static const FEEDKEY_TAG_URL:String = "URL_ID_";
      private static const FEEDKEY_TAG_NOT_SAVED:String = "NO_ID_";
      
      public function NoteModel(visualModel:VisualModel, type:uint) {
         _noteType = type;
         _feedKeyToLocalNotes = new Dictionary();
         _feedKeyToLocalCountNotes = new Dictionary();
         _feedKeyToAllNotes = new Dictionary();
         _feedKeyToAllCountNotes = new Dictionary();
         _feedKeyToNotesToSave = new Dictionary();

         _feedKeyToIsNotesLoading = new Dictionary();
         _feedKeyToIsNotesLoadingInRealTime = new Dictionary();
         
         _notesToUpdate = new Array();
         
         _feedKeyToIsLocalNotesLoaded = new Dictionary();
         _feedKeyToIsAllNotesLoaded = new Dictionary();
         _feedKeyToLastNoteReadDate = new Dictionary();
         _realTimeNodes = new Array();
         _realTimeTimer = new Timer(REAL_TIME_INTERVAL);
         _realTimeTimer.addEventListener(TimerEvent.TIMER, onTimeToRefreshRealTimeFeeds);
         
         _feedKeyToCallback = new Dictionary();
         _feedKeyToNode = new Dictionary();
         _noteExporter = new NoteAmfExporter();
         _noteToPearlNavigator = new NoteToPearlNavigator();
         
         visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
      }
      
      private function onNavigationChange(event:NavigationEvent):void {
         removeAllNodesFromRealTime();
      }
      
      private function onTimeToRefreshRealTimeFeeds(event:TimerEvent):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(!am.isApplicationFocused) {
            return;
         }
         var pollingInterval:int = am.notificationCenter.currentPollingInterval;
         if (!AmfService.REALTIME_REQUEST || pollingInterval <= 0) {
            return;
         }
         
         _realTimeTimer.delay = am.notificationCenter.currentPollingInterval;
         for each (var node:BroPTNode in _realTimeNodes) {
            loadNewNotes(node);
         }
      }      
      public function addToRealTime(node:BroPTNode):void {
         if(!node || _realTimeNodes.indexOf(node) != -1) return;
         
         _realTimeNodes.push(node);
         
         if(!_realTimeTimer.running) {
            _realTimeTimer.start();
         }

         if(_realTimeNodes.length > 1) {
            trace("[NoteModel] NoteModel should have only 1 node in real time mode");
         }
      }
      
      public function removeFromRealTime(node:BroPTNode):void {
         if(!node) return;
         
         var nodeIndex:Number = _realTimeNodes.indexOf(node);
         if(nodeIndex != -1) {
            _realTimeNodes.splice(nodeIndex, 1);
         }
         
         if(_realTimeNodes.length == 0) {
            _realTimeTimer.stop();
         }
      }
      
      public function removeAllNodesFromRealTime():void {
         _realTimeNodes = new Array();
         _realTimeTimer.stop();
      }
      
      public function isInRealTime(node:BroPTNode):Boolean {
         return (node && _realTimeNodes.indexOf(node) != -1);
      }
      
      public function isNotesLoaded(node:BroPTNode, mode:int=-1):Boolean {
         mode = nodeMode(node, mode);
         if (mode == -1) return false;
         var feedKey:String = this.getFeedKey(node, mode);
         
         var isLoaded:Boolean = false;
         if(mode == MODE_LOCAL) {
            isLoaded = _feedKeyToIsLocalNotesLoaded[feedKey];
         }else if(mode == MODE_ALL){
            isLoaded = _feedKeyToIsAllNotesLoaded[feedKey];
         }
         return isLoaded;
      }
      
      public function isLocalNotesLoaded(node:BroPTNode):Boolean {
         return isNotesLoaded(node, MODE_LOCAL);
      }
      public function isAllNotesLoaded(node:BroPTNode):Boolean {
         return isNotesLoaded(node, MODE_ALL);
      }
      private function setNotesLoadedState(node:BroPTNode, mode:int=-1, isLoaded:Boolean=false):void {
         mode = nodeMode(node, mode);
         if (mode == -1) return;
         var feedKey:String = this.getFeedKey(node, mode);
         
         if(mode == MODE_LOCAL) {
            _feedKeyToIsLocalNotesLoaded[feedKey] = isLoaded;
         }else if(mode == MODE_ALL){
            _feedKeyToIsAllNotesLoaded[feedKey] = isLoaded;
         }
      }
      public function markLocalNotesLoaded(node:BroPTNode):void {
         setNotesLoadedState(node, MODE_LOCAL, true);
      }
      public function markAllNotesLoaded(node:BroPTNode):void {
         setNotesLoadedState(node, MODE_ALL, true);
      }
      public function markLocalNotesNotLoaded(node:BroPTNode):void {
         setNotesLoadedState(node, MODE_LOCAL, false);
      }
      public function markAllNotesNotLoaded(node:BroPTNode):void {
         setNotesLoadedState(node, MODE_ALL, false);
      }
      public function markNotesNotLoaded(node:BroPTNode):void {
         setNotesLoadedState(node, -1, false);
      }
      
      public function markNotesRead(node:BroPTNode, mode:int=-1):void {
         mode = nodeMode(node, mode);
         if (mode == -1) return;
         
         var feedKey:String = this.getFeedKey(node, MODE_ALL);  
         
         var noteList:IPaginatedList = getNotes(node);
         var lastNoteReadDate:Number = 0;
         if(noteList && noteList.numberOfItems > 0) {
            var lastComment:BroComment = noteList.getInnerItemAt(0) as BroComment;
            if (lastComment) {
               lastNoteReadDate = lastComment.date;
            }
         }
         
         if(mode == MODE_LOCAL) {
            _feedKeyToLastNoteReadDate[feedKey] = lastNoteReadDate;
         }else if(mode == MODE_ALL){
            _feedKeyToLastNoteReadDate[feedKey] = lastNoteReadDate;
         }
         
         updateNotesType(node);
      }
      
      private function getLastReadDate(node:BroPTNode, mode:int=-1):Number {
         
         var lastUserAck:Number = ApplicationManager.getInstance().currentUser.feedNotifAck;
         if(!node) return lastUserAck;
         var lastAck:Number = Math.max(lastUserAck, node.commentsAck);
         mode = nodeMode(node, mode);
         
         var feedKey:String = this.getFeedKey(node, MODE_ALL);  
         
         if(mode == MODE_LOCAL) {
            return (_feedKeyToLastNoteReadDate[feedKey] > 0)?_feedKeyToLastNoteReadDate[feedKey]:lastAck;
         }else if(mode == MODE_ALL){
            return (_feedKeyToLastNoteReadDate[feedKey] > 0)?_feedKeyToLastNoteReadDate[feedKey]:lastAck;
         }else{
            return lastAck;
         }
      }
      
      public function addNewNoteNotification(node:BroPTNode):void {
         
         markNotesNotLoaded(node);

         if(node.noteMode == MODE_LOCAL && node.serverNoteCount == 0) {
            node.serverNoteCount = 1;
         }
         else if(node.noteMode == MODE_ALL && node.serverFullFeedNoteCount == 0) {
            node.serverFullFeedNoteCount = 1;
         }

         callFeedKeyCallbacksNoteAdded(getFeedKey(node));
      }
      
      public function getNoteCount(node:BroPTNode, mode:int=-1):uint {
         mode = nodeMode(node, mode);
         if (mode == -1) return null;
         
         var feedKey:String = this.getFeedKey(node, mode);
         var noteCount:int = -1;
         
         if (!_feedKeyToLocalCountNotes[feedKey]) {
            _feedKeyToLocalCountNotes[feedKey] = node.serverNoteCount;
         } else if (isNotesLoaded(node, mode)) {
            _feedKeyToLocalCountNotes[feedKey] = getNotes(node, mode).numberOfItems;
         }
         
         if (!_feedKeyToAllCountNotes[feedKey]) {
            _feedKeyToAllCountNotes[feedKey] = node.serverFullFeedNoteCount;
         } else if (isNotesLoaded(node, mode)) {
            _feedKeyToAllCountNotes[feedKey] = getNotes(node, mode).numberOfItems;
         }
         
         if(mode == NoteModel.MODE_LOCAL) {
            noteCount = _feedKeyToLocalCountNotes[feedKey];
         } else if(mode == NoteModel.MODE_ALL) {
            var localFeedKey:String = this.getFeedKey(node, NoteModel.MODE_LOCAL);
            if (_feedKeyToLocalCountNotes[localFeedKey] 
               && _feedKeyToAllCountNotes[feedKey] < _feedKeyToLocalCountNotes[localFeedKey]) {
               setNotesLoadedState(node, NoteModel.MODE_ALL);
               noteCount = _feedKeyToLocalCountNotes[localFeedKey];
            } else {
               noteCount = _feedKeyToAllCountNotes[feedKey];
            }
         }
         return noteCount;
      }

      public function getNotes(node:BroPTNode, mode:int=-1):IPaginatedList {
         mode = nodeMode(node, mode);
         if (mode == -1) return null;
         var feedKey:String = this.getFeedKey(node, mode);
         
         if (isNotesLoaded(node, mode)) {
            if (mode == MODE_LOCAL) {
               return _feedKeyToLocalNotes[feedKey];
            } else if(mode == MODE_ALL) {
               return _feedKeyToAllNotes[feedKey];
            }
         } else {
            loadNotes(node);
         }
         return null;
      }
      public function getLocalNotes(node:BroPTNode):IPaginatedList{
         return getNotes(node, MODE_LOCAL);
      }
      public function getAllNotes(node:BroPTNode):IPaginatedList{
         return getNotes(node, MODE_ALL);
      }
      
      public function isLocalNote(note:BroComment, node:BroPTNode):Boolean{
         if(note && node && node.isPersisted() && note.pearlId == node.persistentID && note.pearlDb == node.persistentDbID) {
            return true;
         }
         var localNotes:IPaginatedList = getLocalNotes(node);
         if(localNotes && localNotes.contains(note)) {
            return true;
         }
         return false;
      }
      
      public function hasNotesInAnyMode(node:BroPTNode):Boolean {
         
         if(!isAllNotesLoaded(node) && node.serverFullFeedNoteCount > 0) {
            return true;
         }
         if(!isLocalNotesLoaded(node) && node.serverNoteCount > 0){
            return true;
         }
         
         var allNotes:IPaginatedList = getAllNotes(node);
         if(allNotes && allNotes.numberOfItems > 0) {
            return true;
         }
         
         var localNotes:IPaginatedList = getLocalNotes(node);
         if(localNotes && localNotes.numberOfItems > 0) {
            return true;
         }
         
         return false;
      }
      
      public function resetNotesRight(node:BroPTNode, mode:int=-1):void {
         updateNotesRight(node, mode, true);
      }
      
      private function updateNotesRight(node:BroPTNode, mode:int=-1, reset:Boolean=false):void {
         if(!node) return;
         var notes:IPaginatedList = getNotes(node, mode);
         
         var note:BroComment;
         for (var i:int = 0 ; i < notes.numberLoaded ; i++) {
            note = notes.getInnerItemAt(i) as BroComment;
            if(!note.editable || reset) { 
               note.editable = isMyNote(note, node);
            }
         }
      }
      
      public function isNotesLoadedAndRead(node:BroPTNode, mode:int=-1):Boolean {
         if(isNotesLoaded(node, mode)) {
            var noteList:IPaginatedList = getNotes(node, mode);
            var note:BroComment;
            for (var i:int = 0 ; i < noteList.numberLoaded ; i++) {
               note = noteList.getInnerItemAt(i) as BroComment;
               if(note.type == BroComment.TYPE_NEW_USER_MESSAGE) {
                  return false;
               }
            }
            return true;
         }
         else{
            return false;
         }
      }
      
      private function updateNotesType(node:BroPTNode, mode:int=-1):void {
         if(!node) return;
         
         var noteList:IPaginatedList = getNotes(node, mode);
         if (!noteList) {
            return;
         }
         var notes:IPaginatedList = getNotes(node, mode);
         
         var currentUser:User = ApplicationManager.getInstance().currentUser;
         
         var note:BroComment;
         for (var i:int = 0 ; i < notes.numberLoaded ; i++) {
            note = notes.getInnerItemAt(i) as BroComment;
            var areUsersSame:Boolean = User.areUsersSame(currentUser, note.author);
            var isOtherUserMessage:Boolean = !areUsersSame && (note.type == BroComment.TYPE_USER_MESSAGE || note.type == BroComment.TYPE_NEW_USER_MESSAGE
               || note.type == BroComment.TYPE_TEAM_DISCUSSION_MESSAGE || note.type == BroComment.TYPE_NEW_TEAM_DISCUSSION_MESSAGE);
            var lastReadDate:Number = getLastReadDate(node, mode);
            var noteDate:Number = note.date;
            
            if(isOtherUserMessage) {
               if(noteDate > lastReadDate) {
                  if (note.type == BroComment.TYPE_USER_MESSAGE)
                     note.type = BroComment.TYPE_NEW_USER_MESSAGE;
                  else if (note.type == BroComment.TYPE_TEAM_DISCUSSION_MESSAGE)
                     note.type = BroComment.TYPE_NEW_TEAM_DISCUSSION_MESSAGE;
               }
               else {
                  if (note.type == BroComment.TYPE_NEW_USER_MESSAGE)
                     note.type = BroComment.TYPE_USER_MESSAGE;
                  else if (note.type == BroComment.TYPE_NEW_TEAM_DISCUSSION_MESSAGE)
                     note.type = BroComment.TYPE_TEAM_DISCUSSION_MESSAGE;
               }
            }
            else if(note.type == BroComment.TYPE_NEW_USER_MESSAGE)
               note.type = BroComment.TYPE_USER_MESSAGE;
            else if(note.type == BroComment.TYPE_NEW_TEAM_DISCUSSION_MESSAGE)
               note.type = BroComment.TYPE_TEAM_DISCUSSION_MESSAGE;
         }
      }
      
      private function isMyNote(note:BroComment, noteNode:BroPTNode):Boolean {

         var am:ApplicationManager = ApplicationManager.getInstance();
         var currentUser:User = am.currentUser;

         if(note.author && currentUser == note.author) {
            return true;
         }
         if (currentUser.persistentId == WelcomePearlsExceptions.WelcomeUser ) {
            return true;
         }

         if(note.parentTree) {
            
            if(note.parentTree.isCurrentUserAuthor()) {
               return true;
            }

            if(!currentUser.isAnonymous()) {
               var treeInUserHierarchy:BroPearlTree = am.pearlTreeLoader.getTreeInAssociationHierarchy(currentUser.userWorld.treeId, note.parentTree.id);
               if(treeInUserHierarchy) {
                  if(treeInUserHierarchy.isOwner) {
                     return true;
                  }
               }
            }
         }
         
         return false;
      }
      
      public function loadNewNotes(node:BroPTNode, mode:int=-1):void {
         mode = nodeMode(node, mode);
         if (mode == -1) return;
         
         if(!isLoadingNotes(node, mode)) {
            var relevantNode:BroPTNode = this.getRelevantNodeForNotes(node);
            var noteLoader:INoteLoader = new NoteAmfLoader(relevantNode, _noteType);
            noteLoader.addEventListener(NoteAmfLoader.NOTE_DATA_LOADED, onNewNotesLoaded);
            noteLoader.addEventListener(NoteAmfLoader.NOTE_DATA_NOT_LOADED, onNotesNotLoaded);
            
            var noteList:IPaginatedList = getNotes(node, mode);
            var lastNote:BroComment = (noteList && noteList.numberLoaded > 0)?(noteList.getInnerItemAt(0) as BroComment):null;
            var sinceTimeLimit:Number = (lastNote)?lastNote.date:-1;
            setNotesLoadingState(node, true, mode, true);
            if(mode == MODE_LOCAL) {
               noteLoader.loadPearlNotes(sinceTimeLimit, null, false);
            }else if(mode == MODE_ALL){
               noteLoader.loadFullFeedNotes(sinceTimeLimit, null, false);
            }
         }
      }
      
      public function loadNotes(node:BroPTNode, callback:INoteModelCallback=null, mode:int=-1):void {
         mode = nodeMode(node, mode);
         if (mode == -1) return;
         
         if(callback != null) this.addOnChangeCallback(node, callback);

         if(isNotesLoaded(node, mode)) {
            if(callback != null) {
               callback.onNotesLoaded();
            }
         }
            
         else if(!isLoadingNotes(node, mode)) {
            var relevantNode:BroPTNode = this.getRelevantNodeForNotes(node);
            var noteLoader:INoteLoader = new NoteAmfLoader(relevantNode, _noteType);
            noteLoader.addEventListener(NoteAmfLoader.NOTE_DATA_LOADED, onNotesLoaded);
            noteLoader.addEventListener(NoteAmfLoader.NOTE_DATA_NOT_LOADED, onNotesNotLoaded);
            setNotesLoadingState(node, true, mode);
            if(mode == MODE_LOCAL) {
               noteLoader.loadPearlNotes();
            }else if(mode == MODE_ALL){
               noteLoader.loadFullFeedNotes();
            }
         }
      }
      
      public function isLoadingNotes(node:BroPTNode, mode:int=-1):Boolean {
         if (!node) return true;
         mode = nodeMode(node, mode);
         var feedKey:String = this.getFeedKey(node, mode);
         
         return (_feedKeyToIsNotesLoading[feedKey] == true);
      }
      
      public function isLoadingNotesInRealTime(node:BroPTNode, mode:int=-1):Boolean {
         if (!node) return false;
         mode = nodeMode(node, mode);
         var feedKey:String = this.getFeedKey(node, mode);
         
         return (_feedKeyToIsNotesLoadingInRealTime[feedKey] == true);
      }
      
      public function loadNextPage(node:BroPTNode, mode:int=-1):void {
         mode = nodeMode(node, mode);
         if (mode == -1) return;
         if(!isLoadingNotes(node, mode)) {
            var relevantNode:BroPTNode = this.getRelevantNodeForNotes(node);
            var noteLoader:INoteLoader = new NoteAmfLoader(relevantNode, _noteType);
            var localFeedKey:String = this.getFeedKey(node, MODE_LOCAL);
            var allFeedKey:String = this.getFeedKey(node, MODE_ALL);
            var localNotes:IPaginatedList = _feedKeyToLocalNotes[localFeedKey];
            var allNotes:IPaginatedList = _feedKeyToAllNotes[allFeedKey];
            noteLoader.addEventListener(NoteAmfLoader.NOTE_DATA_LOADED, onNextPageLoaded);
            noteLoader.addEventListener(NoteAmfLoader.NOTE_DATA_NOT_LOADED, onNotesNotLoaded);
            setNotesLoadingState(node, true, mode);
            var relevantList:IPaginatedList;
            if (mode == MODE_LOCAL) {
               relevantList = _feedKeyToLocalNotes[localFeedKey];
               noteLoader.loadPearlNotes(-1, relevantList.paginationState);
            }
            else if (mode == MODE_ALL) {
               relevantList = _feedKeyToAllNotes[allFeedKey];
               noteLoader.loadFullFeedNotes(-1, relevantList.paginationState);
            }
         }
      }
      
      private function setNotesLoadingState(node:BroPTNode, isLoading:Boolean, mode:int=-1, inRealTime:Boolean = false):void {
         mode = nodeMode(node, mode);
         var feedKey:String = this.getFeedKey(node, mode);
         
         if(isLoading) {
            _feedKeyToIsNotesLoading[feedKey] = true;
            _feedKeyToIsNotesLoadingInRealTime[feedKey] = inRealTime;
         }else{
            delete _feedKeyToIsNotesLoading[feedKey];
            delete _feedKeyToIsNotesLoadingInRealTime[feedKey];
         }
      }
      
      public function registerNodeToNotifyChange(node:BroPTNode, isNewNode:Boolean):void{
         if(!node) return;
         this.addNodeToFeedKey(node, isNewNode);
      }
      
      public function editNote(note:BroComment):void {
         if (note.isPersisted()) {
            _noteExporter.editNote(note);
         } else {
            if (_notesToUpdate.indexOf(note) == -1)
               _noteExporter.addEventListener(NoteSavedEvent.NOTE_SAVED, onNoteSaved);
            _notesToUpdate.push(note);
         }
      }
      
      private function onNoteSaved(event:NoteSavedEvent):void {
         
         var note:BroComment = event.note;
         var index:Number = _notesToUpdate.indexOf(note);
         
         if (index != -1) {
            _noteExporter.editNote(_notesToUpdate[index]);
            _notesToUpdate.splice(index, 1);
         }
      }
      
      public function addNote(node:BroPTNode, note:BroComment, save:Boolean=true, forceEditable:Boolean=false, savedByServer:Boolean=false, replaceLast:Boolean = false):void {
         if(!node || !note) return;
         markNotesRead(node);
         
         var localFeedKey:String = this.getFeedKey(node, MODE_LOCAL);
         var allFeedKey:String = this.getFeedKey(node, MODE_ALL);
         var relevantNode:BroPTNode = this.getRelevantNodeForNotes(node);
         
         var localNotes:IPaginatedList = _feedKeyToLocalNotes[localFeedKey];
         var allNotes:IPaginatedList = _feedKeyToAllNotes[allFeedKey];
         if(!localNotes)_feedKeyToLocalNotes[localFeedKey] = localNotes = new PaginatedList();
         if(!allNotes) _feedKeyToAllNotes[allFeedKey] = allNotes = new PaginatedList();

         note.pearlId = relevantNode.persistentID;
         note.pearlDb = relevantNode.persistentDbID;
         note.editable = (forceEditable)?true:isMyNote(note, relevantNode);
         note.parentTree = relevantNode.owner;
         
         var noteItem:IPaginatedListItem = new PaginatedListItem();
         noteItem.innerItem = note;

         if (replaceLast) {
            localNotes.replaceAtBeginning(noteItem);
         }
         else {
            localNotes.addAtBeginning(noteItem);
         }
         if (!_feedKeyToLocalCountNotes[localFeedKey]) {
            _feedKeyToLocalCountNotes[localFeedKey] = 1;
         }
         if(!node.isRefTreePrivate()) {
            if (replaceLast) {
               allNotes.replaceAtBeginning(noteItem);
            }
            else {
               allNotes.addAtBeginning(noteItem);
            }
            if (!_feedKeyToAllCountNotes[allFeedKey]) {
               _feedKeyToAllCountNotes[allFeedKey] = 1;
            }
         }

         if(save && !note.isPersisted()) {
            if(relevantNode.isPersisted()) {
               _noteExporter.addNote(note, node);
            }else{
               var notesToSave:IPaginatedList = _feedKeyToNotesToSave[localFeedKey];
               if(!notesToSave) _feedKeyToNotesToSave[localFeedKey] = notesToSave = new PaginatedList();
               notesToSave.addAtBeginning(noteItem);
            }
         }
            
         else if(savedByServer) {
            node.serverNoteCount = node.serverNoteCount + 1;
            node.serverFullFeedNoteCount = node.serverFullFeedNoteCount + 1;
         }

         this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         this.notifyNodesForChange(allFeedKey, MODE_ALL);
         this.callFeedKeyCallbacksNoteAdded(localFeedKey);
         this.callFeedKeyCallbacksNoteAdded(allFeedKey);
         
         dispatchEvent(new Event(NoteModel.MODEL_CHANGED_EVENT));
      }
      
      public function removeNote(node:BroPTNode, note:BroComment, persist:Boolean=true):void {
         if(!node || !note) return;
         markNotesRead(node);
         
         var localFeedKey:String = getFeedKey(node, MODE_LOCAL);
         removeNoteFromFeed(localFeedKey, note);
         notifyNodesForChange(localFeedKey, MODE_LOCAL);
         callFeedKeyCallbacksNoteRemoved(localFeedKey);
         
         var allFeedKey:String = getFeedKey(node, MODE_ALL);
         removeNoteFromFeed(allFeedKey, note);
         notifyNodesForChange(allFeedKey, MODE_ALL);
         callFeedKeyCallbacksNoteRemoved(allFeedKey);
         
         if(!isLocalNote(note, node)) {
            var distantFeedKey:String = getLocalFeedKeyFromNote(note);
            removeNoteFromFeed(distantFeedKey, note);
            
            if(!_feedKeyToIsLocalNotesLoaded[distantFeedKey]) {
               var nodes:Array = _feedKeyToNode[distantFeedKey];
               for each(var distantNode:BroPTNode in nodes) {
                  distantNode.serverNoteCount = distantNode.noteCount - 1;
               }
            }
            notifyNodesForChange(distantFeedKey, MODE_LOCAL);
            callFeedKeyCallbacksNoteRemoved(distantFeedKey);
         }
         
         if(note.isPersisted() && persist) {
            _noteExporter.deleteNote(note, node);
         }
         
         dispatchEvent(new Event(NoteModel.MODEL_CHANGED_EVENT));
      }
      
      public function removeNotesOfDeletedNode(node:BroPTNode):void {
         var note:BroComment;
         if(isLocalNotesLoaded(node)) {
            var localNotes:IPaginatedList = getLocalNotes(node);
            for (var i:int = 0 ; i < localNotes.numberLoaded ; i++) {
               note = localNotes.getInnerItemAt(i) as BroComment;
               removeNote(node, note, false);
            }
         }
         if(isAllNotesLoaded(node)) {
            var allNotes:IPaginatedList = getAllNotes(node);
            for (var j:int = 0 ; j < allNotes.numberLoaded ; j++) {
               note = allNotes.getInnerItemAt(j) as BroComment
               if(isLocalNote(note, node)) {
                  removeNote(node, note, false);
               }
            }
         }
      }
      
      public function changeNoteMode(node:BroPTNode, mode:uint):void{
         if(node.noteMode != mode) {
            node.noteMode = mode;
            var feedKeyAll:String = this.getFeedKey(node, MODE_ALL);
            if (node.noteModeHasChanged) {
               if (mode == MODE_ALL) {
                  _feedKeyToAllCountNotes[feedKeyAll] = getNoteCount(node, MODE_ALL) + getNoteCount(node, MODE_LOCAL);
               } else if (mode == MODE_LOCAL) {
                  _feedKeyToAllCountNotes[feedKeyAll] = getNoteCount(node, MODE_ALL) - getNoteCount(node, MODE_LOCAL);
               }
               markAllNotesNotLoaded(node);
            }
            if(node.isCurrentUserOwner()) {
               saveNoteMode(node);
            }
            dispatchEvent(new Event(NoteModel.MODEL_CHANGED_EVENT));
         }
      }
      public function saveNoteMode(node:BroPTNode):void{
         if(!node.isCurrentUserOwner()) return;
         
         if(node.isPersisted()) {
            
            node.noteModeSaved = true;
         }else{
            node.noteModeSaved = false;
         }
      }
      
      public function processNotesToSave(node:BroPTNode):void {
         if(!node) return;
         var relevantNode:BroPTNode = this.getRelevantNodeForNotes(node);
         if(!relevantNode.isPersisted()) return;
         
         var feedKey:String = this.getFeedKey(node, MODE_LOCAL);
         var notesToSave:IPaginatedList = _feedKeyToNotesToSave[feedKey];
         if (!notesToSave) {
            return;
         }
         var note:BroComment;
         for (var i:int = 0 ; i < notesToSave.numberLoaded ; i++) {
            note = notesToSave.getInnerItemAt(i) as BroComment;
            note.pearlId = relevantNode.persistentID;
            note.pearlDb = relevantNode.persistentDbID;
            _noteExporter.addNote(note, relevantNode);
         }
         delete _feedKeyToNotesToSave[feedKey];
      }
      
      public function addOnChangeCallback(node:BroPTNode, callback:INoteModelCallback):void{
         if(!node || !callback) return;
         this.addCallbackToFeedKey(getFeedKey(node, MODE_LOCAL), callback);
         this.addCallbackToFeedKey(getFeedKey(node, MODE_ALL), callback);
      }
      public function removeOnChangeCallback(node:BroPTNode, callback:INoteModelCallback):void{
         if(!node || !callback) return;
         this.removeCallbackFromFeedKey(getFeedKey(node, MODE_LOCAL), callback);
         this.removeCallbackFromFeedKey(getFeedKey(node, MODE_ALL), callback);
      }
      public function removeCallbackForAllNodes(callback:INoteModelCallback):void {
         if(!callback) return;
         this.removeCallbackFromAllFeedKey(callback);
      }
      
      public function get noteToPearlNavigator():INoteToPearlNavigator{
         return _noteToPearlNavigator;
      }
      
      private function removeNoteFromFeed(feedKey:String, note:BroComment):void{
         var localNotes:IPaginatedList = _feedKeyToLocalNotes[feedKey];
         var allNotes:IPaginatedList = _feedKeyToAllNotes[feedKey];
         var notesToSave:IPaginatedList = _feedKeyToNotesToSave[feedKey];
         
         removeNoteFromNoteArray(localNotes, note);
         removeNoteFromNoteArray(allNotes, note);
         removeNoteFromNoteArray(notesToSave, note);
      }
      private function removeNoteFromNoteArray(noteList:IPaginatedList, note:BroComment):void {
         if(!noteList || !note) return;
         var localNotesLength:uint = noteList.numberLoaded;
         for(var i:uint=0; i<localNotesLength; i++) {
            var curNote:BroComment = noteList.getInnerItemAt(i) as BroComment;
            
            if(note.isPersisted() && curNote.persistentID == note.persistentID && curNote.persistentDbID == note.persistentDbID) {
               noteList.removeItemAt(i);
               return;
            }
               
            else if(!note.isPersisted() && note == curNote) {
               noteList.removeItemAt(i);
               return;
            }
         }
      }
      
      private function onNewNotesLoaded(event:Event):void {
         var noteLoader:INoteLoader = INoteLoader(event.target);
         setNotesLoadingState(noteLoader.node, false, noteLoader.loadedMode);
         if(!noteLoader.loadedNotes || noteLoader.loadedNotes.numberOfItems == 0) {
            return;
         }
         var localFeedKey:String = getFeedKey(noteLoader.node, MODE_LOCAL);
         var allFeedKey:String = getFeedKey(noteLoader.node, MODE_ALL);
         
         if(noteLoader.loadedMode == MODE_LOCAL) {
            concatNotes(noteLoader.node, noteLoader.loadedNotes, MODE_LOCAL);
            _feedKeyToIsLocalNotesLoaded[localFeedKey] = true;
            updateNotesRight(noteLoader.node, MODE_LOCAL);
            updateNotesType(noteLoader.node, MODE_LOCAL);
            this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         }
         else if(noteLoader.loadedMode == MODE_ALL) {
            concatNotes(noteLoader.node, noteLoader.loadedNotes, MODE_ALL);
            _feedKeyToIsAllNotesLoaded[allFeedKey] = true;
            mergeDistantNotesAndLocalNotes(noteLoader.node);
            updateNotesRight(noteLoader.node, MODE_ALL);
            updateNotesRight(noteLoader.node, MODE_LOCAL);
            updateNotesType(noteLoader.node, MODE_ALL);
            this.notifyNodesForChange(allFeedKey, MODE_ALL);
            this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         }
         
         this.callFeedKeyCallbacksNoteAdded(localFeedKey);
         this.callFeedKeyCallbacksNoteAdded(allFeedKey);
         
         dispatchEvent(new Event(NoteModel.MODEL_CHANGED_EVENT));
      }
      
      private function concatNotes(node:BroPTNode, newNotes:IPaginatedList, mode:int=-1):void {
         if(!node || !newNotes || newNotes.numberOfItems == 0) return;
         mode = nodeMode(node, mode);
         
         var noteList:IPaginatedList = getNotes(node, mode);
         
         if(!noteList) {
            var feedKey:String = getFeedKey(node, mode);
            if(mode == MODE_LOCAL) {
               _feedKeyToLocalNotes[feedKey] = noteList = new PaginatedList();
            }
            else if(mode == MODE_ALL){
               _feedKeyToAllNotes[feedKey] = noteList = new PaginatedList();
            }
         }
         var notes:IPaginatedList = noteList;
         var newNote:BroComment;
         var note:BroComment;
         for (var i:int = 0 ; i < newNotes.numberLoaded ; i++) {
            newNote = newNotes.getInnerItemAt(i) as BroComment;
            var noteAlreadyInList:Boolean = false;
            for (var j:int = 0 ; j < notes.numberLoaded ; j++) {
               note = notes.getInnerItemAt(j) as BroComment;
               if(note.persistentID == newNote.persistentID) {
                  noteAlreadyInList = true;
                  break;
               }
            }
            if(!noteAlreadyInList) {
               var noteItemNew:IPaginatedListItem = new PaginatedListItem();
               noteItemNew.innerItem = newNote;
               noteList.addAtBeginning(noteItemNew);
            }
         }
      }
      
      private function onNotesLoaded(event:Event):void{
         var noteLoader:INoteLoader = INoteLoader(event.target);
         setNotesLoadingState(noteLoader.node, false, noteLoader.loadedMode);
         
         var localFeedKey:String = getFeedKey(noteLoader.node, MODE_LOCAL);
         var allFeedKey:String = getFeedKey(noteLoader.node, MODE_ALL);
         
         if(noteLoader.loadedMode == MODE_LOCAL) {
            _feedKeyToLocalNotes[localFeedKey] = noteLoader.loadedNotes;
            _feedKeyToIsLocalNotesLoaded[localFeedKey] = true;
            updateNotesRight(noteLoader.node, MODE_LOCAL);
            updateNotesType(noteLoader.node, MODE_LOCAL);
            this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         } else if(noteLoader.loadedMode == MODE_ALL) {
            _feedKeyToAllNotes[allFeedKey] = noteLoader.loadedNotes;
            _feedKeyToIsAllNotesLoaded[allFeedKey] = true;
            mergeDistantNotesAndLocalNotes(noteLoader.node);
            updateNotesRight(noteLoader.node, MODE_ALL);
            updateNotesRight(noteLoader.node, MODE_LOCAL);
            updateNotesType(noteLoader.node, MODE_ALL);
            this.notifyNodesForChange(allFeedKey, MODE_ALL);
            this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         }
         
         this.callFeedKeyCallbacksNotesLoaded(localFeedKey);
         this.callFeedKeyCallbacksNotesLoaded(allFeedKey);
         
         dispatchEvent(new Event(NoteModel.MODEL_CHANGED_EVENT));
      }
      
      private function onNextPageLoaded(event:Event):void {
         var noteLoader:INoteLoader = INoteLoader(event.target);
         setNotesLoadingState(noteLoader.node, false, noteLoader.loadedMode);
         var localFeedKey:String = getFeedKey(noteLoader.node, MODE_LOCAL);
         var allFeedKey:String = getFeedKey(noteLoader.node, MODE_ALL);
         if(noteLoader.loadedMode == MODE_LOCAL) {
            (_feedKeyToLocalNotes[localFeedKey] as IPaginatedList).mergeAfter(noteLoader.loadedNotes);
            updateNotesRight(noteLoader.node, MODE_LOCAL);
            updateNotesType(noteLoader.node, MODE_LOCAL);
            this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         }
         else if(noteLoader.loadedMode == MODE_ALL) {
            (_feedKeyToAllNotes[allFeedKey] as IPaginatedList).mergeAfter(noteLoader.loadedNotes);
            mergeDistantNotesAndLocalNotes(noteLoader.node);
            updateNotesRight(noteLoader.node, MODE_ALL);
            updateNotesRight(noteLoader.node, MODE_LOCAL);
            updateNotesType(noteLoader.node, MODE_ALL);
            this.notifyNodesForChange(allFeedKey, MODE_ALL);
            this.notifyNodesForChange(localFeedKey, MODE_LOCAL);
         }
         
         this.callFeedKeyCallbacksNotesLoaded(localFeedKey);
         this.callFeedKeyCallbacksNotesLoaded(allFeedKey);
         
         dispatchEvent(new Event(NoteModel.MODEL_CHANGED_EVENT));
      }
      
      private function mergeDistantNotesAndLocalNotes(node:BroPTNode):void{
         var localFeedKey:String = this.getFeedKey(node, MODE_LOCAL);
         var allFeedKey:String = this.getFeedKey(node, MODE_ALL);
         var localNotes:IPaginatedList = _feedKeyToLocalNotes[localFeedKey];
         var allNotes:IPaginatedList = _feedKeyToAllNotes[allFeedKey];
         if(!allNotes) _feedKeyToAllNotes[allFeedKey] = allNotes = new PaginatedList();

         if(!isLocalNotesLoaded(node) && localNotes) {
            var localNote:BroComment;
            for (var i:int ; i < localNotes.numberLoaded ; i++) {
               localNote = localNotes.getInnerItemAt(i) as BroComment;
               var isInAllNotes:Boolean = false;
               if(!localNote.isPersisted()) {
                  isInAllNotes = false;
               }else{
                  var distantNote:BroComment;
                  for (var j:int = 0 ; j < allNotes.numberLoaded ; j++) {
                     distantNote = allNotes.getInnerItemAt(j) as BroComment;
                     if(!distantNote.isPersisted()) continue;
                     else if(distantNote.persistentID == localNote.persistentID && distantNote.persistentDbID == localNote.persistentDbID) {
                        isInAllNotes = true;
                        break;
                     }
                  }
               }
               
               if(!isInAllNotes) {
                  allNotes.addAtBeginning(localNotes.innerList.getItemAt(i) as IPaginatedListItem);
                  
               }
            }
         }

         localNotes = new PaginatedList();
         var note:BroComment;
         for (var k:int = 0 ; k < allNotes.numberLoaded ; k++) {
            note = allNotes.getInnerItemAt(k) as BroComment;
            if(note.isPersisted() && note.pearlId == node.persistentID && note.pearlDb == node.persistentDbID) {
               localNotes.addAtEnd(allNotes.innerList.getItemAt(k) as IPaginatedListItem);
               
            }
            else if(!note.isPersisted()) {
               localNotes.addAtEnd(allNotes.innerList.getItemAt(k) as IPaginatedListItem);
               
            }
         }
         localNotes.paginationState = allNotes.paginationState;
         localNotes.refreshMorePlaceholder();
         
         _feedKeyToLocalNotes[localFeedKey] = localNotes;
         _feedKeyToIsLocalNotesLoaded[localFeedKey] = true;
         
         _feedKeyToAllNotes[allFeedKey] = allNotes;
      }
      
      private function onNotesNotLoaded(event:Event):void {
         var noteLoader:INoteLoader = INoteLoader(event.target);
         setNotesLoadingState(noteLoader.node, false, noteLoader.loadedMode);
         
      }
      
      private function callFeedKeyCallbacksNotesLoaded(feedKey:String):void{
         var callbacks:Array = _feedKeyToCallback[feedKey];
         for each(var callback:INoteModelCallback in callbacks) {
            callback.onNotesLoaded();
         }
      }
      private function callFeedKeyCallbacksNoteRemoved(feedKey:String):void{
         var callbacks:Array = _feedKeyToCallback[feedKey];
         for each(var callback:INoteModelCallback in callbacks) {
            callback.onNoteRemoved();
         }
      }
      private function callFeedKeyCallbacksNoteAdded(feedKey:String):void{
         var callbacks:Array = _feedKeyToCallback[feedKey];
         for each(var callback:INoteModelCallback in callbacks) {
            callback.onNoteAdded();
         }
      }
      
      private function addCallbackToFeedKey(feedKey:String, callback:INoteModelCallback):void{
         var callbackArray:Array = _feedKeyToCallback[feedKey];
         if(!callbackArray) {
            _feedKeyToCallback[feedKey] = callbackArray = new Array();
         }
         if(callbackArray.indexOf(callback) == -1) {
            callbackArray.push(callback);
         }
      }
      
      private function removeCallbackFromFeedKey(feedKey:String, callback:INoteModelCallback):void{
         var callbackArray:Array = _feedKeyToCallback[feedKey];
         if(!callbackArray || callbackArray.length == 0) return;
         while(callbackArray.indexOf(callback) != -1) {
            callbackArray.splice(callbackArray.indexOf(callback), 1);
         }
      }
      
      private function removeCallbackFromAllFeedKey(callback:INoteModelCallback):void {
         for (var key:String in _feedKeyToCallback) {
            var callbackArray:Array = _feedKeyToCallback[key];
            while(callbackArray.indexOf(callback) != -1) {
               callbackArray.splice(callbackArray.indexOf(callback), 1);
            }
         }
      }
      
      private function addNodeToFeedKey(node:BroPTNode, isNewNode:Boolean):void{
         var localFeedKey:String = this.getFeedKey(node, MODE_LOCAL);
         var allFeedKey:String = this.getFeedKey(node, MODE_ALL);

         var hasFeedKeyChanged:Boolean = false;
         if (!isNewNode) {
            for (var key:String in _feedKeyToNode) {
               var nodesInKey:Array = _feedKeyToNode[key];
               
               if(nodesInKey && nodesInKey.indexOf(node) != -1 && key != localFeedKey && !isUrlFeed(key)){
                  changeNodeFeedKey(node, key, localFeedKey);
                  hasFeedKeyChanged = true;
               }
            }
         }
         
         var nodes:Array;
         if(!hasFeedKeyChanged) {
            nodes = _feedKeyToNode[localFeedKey];
            if(!nodes) _feedKeyToNode[localFeedKey] = nodes = new Array();
            if(nodes.indexOf(node) == -1) {
               nodes.push(node);
            }
         }
         
         nodes = _feedKeyToNode[allFeedKey];
         if(!nodes) _feedKeyToNode[allFeedKey] = nodes = new Array();
         if(nodes.indexOf(node) == -1) {
            nodes.push(node);
         }
      }
      
      private function isUrlFeed(feedKey:String):Boolean {
         return (feedKey.substr(0,FEEDKEY_TAG_URL.length) == FEEDKEY_TAG_URL);
      }
      
      private function changeNodeFeedKey(node:BroPTNode, oldKey:String, newKey:String, copyNotes:Boolean=true):void{
         
         if(copyNotes) {

            if(_feedKeyToLocalNotes[oldKey]){
               _feedKeyToLocalNotes[newKey] = _feedKeyToLocalNotes[oldKey];
               delete _feedKeyToLocalNotes[oldKey];
            }
            if(_feedKeyToAllNotes[oldKey]){
               _feedKeyToAllNotes[newKey] = _feedKeyToAllNotes[oldKey];
               delete _feedKeyToAllNotes[oldKey];
            }
            if(_feedKeyToNotesToSave[oldKey]) {
               _feedKeyToNotesToSave[newKey] = _feedKeyToNotesToSave[oldKey];
               delete _feedKeyToNotesToSave[oldKey];
            }

            if(_feedKeyToIsLocalNotesLoaded[oldKey]){
               _feedKeyToIsLocalNotesLoaded[newKey] = _feedKeyToIsLocalNotesLoaded[oldKey];
               delete _feedKeyToIsLocalNotesLoaded[oldKey];
            }
            if(_feedKeyToIsAllNotesLoaded[oldKey]) {
               _feedKeyToIsAllNotesLoaded[newKey] = _feedKeyToIsAllNotesLoaded[oldKey];
               delete _feedKeyToIsAllNotesLoaded[oldKey];
            }
         }

         var nodes:Array = _feedKeyToNode[newKey];
         if(!nodes) _feedKeyToNode[newKey] = nodes = new Array();
         if(nodes.indexOf(node) == -1) {
            nodes.push(node);
         }
         nodes = _feedKeyToNode[oldKey];
         if(nodes) {
            nodes.splice(nodes.indexOf(node),1);
            if(nodes.length == 0) delete _feedKeyToNode[oldKey];
         }

         var oldCallbacks:Array = _feedKeyToCallback[oldKey];
         if(oldCallbacks) {
            var newCallbacks:Array = _feedKeyToCallback[newKey];
            if(!newCallbacks) _feedKeyToCallback[newKey] = newCallbacks = new Array();
            for each(var callback:INoteModelCallback in oldCallbacks) {
               newCallbacks.push(callback);
               oldCallbacks.splice(oldCallbacks.indexOf(callback),1);
               if(oldCallbacks.length == 0) delete _feedKeyToCallback[oldKey];
            }
         }
      }

      private function notifyNodesForChange(feedKey:String, mode:uint):void{
         var nodes:Array = _feedKeyToNode[feedKey];
         for each(var node:BroPTNode in nodes) {
            if(node.noteMode == mode) {
               node.notifyNewNote();
            }
         }
      }
      private function isAllFeedKey(key:String):Boolean{
         if (key.lastIndexOf(FEEDKEY_TAG_URL)==0) {
            return true;
         }
         return false;
         
      }
      private function getFeedKey(node:BroPTNode, mode:int=-1):String {
         if(!node) return null;
         mode = nodeMode(node, mode);
         
         var key:String = null;
         var feedKey:String = null;
         var relevantNode:BroPTNode = this.getRelevantNodeForNotes(node);

         if (mode == MODE_ALL && relevantNode is BroPageNode) {
            var pageNode:BroPageNode = relevantNode as BroPageNode;
            
            feedKey = FEEDKEY_TAG_URL.concat(pageNode.refPage.urlId);
            
         }
            
         else if(!relevantNode.isPersisted()) {
            
            for (key in _feedKeyToNode) {
               if (isAllFeedKey(key)) {
                  continue;
               }
               var nodes:Array = _feedKeyToNode[key];
               if(nodes.indexOf(node) != -1){
                  feedKey = key;
                  break;
               }
            }
            
            if(!feedKey) {
               feedKey = FEEDKEY_TAG_NOT_SAVED+_nextFeedKeyUniqueId;
               _nextFeedKeyUniqueId++;
               _feedKeyToNode[feedKey] = new Array(node);
            }
         }
         else {
            feedKey = BroPTNode.getPearlKey(relevantNode.persistentDbID, relevantNode.persistentID);
         }
         return feedKey;
      }
      private function getLocalFeedKeyFromNote(note:BroComment):String {
         return BroPTNode.getPearlKey(note.pearlDb, note.pearlId);
      }
      
      public function getRelevantNodeForNotes(node:BroPTNode):BroPTNode {
         var relevantNode:BroPTNode = null;

         if(node is BroTreeRefNode) {
            var distantNode:BroTreeRefNode = node as BroTreeRefNode;
            Assert.assert((distantNode.refTree != null), "NoteModel can't find a relevant node for a BroTreeRefNode without refTree");
            relevantNode = distantNode.refTree.getRootNode();
         }
            
         else{
            relevantNode = node;
         }
         
         return relevantNode;
      }
      
      public function set notesToHighlight(value:Array):void {
         if (value && value.length > 0) {
            noteToShowAtUpdate = value[0];
         }
         _notesToHighlight = value;
      }
      
      public function isNoteToHighlight(id:int):Boolean {
         if (!_notesToHighlight) {
            return false;
         }
         return (_notesToHighlight.indexOf(id) >= 0);
      }
      
      public function set noteToShowAtUpdate(value:int):void {
         _noteToShowAtUpdate = value;
      }
      
      public function get noteToShowAtUpdate():int {
         return _noteToShowAtUpdate;
      }
      
      public static function BBCodeToHTML(value:String):String {
         var result:String = value;
         var bbcodesToHTML:Dictionary = new Dictionary();
         
         bbcodesToHTML[new RegExp(/\[b\](.*?)\[\/b\]/gi)] = "<b>$1</b>";
         
         bbcodesToHTML[new RegExp(/\[i\](.*?)\[\/i\]/gi)] = "<i>$1</i>";
         
         bbcodesToHTML[new RegExp(/\[u\](.*?)\[\/u\]/gi)] = "<u>$1</u>";

         for (var bbcode:Object in bbcodesToHTML) {
            if(bbcode is RegExp && bbcodesToHTML[bbcode]) {
               result = result.replace(bbcode as RegExp, bbcodesToHTML[bbcode]);
            }
         }
         return result;
      }
      public static function formatNoteToDisplay(value:String):String {
         return value.replace(/<br>/g, "\n");
      }
      
      public static function formatNoteToEdit(value:String):String {

         value = value.replace(/<br>/g, "\n");
         return value;
      }
      
      public static function formatNoteToSave(value:String):String {

         value = value.replace(/\r\n/g, "<br>");
         value = value.replace(/\r/g, "<br>");
         value = value.replace(/\n/g, "<br>");
         for(var i:int = value.lastIndexOf("<br>"); i != -1 && i == (value.length - 4); i = value.lastIndexOf("<br>")) {
            value = value.substring(0, value.length - 4);
         }
         return value;
      }
      
      public static function HTMLToBBCode(value:String):String {
         var result:String = value;
         var bbcodesToHTML:Dictionary = new Dictionary();
         
         bbcodesToHTML[new RegExp(/<b>(.*?)<\/b>/gi)] = "[b]$1[/b]";
         
         bbcodesToHTML[new RegExp(/<i>(.*?)<\/i>/gi)] = "[i]$1[/i]";
         
         bbcodesToHTML[new RegExp(/<u>(.*?)<\/u>/gi)] = "[u]$1[/u]";

         for (var bbcode:Object in bbcodesToHTML) {
            if(bbcode is RegExp && bbcodesToHTML[bbcode]) {
               result = result.replace(bbcode as RegExp, bbcodesToHTML[bbcode]);
            }
         }
         return result;
      }
      
      public static function createNote(noteText:String, author:User = null, date:Number = -1, htmlEncode:Boolean=true, type:uint=0, toUser:User=null):BroComment{
         if(type==0) type = BroComment.TYPE_USER_MESSAGE;
         if(!author) {
            author = ApplicationManager.getInstance().currentUser;
         }
         if(date == -1) {
            date = new Date().getTime();
         }
         if(htmlEncode && noteText) {
            noteText = formatNoteToSave(noteText);
         }
         var note:BroComment = new BroComment();
         note.type = type;
         note.date = date;
         note.author = author;
         note.toUser = toUser;

         note.text = noteText;
         
         return note;
      }
      
      public function nodeMode(node:BroPTNode, mode:int=-1):int {
         if(!node) return -1;
         if(mode == -1) {
            if (node.isRefTreePrivate()) {
               changeNoteMode(node,MODE_LOCAL);
            } else {
               changeNoteMode(node,MODE_ALL);
            }
            return node.noteMode;
         }
         return mode;
      }
      
   }
}