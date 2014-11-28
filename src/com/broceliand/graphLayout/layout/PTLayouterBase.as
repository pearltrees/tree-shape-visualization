package com.broceliand.graphLayout.layout
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EditedGraphVisualModification;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.model.ZoomModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   import mx.core.UIComponent;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph;
   
   [Event(name=EVENT_LAYOUT_FINISHED, type="flash.events.Event")]
   
   public class PTLayouterBase extends BaseLayouter
   {
      public static const EVENT_LAYOUT_STARTED:String = "layoutStarted";
      public static const EVENT_LAYOUT_FINISHED:String = "layoutFinished";
      
      public static const PTW_LAYOUT_DEFAULT:uint = 0;
      public static const PTW_LAYOUT_DISCOVER:uint = 1;

      private var _concentricLayout:AnimatedBaseLayout;
      private var _concentricLayoutV2:AnimatedBaseLayout;
      private var _isLayouting:Boolean=false;
      protected var _isMoving:Boolean=false;
      private var _mustPerformLayout:Boolean = false;
      private var _ptwLayout:ILayoutAlgorithm;
      private var _ptwLayoutDiscover:ILayoutAlgorithm;
      protected var _isPTWLayout:Boolean;
      private var _ptwLayoutType:uint = PTW_LAYOUT_DEFAULT;
      private var _centerNextLayout:Boolean = false;
      protected var _dragNode:IVisualNode = null;
      private var _zoomOutBigTree:Boolean;
      private var _newLayout:Boolean;
      
      public function PTLayouterBase(aGraph:IVisualGraph=null)
      {
         super(aGraph==null? new VisualGraph():aGraph);
         _concentricLayout = makeConcentricRadialLayout(_vgraph);
         _newLayout = true;
         _concentricLayoutV2 = makeConcentricRadialLayout(_vgraph);
         
         _ptwLayout = makePTWLayout(_vgraph);
         _ptwLayoutDiscover = makePTWLayoutDiscover(_vgraph);
         linkLength= GeometricalConstants.LINK_LENGTH;
      }
      
      public function set zoomOutBigTree(value:Boolean):void
      {
         _zoomOutBigTree = value;
      }
      
      public function get centerNextLayout():Boolean {
         return _centerNextLayout;
      }
      public function set centerNextLayout(value:Boolean):void {
         _centerNextLayout = value;
      }
      public function centerNextLayoutAndZoomOutBigTree(center:Boolean, zoomOutNextTree:Boolean):void {
         _centerNextLayout = center;
         _zoomOutBigTree = zoomOutNextTree;
      }
      public function setNewLayout(value:Boolean):void {
         if (value != _newLayout) {
            _newLayout = value;
            layoutPass();
         }
      }
      public static function SetNewLayout(value:Boolean):void {
         PTLayouterBase(ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.layouter).setNewLayout(value);
      }

      override public function set linkLength(rr:Number):void {
         _concentricLayout.linkLength=rr;
         if (_concentricLayoutV2) {
            _concentricLayoutV2.linkLength = rr;
         }
      }
      override public function get linkLength():Number {
         return _concentricLayout.linkLength;
      }
      
      protected function makePTWLayout(graph:IVisualGraph):ILayoutAlgorithm {
         var layout:ConcentricRadialLayout = new PTWLayout(graph);
         layout.disableAnimation=true;
         layout.autoFitEnabled=false;
         layout.linkLength= 5;
         layout.setAngularBounds(180, 360);
         return layout;
      }
      protected function makePTWLayoutDiscover(graph:IVisualGraph):ILayoutAlgorithm {
         var layout:ConcentricRadialLayout = new PTWLayoutDiscover(graph);
         layout.disableAnimation=true;
         layout.autoFitEnabled=false;
         layout.linkLength= 5; 
         layout.setAngularBounds(180, 360);
         return layout;
      }
      private function makeConcentricRadialLayout(graph:IVisualGraph):AnimatedBaseLayout{
         
         var linkLength:Number =5;
         if (_concentricLayout) {
            linkLength = _concentricLayout.linkLength;
         }
         if (_newLayout) {
            var layout:ConcentricRadialLayoutV2= new ConcentricRadialLayoutV2(graph);
            layout.disableAnimation=true;
            layout.autoFitEnabled=false;
            layout.linkLength = linkLength;
            layout.setAngularBounds(180, 360);
            layout.minNodeSeparation = ApplicationManager.getInstance().isEmbed()?GeometricalConstants.MIN_NODE_SEPARATION_EMBED:GeometricalConstants.MIN_NODE_SEPARATION;
            return layout;
         }  else {
            var layout2:ConcentricRadialLayout= new ConcentricRadialLayout(graph);
            layout2.disableAnimation=true;
            layout2.autoFitEnabled=false;
            layout2.linkLength = linkLength;
            layout2.setAngularBounds(180, 360);
            layout2.minNodeSeparation = ApplicationManager.getInstance().isEmbed()?GeometricalConstants.MIN_NODE_SEPARATION_EMBED:GeometricalConstants.MIN_NODE_SEPARATION;
            return layout2;
         }
      }
      
      override public function layoutPass():Boolean {
         dispatchEvent(new Event(EVENT_LAYOUT_STARTED));
         var vgraphModif:EditedGraphVisualModification = getPTVGraph().getEditedGraphVisualModification();
         vgraphModif.cancelVisualGraphModificationForLayout();
         
         if (_isMoving && !_isPTWLayout) {
            _mustPerformLayout = true;
            return true;
         }
         _mustPerformLayout = false;
         _isLayouting =true;
         
         _concentricLayout.autoFitEnabled=false;
         if (_isPTWLayout) {
            if(_ptwLayoutType == PTW_LAYOUT_DISCOVER){
               _ptwLayoutDiscover.layoutPass();
            }else{
               _ptwLayout.layoutPass();
            }
         } else {
            if (_newLayout && !(_vgraph as IPTVisualGraph).containsSubTrees()) {
               _concentricLayoutV2.layoutPass();
            } else {
               _concentricLayout.layoutPass();
            }
         }
         commitNodesPosition();
         _isLayouting =false;
         vgraphModif.restoreVisualGraphModificationAfterLayout();
         
         return true;
         
      }

      protected function commitNodesPosition():void {
         
      }

      protected function onEndLayout():void {
         _isMoving = false;
         _vgraph.refresh();
         if (_mustPerformLayout) {
            layoutPass();
         }
         
         dispatchEvent(new Event(EVENT_LAYOUT_FINISHED));
      }
      override public function dragContinue(event:MouseEvent, vn:IVisualNode):void{
      }
      
      override public function dragEvent(event:MouseEvent, vn:IVisualNode):void {
         if(event.currentTarget is UIComponent) {
            _dragNode = vn;
         }
      }
      
      override public function dropEvent(event:MouseEvent, vn:IVisualNode):void {
         _dragNode = null;
         super.dropEvent(event, vn);
      }
      override public function set vgraph(vg:IVisualGraph):void {
         super.vgraph=vg;
         _concentricLayout.vgraph=vg;
         if (_concentricLayoutV2) {
            _concentricLayoutV2.vgraph = vg;
         }
         _ptwLayout.vgraph = vg;
         _ptwLayoutDiscover.vgraph = vg;
      }
      
      override public function set graph(g:IGraph):void {
         super.graph=g;
         _concentricLayout.graph = g;
         _ptwLayout.graph = g;
         _ptwLayoutDiscover.graph = g;
         _concentricLayoutV2.graph =g;
      }
      
      override public function set layoutChanged(lc:Boolean):void {
         super.layoutChanged = lc;
         _concentricLayout.layoutChanged = lc;
      }

      public function setPearlTreesWorldLayout(value:Boolean):void {
         _isPTWLayout = value;
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         if(navModel.isShowingDiscover() && am.useDiscover()) {
            _ptwLayoutType = PTW_LAYOUT_DISCOVER;
         }else {
            _ptwLayoutType = PTW_LAYOUT_DEFAULT;
         }
      }
      private function getPTVGraph():IPTVisualGraph {
         return _vgraph as IPTVisualGraph;
      }
      protected function centerLayout():void {
         if (_centerNextLayout) {
            _centerNextLayout = false;
            var centeringOffset:Point = computeNewCenteringOffset();
            if (centeringOffset) {
               for each(var vn:IPTVisualNode in _vgraph.visibleVNodes) {
                  vn.x += centeringOffset.x;
                  vn.y += centeringOffset.y;
               } 
               IPTVisualGraph(_vgraph).offsetOrigin(centeringOffset.x, centeringOffset.y);
            }
         }
      }
      
      private  function computeNewCenteringOffset():Point
      {
         var rec:Rectangle;
         var originY:Number =  _vgraph.origin.y;
         var zoomFactor:Number = 1;
         if (_zoomOutBigTree) {
            rec = calcNodesBoundingBox(2);
            if (!rec) {
               return null;
            }
            _zoomOutBigTree = false;
            if (_vgraph.width < rec.width || _vgraph.height < rec.height) {
               var rec2:Rectangle = calcNodesBoundingBox(1);
               if (rec2.width < rec.width) {
                  
                  rec.width *= 0.9;
                  rec.height *= 0.9;
               }
               
               if (rec.width>0) {
                  zoomFactor = Math.min(zoomFactor, _vgraph.width/rec.width);
               }
               if (rec.height > 0) {
                  zoomFactor = Math.min(zoomFactor, _vgraph.height/rec.height);
               }
               zoomFactor = int( 0.5 + 100 * zoomFactor) /100;
               if (zoomFactor < 0.5) {
                  zoomFactor = 0.5;
               } else if (zoomFactor > 1) {
                  zoomFactor = 1;
               }
               zoomFactor *= (ApplicationManager.getInstance().isEmbed() ? ZoomModel.ZOOM_FACTOR_DEFAULT_EMBED : ZoomModel.ZOOM_FACTOR_DEFAULT);
               updateRadius(_vgraph.scale, zoomFactor);
               IPTVisualGraph(_vgraph).zoomModel.setZoomValueWithNoAnim(zoomFactor);

            }
            
         }
         rec = calcNodesBoundingBox();
         if (!rec) return null;
         rec.width *= zoomFactor;
         rec.height *= zoomFactor;
         
         var scrollX:Number = rec.x - (_vgraph.width - rec.width) /2;
         var scrollY:Number = rec.y - (_vgraph.height - rec.height) /2;
         
         scrollY =  originY;
         var leftLimit:Number = 0.20 *_vgraph.width;
         var rightLimit:Number = 0.50 *_vgraph.width;

         var root:IVisualNode= _vgraph.currentRootVNode;
         if (root.x - scrollX < leftLimit) {
            scrollX = root.x  - leftLimit;
         }
         if (root.x - scrollX > rightLimit) {
            scrollX = root.x - rightLimit;
         }
         if (isNaN(scrollX)) {
            scrollX = 0;
         }
         if (isNaN(scrollY)) {
            scrollY = 0;
         }
         
         return new Point(-scrollX, -scrollY);
      }
      private function updateRadius(oldScale:Number, newScale:Number):void{
         
         oldScale = ConcentricRadialLayout.computeScaleFactor(oldScale);
         newScale = ConcentricRadialLayout.computeScaleFactor(newScale);
         newScale /= oldScale;
         var rootVnode:IVisualNode = _vgraph.currentRootVNode;
         for each (var v:IVisualNode in _vgraph.visibleVNodes) {
            v.x = Math.round(rootVnode.x + newScale * (v.x - rootVnode.x));
            v.y = Math.round(rootVnode.y + newScale * (v.y - rootVnode.y));
         }

      }
      private  function calcNodesBoundingBox(maxDistance:int = -1):Rectangle {
         var result:Rectangle = new Rectangle(999999, 999999, -999999, -999999);
         var pearlCount:int = addVnodeToBound(result, _vgraph.currentRootVNode as IPTVisualNode, maxDistance); 
         if (pearlCount>1) {
            var scale:Number = _vgraph.scale;
            
            result.width += PTRootPearl.PEARL_WIDTH_EXCITED * scale ;
            result.height+= PTRootPearl.PEARL_WIDTH_EXCITED * scale; 
            result.x -= PTRootPearl.PEARL_WIDTH_EXCITED  * scale /2 ;
            result.y -= PTRootPearl.PEARL_WIDTH_EXCITED * scale / 2;
            return result;
         }
         return null;
      }
      
      private function addVnodeToBound(result:Rectangle, vnode:IPTVisualNode, childDepth:int):int{
         var pearlCount:int = 0;
         if (vnode.isVisible && !vnode.ptNode.isDocked && vnode.view.alpha==1) {
            pearlCount ++;
            result.left = Math.min(result.left, vnode.x);
            result.right = Math.max(result.right, vnode.x );
            result.top = Math.min(result.top, vnode.y );
            result.bottom = Math.max(result.bottom, vnode.y );
            var node:IPTNode = vnode.ptNode;
            if (childDepth != 0) {
               for each (var child:IPTNode in node.successors) {
                  pearlCount +=  addVnodeToBound(result, child.vnode as IPTVisualNode, childDepth -1);
               }
            }
         }
         return pearlCount;
      }

   }
}