package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.LayoutAction;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.UserGaugeModel;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.model.NodeTitleModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.GenericAction;
   
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   import mx.controls.Image;
   import mx.core.BitmapAsset;
   import mx.core.DragSource;
   import mx.managers.DragManager;
   
   public class CopyDragInteractor extends DragEditInteractorBase implements IDragInteractor
   {
      private var _startPoint:Point= new Point();
      private var _mustInit:Boolean = true;
      private var _vgraph:IPTVisualGraph;
      private var _isDraggingPearl:Boolean;
      private var _isDragCancelled:Boolean = false;
      private var _detachDistance:Number;
      private var _needLayout:Boolean = false;
      private var _isUserStorageFull:Boolean = false;
      private var _dropZoneInteractor:DropZoneInteractor;
      
      private var DETACH_PEARL_RATIO:Number = .25;
      
      public function CopyDragInteractor(interactorManager:InteractorManager){
         _dropZoneInteractor = new DropZoneInteractor(interactorManager);
         super(interactorManager);
      }
      
      override public function handleDrag(ev:MouseEvent):void{
         
         if (_mustInit) {
            initDrag(ev);
         }
         if (_isDraggingPearl) {
            _vgraph.handleDragPearl(ev);
            if (!_needLayout && _interactorManager.hasMouseDragged()) {
               _needLayout = true;
            }
            var distanceFromStart:Number = BroceliandMath.getSquareDistanceBetweenPoints(_startPoint, _interactorManager.mousePosition);
            if (distanceFromStart >  _detachDistance) {
               startDragCopy(ev);
               
               _needLayout = true;
               launchLayout(ev);
               _isDraggingPearl = false;
               var controls:IGraphControls =_interactorManager.pearlTreeViewer.vgraph.controls;
               if (controls.footer.footerBanner) {
                  controls.footer.footerBanner.bannerModel.onDragBegin();
               }
            }
         }
         handleNodeTitleMessageWhileDragging(ev);
         ev.updateAfterEvent();
         super.handleDrag(ev);
      }
      
      private function handleNodeTitleMessageWhileDragging(ev:MouseEvent):void {
         var node:IPTNode = _interactorManager.draggedPearl.node;
         _interactorManager.nodeTitleModel.setNodeMessageType(node, NodeTitleModel.NO_MESSAGE);
         if (_isDraggingPearl && _dropZoneInteractor.isMouseOverDropZone(ev) && _isUserStorageFull) {
            _interactorManager.nodeTitleModel.setNodeMessageType(node, NodeTitleModel.MESSAGE_NO_COPY_PEARL_WHEN_FULL_STORAGE);
         }
      }

      private function testCopyValid(node:IPTNode):Boolean{
         if (node.isDocked) {
            return false;
         }
         if (_isUserStorageFull == true) {
            return false;
         }
         var businessNode:BroPTNode = node.getBusinessNode(); 
         if(!businessNode){
            return false;
         }
         
         if (!businessNode.canBeCopy()) {
            return false;
         }
         return true;
      }
      
      override public function dragEnd(ev:MouseEvent):void {

         if (!_mustInit) {
            handleDrag(ev);
            suscribeToNavEvent(false);
            var controls:IGraphControls =_interactorManager.pearlTreeViewer.vgraph.controls;
            var isMouseOverDropZone:Boolean =controls.isPointOverDropZoneDeck(_interactorManager.mousePosition);
            var isMouseOverTrash:Boolean = controls.isPointOverTrash(_interactorManager.mousePosition);
            if (!isMouseOverDropZone && BroceliandMath.getSquareDistanceBetweenPoints(_startPoint, _interactorManager.mousePosition)> 900) {
               isMouseOverDropZone = true;
            }
            if(!_isDragCancelled && !_isDraggingPearl && !isMouseOverTrash && isMouseOverDropZone && testCopyValid(_interactorManager.draggedPearl.node) ){
               controls.dropZoneDeckModel.dockNode(_interactorManager.draggedPearl.node, true, _interactorManager.mousePosition);
            }		   
            controls.dropZoneDeckModel.unhighlight();
            controls.enableScrollControl(true);
            _mustInit = true;
            launchLayout(ev);   
            _isDraggingPearl = false;
         }
         _interactorManager.depthInteractor.returnPearlAboveAllElseToNormalPosition();
         super.dragEnd(ev);
      }
      
      private function initDrag(ev:MouseEvent):void {
         _mustInit = false;
         _isDragCancelled = false;
         suscribeToNavEvent(true);
         _startPoint.x = ev.stageX;
         _startPoint.y = ev.stageY;
         var pr:IUIPearl = _interactorManager.pearlRendererUnderCursor;
         _detachDistance = pr.pearlWidth * DETACH_PEARL_RATIO;
         _detachDistance *= pr.pearlWidth * DETACH_PEARL_RATIO;
         _vgraph= pr.vnode.vgraph as IPTVisualGraph;
         _vgraph.dragNodeBegin(pr.uiComponent, ev);
         _isDraggingPearl = true;
         var controls:IGraphControls =_interactorManager.pearlTreeViewer.vgraph.controls; 
         controls.dropZoneDeckModel.highlight();
         controls.enableScrollControl(false);
      }
      
      private function suscribeToNavEvent(suscribe:Boolean):void {
         var navManager:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         if (suscribe) {
            navManager.addEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigate);
         } else {
            navManager.removeEventListener(NavigationEvent.NAVIGATION_EVENT, onNavigate);
         }
      }
      private function onNavigate(event:NavigationEvent):void {
         _isDragCancelled = true;
         suscribeToNavEvent(false);
      }
      private function startDragCopy(ev:MouseEvent):void {
         var dragSource:DragSource = new DragSource();
         var businessNode:BroPTNode = _interactorManager.pearlRendererUnderCursor.node.getBusinessNode();
         dragSource.addData(businessNode, BroPTNode.DATA_FORMAT_BROPTNODE);
         var pearlBase:IUIPearl= _interactorManager.pearlRendererUnderCursor;
         var scale:Number = pearlBase.getScale();
         var ringOffset:Number = 20;
         var bitmapData:BitmapData  = new BitmapData(pearlBase.width + 2 * scale * ringOffset, pearlBase.height +2*  scale *ringOffset , true, 0x00000000);
         var m:Matrix = new Matrix();
         m.a = m.d = scale;
         
         if (pearlBase.pearl._colorRing) {
            m.tx = ringOffset * scale + pearlBase.pearl.x * scale ;
            m.ty = ringOffset * scale + pearlBase.pearl.y * scale ;
            bitmapData.draw(pearlBase.pearl._colorRing, m);
         }
         m.a = m.d = scale;
         m.tx = ringOffset * scale ;
         m.ty = ringOffset * scale ;
         bitmapData.draw(pearlBase, m);
         
         var capImage:Image = new Image();
         capImage.source = new BitmapAsset(bitmapData);
         
         if (ev) {
            
            var nonNullTarget:Object = ev.target;
            if (nonNullTarget == null) { 
               nonNullTarget =_interactorManager.pearlRendererUnderCursor ;
            }
            var proxyOrigin:Point = DisplayObject(nonNullTarget).localToGlobal(new Point(ev.localX, ev.localY));
            proxyOrigin = DisplayObject(_interactorManager.pearlRendererUnderCursor).globalToLocal(proxyOrigin);
            var offsetX:Number = ringOffset * scale + (scale - 1) * proxyOrigin.x;
            var offsetY:Number = ringOffset * scale + (scale - 1) * proxyOrigin.y;
            DragManager.doDrag(_interactorManager.pearlRendererUnderCursor, dragSource, ev, capImage, offsetX, offsetY, 1);
            checkIfUserStorageFull();
         }
      }
      
      private function checkIfUserStorageFull():void {
         var userGaugeModel:UserGaugeModel = ApplicationManager.getInstance().currentUser.userGaugeModel();
         var notOverMaxAction:GenericAction = new GenericAction(null, this, onUserStorageNotFull);
         var overMaxAction:GenericAction = new GenericAction(null, this, onUserStorageFull);
         userGaugeModel.performActionIfNotOverMax(notOverMaxAction, overMaxAction, true);
      }
      
      private function onUserStorageFull():void {
         _isUserStorageFull = true;
      }
      
      private function onUserStorageNotFull():void {
         _isUserStorageFull = false;
      }
      
      private function launchLayout(ev:MouseEvent):void  {
         if (_needLayout) {
            _vgraph.dragEndEventSafe(ev);
            ApplicationManager.getInstance().visualModel.animationRequestProcessor.postActionRequest(new LayoutAction(_vgraph, false));
            _needLayout = false;
            
         }
      } 
      
   }
}