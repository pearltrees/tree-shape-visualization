package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.io.IPearlTreeLoaderManager;
   import com.broceliand.pearlTree.io.loader.IPearlTreeHierarchyLoaderCallback;
   import com.broceliand.pearlTree.io.loader.IPearlTreeLoaderCallback;
   import com.broceliand.pearlTree.io.loader.PearlTreeLoaderManager;
   import com.broceliand.pearlTree.io.loader.SpatialTreeLoader;
   import com.broceliand.pearlTree.io.loader.SpatialTreeLoaderEvent;
   import com.broceliand.pearlTree.io.loader.UserLoader;
   import com.broceliand.pearlTree.io.object.tree.PearlData;
   import com.broceliand.pearlTree.model.BroAnonymousTreeRefNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTDataEvent;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.NeighbourPearlTree;
   import com.broceliand.pearlTree.model.TreeHierarchy;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.UserFactory;
   import com.broceliand.pearlTree.model.discover.SpatialTree;
   import com.broceliand.pearlTree.navigation.INavigationResultCallback;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.error.ErrorConst;
   
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.events.FlexEvent;

   public class NavigationRequest extends NavigationRequestBase implements IPearlTreeHierarchyLoaderCallback, IPearlTreeLoaderCallback {
      
      private static const WHATS_HOT_ID:int=0;
      private var _isFocusTreeProcessed:Boolean = false;
      private var _isFocusTreeLoaded:Boolean = false;
      private var _isPearlSelectionProcessed:Boolean = false;
      private var _associationId:int;
      private var _userId:int=-1;
      private var _focusTreeId:int=-1;
      private var _selectedTreeId:int=-1;
      private var _pearlId:int=-1;
      private var _intermediateTreesLeft2Load:int= 0;
      private var _isProcessing:Boolean = true;
      private var _treeHierarchy:TreeHierarchy = null; 
      private var _playState:int;
      private var _isShowingPearlTreesWorld:Boolean;
      private var _onIntersection:int;
      private var _pearlWindowPreferredState:Number;
      private var _isHome:Boolean;
      private var _navigateFromNode:Boolean;
      private var _revealState:int=-1;
      private var _followMoved:Boolean;
      private var _resultCallback:INavigationResultCallback;
      private var _loadingTreesIds:Dictionary=new Dictionary();
      private var _hasErrorLoadingTree:Boolean;

      private var _pearlFinder:pearlFinderReturn;
      
      public  function NavigationRequest(navDes:NavigationDescription){
         super(navDes);
         _associationId = navDes.associationId;
         _userId= navDes.userId;
         _focusTreeId= navDes.focusedTreeId;
         if (_focusTreeId<0 && _associationId>0) {
            _focusTreeId = navDes.associationId;
         }
         _selectedTreeId= navDes.selectedTreeId;
         _pearlId= navDes.pearlId;
         _playState = navDes.playState;
         _onIntersection= navDes.onIntersection;
         _isShowingPearlTreesWorld = navDes.navType == NavigationDescription.DISCOVER_NAVIGATION;
         _startTime = getTimer();
         _pearlWindowPreferredState = navDes.pearlWindowPreferredState;
         _isHome = navDes.isHomePage;
         _navigateFromNode = navDes.navigateFromNode;
         _revealState = navDes.revealState;
         _followMoved = navDes.followMoved;
         _resultCallback = navDes.resultCallback;
      }
      override public function startProcessingRequest(navigator:NavigationManagerImpl, eventToPropagateWhenFinished:NavigationEvent):void {
         super.startProcessingRequest(navigator, eventToPropagateWhenFinished);
         processAssociation();
         loadFocusAndSelectedTree();
         processFocusTree();
         processPearlSelection();
         checkEventProcessComplete();
         
      } 
      override protected function initEvent(event:NavigationEvent):void {
         super.initEvent(event);
         _event.selectionOnIntersection = _onIntersection;
         _event.playState= _playState;
         _event.revealState = _revealState;
         _event.isShowingPTW = _isShowingPearlTreesWorld;
         _event.newPearlWindowPreferredState = _pearlWindowPreferredState;
         _event.isHome = _isHome;
         
      }
      
      public function processAssociation():void {
         if (_userId == WHATS_HOT_ID) {
            _event.newUser = User.GetWhatsHotUser();
         } else { 

            var uf:UserFactory = ApplicationManager.getInstance().userFactory;
            _event.newUser = uf.getOrMakeUser(1, _userId);
            if (_associationId != -1) {
               ApplicationManager.getInstance().pearlTreeLoader.loadAssociationTreeHierarchy(_associationId, this, true);
            } else {
               if (_focusTreeId == -1 && _userId>0) {
                  
                  if (_event.newUser.isInit()) {
                     _focusTreeId = _associationId = _event.newUser.userWorld.treeId;
                     if(_associationId != -1) {
                        ApplicationManager.getInstance().pearlTreeLoader.loadAssociationTreeHierarchy(_associationId, this, true);
                     }
                  } else {
                     _event.newUser.addEventListener(FlexEvent.INIT_COMPLETE, onUserLoaded);
                     new UserLoader().loadUser(_event.newUser, null);
                  }               
               }
            }
         }
      }     
      private function onUserLoaded(event:Event):void {
         _event.newUser.removeEventListener(FlexEvent.INIT_COMPLETE, onUserLoaded);
         _focusTreeId = _associationId = _event.newUser.userWorld.treeId;
         if (_associationId != -1) {
            ApplicationManager.getInstance().pearlTreeLoader.loadAssociationTreeHierarchy(_associationId, this, true);
         }
         loadFocusAndSelectedTree();
         processFocusTree();
         processPearlSelection();
         checkEventProcessComplete();
      }
      
      private function loadTree(id:int, loader:IPearlTreeLoaderManager):void {
         if (_loadingTreesIds[id] ==null) {
            _intermediateTreesLeft2Load  ++;
            _loadingTreesIds[id] = id;
            loader.loadTree(_associationId, id, this, true);
         }
      }
      
      private function loadFocusAndSelectedTree():void {
         var loader:IPearlTreeLoaderManager  = ApplicationManager.getInstance().pearlTreeLoader;
         if (!_isShowingPearlTreesWorld) {
            if (_focusTreeId>0) {
               loadTree(_focusTreeId, loader);
            } 
            if (_selectedTreeId >0 && _focusTreeId != _selectedTreeId) {
               loadTree(_selectedTreeId, loader);
               
            }
         }   
      }
      private function loadIntermediateTrees(treeHierarchy:TreeHierarchy, ptLoader:IPearlTreeLoaderManager ):void {

         var oldFocusTree:BroPearlTree = _navigator.getFocusedTree();
         var newFocusTree:BroPearlTree = treeHierarchy.getTree(_focusTreeId);
         var itree:BroPearlTree;
         if (oldFocusTree!=null && _revealState == -1) {
            var parentTrees:Array= oldFocusTree.treeHierarchyNode.getTreePath();
            var newFocusTreeIndex:int  = parentTrees.lastIndexOf(newFocusTree);
            if (newFocusTreeIndex != -1) {
               for (var i:int =newFocusTreeIndex+1; i<parentTrees.length-1;i++) {
                  itree = parentTrees[i] as BroPearlTree;
                  if (!itree.pearlsLoaded) {
                     loadTree(itree.id, ptLoader);
                  }  
               }
            }
         }
         if (_selectedTreeId>0) {
            var selectedTree:BroPearlTree = treeHierarchy.getTree( _selectedTreeId);
            if (selectedTree!=null ) { 
               
               var parentSelection:Array= selectedTree.treeHierarchyNode.getTreePath();
               var startIndex:int = parentSelection.lastIndexOf(newFocusTree);
               
               if (startIndex>=0) {
                  
                  _event.newSelectedTree= selectedTree;
                  for ( i=startIndex+1; i<parentSelection.length;i++) {
                     itree= parentSelection[i] as BroPearlTree; 
                     if (!itree.pearlsLoaded) {
                        loadTree(itree.id, ptLoader);
                     }  
                  }
               }    
            } else {
               trace(" tree not found in the hierarchy id=" +_selectedTreeId);
               _selectedTreeId=-1; 
               _isPearlSelectionProcessed = true;
            }           
         }
      }
      
      private function loadPTW(focusTree:BroPearlTree, ptLoader:IPearlTreeLoaderManager):void {
         if(ApplicationManager.getInstance().useDiscover()) {

            var positionnedTrees:Vector.<SpatialTree> = new Vector.<SpatialTree>();
            if (focusTree) {
               var spacialTree:SpatialTree = new SpatialTree();
               spacialTree.tree = focusTree;
               spacialTree.relativeX = 0;
               spacialTree.relativeY = 0;
               positionnedTrees.push(spacialTree);
            }
            
            var missingTrees:Vector.<SpatialTree> = new Vector.<SpatialTree>();
            var spatialTree:SpatialTree = new SpatialTree();
            spatialTree.hexX = 0;
            spatialTree.hexY = 0;
            missingTrees.push(spatialTree);
            
            var loader:SpatialTreeLoader = new SpatialTreeLoader();
            var isCenterOwner:Boolean = focusTree && focusTree.isCurrentUserAuthor();
            loader.loadSpatialTreeCollection(positionnedTrees, missingTrees, 0, 0, null, isCenterOwner, true);
            loader.addEventListener(SpatialTreeLoader.SPATIAL_TREE_COLLECTION_LOADED, onSpacialTreeLoaded);
         }
      }
      
      private function onSpacialTreeLoaded(event:SpatialTreeLoaderEvent):void {
         var loader:SpatialTreeLoader = event.target as SpatialTreeLoader;
         loader.removeEventListener(SpatialTreeLoader.SPATIAL_TREE_COLLECTION_LOADED, onSpacialTreeLoaded);
         var distantNode:BroDistantTreeRefNode;
         var tree:BroPearlTree;
         if(_event.newFocusTree) {
            if ((event.spatialTreeLoaded.length <1) && _event.newFocusTree.isCurrentUserAuthor()) {
               ApplicationManager.getInstance().components.mainPanel.navBar.layoutEmptyMessageOnDiscover(true);

               return;
            }
            
            distantNode = new BroDistantTreeRefNode(_event.newFocusTree,_event.newUser);
            tree = NeighbourPearlTree.makeNeighbourTreee(distantNode,false, 0);
            
         } else{
            
            distantNode = BroAnonymousTreeRefNode.GetAnonymousTreeRefNode(false);
            tree =NeighbourPearlTree.makeNeighbourTreee(distantNode,true, 0); 
         }
         _event.newNeighbourTree = tree;
         _event.spatialTreeList = event.spatialTreeLoaded;
         _isFocusTreeLoaded = true;
         checkEventProcessComplete();      
      }

      public function onHierarchyLoaded(treeHierarchy:TreeHierarchy):void {
         if (treeHierarchy.owner.isMyAssociation()) {
            _treeHierarchy = treeHierarchy.getMyWorldHierarchy();
            _event.newUser= treeHierarchy.owner.preferredUser; 
         } else {
            _treeHierarchy = treeHierarchy;
         }
         if (_focusTreeId>0 && _treeHierarchy.getTree(_focusTreeId) == null && !_hasErrorLoadingTree) {
            
            return;
         }
         if (!_isFocusTreeProcessed) {
            processFocusTree();
         }
      }

      public function processFocusTree():void {
         if (!_isFocusTreeProcessed) { 
            if (!_treeHierarchy && !_event.newUser.isAnonymous()) {
               return;
            } 
            var am:ApplicationManager = ApplicationManager.getInstance();
            var ptLoader:IPearlTreeLoaderManager = am.pearlTreeLoader;
            if (_event.newUser.isAnonymous()) {
               
               _event.newFocusTree = null;
            } else {
               if (_focusTreeId <0) {
                  _focusTreeId = _event.newUser.userWorld.treeId;
               }
               if (!_event.newFocusTree) {
                  _event.newFocusTree = _treeHierarchy.getTree(_focusTreeId);
               }

               if (_event.newFocusTree==null) {
                  if(_navigateFromNode) {
                     onError(ErrorConst.ERROR_LOADING_DELETED_TREE, true);
                  }else{
                     if (_revealState != 1) {
                        onError(ErrorConst.ERROR_LOADING_DELETED_TREE, true);
                     } else {
                        am.persistencyQueue.processActionAfterNextSynchronization(new GenericAction(null, this, processFocusTree));
                     }
                  }
                  return;
               } 
               
               if(NavigationManagerImpl.isTreeInUserDropZone(_event.newFocusTree, _event.newUser)) {
                  if (_event.newUser == am.currentUser) {
                     am.errorReporter.onError(ErrorConst.ERROR_LOADING_OUR_DROPZONE_TREE, false);
                  } else {
                     am.errorReporter.onError(ErrorConst.ERROR_LOADING_DELETED_TREE, true);
                  }
                  
                  var currentTree:BroPearlTree = _navigator.getSelectedTree();
                  if (currentTree== null ) {                  
                     _navigator.goTo(_event.newUser.getAssociation().associationId, _event.newUser.persistentId);
                  }
                  onNavigationForbidden();
                  
                  return;              
               }
            }
            
            _isFocusTreeProcessed = true;
            if (_isShowingPearlTreesWorld) {
               loadPTW(_event.newFocusTree, ptLoader);
            } else {
               loadIntermediateTrees(_treeHierarchy, ptLoader);
            }
            checkEventProcessComplete();
         } else {
            if (_event.newUser && _event.newUser.isAnonymous() && _isShowingPearlTreesWorld) {
               
               _event.newFocusTree = null;
               loadPTW(_event.newFocusTree, ApplicationManager.getInstance().pearlTreeLoader);
            }
            
         }
         
      }

      public function onTreeLoaded(tree:BroPearlTree):void {
         if (tree.id == _focusTreeId) {
            _event.newFocusTree = tree;
            if (_associationId == -1 || _associationId != tree.getMyAssociation().associationId) {
               ApplicationManager.getInstance().pearlTreeLoader.loadAssociationTreeHierarchy(tree.getMyAssociation().associationId, this, true);
            } else {
               if (tree.getMyAssociation().preferredUser) {
                  _event.newUser = tree.getMyAssociation().preferredUser;
               }
            }
            
            _isFocusTreeLoaded = true;
            if (PearlTreeLoaderManager.QUICK_LOAD && _selectedTreeId == _focusTreeId) {
               _isFocusTreeProcessed = true; 
            }
            
         }
         if (tree.id == _selectedTreeId ) {
            _event.newSelectedTree = tree;
            processPearlSelection();
         } 
         _intermediateTreesLeft2Load --;
         checkEventProcessComplete(); 
      }
      
      public function onNeighbourTreeLoaded(event:BroPTDataEvent):void {
         _event.newNeighbourTree= event.tree;
         _isFocusTreeLoaded = true;
         checkEventProcessComplete();
      }
      
      public function processPearlSelection():void {
         if (!_isPearlSelectionProcessed) {
            if (_selectedTreeId >0 && _pearlId != -1) {
               if (_event.newSelectedTree && _event.newSelectedTree.pearlsLoaded) {
                  
                  var node:IPTNode = ApplicationManager.getInstance().visualModel.selectionModel.nodeBeingSelected;
                  if (node) {
                     _event.newSelectedPearl = node.getBusinessNode(); 
                     
                  }
                  if (_event.newSelectedPearl == null || _event.newSelectedPearl.persistentID != _pearlId || _event.newSelectedPearl.owner != _event.newSelectedTree) {
                     _event.newSelectedPearl= _event.newSelectedTree.getPearl(_pearlId);
                  } 
               } else {
                  return;
               }
            }
            _isPearlSelectionProcessed= true;
            checkEventProcessComplete(); 
            
         }
      }
      
      public function checkEventProcessComplete():void {
         if (_isFocusTreeLoaded && _isPearlSelectionProcessed && _intermediateTreesLeft2Load== 0 && _isProcessing && (_isShowingPearlTreesWorld || _isFocusTreeProcessed)) {
            _isProcessing = false; 
            
            if (!_event.isShowingPTW) {
               if (_event.newSelectedTree == null) {
                  _event.newSelectedTree = _event.newFocusTree;
               }   
               
               if (_event.newSelectedPearl == null && _event.newSelectedTree == _event.newFocusTree) {
                  
                  if (_followMoved && _pearlId > 0) {
                     if (!_pearlFinder) {
                        _pearlFinder = new pearlFinderReturn(this);
                        ApplicationManager.getInstance().distantServices.amfTreeService.findPearl(_pearlId, _pearlFinder);
                     }
                     return;
                  }
                  
                  if (_pearlId == -2) {
                     var selectedNode:IPTNode = ApplicationManager.getInstance().visualModel.selectionModel.getSelectedNode();
                     _event.newSelectedPearl = selectedNode == null ? _event.newSelectedTree.getRootNode(): selectedNode.getBusinessNode();
                  } else {
                     _event.newSelectedPearl = _event.newSelectedTree.getRootNode();
                  }
                  _event.isEndPearl = true;
               }
            } 
            
            onEndProcessing();
         } 
      }
      
      public function onPearlFound(pearl:PearlData):void {
         var userId:int;
         if (pearl) {
            if (ApplicationManager.getInstance().currentUser.getAssociation().myWorldAssociations.isSubAssociation(pearl.tree.assoId)) {
               userId = ApplicationManager.getInstance().currentUser.persistentId;
            }
            else {
               userId = pearl.tree.asso.chiefUserId;
            }
            _navigator.goTo(pearl.tree.assoId,
               userId,
               pearl.treeId,  
               pearl.treeId, 
               pearl.id, 
               _onIntersection, 
               _playState, 
               _pearlWindowPreferredState, 
               _navigateFromNode, 
               _revealState, 
               _followMoved, 
               _resultCallback);
         }
         else {
            if (_resultCallback) {
               _resultCallback.onPearlDeleted();
            }
         }
      }
      
      private function onError(errorCode:int=-1, recoverable:Boolean=false,  ...context):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if (_followMoved && recoverable) {
            var pearlFinder:pearlFinderReturn = new pearlFinderReturn(this);
            am.distantServices.amfTreeService.findPearl(_pearlId, pearlFinder);            
         }
         else {
            var func:Function = am.errorReporter.onError;
            var args:Array = new Array();
            var errorCode:int; 
            if (am.components.pearlTreeViewer.vgraph.currentRootVNode== null) {
               errorCode = ErrorConst.ERROR_BAD_INITIAL_URL;
               if(am.isEmbed()) {
                  am.getExternalInterface().notifyLoadingEnd();
               }
            } else {
               if (_navigator.isShowingPearlTreesWorld()) {
                  
                  trace("Invalid navigation ;-(");
                  return;
               }
            }

            args.push(errorCode);
            for each (var o:Object in context) {
               args.push(o);
            } 
            func.apply(null, args);
         }
         
      } 
      
      public function onErrorLoadingTree(error:Object):void{
         _hasErrorLoadingTree = true;
         if (_treeHierarchy && !_isFocusTreeProcessed) {
            processFocusTree()
         }
         if  (error is BroPTDataEvent) {
            if (BroPTDataEvent(error).isErrorAlreadyReported && ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.currentRootVNode) {
               
               return;
            }
         } 
         onError(-1,false, error);   
         
      }
      
      public  function onErrorLoadingTreeSet(error:Object):void {
         onErrorLoadingTree(error); 
      }
   }
}
import com.broceliand.pearlTree.io.object.tree.PearlData;
import com.broceliand.pearlTree.io.services.callbacks.IAmfRetPearlCallback;
import com.broceliand.pearlTree.navigation.impl.NavigationRequest;

import mx.rpc.events.FaultEvent;

internal class pearlFinderReturn implements IAmfRetPearlCallback {
   
   private var _request:NavigationRequest;
   
   public function pearlFinderReturn(request:NavigationRequest) {
      _request = request;
   }
   
   public function onReturnNewPearl(pearl:PearlData):void {
      _request.onPearlFound(pearl);
   }
   
   public function onError(message:FaultEvent, status:int=0):void {
      _request.onPearlFound(null);
   }
   
}