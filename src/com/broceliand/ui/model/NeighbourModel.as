package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.loader.ILoadedTreeMemoryReleaser;
   import com.broceliand.pearlTree.io.loader.INeighbourLoader;
   import com.broceliand.pearlTree.io.loader.NeighbourAmfLoader;
   import com.broceliand.pearlTree.io.loader.NeighbourLoaderEvent;
   import com.broceliand.pearlTree.model.BroAssociation;
   import com.broceliand.pearlTree.model.BroDataRepository;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbour;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedListItem;
   import com.broceliand.pearlTree.model.paginatedlists.PaginatedListItem;
   import com.broceliand.util.Assert;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;

   public class NeighbourModel extends EventDispatcher
   {
      public static const START_LOADING_NEIGHBOUR:String = "StartLoadingNeighbour";
      
      public static const TREE_NEIGHBOURS_LOADED:String = "TreeNeighboursLoaded";
      
      public static const PAGE_NEIGHBOURS_LOADED:String = "PageNeighboursLoaded";
      
      public static const DISTANT_TREE_REF_NEIGHBOURS_LOADED:String = "DistantTreeRefNeighboursLoaded";
      
      public static const NEIGHBOURS_NOT_LOADED:String = "NeighboursNotLoaded";
      
      public static const MODEL_CHANGED_EVENT:String = "ModelChanged";
      
      public static const NEIGHBOUR_COUNT_CHANGED_EVENT:String = "NeighbourCountChanged";
      
      public static const MAX_NEIGHBOUR_TO_USE_AS_COUNT:uint = 95;
      
      protected var _neighbourLoader:INeighbourLoader;
      private   var _clientNeighbourRepository:NeighbourClientRepository;
      protected var _inProgress:Array;
      
      public function NeighbourModel(dataRepository:BroDataRepository) {
         super();
         _inProgress = new Array();
         _neighbourLoader = new NeighbourAmfLoader(dataRepository);
         _neighbourLoader.addEventListener(NeighbourAmfLoader.NEIGHBOUR_DATA_LOADED, onNeighboursLoaded);
         _neighbourLoader.addEventListener(NeighbourAmfLoader.NEIGHBOUR_DATA_NOT_LOADED, onNeighboursNotLoaded);
         _clientNeighbourRepository = new NeighbourClientRepository();
      }
      
      public function loadTreeNeighbours(tree:BroPearlTree):void{
         if(!isInProgress(tree)) {
            _neighbourLoader.loadNeighbours(tree.getRootNode());
            addInProgressList(tree);
         }
         dispatchEvent(new TreeNeighboursLoadedEvent(tree, null, START_LOADING_NEIGHBOUR));
      }
      
      public function loadPageNeighbours(node:BroPageNode):void {
         
         if(!isInProgress(node)) {

            _neighbourLoader.loadNeighbours(node);
            addInProgressList(node);             
         }
         dispatchEvent(new PageNeighboursLoadedEvent(node, null, START_LOADING_NEIGHBOUR));
      }
      
      public function loadDistantTreeRefNeighbours(node:BroDistantTreeRefNode):void{
         if(!isInProgress(node) && node.isPersisted()) {
            _neighbourLoader.loadNeighbours(node);            
            addInProgressList(node);
         }
         dispatchEvent(new DistantTreeRefNeighboursLoadedEvent(node,null , START_LOADING_NEIGHBOUR));
      }
      
      public function addNeighbour(node:BroPTNode, neighbour:BroNeighbour):void {
         var neighbourItem:IPaginatedListItem = new PaginatedListItem();
         neighbourItem.innerItem = neighbour;
         node.neighbours.addAtEnd(neighbourItem);
      }
      
      public function addNewNeighbourNotification(node:BroPTNode):void {
         if (!node.neighbourCount) { 
            node.neighbourCount = node.neighbourCount + 1;
            dispatchEvent(new Event(MODEL_CHANGED_EVENT));
         }
      }
      
      private function isInProgress(object:Object):Boolean {
         return (_inProgress.indexOf(object) != -1);
      }
      private function addInProgressList(object:Object):void {
         _inProgress.push(object);
      }
      private function removeFromInProgressList(object:Object):void{
         var index:int = _inProgress.indexOf(object);
         if(index != -1) {
            _inProgress.splice(index, 1);
         }
      }
      
      public function neighbourCountChanged(node:BroPTNode):void {
         dispatchEvent(new NeighbourCountChangedEvent(node));
      }
      
      private function onTreeNeighboursLoaded(tree:BroPearlTree, neighbours:IPaginatedList):void {
         removeFromInProgressList(tree);
         _clientNeighbourRepository.updateNodesNeighbour(tree.getRootNode(), neighbours);
         var event:TreeNeighboursLoadedEvent = new TreeNeighboursLoadedEvent(tree, neighbours, TREE_NEIGHBOURS_LOADED);
         dispatchEvent(event);
      }     
      private function onPageNeighboursLoaded(node:BroPageNode, neighbours:IPaginatedList):void {
         removeFromInProgressList(node);
         _clientNeighbourRepository.updateNodesNeighbour(node, neighbours);
         var event:PageNeighboursLoadedEvent = new PageNeighboursLoadedEvent(node, neighbours, PAGE_NEIGHBOURS_LOADED);
         dispatchEvent(event);
      }
      private function onDistantTreeRefNeighboursLoaded(node:BroDistantTreeRefNode, neighbours:IPaginatedList):void {
         removeFromInProgressList(node);
         var event:DistantTreeRefNeighboursLoadedEvent = new DistantTreeRefNeighboursLoadedEvent(node, neighbours, DISTANT_TREE_REF_NEIGHBOURS_LOADED);
         dispatchEvent(event);
      }

      public function declareClientNeighbour(nodeNeighbour:BroPTNode, destinationTree:BroPearlTree, crossingNode:BroPTNode=null):Boolean{
         return _clientNeighbourRepository.declareClientNeighbour(nodeNeighbour, destinationTree, crossingNode);
      }
      
      private function onNeighboursLoaded(event:NeighbourLoaderEvent):void{

         if (event.neighbours.paginationState.pageNumber > 1) {
            event.node.neighbours.mergeAfter(event.neighbours);
         }
         else {
            event.node.neighbours = event.neighbours;
         }

         if(event.node.neighbours.numberOfItems < MAX_NEIGHBOUR_TO_USE_AS_COUNT) {
            event.node.neighbourCount = event.node.neighbours.numberOfItems;
         }

         dispatchEvent(new Event(MODEL_CHANGED_EVENT));

         if(event.node is BroPageNode) {
            onPageNeighboursLoaded(BroPageNode(event.node), event.node.neighbours);
         }
         else if(event.node is BroPTRootNode) {
            onTreeNeighboursLoaded(BroPTRootNode(event.node).owner, event.node.neighbours);
         }
         else if(event.node is BroDistantTreeRefNode){
            onDistantTreeRefNeighboursLoaded(BroDistantTreeRefNode(event.node), event.node.neighbours);
         }
      }
      private function onNeighboursNotLoaded(event:NeighbourLoaderEvent):void {
         removeFromInProgressList(event.node);
         dispatchEvent(new Event(NEIGHBOURS_NOT_LOADED));
      }
      
      public function loadNextPage(node:BroPTNode):void {

         if(!isInProgress(node)) {
            _neighbourLoader.loadNeighbours(node, node.neighbours.paginationState);
            if (node is BroPTRootNode) {
               addInProgressList(node.owner);
            }
            else {
               addInProgressList(node);
            }
         }
      }

   }
}