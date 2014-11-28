package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.InfoPanelAssets;
   import com.broceliand.pearlTree.io.loader.SpatialTreeLoader;
   import com.broceliand.pearlTree.io.object.tree.SpatialTreeData;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
   import com.broceliand.pearlTree.model.BroAnonymousTreeRefNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.NeighbourPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.discover.SpatialTree;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.SearchEvent;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.util.Profiler;
   import com.broceliand.ui.window.ui.infoWindow.InfoWindowModel;
   
   import mx.rpc.events.FaultEvent;
   
   public class SearchNavigationRequest extends NavigationRequestBase implements IAmfRetArrayCallback {
      private var _keyword:String;   
      
      private var _userId:Number;   
      private var _userOnly:Boolean;   
      
      public function SearchNavigationRequest(navDesc:NavigationDescription)
      {
         super(navDesc);
         _keyword= navDesc.searchKeyword;
         _userId = navDesc.userId > 0 ? _navDesc.userId : 0;
         _userOnly = navDesc.searchUserOnly;
      }
      override public function startProcessingRequest(navigator:NavigationManagerImpl, eventToPropagateWhenFinished:NavigationEvent):void {
         super.startProcessingRequest(navigator,eventToPropagateWhenFinished);
         initEvent(_event);
         launchSearch();
      }
      override protected function initEvent(event:NavigationEvent):void {
         super.initEvent(event);
         _event.selectionOnIntersection = -1;
         _event.playState= -1;
         _event.revealState = -1;
         _event.isShowingPTW = true;
         _event.newPearlWindowPreferredState = -1;
         _event.isHome = false;
         _event.newUser = User.GetWhatsHotUser();
         _event.searchKeyword = _keyword;
         _event.searchUserId = _userId
         _event.searchUserOnly= _userOnly;
      }
      
      private function launchSearch():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var user:User = am.currentUser;
         am.distantServices.amfTreeService.find(AmfUserService.makeDataFromBUser(user),_keyword, _event.searchUserId, _userOnly , this);
      }
      
      public function onReturnValue(value:Array):void {
         Profiler.getInstance().addMarker("server (250ms is flex)","search");         
         var hasMoreThanThreshold:Boolean=false;
         
         var count:int = value.length;
         var spatialTreeList:Vector.<SpatialTree> = new Vector.<SpatialTree>();
         var neighbourTree:BroPearlTree;
         for each (var spatialTreeData:SpatialTreeData in value) {
            var spatialTree:SpatialTree = SpatialTreeLoader.makeSpatialTree(spatialTreeData);
            spatialTreeList.push(spatialTree);
            
            if(!neighbourTree) {
               
               var distantNode:BroDistantTreeRefNode = BroAnonymousTreeRefNode.GetAnonymousTreeRefNode(false);
               neighbourTree = NeighbourPearlTree.makeNeighbourTreee(distantNode,true, count);
               _event.newNeighbourTree = neighbourTree;
            }
         }
         _event.spatialTreeList = spatialTreeList;
         onEndProcessing();   
         
         if(count == 0 && !StartPolicyLogger.getInstance().isFirstNavigationEnded()) {
            _navigator.goToWhatsHot(false);
            var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
            wc.openInfoWindow(
               "search.noResult",
               InfoPanelAssets.SORRY,
               InfoWindowModel.BUTTON_TYPE_OK);
         }
         _navigator.dispatchEvent(new SearchEvent(_keyword, count, hasMoreThanThreshold, _userId, _userOnly, spatialTreeList));
      }
      
      public function onError(message:FaultEvent):void {
         _navigator.dispatchEvent(new SearchEvent(_keyword, 0, false, _userId, _userOnly, null, true));
      }
   }
}
