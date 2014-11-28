package com.broceliand.ui.pearlTree
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.graphLayout.visual.IScrollable;
   import com.broceliand.ui.pearl.UICoeditCenterPTWPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.ui.renderers.IRepositionable;
   import com.broceliand.ui.renderers.MoveNotifier;
   import com.broceliand.util.GenericAction;
   
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.containers.Canvas;
   import mx.core.IUIComponent;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;
   
   public class PearlComponentAddOn extends Canvas implements IRepositionable, IScrollable
   {
      protected var _bindedComponent:IUIComponent;
      protected var _node:IPTNode;
      protected var _moveNotifier:MoveNotifier;
      private var _targetPosition:Point = new Point();
      private var _targetVisibleState:Boolean;
      private var _isAddedToControlLayer:Boolean;
      
      public function PearlComponentAddOn() {
         visible = includeInLayout = false;
      }
      
      override protected function createChildren():void{
         super.createChildren();
         horizontalScrollPolicy = ScrollPolicy.OFF;
         verticalScrollPolicy = ScrollPolicy.OFF; 
      }
      
      protected function getUIComponentFromNode(node:IPTNode,uiComponent:UIComponent=null):UIComponent {
         if (node && node.vnode && node.vnode.view) {
            return node.vnode.view;
         }
         return uiComponent;            
      }
      public function bindToNode(node:IPTNode, defaultC:UIComponent=null):void {
         if (_node != node) {
            clear();
            _node = node;
         }
         var uiComponent:UIComponent = getUIComponentFromNode(node, defaultC);
         if (uiComponent) {
            if (uiComponent != _bindedComponent) {
               _moveNotifier = IPTVisualNode(node.vnode).moveNotifier;
               _moveNotifier.addMoveListener(this);
            } 
            else if (uiComponent && IPTVisualNode(node.vnode).moveNotifier != _moveNotifier) {
               if (_moveNotifier) {
                  _moveNotifier.removeMoveListener(this);
               }
               _moveNotifier = IPTVisualNode(node.vnode).moveNotifier;
               _moveNotifier.addMoveListener(this);
            }
         } else {
            clear();
         }
         bindToComponent(uiComponent);
      }
      
      protected function clear():void  {
         if (_bindedComponent) {
            _bindedComponent.removeEventListener(Event.REMOVED_FROM_STAGE, onPearlRemovedFromStage);
            _bindedComponent.removeEventListener(Event.ADDED_TO_STAGE, onPearlAddedToStage);
         }
         if (_moveNotifier) {
            _moveNotifier.removeMoveListener(this);
            _moveNotifier =null;
         }
      }
      private function bindToComponent(view:IUIComponent):void {
         onChangeBoundComponent(_bindedComponent, view);
         _bindedComponent = view;
         if (_bindedComponent) {
            _bindedComponent.addEventListener(Event.REMOVED_FROM_STAGE, onPearlRemovedFromStage);
            _bindedComponent.addEventListener(Event.ADDED_TO_STAGE, onPearlAddedToStage);
            if (_bindedComponent.stage && !stage) {
               onPearlAddedToStage(null);
            }
         }
         updateVisible();
         repositionNow(true);
      }
      
      protected function onChangeBoundComponent(oldComponent:IUIComponent, newComponent:IUIComponent):void {
      }
      public function reposition():void {
         updateScale();
         invalidateProperties();
      }
      protected function updateScale():void {
         if (visible && _bindedComponent && scaleX != _bindedComponent.scaleX) {
            scaleX = _bindedComponent.scaleX;
            scaleY = scaleX;
         }
      }
      
      protected function onPearlRemovedFromStage(event:Event):void {
         removeFromControlLayer();
      } 
      protected function onPearlAddedToStage(event:Event):void {
         if(visible) {
            addToControlLayer();
            visible = true;
            reposition();
         }
      }
      
      protected function addToControlLayer():void {
         if(!_isAddedToControlLayer) {           
            ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.controls.addButtonToControlLayer(this);
            _isAddedToControlLayer = true;
         }
      }
      protected function removeFromControlLayer():void {
         if(_isAddedToControlLayer) {
            ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.controls.removeButtonToControlLayer(this);
            _isAddedToControlLayer = false;
         }
      }
      
      override protected function commitProperties():void {
         super.commitProperties();
         repositionNow();
      }
      protected function repositionNow(onCreation:Boolean = false):void {
         if (_bindedComponent && (visible || onCreation)) {
            updateTargetComponentPosition(_targetPosition);
            alpha = _bindedComponent.alpha;
            if (_targetPosition.x != x || _targetPosition.y != y) {
               move(_targetPosition.x,_targetPosition.y);
            } 
         }         
      }
      
      protected function updateTargetComponentPosition(point:Point):void{
      }
      
      override public function set visible(value:Boolean):void {
         if(value) {
            if(!_isAddedToControlLayer) {
               addToControlLayer();
            }
            reposition();
         }
         _targetVisibleState = value;
         updateVisible();
      }
      private function updateVisible():void {
         super.visible = _targetVisibleState && _bindedComponent;
         if (super.visible) {
            updateScale();
            updateSize();
            if (_bindedComponent is UIPearl && !UIPearl(_bindedComponent).isCreationCompleted()) {
               super.visible = false;
               _bindedComponent.addEventListener(FlexEvent.CREATION_COMPLETE, new GenericAction(null, this, updateVisible).performActionOnFirstEvent);
            }
         }
      }
      protected function updateSize():void {
         
      }
      public function end():void {
         removeFromControlLayer();
         clear();
         onChangeBoundComponent(_bindedComponent, null);
         _bindedComponent = null;
         _node = null;
         
      }
      
      public function get node():IPTNode {
         return _node;
      }
      public function isScrollable():Boolean {
         if (node && node.vnode && node.vnode.view) {
            return IScrollable(node.vnode.view).isScrollable();
         }
         return true;
      }
      
   }
}