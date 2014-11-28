package com.broceliand.ui.renderers
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.object.url.UrlData;
   import com.broceliand.pearlTree.io.services.AmfTreeService;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.pearlTree.io.services.callbacks.IAmfRetArrayCallback;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.CurrentUser;
   
   import flash.net.URLLoader;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   import mx.collections.ArrayCollection;
   import mx.rpc.events.FaultEvent;
   
   public class PearlLogoUpdater implements IAmfRetArrayCallback
   {
      private var _pagesToCheck: Array;
      private var _urlIdsToCheck: Array;
      private var _stateLoader:URLLoader;
      private var _isWaitingForServerAnswer:Boolean;
      private var _timeOutId:uint =0;
      
      private static const pollingDelay:Number = 5000;
      
      public function PearlLogoUpdater() {
         _pagesToCheck = new Array();
         _urlIdsToCheck = new Array();
      }
      
      public function addPageToCheck(value:BroPageNode):void {
         if (value == null) return;
         var urlId : String = value.refPage.urlId.toString();
         _pagesToCheck.push(value);
         _urlIdsToCheck.push(urlId);
         poll();
      }
      
      private function refreshNodeAndRemoveUrlIdToCheck(urlDataToRemove:UrlData, toRefresh:Boolean = true):void {
         var newUrlIdsToCheck : Array = new Array();
         var newPages : Array = new Array();
         var broPageNodeChecked : BroPageNode;
         var urlIdToRemove : String = urlDataToRemove.id.toString();
         var selectedNode : BroPTNode = ApplicationManager.getInstance().visualModel.navigationModel.getSelectedPearl();
         
         for (var i:int = 0 ; i < _pagesToCheck.length ; i++) {
            broPageNodeChecked = _pagesToCheck[i] as BroPageNode;
            if ((_urlIdsToCheck[i] as String) == urlIdToRemove) {
               
               if (toRefresh) {
                  var pageChecked:BroPage = broPageNodeChecked.refPage;
                  pageChecked.logoType = urlDataToRemove.logoType;  
                  pageChecked.resetPreviewUrls();
                  if (broPageNodeChecked == selectedNode) {
                     
                  }
               }
               if (broPageNodeChecked.graphNode) { 
                  broPageNodeChecked.graphNode.renderer.pearl.refreshLogo();
               }
               
            } else {
               
               newPages.push(broPageNodeChecked);
               newUrlIdsToCheck.push(_urlIdsToCheck[i]);
            }
         }
         _pagesToCheck = newPages;
         _urlIdsToCheck = newUrlIdsToCheck;
      }
      private function cancelTimeout():void {
         if (_timeOutId > 0) {
            clearTimeout(_timeOutId);
            _timeOutId = 0;
         }
      } 

      private function checkIfLogosAreReady():void {

         if (!_isWaitingForServerAnswer) {
            cancelTimeout();
            var user:CurrentUser = ApplicationManager.getInstance().currentUser;
            var service:AmfTreeService = ApplicationManager.getInstance().distantServices.amfTreeService;
            service.getUrlDataWithLogos(AmfUserService.makeDataFromBUser(user), _urlIdsToCheck, this);
            _isWaitingForServerAnswer = true;
         }
      }
      
      private function poll(fromTimeOut:Boolean = false):void {
         if (_pagesToCheck.length > 0) {
            if (fromTimeOut) {
               _timeOutId = 0;
            }
            checkIfLogosAreReady();
         }
      }
      
      public function onReturnValue(value:Array):void {
         var nextUpdateInterval:Number = value[0]; 
         var urlDatasReady:ArrayCollection = value[1];
         _isWaitingForServerAnswer = false;
         for each (var urlDataReady:UrlData in urlDatasReady) {
            refreshNodeAndRemoveUrlIdToCheck(urlDataReady);
         }
         if (nextUpdateInterval > -1) {
            _timeOutId = setTimeout(poll, nextUpdateInterval, true);
         }
      }
      
      public function onError(message:FaultEvent):void {
         _isWaitingForServerAnswer = false;
      }
   }
}