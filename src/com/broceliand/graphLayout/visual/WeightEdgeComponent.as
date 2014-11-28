package com.broceliand.graphLayout.visual
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.IRepositionable;
   import com.broceliand.ui.renderers.MoveNotifier;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.Assert;
   
   import flash.display.Graphics;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class WeightEdgeComponent extends UIComponent implements IRepositionable, IScrollable
   {
      public static const USE_EDGE_COMPONENT:Boolean = true;
      private var _vedge:IVisualEdge= null;
      private var _xFrom:Number;
      private var _yFrom:Number;
      private var _xTo:Number;
      private var _yTo:Number;
      private var _scale:Number =1;
      private var _moveNotifier1:MoveNotifier;
      private var _moveNotifier2:MoveNotifier;
      
      private var _mustRedraw:Boolean = true;
      private var _selected:Boolean = false;
      private var _weight:Number=1;
      private var _lineWidth:Number=1;
      private var _numDescendants:Number = 0;
      private var _edgeColor:uint;
      private var _filters:Array=null
      private var _hidden:Boolean = false;
      private static const COLOR_TEMPORARY:int = ColorPalette.getInstance().pearltreesDarkColor;
      
      private static var _withBackgroundColorlink:Boolean = false;
      private static const COLOR_WITH_BACKGROUND:uint =0x989898;
      private static const COLOR_WITH_WHITE_BACKGROUND:uint = 0xb4b4b4;

      public function WeightEdgeComponent(){
         
      }
      
      public function init(vedge:IVisualEdge):void {
         end();
         _vedge = vedge;
         
         _moveNotifier1 = getVnode1().moveNotifier;
         _moveNotifier1.addMoveListener(this);
         _moveNotifier2 = getVnode2().moveNotifier;
         _moveNotifier2.addMoveListener(this);
         _mustRedraw= true;
         _selected= false;
         _weight=1;
         _lineWidth=1;
         var endNode:EndNode = getVnode2().node as EndNode;
         if (endNode && endNode.rootNodeOfMyTree == getVnode1().node) {
            _hidden = true;
         } else {
            _hidden = false;
         }

      }

      private function computeFromPoint(pearl:IUIPearl):void {
         var targetPoint:Point = pearl.getTargetMove();
         var center:Point = pearl.pearlCenter; 
         var xFrom:Number = center.x;
         var yFrom:Number = center.y;
         if (targetPoint) {
            xFrom += targetPoint.x - pearl.x;   
            yFrom += targetPoint.y - pearl.y;
         }
         if (_xFrom != xFrom) {
            _xFrom = xFrom;
         }
         if (_yFrom!= yFrom) {
            _yFrom = yFrom;
         }
      }
      private function computeToPoint(pearl:IUIPearl):void {
         var targetPoint:Point = pearl.getTargetMove();
         var center:Point = pearl.pearlCenter; 
         var xFrom:Number = center.x;
         var yFrom:Number = center.y;
         if (targetPoint) {
            xFrom += targetPoint.x - pearl.x;   
            yFrom += targetPoint.y - pearl.y;
         }
         if (_xTo!= xFrom) {
            _xTo = xFrom;
         }
         if (_yTo != yFrom) {
            _yTo = yFrom;
         }
         scale = pearl.getScale() / pearl.animationZoomFactor;
      }
      
      private function getVnode1():IPTVisualNode{
         return _vedge.edge.node1.vnode as IPTVisualNode; 
      }
      private function getVnode2(): IPTVisualNode{
         return _vedge.edge.node2.vnode as IPTVisualNode;
      }
      public function isScrollable():Boolean {
         return true;
      }
      public function end():void {
         if (_moveNotifier1) {
            _moveNotifier1.removeMoveListener(this);
            _moveNotifier1 == null;
         }
         if (_moveNotifier2) {
            _moveNotifier2.removeMoveListener(this);
            _moveNotifier2 == null;
         }
         _vedge = null;
      }
      public function reposition():void {
         invalidateProperties();
      }
      override protected function commitProperties():void {
         if (!_vedge) { 
            return;
         }
         var vnode1:IPTVisualNode= getVnode1();
         var vnode2:IPTVisualNode= getVnode2();
         var edgeData:EdgeData = _vedge.data as EdgeData;
         var shouldBeVisible:Boolean = edgeData.visible;
         
         if (!shouldBeVisible|| !vnode1 || !vnode2 || !vnode1.view || !vnode2.view || _hidden) {
            shouldBeVisible=false;
         } else {
            computeFromPoint(vnode1.pearlView);
            computeToPoint(vnode2.pearlView);
            shouldBeVisible = shouldBeVisible && computeVisibility(vnode1.view.alpha, vnode2.view.alpha);
            var targetX:Number =0;
            var targetY:Number =0;
            if (shouldBeVisible) {
               targetX = Math.min(_xFrom, _xTo);
               targetY = Math.min(_yFrom, _yTo);
               var newWidth:Number  = Math.max(_xFrom, _xTo) - targetX;
               var newHeight:Number  = Math.max(_yFrom, _yTo) - targetY;
               if (newWidth !=width || newHeight != height) {
                  _mustRedraw = true;
                  width = newWidth;
                  height = newHeight;
               } else {
                  move(targetX, targetY);
               } 
               var toNode:IPTNode= getVnode2().node as IPTNode;
               var numDescendants:Number = toNode.getDescendantWeight();
               if (_numDescendants != numDescendants) {
                  _numDescendants = numDescendants;
                  _mustRedraw = true;   
               }

               edgeColor = computeColor(edgeData);
               if (edgeData.highlighted){
                  filters= getHaloFilters();
               } else {
                  filters = null;
               }
            }
         }
         if (shouldBeVisible != visible) {
            visible = shouldBeVisible;
            _mustRedraw = true;
         }
         if (_mustRedraw) {
            if (shouldBeVisible && ((x != targetX ) || (y!=targetY))) {
               move(targetX, targetY)
               draw(_vedge); 
            }  else {
               invalidateDisplayList();
            }
         }
      } 
      private function computeVisibility(alphaNode1:Number, alphaNode2:Number):Boolean{
         var edgeAlpha:Number = Math.min(alphaNode1,alphaNode2);       
         if (edgeAlpha>0.4 ) {
            return true; 
         } else {
            return false;
         }
      }
      
      private function set weight(w:Number):void {
         if (_weight != w ) {
            _weight = w;
            lineWidth = balancedWeight(_weight) * _scale;  
         }
      }
      private function set scale(value:Number):void {
         if (_scale != value) {
            _scale = value;
            lineWidth = balancedWeight(_weight) * _scale;
         }
      }
      private function set lineWidth(width:Number):void {
         if (width != _lineWidth) {
            _lineWidth = width;
            _mustRedraw = true;
            invalidateDisplayList();
         }
      }
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         if (!_vedge) {
            return;
         }
         
         var vnode1:IVisualNode = getVnode1();
         var vnode2:IVisualNode = getVnode2();
         if (!vnode1 || !vnode2 || !vnode1.view || !vnode2.view) {
            return;
         }
         if (_mustRedraw) {
            draw(_vedge);
         }
      }
      override protected function measure():void
      {  
         if (!_vedge) {
            return;
         }
         var vnode1:IVisualNode = getVnode1();
         var vnode2:IVisualNode = getVnode2();
         if (vnode1 && vnode2 && vnode1.view && vnode2.view) {
            var viewCenter1:Point = vnode1.viewCenter;
            var viewCenter2:Point = vnode2.viewCenter;
            measuredMinWidth = measuredWidth  = Math.abs(viewCenter1.x- viewCenter2.x);
            measuredHeight = measuredHeight = Math.abs(viewCenter1.y- viewCenter2.y);
         }
         
      }  
      public function set edgeColor (value:uint):void
      {
         if (_edgeColor != value) {
            _edgeColor = value;
            _mustRedraw = true;
            invalidateDisplayList();
         }
      }
      
      public function get edgeColor ():uint
      {
         return _edgeColor;
      }

      private function balancedWeight(weight:int):Number{
         
         if(weight == 0){
            
            return 1;
         }else{
            var width:Number = Math.log(weight) / Math.log(GeometricalConstants.LINK_LENGTH_ALGO_DIVIDER) - GeometricalConstants.LINK_LENGTH_ALGO_SUBSTRACTOR;
            if(width < 1 || isNaN(width)){ 
               return 1;
            }else{
               return Math.floor(width);
            }
         }           
      } 

      public function applyLineStyle(ve:IVisualEdge):void {
         /* apply the style to the drawing */
         Assert.assert(ve.data is EdgeData, "data obj is not an EdgeData");
         var edgeData:EdgeData = ve.data as EdgeData;
         var edgeAlpha:Number = Number(ve.lineStyle.alpha);
         if(edgeData.visible == false){
            edgeAlpha = 0;
         } else {
            
            var alpha1:Number = edgeAlpha;
            var alpha2:Number = edgeAlpha;
            if (ve.edge.node2.vnode && ve.edge.node2.vnode.view) {
               if (!ve.edge.node2.vnode.isVisible) alpha2 = 0;
               else {
                  alpha2 = ve.edge.node2.vnode.view.alpha;
               }
               
            }
            if (ve.edge.node1.vnode && ve.edge.node1.vnode.view) {
               if (!ve.edge.node1.vnode.isVisible) alpha1 = 0;
               else {
                  alpha1 = ve.edge.node1.vnode.view.alpha;
               }
            } 
            edgeAlpha = Math.min(alpha1,alpha2);       
            if (edgeAlpha>0.4) edgeAlpha=1;
            else edgeAlpha = 0;                 
         }           
         var toNode:IPTNode= ve.edge.toNode as IPTNode;
         var numDescendants:Number = 0;
         if(toNode){
            numDescendants = toNode.getDescendantWeight();
         }
         var edgeWidth:Number = balancedWeight(numDescendants);
         edgeData.weight = edgeWidth;
         if (edgeData.temporary) {
            edgeWidth = 1;   
         }
         edgeWidth *=_scale;

         graphics.lineStyle(
            edgeWidth,
            edgeColor,
            1,
            Boolean(ve.lineStyle.pixelHinting),
            String(ve.lineStyle.scaleMode),
            String(ve.lineStyle.caps),
            String(ve.lineStyle.joints),
            Number(ve.lineStyle.miterLimits)
         );

      }
      private function computeColor(edgeData:EdgeData):uint {
         var edgeColorVar:uint = COLOR_WITH_WHITE_BACKGROUND;
         if(edgeData.temporary){
            edgeColorVar = COLOR_TEMPORARY;
         } else if (isInCloseTree()) {
            edgeColorVar = COLOR_TEMPORARY 
         } else if (edgeData.highlighted){
            edgeColorVar = ColorPalette.getInstance().pearltreesColor;

         } else  if (_withBackgroundColorlink) {
            edgeColorVar = COLOR_WITH_BACKGROUND;
         } else {
            edgeColorVar = COLOR_WITH_WHITE_BACKGROUND;
         }
         return edgeColorVar;
         
      }
      private function isInCloseTree():Boolean {
         var closeTree:BroPearlTree = ApplicationManager.getInstance().visualModel.highlightManager.getHighlightedCloseTree();
         if (!closeTree) {
            return false;
         } else {
            var trees:Array = closeTree.treeHierarchyNode.getDescendantTrees(false);
            for each (var t:BroPearlTree in trees) {
               if (isInTree(t)){
                  return true;
               }               
            }
            return false;
         }
      }
      
      public function draw(vedge:IVisualEdge):void {
         _mustRedraw = false;
         var graphic:Graphics = graphics;
         graphic.clear();
         if(!visible){
            return;
         }
         /* apply the line style */
         applyLineStyle(vedge);
         
         /* now we actually draw */
         graphic.beginFill(uint(vedge.lineStyle.color));
         
         graphic.moveTo(_xFrom - x, _yFrom - y);            
         graphic.lineTo(_xTo - x, _yTo-y);

         graphic.endFill();
      }

      private function set selected (value:Boolean):void
      {
         if (_selected != value) {
            _selected = value;
            _mustRedraw = true;
            invalidateDisplayList();
         }
      }
      
      private function get selected ():Boolean
      {
         return _selected;
      }

      private function isInTree(selectedTree:BroPearlTree):Boolean {
         if (!selectedTree) {
            return false;
         }
         var vnode1:IPTVisualNode = getVnode1();
         var tree1:BroPearlTree = vnode1.ptNode.treeOwner;
         if (tree1 == selectedTree && !(vnode1.ptNode is EndNode)) {
            return true;
         }
         if (vnode1.ptNode is EndNode) {
            var bnode:BroPTNode= vnode1.ptNode.getBusinessNode();
            if (bnode && bnode.owner == selectedTree) {
               return true;
            }    
         }
         return false;
      }
      
      public function forceRedraw():void {
         _mustRedraw = true;
         invalidateDisplayList();
      }
      override public function get width():Number {
         return super.width;
      } 
      private function getHaloFilters():Array{
         if (!_filters) {
            var color:Number = ColorPalette.getInstance().pearltreesDarkColor;
            var angle:Number = 0;
            var alpha:Number = 0.8;
            var blurX:Number = 20;
            var blurY:Number = 20;
            var distance:Number = 0;
            var strength:Number = 2;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.MEDIUM;
            var filter:DropShadowFilter = new DropShadowFilter(distance,
               angle,
               color,
               alpha,
               blurX,
               blurY,
               strength,
               quality,
               inner,
               knockout);
            var ret:Array = new Array();
            ret.push(filter);
            _filters = ret;
         }
         return _filters;
      }

      public static function setDefaultColorLink(hasBackground:Boolean):Boolean{
         if (hasBackground != _withBackgroundColorlink) {
            _withBackgroundColorlink = hasBackground;
            return true;
         }
         return false;
      }
      
   }

}