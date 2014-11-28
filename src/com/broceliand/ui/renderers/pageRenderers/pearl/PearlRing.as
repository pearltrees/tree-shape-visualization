package com.broceliand.ui.renderers.pageRenderers.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.graphLayout.visual.IScrollable;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.renderers.IRepositionable;
   import com.broceliand.ui.renderers.MoveNotifier;
   
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;

   public class PearlRing extends ColorRing implements IRepositionable, IScrollable{
      
      private var _pearl:PearlBase;
      private var _outsidePearl:Boolean  =true;
      private var _nullPoint:Point = new Point(0,0);
      private var _moveNotifier:MoveNotifier;
      private var _bindedComponent:IUIComponent;
      private var _positionChanged:Boolean;
      public function PearlRing(pearl:PearlBase)
      {
         _pearl = pearl;
         
      }
      public function moveRingInPearl():void {
         if (_outsidePearl) {
            _outsidePearl = false;
            if (parent){ 
               parent.removeChild(this);
            }
            includeInLayout= true;
            _pearl.addChildAt(this,0);
            x  = y = 0;
            alpha=1;
            updateScale();
            
         }
      }
      override protected function getPearlRadius():Number {
         return _pearl.getPearlVisibleWidth()/2.0;
      }  
      override  protected function getPearlCenterX():Number {
         return _pearl.width/2.0;
      }
      
      internal function commitRingsProperties(zoomChanged:Boolean):void {
         if (_pearl.width ==0) {
            
            return;
         }
         var hadRing:Boolean =  hasRings()
         super.commitColorRingsProperties(zoomChanged);
         if (zoomChanged || (!hadRing && hasRings())) {   
            reposition();
         }
         
      }
      
      public function moveRingOutPearl():void {
         if (!_outsidePearl) {
            updateScale();
            _outsidePearl = true;
            includeInLayout= false;
            onAddedToStage(null);
            reposition();
            
            validateNow();

         }
      }
      private function bindToComponent(view:IUIComponent):void {
         _bindedComponent = view;
         view.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
         view.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
         if (view.stage && !stage) {
            onAddedToStage(null);
         }
         
         reposition();
      }
      protected  function onRemoveFromStage(event:Event):void {
         parent.removeChild(this);
      } 
      protected function onAddedToStage(event:Event):void {
         ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.ringLayer.addChild(this);
         includeInLayout =false;
      } 
      
      override protected function createChildren():void {
         bindToComponent(_pearl.parent as UIComponent);
         super.createChildren();
         visible = false;
         if (!_pearl.initialized) {
            _pearl.addEventListener(FlexEvent.CREATION_COMPLETE, onPearlCreated);   
         } 
      }
      public function onPearlCreated(event:Event):void {
         IEventDispatcher(event.target).removeEventListener(FlexEvent.CREATION_COMPLETE, onPearlCreated);
         if (!_pearl) {
            return;
         } 
         if (_pearl.parent) {
            visible = _pearl.parent.visible;
         } else {
            visible = true;
         }
         reposition();
      }
      
      public function listenToNode(node:IPTNode):void {
         if (_moveNotifier) {
            _moveNotifier.removeMoveListener(this);
         }
         if (node && node.vnode) {
            _moveNotifier = IPTVisualNode(node.vnode).moveNotifier;
            _moveNotifier.addMoveListener(this);
         }
      }
      
      public function reposition():void {
         updateScale();
         if (_outsidePearl) {
            _positionChanged = true;
            
            if (_pearl.parent) {
               alpha = _pearl.parent.alpha;
            }
            if (hasRings()) {

               updatePosition();
            }
            
         }
         
      }
      private function updatePosition():void {
         if (_positionChanged) {
            var p:Point = _pearl.localToGlobal(_nullPoint);
            if (p.x == p.y && p.x ==0 && !_pearl.visible ){
               return;
            }
            var p2:Point = _nullPoint;
            if (parent) {
               p2 = parent.localToGlobal(_nullPoint);
            }
            var offsetX:Number = 0;
            var offsetY:Number = 0;

            move(p.x - p2.x + offsetX, p.y- p2.y + offsetY);
            _positionChanged = false;
         }
      }
      override protected function commitProperties():void {
         super.commitProperties();
         if (_positionChanged) {
            updatePosition();
         }
         
      }
      internal function clearMemory():void {
         if (_bindedComponent) {
            _bindedComponent.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
            _bindedComponent.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _bindedComponent = null;
         }
         
         if (_moveNotifier) {
            _moveNotifier.removeMoveListener(this);
            _moveNotifier = null;
         }

      }
      override protected function get noteCount():Number{
         var count:Number = super.noteCount;
         if (count == 0 && _pearl.pearlNotificationState.notifyingNewNote) {
            count = 1;
         }
         return count;
      }
      override protected function get neighbourCount():Number {
         var count:Number = super.neighbourCount;
         if (count == 0 && _pearl.pearlNotificationState.notifyingNewCross) {
            count = 1;
         }  
         return count;
      }
      
      override protected function get node():BroPTNode {
         if(_pearl.node) {
            return _pearl.node.getBusinessNode();
         }
         else{
            return null;
         }
      }
      
      override protected function get showNeighbourRing():Boolean {
         return (_pearl.node && !_pearl.node.isDocked);
      }
      
      override protected function get showNoteRing():Boolean {
         return (_pearl.node  && !_pearl.node.isInDropZone);
      }      
      public function isScrollable():Boolean {
         if (visible && _pearl && _pearl.node && !_pearl.node.isDocked) {
            return true;
         }
         return false;
      }
      private  function updateScale():void {
         if (_outsidePearl && _pearl && scaleX != _pearl.scale) {
            scaleX = _pearl.scale;
            scaleY = _pearl.scale;
         } else {
            if (!_outsidePearl && scaleX !=1) {
               scaleX = 1;
               scaleY = 1;
            }
         } 
      }
      override  public function restoreInitialState():void {
         super.restoreInitialState();
         _outsidePearl = true;
      }
      
   }
}