package com.broceliand.ui.interactors {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.SavedPearlReference;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.team.TeamRightManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.controller.startPolicy.StartPolicyLogger;
   import com.broceliand.ui.interactors.drag.CopyDragInteractor;
   import com.broceliand.ui.interactors.drag.DistantDragEditInteractor;
   import com.broceliand.ui.interactors.drag.IDragInteractor;
   import com.broceliand.ui.interactors.drag.PearlDetachmentInteractor;
   import com.broceliand.ui.interactors.drag.StopDetector;
   import com.broceliand.ui.interactors.scroll.ScrollInteractor;
   import com.broceliand.ui.model.INodeTitleModel;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIRootPearl;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlBase;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.ui.window.ui.signUpBanner.SignUpBanner;
   import com.broceliand.util.IAction;
   import com.broceliand.util.flexWorkaround.SafariMouseWheelHandler;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   import mx.core.UIComponent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class InteractorManager implements IActive {
      
      public static const DOUBLE_CLICK_LENGTH:Number = 300;
      public static var log:BroLogger = Log.getLogger("com.broceliand.ui.interactors.InteractorManager");
      private var _lastMouseDownTime:Number;
      
      private var _hasDoubleClicked:Boolean;
      
      private var _selectedPearl:IUIPearl = null;
      
      private var _draggedPearl:IUIPearl = null;
      private var _originalParentNode:SavedPearlReference;
      
      private var _draggedPearlOriginalParentIndex:int;
      private var _draggedPearlInitialPosition:Point;
      protected var _mousePosition:Point;
      private var _nodeWhoseTitleIsBeingEdited:IPTNode = null;
      private var _dragEditInteractor:IDragInteractor = null;
      protected var _pearlTreeViewer:IPearlTreeViewer;
      private var _draggedPearlIsDetached:Boolean = false;
      private var _draggedPearlOverTrash:Boolean = false;
      private var _mouseDownOnViewer:Boolean = false;
      private var _userClickedOnPearl:Boolean;
      private var _nodeTitleModel:NodeTitleModel;
      private var _manipulatedNodesModel:ManipulatedNodesModel;
      
      private var _nodesBeingDeleted:Array;

      private var _selectInteractor:SelectInteractor = null;
      private var _hoverInteractor:HoverInteractor = null;
      protected var _scrollInteractor:ScrollInteractor = null;
      private var _pearlRendererUnderCursor:IUIPearl = null;
      private var _openCloseTreeInteractor:OpenCloseTreeInteractor = null;
      private var _modeSwitcherInteractor:ModeSwitcherInteractor = null;
      private var _depthInteractor:DepthInteractor;
      private var _nodePositioningInteractor:NodePositioningInteractor = null;
      private var _trashInteractor:TrashInteractor = null;
      
      private var _windowProtectionManager:WindowProtectionManager = null;

      private var _userInteractionMode:int = UserInteractionMode.UIM_NEUTRAL;
      
      private var _interactorRightsManager:InteractorRightsManager;
      private var _stopDetector:StopDetector;
      
      private var _active:Boolean = true;
      private var _actionForbidden:Boolean;
      private var _cursorInteractor:CursorInteractor;
      private var _gestureInteractor:IGestureInteractor;
      
      private var _userHasRightToMoveNode:Boolean;
      private var _userHasRightToCopyNode:Boolean;
      
      private var _actionToPerformAfterEditionEnds:Array = new Array();
      
      private var _browserScrollLocker:BrowserScrollLocker = new BrowserScrollLocker();
      
      public static const MIN_TIME_UNDER_CURSOR:Number = 65;
      
      public function InteractorManager(pearlTreeViewer:IPearlTreeViewer, garp:GraphicalAnimationRequestProcessor) {
         _pearlTreeViewer = pearlTreeViewer;
         _mousePosition = new Point();
         _pearlTreeViewer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
         if(_pearlTreeViewer.stage) {
            addStageListeners(null);
         }else{
            _pearlTreeViewer.addEventListener(Event.ADDED_TO_STAGE, addStageListeners);
         }
         _selectInteractor = new SelectInteractor(this);
         _hoverInteractor = new HoverInteractor(this);
         _dragEditInteractor = new DistantDragEditInteractor(this,true, true);
         _scrollInteractor = new ScrollInteractor(this);
         _openCloseTreeInteractor = new OpenCloseTreeInteractor(this);
         _modeSwitcherInteractor = new ModeSwitcherInteractor(this, garp);
         _trashInteractor = new TrashInteractor(this);
         
         _windowProtectionManager = new WindowProtectionManager();
         
         _interactorRightsManager = new InteractorRightsManager();
         _depthInteractor = new DepthInteractor(this);
         _nodePositioningInteractor = new NodePositioningInteractor(this);
         _nodeTitleModel = new NodeTitleModel();
         _manipulatedNodesModel = new ManipulatedNodesModel();
         _cursorInteractor = new CursorInteractor(this, pearlTreeViewer);
         if(ApplicationManager.getInstance().isFlashSupportingMultitouch) {
            _gestureInteractor = new GestureInteractor(this);
         }else{
            _gestureInteractor = new GestureInteractorDisabled();
         }
         _stopDetector = new StopDetector();
         _nodesBeingDeleted =  new Array();
         setActive(false);
      }
      
      public function isScrolling():Boolean {
         return _scrollInteractor.isScrolling();
      }
      
      public function get interactorRightsManager():InteractorRightsManager {
         return _interactorRightsManager;
      }
      
      public function getSelectInteractor():SelectInteractor {
         return _selectInteractor;
      }
      public function getOpenCloseTreeInteractor():OpenCloseTreeInteractor {
         return _openCloseTreeInteractor;
      }
      
      public function getUserInteractionMode():int {
         return _userInteractionMode;
      }
      
      public function get trashInteractor():TrashInteractor {
         return _trashInteractor;
      }
      
      public function performActionAfterEndOfEditing(action:IAction):void {
         if (_userInteractionMode == UserInteractionMode.UIM_PEARL_EDITING) {
            _actionToPerformAfterEditionEnds.push(action);
         } else {
            action.performAction();
         }
      }

      public function setUserInteractionMode(o:int, ev:MouseEvent):void {
         
         if (ApplicationManager.getInstance().isEmbed()) {
            return;
         }
         
         if(_userInteractionMode == o){
            return;
         }
         
         if(_userInteractionMode == UserInteractionMode.UIM_PEARL_EDITING){
            _dragEditInteractor.dragEnd(ev);
            while (_actionToPerformAfterEditionEnds.length>0) {
               IAction(_actionToPerformAfterEditionEnds.shift()).performAction();
            }
         }else if(_userInteractionMode == UserInteractionMode.UIM_NEUTRAL){
            if(o == UserInteractionMode.UIM_PEARL_EDITING){
               updateDragInteractor();
               ApplicationManager.getInstance().visualModel.navigationModel.cancelCurrentLoadingEvent();
               _dragEditInteractor.dragBegin(ev);
            }
         }

         _userInteractionMode = o;
      }
      public function ensureEndDrag(event:MouseEvent=null):Boolean{
         if (_draggedPearl) {
            if(_userInteractionMode == UserInteractionMode.UIM_PEARL_EDITING){
               if (!event) {
                  event = new MouseEvent(MouseEvent.MOUSE_UP, true,false, _draggedPearl.stage.mouseX, _draggedPearl.stage.mouseY);
                  
               }
               IPTVisualGraph(_draggedPearl.node.vnode.vgraph).ensureDragEnd(event);
               
               setUserInteractionMode(UserInteractionMode.UIM_NEUTRAL,event);
               return true;
            }
            
         }
         return false;
      }
      
      public function get draggedPearlInitialPosition():Point {
         return _draggedPearlInitialPosition;
      }
      
      public function set draggedPearlInitialPosition(o:Point):void {
         _draggedPearlInitialPosition = o;
      }

      public function get userClickedOnPearl():Boolean {
         return _userClickedOnPearl;
      }
      
      public function set userClickedOnPearl(o:Boolean):void {
         _userClickedOnPearl = o;
      }
      
      public function get pearlTreeViewer():IPearlTreeViewer {
         return _pearlTreeViewer;
      }
      
      public function set pearlTreeViewer(o:IPearlTreeViewer):void {
         _pearlTreeViewer = o;
      }
      
      public function get draggedPearlOverTrash():Boolean {
         return _draggedPearlOverTrash;
      }
      
      public function set draggedPearlOverTrash(o:Boolean):void {
         _draggedPearlOverTrash = o;
      }
      
      public function get draggedPearlIsDetached():Boolean {
         return _draggedPearlIsDetached;
      }
      
      public function set draggedPearlIsDetached(o:Boolean):void {
         if (_draggedPearlIsDetached != o) {
            if (o) {
               showExplanationForAnonymousUser(SignUpBanner.DRAG_PEARL_DETACHED);
            }
            _draggedPearlIsDetached = o;
         }
      }
      public function set hasDoubleClicked (value:Boolean):void
      {
         if (_hasDoubleClicked != value) {
            _hasDoubleClicked = value;
         }
      }
      
      public function get hasDoubleClicked ():Boolean
      {
         return _hasDoubleClicked;
      }

      public function getDraggedPearlOriginParentNodeRef():SavedPearlReference {
         return _originalParentNode;
      }
      public function get draggedPearlOriginalParentVNode():IVisualNode {
         if (_originalParentNode ) {
            var node:IPTNode = _originalParentNode.getNode();
            if (node) {
               return node.vnode;
            }
         }
         return null;
      }
      public function get draggedPearlLogicalOriginParentVNode():IVisualNode {
         var result:IPTNode = null;
         if (_originalParentNode != null) {
            result = _originalParentNode.getNode();
         }
         if (result) {
            return result.vnode;
         }
         return null;
      }
      
      public function setDraggedPearlOriginalParentNode(o:IPTNode):void {
         if (o) {
            _originalParentNode  = _manipulatedNodesModel.savePearlRef(o);
         } else {
            _originalParentNode= null;
         }
         
      }
      
      public function get draggedPearl():IUIPearl {
         return _draggedPearl;
      }
      
      public function set draggedPearl(o:IUIPearl):void {
         _draggedPearl = o;
      }
      
      public function get selectedPearl():IUIPearl {
         return _selectedPearl;
      }
      
      public function set selectedPearl(o:IUIPearl):void {
         _selectedPearl = o;
      }
      
      public function set draggedPearlOriginalParentIndex (value:int):void
      {
         _draggedPearlOriginalParentIndex = value;
         
      }
      
      public function get draggedPearlOriginalParentIndex ():int
      {
         return _draggedPearlOriginalParentIndex;
      }

      private function updateDragInteractor():void{
         if(_interactorRightsManager.userHasRightToMoveNode(_pearlRendererUnderCursor.node)){
            _dragEditInteractor = new DistantDragEditInteractor(this, _interactorRightsManager.userIsHome(), _interactorRightsManager.isUserAnonymous());
         } else if(_interactorRightsManager.userCanCopyNode(_pearlRendererUnderCursor.node.getBusinessNode())){
            _dragEditInteractor = new CopyDragInteractor(this);
         }
      }
      
      private var _temporaryPearlUnderCursorTime:Number; 
      private var _temporaryPearlUnderCursor:IUIPearl; 
      private var _temporaryPearlUnderCursorTimeout:uint; 
      
      private function checkMousePositionAfterTimeout():void {
         if (_temporaryPearlUnderCursor) {
            checkPearlUnderCursor();
         }
      }
      private function checkPearlUnderCursor(withTimeOut:Boolean = true):void {
         if (!_pearlTreeViewer.stage) {
            return;
         }
         _mousePosition.x = _pearlTreeViewer.stage.mouseX;
         _mousePosition.y = _pearlTreeViewer.stage.mouseY;
         updatePearlRendererUnderCursor(_mousePosition, withTimeOut);
      }
      
      public function updatePearlUnderCursorAfterCross():void {
         var oldPearlUnderCursor:IUIPearl = _pearlRendererUnderCursor;
         checkPearlUnderCursor(false);
         if (_temporaryPearlUnderCursor && oldPearlUnderCursor != _temporaryPearlUnderCursor && !_temporaryPearlUnderCursor.node.isEnded()) {
            if (oldPearlUnderCursor && oldPearlUnderCursor == draggedPearl) {
               draggedPearl = _temporaryPearlUnderCursor;
            }
            _pearlRendererUnderCursor = _temporaryPearlUnderCursor;

            if (_pearlRendererUnderCursor is UIRootPearl) {
               UIRootPearl(_pearlRendererUnderCursor).setButtonVisible(true);
            }
            ApplicationManager.getInstance().visualModel.mouseManager.update();
         }
      }
      public function updatePearlRendererUnderCursor(mousePosition:Point, withTimeOut:Boolean = true, resetNodeUnderCursor:Boolean = false):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed() && am.embedManager.isSelectionFreezed) return;
         var old:IUIPearl = _pearlRendererUnderCursor;
         if (old && old.node && old.node.isEnded()) {
            old = null;
            _pearlRendererUnderCursor = null;
         }
         var rendererUnderCursor:IUIPearl = null;
         var nodeUnderCursor:IPTNode = null;
         var pearlUnderCursorChanged:Boolean = false;
         var controls:IGraphControls = _pearlTreeViewer.vgraph.controls;
         var wc:IWindowController =  ApplicationManager.getInstance().components.windowController;
         if (resetNodeUnderCursor) {
            nodeUnderCursor = null;
            rendererUnderCursor = null;
         } else if(am.isEmbed() || !(controls.isPointOverTopButtons(mousePosition) || wc.isPointOverWindow(mousePosition.x, mousePosition.y) || wc.isPointOverNotificationWindow(mousePosition.x, mousePosition.y))) {
            rendererUnderCursor = PearlBase.getPearlRendererUnderPoint(mousePosition);
            if(rendererUnderCursor) {
               nodeUnderCursor = rendererUnderCursor.node;
               if(nodeUnderCursor && nodeUnderCursor.isDocked && isDisplayingPTW()) {
                  nodeUnderCursor = null;
                  rendererUnderCursor = null;
               }
            }
         }
         
         pearlUnderCursorChanged = (old != rendererUnderCursor);
         
         if(!nodeUnderCursor) {
            _pearlRendererUnderCursor = null;
            removeTemporaryPearlUnderCursor();
         }
         else if(pearlUnderCursorChanged && !_gestureInteractor.isTouchScreen() && withTimeOut) {
            var currentTime:Number = getTimer();
            var pearlUnderCursorSinceTime:Number = (currentTime - _temporaryPearlUnderCursorTime);
            
            if(_temporaryPearlUnderCursor != rendererUnderCursor) {
               removeTemporaryPearlUnderCursor();
               _temporaryPearlUnderCursor = rendererUnderCursor;
               _temporaryPearlUnderCursorTime = currentTime;
               _temporaryPearlUnderCursorTimeout = setTimeout(checkMousePositionAfterTimeout, MIN_TIME_UNDER_CURSOR);
               pearlUnderCursorChanged = false;
            }
               
            else if(pearlUnderCursorSinceTime < MIN_TIME_UNDER_CURSOR) {
               pearlUnderCursorChanged = false;
            }
         }
         
         if(pearlUnderCursorChanged) {
            _pearlRendererUnderCursor = rendererUnderCursor;
            removeTemporaryPearlUnderCursor();
            am.visualModel.mouseManager.update();
            
            if (old != null){
               _hoverInteractor.onMouseOut(old);
            }
            if (_pearlRendererUnderCursor != null){
               var isOverControl:Boolean = _pearlTreeViewer.vgraph.controls.isPointOverAControl(mousePosition);
               if(isOverControl){
                  if (_pearlTreeViewer.vgraph.controls.isPointOverPearlButton(mousePosition)) {
                     _hoverInteractor.onMouseOver(_pearlRendererUnderCursor);
                  } else {
                     if(_pearlRendererUnderCursor.node && !nodeUnderCursor.isDocked){
                        
                        _pearlRendererUnderCursor= null;
                     }
                  }
               }
            }
            if (_pearlRendererUnderCursor != null && !_pearlRendererUnderCursor.node.isEnded()){
               _hoverInteractor.onMouseOver(_pearlRendererUnderCursor);
               if (nodeUnderCursor) {
                  _userHasRightToMoveNode = _interactorRightsManager.userHasRightToMoveNode(nodeUnderCursor);
                  if(_userHasRightToMoveNode){
                     
                     _userHasRightToCopyNode = false;
                  }else{
                     _userHasRightToCopyNode = _interactorRightsManager.userCanCopyNode(nodeUnderCursor.getBusinessNode());
                  }
               }
            }
         }
      }
      
      private function removeTemporaryPearlUnderCursor():void {
         if (_temporaryPearlUnderCursorTimeout !=0) {
            clearTimeout(_temporaryPearlUnderCursorTimeout);
            _temporaryPearlUnderCursorTimeout = 0;
         }
         _temporaryPearlUnderCursorTimeout = 0;
         _temporaryPearlUnderCursor = null;
      }
      
      private function updateContextualHelp(mousePosition:Point):void {
         var controls:IGraphControls = _pearlTreeViewer.vgraph.controls;
         if(controls.footer && controls.footer.isPointOverFooter(mousePosition)) {
            var highlightDropZone:Boolean = controls.isPointOverDropZoneDeck(mousePosition);
            var highlightInbox:Boolean = false;
            
            if(highlightDropZone){
               if(controls.dropZoneDeckModel) {
                  controls.dropZoneDeckModel.highlight();
               }
            }
            else{
               if(controls.dropZoneDeckModel) {
                  controls.dropZoneDeckModel.unhighlight();
               }
            }
         }
         else {
            if(controls.dropZoneDeckModel) {
               controls.dropZoneDeckModel.unhighlight();
            }
         }
      }
      
      public function get pearlRendererUnderCursor():IUIPearl {
         return _pearlRendererUnderCursor;
      }
      
      public function get temporaryPearlRendererUnderCursor():IUIPearl {
         return _temporaryPearlUnderCursor;
      }
      
      protected function refreshMousePosition(mouseEvent:MouseEvent):void {
         if(!_mousePosition) _mousePosition = new Point();
         _mousePosition.x = mouseEvent.stageX;
         _mousePosition.y = mouseEvent.stageY;
      }
      
      public function get mousePosition():Point {
         return _mousePosition;
      }
      
      protected function onMouseMove(ev:MouseEvent):void {
         SafariMouseWheelHandler.getInstance().invalidateObjectUnderCursor();
         if(!_active) {
            _browserScrollLocker.setBrowserScrollLocker(true);
            return;
         }
         _stopDetector.onMove();
         refreshMousePosition(ev);
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         refreshApplicationFocusState();
         
         if(_userInteractionMode == UserInteractionMode.UIM_PEARL_EDITING){
            if (!pearlRendererUnderCursor) {
               setUserInteractionMode(UserInteractionMode.UIM_NEUTRAL,ev);
            } else {
               _dragEditInteractor.handleDrag(ev);
               _selectInteractor.commitPendingSelection();
            }
         }else{
            if(isEventOnWindow(ev) || isEventOnOrCloseNotificationWindow(ev)){
               _scrollInteractor.onMouseOverComponent();
               _browserScrollLocker.setBrowserScrollLocker(true);
               return;
            }
            updateContextualHelp(_mousePosition);
            updatePearlRendererUnderCursor(_mousePosition);
            _browserScrollLocker.setBrowserScrollLocker(false);
         }
         _pearlTreeViewer.vgraph.controls.scrollControl.updateOnMouseMove(ev.stageX, ev.stageY, _draggedPearl != null);
         var wc:IWindowController = am.components.windowController;
         if(!am.isEmbed() || wc.isAllWindowClosed() || wc.getNodeDisplayed()) {
            _scrollInteractor.onMouseMove(_mousePosition);
         }
         _modeSwitcherInteractor.updateModeOnMouseMove(ev);
      }
      
      private function refreshApplicationFocusState():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if (!am.isApplicationFocused) {
            
            var marginThreshold:int = (!am.isEmbed())?50:0;
            if (_mousePosition.x > marginThreshold && _mousePosition.y > marginThreshold) {
               var stageWidth:Number = ApplicationManager.flexApplication.stage.stageWidth;
               var stageHeight:Number = ApplicationManager.flexApplication.stage.stageHeight;
               if (_mousePosition.x < stageWidth - marginThreshold && _mousePosition.y < stageHeight - marginThreshold) {
                  am.isApplicationFocused = true;
               }
            }
         }
      }
      
      private function isEventOnWindow(ev:MouseEvent):Boolean{
         var wc:IWindowController =  ApplicationManager.getInstance().components.windowController;
         return wc.isPointOverWindow(ev.stageX, ev.stageY);
      }
      
      private function isEventOnOrCloseNotificationWindow(ev:MouseEvent):Boolean{
         var wc:IWindowController =  ApplicationManager.getInstance().components.windowController;
         return (wc && ev && wc.isPointOverNotificationWindow(ev.stageX, ev.stageY));
      }

      protected function onStageMouseUp(ev:MouseEvent):void{
         if(!_active) return;
         if(!_mouseDownOnViewer) return;
         var clickDuration:Number = getTimer() - _lastMouseDownTime;
         refreshMousePosition(ev);
         _mouseDownOnViewer = false;
         _scrollInteractor.onMouseUp(ev);
         var wasNeutralMode:Boolean = (_userInteractionMode == UserInteractionMode.UIM_NEUTRAL);
         
         _modeSwitcherInteractor.updateModeOnMouseUp(ev);
         
         var isNeutralMode:Boolean = (_userInteractionMode == UserInteractionMode.UIM_NEUTRAL);
         var hasMouseDragged:Boolean = _modeSwitcherInteractor.hasMouseDragged();
         if (clickDuration> PearlDetachmentInteractor.MIN_INACTIVE_TIME_1) {
            hasMouseDragged = true;
         }
         var node:IPTNode = (_pearlRendererUnderCursor)?_pearlRendererUnderCursor.node:null;
         var isPointOverControl:Boolean = _pearlTreeViewer.vgraph.controls.isPointOverAControl(mousePosition);
         
         if(isNeutralMode && !isEventOnWindow(ev) && !hasMouseDragged && node && !isPointOverControl  && _pearlRendererUnderCursor.isPointOnPearl(mousePosition)) {
            if(!node.isDocked && _pearlRendererUnderCursor) {
               _openCloseTreeInteractor.onPearlClick(_pearlRendererUnderCursor, clickDuration);
            }
            else {
               _selectInteractor.unselect();
            }
         }
         
         _selectInteractor.onMouseUp(hasMouseDragged, clickDuration);

         _actionForbidden = false;
         ApplicationManager.getInstance().visualModel.mouseManager.update();

         _lastMouseDownTime = getTimer();
         if ( _interactorRightsManager.isUserAnonymous()) {
            if ((!hasMouseDragged && !node && !isPointOverControl)  || (hasMouseDragged && !wasNeutralMode)) {
               if (ApplicationManager.getInstance().components.windowController.hasAppearedOnce) {
                  showExplanationForAnonymousUser(SignUpBanner.MOUSE_UP);            
               }
            }    
         }
         
      }
      
      protected function onMouseDown(ev:MouseEvent):void{
         if(!_active) return;
         refreshMousePosition(ev);
         
         var time:Number = getTimer();
         updatePearlRendererUnderCursor(_mousePosition);
         if(isDisplayingPTW() && _pearlRendererUnderCursor && _pearlRendererUnderCursor.node && _pearlRendererUnderCursor.node.isDocked) return;
         hasDoubleClicked = (time -_lastMouseDownTime < DOUBLE_CLICK_LENGTH);
         _lastMouseDownTime = time;
         _mouseDownOnViewer = true;
         _scrollInteractor.onMouseDown(ev);
         if(_pearlRendererUnderCursor && _pearlRendererUnderCursor.isPointOnPearl(mousePosition)){
            _userClickedOnPearl = true;
            _scrollInteractor.onClickOnPearl();
            _openCloseTreeInteractor.saveCurrentSelectionOnMouseDown();
            var isPointOverCloseButton:Boolean = _pearlTreeViewer.vgraph.controls.isPointOverPearlButton(_mousePosition);
            if (!isPointOverCloseButton && (!ApplicationManager.getInstance().isEmbed() || !_pearlRendererUnderCursor.node.isDocked)) {
               _selectInteractor.selectOnMouseDown(_pearlRendererUnderCursor);
            }
         }else{
            _userClickedOnPearl = false;
         }
         _modeSwitcherInteractor.updateModeOnMouseDown(ev);
      }
      
      private function onMouseLeaveStage(ev:Event):void{
         var mev:MouseEvent = new MouseEvent(ev.type);
         refreshMousePosition(mev);
         
         updatePearlRendererUnderCursor(_mousePosition);

         if(StartPolicyLogger.getInstance().isFirstNavigationEnded()) {
            updateContextualHelp(_mousePosition);
         }
         _scrollInteractor.onMouseLeaveStage(mev);
         
      }
      public function hasMouseDragged():Boolean {
         return _modeSwitcherInteractor.hasMouseDragged() || _draggedPearlIsDetached;
      }
      
      private function addStageListeners(event:Event):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if (event) {
            _pearlTreeViewer.removeEventListener(Event.ADDED_TO_STAGE, addStageListeners);
         }
         _pearlTreeViewer.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveStage);
         _pearlTreeViewer.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
         _pearlTreeViewer.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
         
         am.visualModel.navigationModel.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigate);
         
         if(_pearlTreeViewer.stage) {
            _mousePosition = new Point();
            _mousePosition.x = _pearlTreeViewer.stage.mouseX;
            _mousePosition.y = _pearlTreeViewer.stage.mouseY;
            refreshApplicationFocusState();
         }
      }
      
      public function installWindow(window:UIComponent):void {
         if(!window) return;
         window.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      }
      
      private function onNavigate(event:NavigationEvent):void{
         
         if (event.isNewTreeSelection && !event.isNewFocus){
            _pearlTreeViewer.vgraph.refreshNodes();
         }
         
      }
      
      public function get depthInteractor():DepthInteractor {
         return _depthInteractor;
      }
      
      public function get nodePositioningInteractor():NodePositioningInteractor {
         return _nodePositioningInteractor;
      }
      
      public function get nodeWhoseTitleIsBeingEdited():IPTNode {
         return _nodeWhoseTitleIsBeingEdited;
      }
      
      public function set nodeWhoseTitleIsBeingEdited(value:IPTNode):void {
         _nodeWhoseTitleIsBeingEdited = value;
      }

      public function isDisplayingPTW():Boolean {
         return ApplicationManager.getInstance().visualModel.navigationModel.isShowingPearlTreesWorld();
      }
      
      public function isDisplayingWhatsHot():Boolean {
         return ApplicationManager.getInstance().visualModel.navigationModel.isWhatsHot();
      }
      
      public function getActive():Boolean {
         return _active;
      }
      
      public function setActive(value:Boolean):void {
         _active = value;
      }
      
      public function get nodeTitleModel():INodeTitleModel {
         return _nodeTitleModel;
      }
      
      public function get manipulatedNodesModel():ManipulatedNodesModel {
         return _manipulatedNodesModel;
      }
      
      public function get actionForbidden():Boolean {
         return _actionForbidden;
      }
      
      public function set actionForbidden(value:Boolean):void {
         _actionForbidden = value;
      }
      
      public function get userHasRightToMoveNode():Boolean {
         return _userHasRightToMoveNode;
      }
      
      public function get userHasRightToCopyNode():Boolean {
         return _userHasRightToCopyNode;
      }
      
      public function set nodesBeingDeleted (value:Array):void
      {
         _nodesBeingDeleted = value;
      }
      
      public function get nodesBeingDeleted ():Array
      {
         return _nodesBeingDeleted;
      }
      
      public function get selectInteractor():SelectInteractor {
         return _selectInteractor;
      }
      
      public function turnOffSelectionOnOver (value:Boolean, windowID:int, subPanelID:int = 0):void {
         if(_gestureInteractor.isTouchScreen()) return;
         
         if (value) {
            _windowProtectionManager.requestWindowProtection(windowID, subPanelID);
         }
         else {
            _windowProtectionManager.requestWindowUnlock(windowID, subPanelID);
         }
      }
      
      public function isWindowProtected(windowID : int, subPanelID : int = 0) : Boolean {
         var res : Boolean = _windowProtectionManager.isWindowProtected(windowID, subPanelID);
         return res;
      }

      public function isInsideCreationCycle() : Boolean {
         if (isWindowProtected(WindowController.NEW_PEARLTREE_WINDOW)) return true;
         if (isWindowProtected(WindowController.PEARL_URL_WINDOW)) return true;
         if (isWindowProtected(WindowController.PEARL_NOTE_WINDOW)) return true;
         if (isWindowProtected(WindowController.PEARL_PHOTO_WINDOW)) return true;
         if (isWindowProtected(WindowController.PEARL_DOCUMENT_WINDOW)) return true;
         return false;
      }
      
      public function get updateSelectionOnOver ():Boolean {
         if(_gestureInteractor.isTouchScreen()) return false;
         return !_windowProtectionManager.isProtected();
      }
      
      public function get stopDetector():StopDetector {
         return _stopDetector;
      }
      
      public function showExplanationForAnonymousUser(action:int):void {
         if (_interactorRightsManager.isUserAnonymous()) {
            var signupBanner:SignUpBanner = ApplicationManager.getInstance().components.mainPanel.signUpBanner;
            if (signupBanner) {
               signupBanner.showExplanationForAnonymousUser(action);
            }
         }
      }

      public function movePearlOutsideFromTeam():Boolean {
         var bnode:BroPTNode = draggedPearl.node.getBusinessNode();
         return (bnode.owner && bnode.owner.isInATeam() && !TeamRightManager.hasMovingOutsideRight(bnode));
      }
      
      public function noFounderDeletePearlFromTeam():Boolean {
         var bnode:BroPTNode = draggedPearl.node.getBusinessNode();
         return (bnode.owner && bnode.owner.isInATeam() && !TeamRightManager.hasDeletingRight(bnode));
      }
      
   }
   
}
