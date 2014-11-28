package com.broceliand {
   
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class EmbedManager extends EventDispatcher {
      
      public static const EMBED_TREE_LOADED:String = "embedTreeLoaded";
      public static const PEARL_CLIKED:String = "pearlClicked";
      
      public static const FACEBOOK_PADDING_BOTTOM:uint = 39;
      public static const FACEBOOK_LINK_COLOR:int=0x3B5998;
      
      public static const BORDER_THICKNESS:Number = 2;
      public static const MODE_SMALL_EMBED_MAX_WIDTH:Number = 260;
      public static const MODE_MEDIUM_EMBED_MAX_WIDTH:Number = 500;
      public static const ZOOM_BASE_WIDTH:Number = 500;
      
      public static const EMBED_TYPE_DEFAULT:uint = 0;
      public static const EMBED_TYPE_FACEBOOK:uint = 1;
      
      private var _am:ApplicationManager;
      private var _embedTree:BroPearlTree;
      private var _embedTreeRootNode:IPTNode;
      private var _isSelectionFreezed:Boolean;
      private var _isFacebookMode:Boolean;
      
      public function EmbedManager(am:ApplicationManager) {
         _am = am;
         if(am.isManagerInitialized) {
            _am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
         }else{
            _am.addEventListener(ApplicationManager.MANAGER_INITIALIZED_EVENT, onApplicationManagerInitialized);
         }
         StartPolicyLogger.getInstance().addEventListener(StartPolicyLogger.NEXT_STEP_EVENT, onStartNextStep);        
         _isFacebookMode = am.getPreloaderExplicitParam('isFacebookMode');
      }
      
      private function onStartNextStep(event:Event):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(StartPolicyLogger.getInstance().isFirstOpenAnimationEnded()) {
            am.getExternalInterface().notifyLoadingEnd();
         }
      }      
      
      private function onApplicationManagerInitialized(event:Event):void {
         _am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigationChange);
      }
      
      private function onNavigationChange(event:NavigationEvent):void {
         if(!embedTree && event.newFocusTree && event.newFocusTree.getMyAssociation() && event.newFocusTree.getMyAssociation().info) {
            _embedTree = event.newFocusTree;
            dispatchEvent(new Event(EMBED_TREE_LOADED));
         }
      }     
      
      public function isModeSmall():Boolean {
         var embedWidth:Number = ApplicationManager.flexApplication.stage.stageWidth;
         return (embedWidth < MODE_SMALL_EMBED_MAX_WIDTH);
      }
      
      public function isModeMedium():Boolean {
         var embedWidth:Number = ApplicationManager.flexApplication.stage.stageWidth;
         return (embedWidth < MODE_MEDIUM_EMBED_MAX_WIDTH && embedWidth >= MODE_SMALL_EMBED_MAX_WIDTH);
      }
      
      public function isModeFacebook():Boolean {

         return _isFacebookMode;
      }
      
      public function get embedTree():BroPearlTree {
         return _embedTree;
      }    
      
      public function getEmbedId():String {
         var preloaderExplicitValue:Object = _am.getPreloaderExplicitParam("embedId");
         if(preloaderExplicitValue) {
            return preloaderExplicitValue as String;
         }else{
            return _am.loaderParameters.getEmbedId();
         }
      }      
      
      public function set pearlClicked(value:Boolean):void {
         dispatchEvent(new Event(PEARL_CLIKED));
      }
      
      public function set isSelectionFreezed(value:Boolean):void {
         _isSelectionFreezed = value;
      }
      public function get isSelectionFreezed():Boolean {
         return _isSelectionFreezed;
      }
      
      public function getEmbedTreeRootNode():IPTNode {
         if(!_embedTreeRootNode) {
            var id:int = -1;
            var sid:String = "[embedRootNode]:" + _embedTree.title;
            _embedTreeRootNode = new PTNode(id, sid, null, _embedTree.getRootNode());
         }
         return _embedTreeRootNode;
      }
      
      public function openCreateAccountTab():void {
         var createAccountURL:String = _am.getServicesUrl()+"embed/createAccount";
         ApplicationManager.getInstance().getExternalInterface().openWindow(createAccountURL, '_blank');
      }
      
      public function navigateToEmbedTree():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.components.pearlTreeViewer.vgraph.PTLayouter.centerNextLayoutAndZoomOutBigTree(true, true);
         am.visualModel.navigationModel.goTo(
            embedTree.getMyAssociation().associationId,
            -1,
            embedTree.id,
            embedTree.id,
            embedTree.getRootNode().persistentID,
            -1,-1,0,false,2);         
      }
   }
}