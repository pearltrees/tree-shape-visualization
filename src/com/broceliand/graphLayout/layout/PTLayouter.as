package com.broceliand.graphLayout.layout
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.Alert;
   
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.events.EffectEvent;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class PTLayouter extends PTLayouterBase implements IPTLayouter
   {
      protected static const COMPUTING_LAYOUT_ONLY:Number = 3;
      protected static const PERFORMING_INITIAL_ANIMATION:Number = 1;
      protected static const INIT_DONE:Number = 2;
      protected static const LAYOUT_WITH_FIX_NODE_POSITION:Number = 4;
      protected static const SLOW_LAYOUT:Number = 5;

      protected var _initialAnimationState:Number = INIT_DONE;
      private var _nodePosition:Dictionary = null;
      private var _fixedNode:INode;
      private var _fixedNodeCenter:Point;
      private var _defaultAnimationLength:Number;
      private var _slowLayoutLength:Number;
      
      public function PTLayouter(aGraph:IVisualGraph=null) {
         super(aGraph);
         _defaultAnimationLength = 300;
         
      }
      private function resetTree():void {
         _initialAnimationState = INIT_DONE;
      }
      
      override public  function layoutPass():Boolean {
         var ret:Boolean = true;
         if (_fixedNode != null) {
            _initialAnimationState = LAYOUT_WITH_FIX_NODE_POSITION;
            ret = super.layoutPass();
         } else if(_initialAnimationState == LAYOUT_WITH_FIX_NODE_POSITION) {
            _initialAnimationState = INIT_DONE;
         } 
         if (_initialAnimationState == INIT_DONE || _initialAnimationState == SLOW_LAYOUT){
            ret = super.layoutPass();
         }
         return ret;
      }
      public function performSlowLayout(moveTime:Number=1000):Boolean {
         var oldState:Number  = _initialAnimationState;
         _initialAnimationState = SLOW_LAYOUT;
         _slowLayoutLength = moveTime;
         var result:Boolean=false;
         try {
            result = layoutPass();
         } finally {
            _initialAnimationState = oldState;
            return result; 
         }
      }
      public function computeLayoutPositionOnly():Dictionary {
         var oldState:Number  = _initialAnimationState;
         _nodePosition = new Dictionary();
         _initialAnimationState = COMPUTING_LAYOUT_ONLY;
         var oldIsMovingValue:Boolean= super._isMoving;
         super._isMoving =false;
         super.layoutPass();
         super._isMoving = oldIsMovingValue;
         _initialAnimationState = oldState;
         return _nodePosition;
      }
      
      public function layoutWithFixNodePosition(node:IPTNode):void {
         var oldState:Number  = _initialAnimationState;
         if (node.vnode.view == null) {
            super.layoutPass();
            return;
         } else {

            _fixedNode = node;
            if (super._isMoving) {
               _fixedNodeCenter = new Point(node.vnode.x, node.vnode.y); 
            }
            else {
               _fixedNodeCenter = node.pearlVnode.pearlView.pearlCenter;
            }
            _initialAnimationState = LAYOUT_WITH_FIX_NODE_POSITION;
            super.layoutPass();
            _initialAnimationState = oldState;
         }
      }

      override protected function commitNodesPosition():void {
         if (!_vgraph.currentRootVNode) {
            return;
         }
         
         centerLayout();
         var pearlView:IUIPearl = _vgraph.currentRootVNode.view as IUIPearl;
         var defaultPearlXOffset:Number = 57;
         var defaultPearlYOffset:Number = 29;
         if (pearlView) {
            defaultPearlXOffset = pearlView.pearlCenter.x - pearlView.x;
            defaultPearlYOffset= pearlView.pearlCenter.y - pearlView.y;
         }
         var pearlXOffset:Number;
         var pearlYOffset:Number;
         switch(_initialAnimationState){
            case PERFORMING_INITIAL_ANIMATION:
               
               _nodePosition = new Dictionary();
               for each(var vn:IVisualNode in _vgraph.visibleVNodes) {
               pearlView = vn.view as IUIPearl;
               if (pearlView) {
                  pearlXOffset = pearlView.pearlCenter.x - pearlView.x;
                  pearlYOffset = pearlView.pearlCenter.y - pearlView.y;
               } else {
                  pearlXOffset = defaultPearlXOffset;
                  pearlYOffset = defaultPearlYOffset;
               }
               _nodePosition[vn] = new Point(int(0.5 + vn.x- pearlXOffset), int (0.5 +  vn.y - pearlYOffset));
               vn.view.alpha=0;
            }
            case INIT_DONE:
               
               var animLength:Number = _defaultAnimationLength;
               moveNodeWithAnimation(animLength);
               break;
            case SLOW_LAYOUT:
               moveNodeWithAnimation(_slowLayoutLength);
               break;
            
            case COMPUTING_LAYOUT_ONLY:
               _nodePosition = new Dictionary();
               var draggedNode:IVisualNode = _dragNode;
               if (!draggedNode) {
                  var draggedPearl:IUIPearl = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.draggedPearl;
                  if (draggedPearl) {
                     draggedNode = draggedPearl.vnode;
                  }
               }
               for each(vn in _vgraph.visibleVNodes) {
               if (vn == draggedNode) {
                  continue;
               }
               pearlView = vn.view as IUIPearl;
               if (pearlView) {
                  pearlXOffset = int( 0.5 + pearlView.pearlCenter.x - pearlView.positionWithoutZoom.x);
                  pearlYOffset = int ( 0.5 + pearlView.pearlCenter.y - pearlView.positionWithoutZoom.y);
               } else {
                  pearlXOffset = defaultPearlXOffset;
                  pearlYOffset = defaultPearlYOffset;
               }
               _nodePosition[vn] = new Point(vn.x- pearlXOffset , vn.y - pearlYOffset);
            }
               break;
            
            case LAYOUT_WITH_FIX_NODE_POSITION:
               if (_fixedNodeCenter && _fixedNode.vnode) {
                  var offset:Point = new Point(int(0.5 + _fixedNodeCenter.x - _fixedNode.vnode.x) ,
                     int(0.5 + _fixedNodeCenter.y - _fixedNode.vnode.y ));
                  
                  IPTVisualGraph(_vgraph).offsetOrigin(offset.x, offset.y);

                  for each(vn in _vgraph.visibleVNodes) {
                     if (IPTNode(vn.node).isDocked) {
                        continue;
                     }
                     vn.x += offset.x;
                     vn.y += offset.y;
                  }
               } else {
                  Alert("PBM WITH NO _FIXED.VNODE.VIEW");
               }
               moveNodeWithAnimation(_defaultAnimationLength);
               _fixedNodeCenter=null;
               _fixedNode = null;
               break;
         }
      }
      
      override public function set graph(g:IGraph):void {
         resetTree();
         super.graph=g;
      }
      
      private function moveNodeWithAnimation(animationLength:Number):void {
         _isMoving = true;
         var p:Parallel = new Parallel();
         var m:Move = null;
         for each(var vn:IPTVisualNode in _vgraph.visibleVNodes) {
            var n:IPTNode = vn.node as IPTNode;
            if(n && n.isDocked){
               
               continue;
            }
            if (vn == _dragNode) {
               continue;
            }
            var pearlView:IUIPearl = vn.pearlView;
            var x:Number = 0;
            var y:Number = 0;

            if (pearlView !=null) {
               var posWithoutZoom:Point = pearlView.positionWithoutZoom;
               var pearlXOffset:Number = pearlView.pearlCenter.x - posWithoutZoom.x;
               var pearlYOffset:Number = pearlView.pearlCenter.y - posWithoutZoom.y;
               x= (vn.x   - pearlXOffset) ;
               y= (vn.y  - pearlYOffset) ;
            }  else {
               x= vn.x - (vn.view.width/ 2.0);
               y= vn.y - (vn.view.height / 2.0);
            }
            if (pearlView && (pearlView.x != x || pearlView.y != y)) {
               m = (_vgraph as IPTVisualGraph).moveNodeTo(vn, x+0.5 ,y +0.5, animationLength,false);
               p.addChild(m);
            }
         }
         if (m!=null)  {
            m.addEventListener(TweenEvent.TWEEN_UPDATE, tweenUpdated);
            p.addEventListener(EffectEvent.EFFECT_END, onEndMovingNode);
         } else {
            onEndMovingNode(null);
         }
         p.play();
      }
      protected function tweenUpdated(event:TweenEvent):void {
         _vgraph.refresh();
      }
      protected function onEndMovingNode(event:Event):void {
         _vgraph.drawingSurface.callLater(onEndLayout);
      }
      
   }
}  