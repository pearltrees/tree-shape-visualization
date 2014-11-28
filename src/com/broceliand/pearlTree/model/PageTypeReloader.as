package com.broceliand.pearlTree.model {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetContentUrlState;
   import com.broceliand.pearlTree.model.event.ChangeNodePropertyEvent;
   
   import flash.events.EventDispatcher;
   
   import mx.rpc.events.FaultEvent;

   public class PageTypeReloader extends EventDispatcher implements IAmfRetContentUrlState {
      
      public static const PAGE_TYPE_CHANGED_EVENT:String = "pageTypeReloaded";
      
      private static var _singleton:PageTypeReloader;
      private var _pagesToReload:Array;
      
      public function PageTypeReloader() {
         super();
         _pagesToReload = new Array();
      }
      
      public static function getInstance():PageTypeReloader {
         if (!_singleton) {
            _singleton = new PageTypeReloader();
         }
         return _singleton;
      }
      
      public function reloadPageTypeIfNeeded(page:BroPage):void {
         if(page && _pagesToReload.indexOf(page) != -1) {
            if(page.urlId > 0) {
               var treeService:AmfTreeService = ApplicationManager.getInstance().distantServices.amfTreeService;
               treeService.getContentUrlState(page, this);
            }
         }
      }
      
      public function addPageTypeToReload(page:BroPage):void {
         if(_pagesToReload.indexOf(page) == -1) {
            _pagesToReload.push(page);
         }
      }
      
      public function updateEditedLayoutForPage(node:BroPTNode, newLayout:int):void {
         var pageNode:BroPageNode = (node as BroPageNode);
         ApplicationManager.getInstance().visualModel.applicationMessageBroadcaster.dispatchEvent(new ChangeNodePropertyEvent(pageNode));
         var page:BroPage = pageNode.refPage;
         if (page.editedLayout != newLayout) {
            page.editedLayout = newLayout;
            dispatchEvent(new PageTypeReloaderEvent(PAGE_TYPE_CHANGED_EVENT, page));
         }
      }
      
      public function onReturnValue(intValue:int, page:BroPage):void {
         removePageTypeToReload(page);
         if (page.type != intValue) {
            page.type = intValue;
            dispatchEvent(new PageTypeReloaderEvent(PAGE_TYPE_CHANGED_EVENT, page));
         }
      }
      
      public function onError(message:FaultEvent, page:BroPage):void {
         removePageTypeToReload(page);
      }
      
      private function removePageTypeToReload(page:BroPage):void {
         var indexOfPageToReload:int = _pagesToReload.indexOf(page);
         if(indexOfPageToReload != -1) {
            _pagesToReload.splice(indexOfPageToReload, 1);
         }
      }
   }
}