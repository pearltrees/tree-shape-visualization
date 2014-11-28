package com.broceliand.ui.pearlTree{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.controller.PearlTreeEditionController;
   import com.broceliand.graphLayout.layout.PTLayouterBase;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.PTVisualGraph;
   import com.broceliand.graphLayout.visual.PearlRendererFactories;
   import com.broceliand.io.IPearlTreeLoaderManager;
   import com.broceliand.pearlTree.model.BroPTDataEvent;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.team.TeamRequestChangeEvent;
   import com.broceliand.ui.customization.avatar.AvatarManager;
   import com.broceliand.ui.customization.common.ImageUploadRequest;
   import com.broceliand.ui.interactors.BrowserScrollLocker;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.model.NeighbourModel;
   import com.broceliand.ui.model.NoteModel;
   import com.broceliand.ui.model.VisualModel;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.ui.util.upload.FileUploadRequest;
   import com.broceliand.ui.util.upload.FileUploadRequestFlash;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import flash.events.Event;
   
   import mx.core.UIComponent;
   
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class RavisPearlTreeViewer extends UIComponent implements IPearlTreeViewer{
      
      private var _pearlTreeEditionController:PearlTreeEditionController= null;
      private var _mustBeInitialized:Boolean = false;
      private var _remoteResourceManager:IRemoteResourceManager = null;
      private var _pearlTreeLoaderManager:IPearlTreeLoaderManager = null;
      private var _pearlRendererStateManager:PearlRendererStateManager = null;
      private var _browserScrollLocker:BrowserScrollLocker = new BrowserScrollLocker();

      private var _mustDraw:Boolean = false;
      
      private var _vgraph:IPTVisualGraph;

      private var _interactorManager:InteractorManager = null;
      
      public function RavisPearlTreeViewer(garp:GraphicalAnimationRequestProcessor) {
         
         setStyle("backgroundColor", ColorPalette.getInstance().backgroundColor);
         _vgraph = new PTVisualGraph();
         _vgraph.percentWidth = 100;
         _vgraph.percentHeight = 100;
         _interactorManager = new InteractorManager(this, garp);
      } 
      
      public function get pearlTreeEditionController():IPearlTreeEditionController{
         if (_pearlTreeEditionController==null)
            _pearlTreeEditionController= makeEditionController();
         return _pearlTreeEditionController;
      }
      
      public function set layouter (value:ILayoutAlgorithm):void
      {
         _vgraph.layouter = value;
         _vgraph.layouter.addEventListener(PTLayouterBase.EVENT_LAYOUT_FINISHED, onLayoutFinished);
      }
      
      private function onLayoutFinished(event:Event):void{
         refresh();
      }
      public function get layouter ():ILayoutAlgorithm
      {
         return _vgraph.layouter;
      }
      
      private function makeEditionController():PearlTreeEditionController {
         return  new PearlTreeEditionController(_vgraph, _pearlTreeLoaderManager, ApplicationManager.getInstance().visualModel.animationRequestProcessor, _interactorManager);
      }   
      
      public function get vgraph ():IPTVisualGraph{
         return _vgraph; 
      }

      public function init():void {
         _mustBeInitialized =true;
         var am:ApplicationManager = ApplicationManager.getInstance();
         am.avatarManager.addEventListener(FileUploadRequest.PROCESSING_COMPLETE_EVENT, onAvatarManagerProcessingComplete, false, -1);
         am.avatarManager.addEventListener(AvatarManager.AVATAR_CHANGED, onAvatarChanged);
         am.visualModel.noteModel.addEventListener(NoteModel.MODEL_CHANGED_EVENT, onNotesChanged);
         am.visualModel.teamDiscussionModel.addEventListener(NoteModel.MODEL_CHANGED_EVENT, onTeamDiscussionChanged);
         am.visualModel.neighbourModel.addEventListener(NeighbourModel.MODEL_CHANGED_EVENT, onNeighboursChanged);
         am.notificationCenter.teamRequestModel.addEventListener(TeamRequestChangeEvent.STATE_CHANGED, onTeamRequestModelChanged);
         initFactories();
         
      }
      private function initFactories():void {
         var am:ApplicationManager= ApplicationManager.getInstance();
         var visualModel:VisualModel = am.visualModel;
         _mustBeInitialized=false;
         _remoteResourceManager = am.remoteResourceManagers.remoteImageManager;
         _pearlTreeLoaderManager = am.pearlTreeLoader;
         _pearlRendererStateManager = new PearlRendererStateManager(_vgraph, _interactorManager.nodeTitleModel, 
            _interactorManager, 
            visualModel.navigationModel, 
            visualModel.selectionModel,
            am.components.windowController);
         _vgraph.pearlRendererFactories = new PearlRendererFactories(_remoteResourceManager, _interactorManager, _pearlRendererStateManager);

         _vgraph.origin.x = 0;
         _vgraph.origin.y = 0;
         invalidateDisplayList();   
      }
      
      private function onNeighboursChanged(event:Event):void{
         refresh();
      }
      private function onNotesChanged(event:Event):void{
         refresh();
      }
      private function onTeamDiscussionChanged(event:Event):void{
         refresh();
      }            
      private function onAvatarManagerProcessingComplete(event:Event):void{
         for each(var vnode:IVisualNode in _vgraph.visibleVNodes){
            var pearlRenderer:PearlRendererBase = vnode.view as PearlRendererBase;
            pearlRenderer.pearl.refreshAvatar();
         }
      }
      override protected function createChildren():void {
         super.createChildren();
         
         addChild(_vgraph as PTVisualGraph);        	    
         
         /* create and set an EdgeRenderer */

         /* set the visibility limit options, default 2 
         * a.k.a degrees of separation */
         _vgraph.maxVisibleDistance = 1000;
         
         /* set if edge labels should be displayed */
         _vgraph.displayEdgeLabels = false;

      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);         
         _vgraph.setActualSize(unscaledWidth, unscaledHeight);
         if (_mustDraw) {
            _vgraph.draw();
            _mustDraw = false;
         }         	  
      }

      public function get interactorManager():InteractorManager{
         return _interactorManager;
      }
      
      public function get pearlRendererStateManager():PearlRendererStateManager{
         return _pearlRendererStateManager;
      }
      
      public function refresh():void{
         if (ApplicationManager.getInstance().visualModel.navigationModel.getPlayState() !=1) {
            vgraph.refreshNodes();
         }
      }

      public function getActive():Boolean {
         if(_interactorManager){
            return _interactorManager.getActive();
         }else{
            return false;
         }
      }
      
      public function setActive(value:Boolean):void {
         if(_interactorManager){
            _interactorManager.setActive(value);
            if (value) {
               _browserScrollLocker.setBrowserScrollLocker(false);
            }
            else {
               _browserScrollLocker.setBrowserScrollLocker(true);
            }
         }else{
            trace("couldn't set active, interactor manager not yet instanciated");
         }
      }
      public function onAvatarChanged(event:BroPTDataEvent):void {
         var tree:BroPearlTree = event.tree;
         var node:IPTNode = pearlTreeEditionController.getDisplayModel().getNode(tree);
         if (node && node.renderer) {
            node.renderer.refreshAvatar();
         }
      }
      
      public function onTeamRequestModelChanged(event:TeamRequestChangeEvent):void {
         refresh();
      }
   }
}