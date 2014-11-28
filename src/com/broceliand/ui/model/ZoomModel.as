package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.effects.SmoothSetter;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.util.NullSkin;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import mx.containers.Canvas;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   [Event(name="dataChange", type="mx.events.FlexEvent")]
   
   public class ZoomModel extends EventDispatcher
   {
      public static const MIN_ZOOM:Number = 0.30;
      public static const MAX_ZOOM:Number = 3.00;
      public static const ZOOM_STEP:Number = 0.05;
      public static const ZOOM_DEFAULT:Number = 1.2;
      public static const ZOOM_INCR_STEP:Number = 0.17;
      public static const ZOOM_DECR_STEP:Number = 0.1;
      
      public static const ZOOM_FACTOR_DEFAULT:Number = 1;
      public static const ZOOM_FACTOR_DEFAULT_EMBED:Number = 1.25;
      
      private var _isLoggedUserInit:Boolean = false;
      private var _visible:Boolean;
      private var _smoothSetter:SmoothSetter;
      private var _vgraph:IPTVisualGraph;
      private var _perstistencyManager:ZoomModelPersistency;
      
      public function ZoomModel(vgraph:IPTVisualGraph)
      {
         _vgraph = vgraph;
         _perstistencyManager = new ZoomModelPersistency(this);
         _vgraph.scale = _perstistencyManager.zoomValue;
         _smoothSetter = new SmoothSetter(this, "internalVgraphScaleValue");
         _visible  = false;
      }
      
      public function get zoomValue():Number {
         return _smoothSetter.getValue();
      }
      
      public function set zoomValue(value:Number):void {
         if (value != _smoothSetter.getValue()) {
            _smoothSetter.setValue(value);
            dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
         }
      }
      
      public function setZoomValueWithNoAnim(value:Number):void {
         if (value != _smoothSetter.getValue()) {
            scaleVgraph(_vgraph, value, null, null);
            _smoothSetter.setValue(value);
            dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
         }
      }
      public function get internalVgraphScaleValue():Number {
         return _vgraph.scale;
      }
      
      public function set internalVgraphScaleValue(value:Number):void{
         if (_vgraph && _vgraph.scale == value) {
            return;
         }
         var am:ApplicationManager= ApplicationManager.getInstance();
         var selectedNode:IPTNode = am.visualModel.selectionModel.getSelectedNode();
         if (!selectedNode || selectedNode.isDocked) {
            var rootVnode:IVisualNode  = _vgraph.currentRootVNode;
            if (rootVnode) {
               selectedNode= rootVnode.node as IPTNode;
            }
         }
         var draggedPearl:IUIPearl = am.components.pearlTreeViewer.interactorManager.draggedPearl;
         scaleVgraph(_vgraph, value, selectedNode, draggedPearl);
      }
      
      private function getLogger():BroLogger {
         return Log.getLogger("com.broceliand.ui.model.ZoomModel");
      }
      
      private function scaleVgraph(vgraph:IPTVisualGraph, value:Number, centerNode:IPTNode, draggedPearl:IUIPearl, scrolled:Boolean = true):void {
         
         var children:Array = (vgraph as Canvas).getChildren();
         var child:UIComponent;
         if(vgraph == null) {
            return;
         }
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;	
         var oldCenter:Point =null;
         var oldScale:Number = vgraph.scale;
         var centerOffset:Point = null;
         
         if (scrolled && centerNode && centerNode.pearlVnode && centerNode.pearlVnode.pearlView) {
            oldCenter = centerNode.pearlVnode.pearlView.pearlCenter.clone();
            centerOffset = new Point((oldCenter.x - centerNode.vnode.viewX) / vgraph.scale, 
               (oldCenter.y - centerNode.vnode.viewY) / vgraph.scale);
         }
         
         for each(child in children) {
            if(child is IUIPearl ) {
               IUIPearl(child).setScale(value);
            } 
         }
         
         vgraph.scale = value;

         if (!centerNode || !scrolled) {
            return;
         }
         
         vgraph.PTLayouter.setPearlTreesWorldLayout(navModel.isShowingPearlTreesWorld());
         var positions:Dictionary = vgraph.PTLayouter.computeLayoutPositionOnly();
         vgraph.PTLayouter.setPearlTreesWorldLayout(false);
         
         var newCenter:Point = new Point();
         var offset:Point = new Point();
         if (navModel.isShowingDiscover() && am.useDiscover()) { 
            offset.x = Math.round(vgraph.origin.x * (value / oldScale - 1));
            offset.y = Math.round(vgraph.origin.y * (value / oldScale - 1));                           
         }
         else if (centerNode && centerNode.vnode) {
            var p:Point = positions[centerNode.vnode];
            newCenter.x = p.x + value * centerOffset.x;
            newCenter.y = p.y + value * centerOffset.y;
            offset.x = Math.round(oldCenter.x - newCenter.x);
            offset.y = Math.round(oldCenter.y - newCenter.y);            
         }
         vgraph.offsetOrigin(offset.x, offset.y);
         for each(child in children) {
            var pearl:IUIPearl = child as IUIPearl;
            if (pearl && !pearl.node.isDocked && pearl != draggedPearl) {
               p = positions[pearl.vnode];
               if (!pearl.isMoving) { 
                  pearl.move(p.x + offset.x, p.y + offset.y);
               }
            } 
         }
      }
      
      public function setVisible (value:Boolean, persist:Boolean = false):void
      {
         if (_visible != value) {
            _visible = value;
            dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
            
         }
         if (persist) {
            _perstistencyManager.saveVisibleValue(value);
         }	
      }
      
      public function getVisible ():Boolean
      {
         return _visible;
      }
      
      public function isZoomDisabled():Boolean{
         return false;
      }
      
      public function increaseZoom():void {
         if (isZoomDisabled()) {
            return;
         }  
         
         var step:Number = zoomValue < ZOOM_DEFAULT ? ZOOM_DECR_STEP : ZOOM_INCR_STEP;
         var value:Number = zoomValue + step;
         if (value > MAX_ZOOM) {
            value = MAX_ZOOM;
         }
         zoomValue = value;
      }
      
      public function decreaseZoom():void {
         if (isZoomDisabled()) {
            return;
         }
         
         var step:Number = zoomValue < ZOOM_DEFAULT ? ZOOM_DECR_STEP : ZOOM_INCR_STEP;
         var value:Number = zoomValue - step;
         if (value < MIN_ZOOM) {
            value = MIN_ZOOM;
         }
         zoomValue = value;
      }
      
      public function resetZoom():void {
         if (isZoomDisabled()) {
            return;
         }
         zoomValue = ZOOM_DEFAULT;
      }
      
      public function initZoomVisibilityForLoggedUser():void {
         if (!_isLoggedUserInit) {
            _isLoggedUserInit = true;
            setVisible(true, false);
            
         }
      }
      
      public function getTargetValue():Number {
         return _smoothSetter.getTargetValue();
      }
      
      public function isZoomSet():Boolean {
         return getTargetValue() == _vgraph.scale;
      }
   }
}