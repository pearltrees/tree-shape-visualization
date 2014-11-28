package com.broceliand.pearlTree.navigation.impl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class NavigationHistoryModel
   {
      private var _navManager:INavigationManager;
      private var _history:Array = new Array();
      private var _maxSize:int = 30;
      public function NavigationHistoryModel(navManager:NavigationManagerImpl) {
         _navManager = navManager;
         _navManager.addEventListener(NavigationEvent.NAVIGATION_EVENT , onNavigate);
      }
      
      private function onNavigate(event:NavigationEvent):void {
         if (event.isNewFocus && !event.isHistoryNavigation()) {
            
            var navDesc:NavigationDescription = NavigationDescription.makeBackFromEvent(event);
            if (navDesc) {
               _history.push(navDesc);
               while (_history.length > _maxSize) {
                  _history.shift();
               }
            }
         }
      }
      
      public function hasBack():Boolean {
         return _history.length > 0;
      }
      
      public function goBack():void {
         if (hasBack()) {
            var desc:NavigationDescription= _history.pop();
            desc.withHistoryNavigation(true);
            if (desc.isAliasNavigation) {
               var am:ApplicationManager = ApplicationManager.getInstance();
               var oldRoot:IVisualNode = am.components.pearlTreeViewer.vgraph.currentRootVNode;
               if (oldRoot) {
                  var ptRoot:IPTNode = oldRoot.node as IPTNode;
                  am.visualModel.selectionModel.saveCrossingBusinessNode(ptRoot);
               }
            }
            _navManager.navigate(desc);
         }
      }
      
      public function isLastItemIsSearch():Boolean {
         if (hasBack()) {
            var lastItem :NavigationDescription = _history[_history.length -1 ];
            return lastItem.navType == NavigationDescription.SEARCH_NAVIGATION;
         }
         return false;
      }
      
      public function clearHistory():void {
         _history = new Array(); 
      }

   }
}