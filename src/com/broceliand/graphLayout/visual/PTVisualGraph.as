/* 
* The MIT License
*
* Copyright (c) 2014 , Broceliand SAS, Paris, France (company in charge of developing Pearltrees)
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

/* 
* The MIT License
*
* Copyright (c) 2007 The SixDegrees Project Team
* (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package com.broceliand.graphLayout.visual
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.controller.PearlContextMenu;
   import com.broceliand.graphLayout.layout.IPTLayouter;
   import com.broceliand.graphLayout.model.DistantTreeRefNode;
   import com.broceliand.graphLayout.model.EdgeData;
   import com.broceliand.graphLayout.model.EditedGraphVisualModification;
   import com.broceliand.graphLayout.model.EndNodeVisibilityManager;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.graphLayout.model.IPTGraph;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.OpeningState;
   import com.broceliand.graphLayout.model.PTGraph;
   import com.broceliand.graphLayout.model.PTNode;
   import com.broceliand.graphLayout.model.PTRootNode;
   import com.broceliand.graphLayout.model.PageNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   import com.broceliand.ui.interactors.ManipulatedNodesModel;
   import com.broceliand.ui.interactors.SelectInteractor;
   import com.broceliand.ui.interactors.scroll.ScrollUi;
   import com.broceliand.ui.model.ZoomModel;
   import com.broceliand.ui.navBar.NavBar;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPTWPearl;
   import com.broceliand.ui.pearlTree.GraphControlLayer;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.ui.pearlTree.TitleLayer;
   import com.broceliand.ui.renderers.MoveNotifier;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.renderers.factory.IPearlRecyclingManager;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlBase;
   import com.broceliand.util.logging.BroLogger;
   import com.broceliand.util.logging.Log;
   
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.sampler.getLexicalScopes;
   import flash.utils.Dictionary;
   
   import mx.containers.Canvas;
   import mx.core.IDataRenderer;
   import mx.core.IFactory;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.effects.Effect;
   import mx.effects.EffectManager;
   import mx.effects.Move;
   import mx.events.EffectEvent;
   import mx.utils.ObjectUtil;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph;

   public class PTVisualGraph extends VisualGraph implements IPTVisualGraph
   {
      private var _logger:BroLogger = Log.getLogger("com.broceliand.graphLayout.visual.PTVisualGraph");
      private var _editedGraphVisualModification:EditedGraphVisualModification;
      private var _endNodeVisibilityManager:EndNodeVisibilityManager;
      private var _moveNodeManager:MoveNodeManager= null;
      private const backgroundDragEnabled:Boolean = true;
      private var _scaleValue:Number =1.0;
      private var _zoomModel:ZoomModel;
      private var _graphControlLayer:GraphControlLayer = null;
      private var _ringLayer:UIComponent;
      private var _ringLayerAbove:UIComponent;
      private var _overPearlLayer:UIComponent;
      private var _titleLayerNotDockedBelow:TitleLayer = null;
      private var _titleLayerNotDockedAbove:TitleLayer = null;
      private var _titleLayerNotDockedTop:TitleLayer = null;
      private var _titleLayerDockedBelow:TitleLayer = null;
      private var _titleLayerDockedAbove:TitleLayer = null;
      private var _draggedNodeRenderer:UIComponent = null; 
      private var _titleRendererManager:TitleRendererManager = null;        
      private var _vedgeToComponents:Dictionary= new Dictionary();
      private var _vetoRefresh:Boolean =false;
      private var _vetoDragScroll:Boolean =false;
      private var _pearlRendererFactories:PearlRendererFactories;
      
      private var _recycledEdges:Array=new Array();
      private var _pearlContextMenu:PearlContextMenu;
      private var _isScrolling:Boolean = false;
      private var _playingRemoveComponentEffectsCount:int;
      private var _displayModel:GraphicalDisplayedModel;
      private var _previousCenter:Point;
      private var _stageStabilized:Boolean = false;
      private var _backgroundDragBox:Rectangle;
      private var _updateAfterEvent:Boolean;
      private var _offsetIfAnonymous:int = 1;
      private var _navbarOffset:int = 0;
      
      public function PTVisualGraph() {
         scale = GeometricalConstants.DEFAULT_ZOOM_VALUE;
         _zoomModel = new ZoomModel(this);
         _endNodeVisibilityManager = new EndNodeVisibilityManager(); 
         _moveNodeManager = new MoveNodeManager(this);
         graph = new PTGraph("pearltrees", true, null);
         _ringLayer = new UIComponent();
         
         _titleLayerNotDockedBelow = new TitleLayer(false, "NotDockedBelow"); 
         _titleLayerNotDockedAbove = new TitleLayer(true, "NotDockedAbove"); 
         _titleLayerNotDockedTop = new TitleLayer(true, "NotDockedTop");  
         _titleLayerDockedBelow = new TitleLayer(false, "DockedBelow"); 
         _titleLayerDockedAbove = new TitleLayer(true, "DockedAbove");
         _titleRendererManager = new TitleRendererManager(_titleLayerNotDockedBelow, _titleLayerNotDockedAbove, _titleLayerNotDockedTop, _titleLayerDockedBelow, _titleLayerDockedAbove);
         
         horizontalScrollPolicy = ScrollPolicy.OFF;
         verticalScrollPolicy = ScrollPolicy.OFF;
         _displayModel  = new GraphicalDisplayedModel(this);
         super();
         visibilityLimitActive = false;
         addChild(_ringLayer);
         if (!ApplicationManager.getInstance().isEmbed()) {
            _navbarOffset = NavBar.NAVBAR_HEIGHT ;
         }
         addChild(_titleLayerNotDockedBelow);
         _drawingSurface.includeInLayout=false;
         
         _canvas.removeEventListener(MouseEvent.MOUSE_DOWN,backgroundDragBegin);
         addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
         _editedGraphVisualModification = new EditedGraphVisualModification(this);           
         
         _pearlContextMenu = new PearlContextMenu(); 
         contextMenu = _pearlContextMenu.contextMenu;
         _graphControlLayer = new GraphControlLayer();
         _graphControlLayer.percentHeight = 100;
         _graphControlLayer.percentWidth = 100;
         _graphControlLayer.zoomControl.model = _zoomModel;
         _updateAfterEvent =  (ApplicationManager.getInstance().getBrowserName() != ApplicationManager.BROWSER_NAME_MSIE) 
            && (ApplicationManager.getInstance().getOS() != ApplicationManager.OS_NAME_LINUX);
         
      }
      
      override protected function createChildren():void{
         super.createChildren();

         newNodesDefaultVisible = true;
         addChild(_titleLayerNotDockedAbove);
         addChild(_graphControlLayer);

         addChild(_titleLayerDockedBelow);
         addChild(_titleLayerNotDockedTop);
         addChild(_titleLayerDockedAbove);
      }
      
      public function get controls():IGraphControls{
         return _graphControlLayer;
      }
      public function get ringLayer():UIComponent {
         return _ringLayer;
      }

      override protected function createVNode(n:INode):IVisualNode{
         
         var vnode:IVisualNode;
         
         /* as an id we use the id of the graph node for simplicity
         * for now, it is not really used separately anywhere
         * we also use the graph data object as our data object.
         * the view is set to null and remains so. */
         if(n is PTRootNode){
            vnode = new PTRootVisualNode(this, n, n.id, null, n.data);
            _displayModel.onTreeGraphBuilt(n as PTRootNode);
         }else if(n is DistantTreeRefNode){
            vnode = new DistantTreeRefVisualNode(this, n, n.id, null, n.data);
         }else if(n is PageNode){
            vnode = new PageVisualNode(this, n, n.id, null, n.data);
         } else{
            vnode = new EndVisualNode(this, n, n.id, null, n.data);
            _endNodeVisibilityManager.onCreateEndNode(vnode); 
         }
         /* now set the vnode in the node */
         n.vnode = vnode;
         
         /* if the node should be visible by default 
         * we need to make sure that the view is created */
         if(newNodesDefaultVisible) {
            setNodeVisibility(vnode, true);
         }

         /* add the node to the hash to keep track */
         _vnodes[vnode] = vnode;

         return vnode;
      }

      override public function get itemRenderer():IFactory {
         throw new Error("don't use this, use one of the others!");
      }

      override public function set itemRenderer(ifac:IFactory):void {
         throw new Error("don't use this, use one of the others!");
      }   
      
      public function set effectForItemRemoval(effect:Effect): void{
         removeItemEffect = effect;
      }
      public function get effectForItemRemoval():Effect{
         return removeItemEffect;
      }
      
      public function set pearlRendererFactories(value:PearlRendererFactories):void {
         _pearlRendererFactories = value;
      }

      override protected function createVNodeComponent(vn:IVisualNode):UIComponent {
         
         var mycomponent:UIComponent = null;
         
         /*
         * a possible view factory is our own implementation
         * of such a Factory, currently not used.
         if(_viewFactory != null) {
         result = viewFactory.getView(VNode) as UIComponent;
         }
         */

         mycomponent = _pearlRendererFactories.createVNodeComponent(vn);
         (mycomponent as IUIPearl).setScale(scale);
         
         mycomponent.contextMenu = _pearlContextMenu.contextMenu;
         
         /* assigns the item (VisualNode) to the IDataRenderer part of the view
         * this is important to access the data object of the VNode
         * which contains information for rendering. */     
         if(mycomponent is IDataRenderer) {
            (mycomponent as IDataRenderer).data = vn;
         }
         
         /* set initial x/y values */
         mycomponent.move(_canvas.width / 2.0, _canvas.height / 2.0);
         
         /* enable bitmap cachine if required */
         mycomponent.cacheAsBitmap = cacheRendererObjects;
         
         mycomponent.includeInLayout = false;
         /* add the component to its parent component */
         _canvas.addChild(mycomponent);
         
         /* do we have an effect set for addition of
         * items? If yes, create and start it. */
         if(addItemEffect != null) {
            addItemEffect.createInstance(mycomponent).startEffect();
         }
         
         /* register it the view in the vnode and the mapping */
         vn.view = mycomponent;
         _viewToVNodeMap[mycomponent] = vn;
         
         /* increase the component counter */
         ++_componentCounter;
         
         /* assertion there should not be more components than
         * visible nodes */
         if(_componentCounter > (_noVisibleVNodes)) {
            if (_componentCounter - _playingRemoveComponentEffectsCount > _noVisibleVNodes) {
               throw Error("Got too many components:"+_componentCounter+" but only:"+_noVisibleVNodes
                  +" nodes visible and "+_playingRemoveComponentEffectsCount+" disappearing components");
            }
         }
         
         /* we need to invalidate the display list since
         * we created new children */
         refresh();
         invalidateDisplayList();
         return mycomponent;
      }

      override protected function createVEdge(e:IEdge):IVisualEdge {
         
         var vedge:IVisualEdge;
         var n1:INode;
         var n2:INode;
         var lStyle:Object;
         var attrs:Array;
         
         /* create a copy of the default style */
         lStyle = ObjectUtil.copy(_defaultEdgeStyle);
         
         /* extract style data from associated XML data for each parameter */
         attrs = ObjectUtil.getClassInfo(lStyle).properties;
         
         /*          for each(attname in attrs) {
         if(e.data != null && (e.data as XML).attribute(attname).length() > 0) {
         lStyle[attname] = e.data.@[attname];
         }
         }
         */          
         vedge = new VisualEdge(this, e, e.id, e.data, null, lStyle);
         
         /* set the VisualEdge reference in the graph edge */
         e.vedge = vedge;
         
         /* check if the edge is supposed to be visible */
         n1 = e.node1;
         n2 = e.node2;
         
         /* if both nodes are visible, the edge should
         * be made visible, which may also create a label
         */
         if(n1.vnode.isVisible && n2.vnode.isVisible) {
            setEdgeVisibility(vedge, true);
         }
         
         /* add to tracking hash */
         _vedges[vedge] = vedge;
         
         if (WeightEdgeComponent.USE_EDGE_COMPONENT){
            if (((vedge.edge.fromNode as IPTNode).getBusinessNode() as BroNeighbourRootPearl) == null) {
               makeWeightEdgeComponent(vedge);   
            }
         }

         return vedge;
      }  
      
      override protected function removeVEdge(ve:IVisualEdge):void {
         removeWeightEdgeComponent(ve);
         super.removeVEdge(ve);
      }

      private function makeWeightEdgeComponent(vedge:IVisualEdge):WeightEdgeComponent{
         var wec:WeightEdgeComponent ;
         var isNew:Boolean =false;
         if (_recycledEdges.length>0) {
            wec = _recycledEdges.pop();
         } else {
            wec = new WeightEdgeComponent();
            isNew = true;
         }
         wec.init(vedge);
         wec.includeInLayout=false;
         _vedgeToComponents[vedge]=wec;
         _drawingSurface.addChild(wec);
         return wec;
      }
      private function removeWeightEdgeComponent( ve:IVisualEdge):void{
         var component:WeightEdgeComponent= _vedgeToComponents[ve];
         if (component) {
            delete _vedgeToComponents[ve];
            component.visible=false;
            component.x = component.y = -20;
            _drawingSurface.removeChild(component);
            component.end();
            _recycledEdges.push(component);

         }
      }

      override public function calcNodesBoundingBox():Rectangle {
         
         var children:Array;
         var result:Rectangle;
         
         /* get all children of our canvas, these should only
         * be node views and the edge drawing surface. */
         children = _canvas.getChildren();
         
         /* init the rectangle with some large values. 
         * Originally I wanted to use Number.MAX_VALUE / Number.MIN_VALUE but
         * ran into serious numerical problems, thus 
         * we use +/- 999999 for now, although this is 
         * more like a hack.
         * Note that the coordinates are reversed, i.e. the origin of the rectangle
         * has been pushed to the far bottom right, and the height and width
         * are negative */
         result = new Rectangle(999999, 999999, -999999, -999999);

         /* if there are no children at all, there may be something
         * wrong as it should at least contain the drawing surface */
         if(children.length == 0) {
            trace("Canvas has no children, not even the drawing surface!");
            return null;
         }
         
         /* The children should only be the visible node's views and
         * the drawing surface for the edges, so we
         * add a safeguard here to see of these are actually much more */
         
         /* since the edge labels were introduced this no longer works
         * because we also need to count each displayed edge label
         * but we have no counter yet for that, so the check is commented
         * for now
         if(children.length > _noVisibleVNodes + 1) {
         throw Error("Children are more than visible nodes plus drawing surface");
         }
         */
         var manipulatedNodeModel:ManipulatedNodesModel = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.manipulatedNodesModel;
         /* now walk through all children, which are UIComponents
         * and not our drawing surface and expand the result rectangle */
         
         for(var i:int = 0;i < children.length; ++i) {
            
            var view:UIComponent = (children[i] as UIComponent);

            /* only consider currently visible views */
            if(view.visible) {
               if((view != _drawingSurface) &&
                  (view != _graphControlLayer) && !(view is TitleLayer)){
                  if(view is PearlRendererBase){
                     var pearlView:PearlRendererBase = view as PearlRendererBase;
                     if(pearlView.node.isDocked || manipulatedNodeModel.isNodeManipulated(pearlView.node)) {
                        continue;
                     }
                     result.left = Math.min(result.left, pearlView.x + pearlView.pearl.x);
                     result.right = Math.max(result.right, pearlView.x + pearlView.pearl.x + pearlView.pearl.width);
                     result.top = Math.min(result.top, pearlView.y + pearlView.pearl.y);
                     result.bottom = Math.max(result.bottom, pearlView.y + pearlView.pearl.y + pearlView.pearl.height);
                  }
               } else {
                  if(children.length == 1) {
                     /* only child is the drawing surface, we return an empty Rectangle
                     * anchored in the middle */
                     return new Rectangle(_canvas.width / 2, _canvas.height / 2, 0, 0);
                  }
               }
            }
         }
         return result;
      }
      
      private function scrollLayer(layer:UIComponent, deltaX:Number, deltaY:Number):void {
         
         var view:UIComponent;
         var scrollableView:IScrollable =null;
         var n:int = layer.numChildren;
         for (var i:int = 0; i < n; i++)
         {
            view = layer.getChildAt(i) as UIComponent;
            scrollableView = view as IScrollable;
            if(scrollableView && view.visible && scrollableView.isScrollable()){
               if (view is IUIPearl && (IUIPearl(view).animationZoomFactor != 1)) {
                  var p:Point = IUIPearl(view).positionWithoutZoom;
                  
                  view.move(view.x + deltaX, view.y + deltaY);
               }  else {
                  view.move(view.x + deltaX, view.y + deltaY);
               }
            } 
         }
         
      }    
      
      public function isSilentReposition():Boolean {
         return _isScrolling;
      }
      
      override public function scroll(deltaX:Number, deltaY:Number):void {
         if (_backgroundDragInProgress && _vetoDragScroll) {
            _backgroundDragBox.x += deltaX;
            _backgroundDragBox.y += deltaY;
            if (!isBoundingBoxHitScreen(_backgroundDragBox)) {
               
               _backgroundDragBox = calcNodesBoundingBox();
               _backgroundDragBox.x += deltaX;
               _backgroundDragBox.y += deltaY;
               if (!isBoundingBoxHitScreen(_backgroundDragBox)) {
                  _backgroundDragBox.x -= deltaX;
                  _backgroundDragBox.y -= deltaY;
                  return;
               }
            } 
            
         }
         
         _isScrolling = true;

         /* we walk through all children of the canvas, which
         * are not the drawing surface and which are UIComponents
         * (they should be all node views) and move them according
         * to the scroll offset */
         scrollLayer(_canvas, deltaX, deltaY);

         scrollLayer(_ringLayer, deltaX, deltaY);

         scrollLayer(_titleLayerNotDockedTop, deltaX, deltaY);
         scrollLayer(_titleLayerNotDockedAbove, deltaX, deltaY);
         scrollLayer(_titleLayerNotDockedBelow, deltaX, deltaY);

         scrollLayer(_drawingSurface, deltaX, deltaY);

         scrollLayer(_graphControlLayer.getAddOnLayer(), deltaX, deltaY);

         _isScrolling = false;

         var im:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
         if (im.draggedPearl) {
            im.draggedPearl.dispatchEvent(new Event(MoveNotifier.FORCE_REPOSITION_NOW_EVENT));
         }

         /* adjust the current origin of the canvas
         * (not 100% sure if this is a good idea but seems
         * to work) XXX */
         offsetOrigin(deltaX,deltaY);

      }

      private function onMouseDown(event:MouseEvent):void{
         var point:Point = new Point(event.stageX, event.stageY);
         
         var pearlRenderer:IUIPearl = PearlBase.getPearlRendererUnderPoint(point);
         var titleRenderer:TitleRenderer = TitleRenderer.getTitleRendererUnderPoint(point);
         var cursorIsOverAControl:Boolean = controls.isPointOverAControl(point);

         if(titleRenderer && titleRenderer.editable){
            return;
         }
         
         if(pearlRenderer ){
            if(!pearlRenderer.node.isDocked && (cursorIsOverAControl || !pearlRenderer.isPointOnPearl(point))){
               
               return;
            }
            if(!pearlRenderer.canBeMoved() ){
               if(pearlRenderer.vnode == currentRootVNode){
                  var rightsManager:InteractorRightsManager= ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.interactorRightsManager;
                  if (rightsManager.userIsHome() || ApplicationManager.getInstance().currentUser.isAnonymous()) {
                     backgroundDragBegin(event);
                  }
               } 
            } else {
               if (ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.getActive()) {
                  dragNodeBegin(pearlRenderer.uiComponent, event);
               }
            }
         }else{
            if(!cursorIsOverAControl){
               backgroundDragBegin(event);
            }
         } 

      }
      
      public function dragNodeBegin(renderer:UIComponent, event:MouseEvent):void{
         _draggedNodeRenderer = renderer; 

         var ecomponent:UIComponent;
         var evnode:IVisualNode;
         var pt:Point;

         /* if there is an animation in progress, we ignore
         * the drag attempt */
         if(_layouter && _layouter.animInProgress) {
            trace("Animation in progress, drag attempt ignored");
            return;
         }
         
         /* make sure we get the right component */
         if(renderer) {

            ecomponent = renderer;
            /* get the associated VNode of the view */
            evnode = _viewToVNodeMap[ecomponent];
            
            /* stop propagation to prevent a concurrent backgroundDrag */

            if(evnode != null) {
               if(!dragLockCenter) {
                  
                  pt = ecomponent.localToGlobal(new Point(ecomponent.mouseX, ecomponent.mouseY));
               } else {

                  pt = ecomponent.localToGlobal(new Point(0,0));
               }
               
               /* Save the offset values in the map 
               * so we can compute x and y correctly in case
               * we use lockCenter */
               _drag_x_offsetMap[ecomponent] = pt.x / scaleX - ecomponent.x;
               _drag_y_offsetMap[ecomponent] = pt.y / scaleY - ecomponent.y;
               
               /* now we would need to set the bounds
               * rectangle in _drag_boundsMap, but this is
               * currently not implemented *
               _drag_boundsMap[ecomponent] = rectangle;
               */
               
               /* Registeran eventListener with the component's stage that
               * handles any mouse move. This wires the component
               * to the mouse. On every mouse move, the event handler
               * is called, which updates its coordinates.
               * We need to save the drag component, since we have to 
               * register the event handler with the stage, not the component
               * itself. But from the stage we have no way to get back to
               * the component or the VNode in case of the mouse move or 
               * drop event. 
               */
               _dragComponent = ecomponent;

               /* also register a drop event listener */

               /* and inform the layouter about the dragEvent */
               _layouter.dragEvent(event, evnode);
            } else {
               throw Error("Event Component was not in the viewToVNode Map");
            }
         } else {
            throw Error("MouseEvent target was no UIComponent");
         }           
         
      }
      
      override protected function dragBegin(event:MouseEvent):void {

      }
      public function dragEndEventSafe(event:Event):void {
         dragEnd(event as MouseEvent);
      }
      
      override protected function backgroundDragBegin(event:MouseEvent):void {

         if(backgroundDragEnabled ) {
            controls.scrollControl.setForceShowControls(true);
            _backgroundDragBox = calcNodesBoundingBox(); 
            super.backgroundDragBegin(event);

            _canvas.stage.addEventListener(Event.MOUSE_LEAVE, dragEndEventSafe);
            ApplicationManager.flexApplication.systemManager.addEventListener(MouseEvent.MOUSE_UP, dragEnd);
            
         }
      }
      override protected function backgroundDragContinue(event:MouseEvent):void {
         if(backgroundDragEnabled ) {
            if (WeightEdgeComponent.USE_EDGE_COMPONENT) {
               _vetoDragScroll= true;
            }
            _vetoRefresh = true;
            
            super.backgroundDragContinue(event);
            _vetoDragScroll = false;
            _vetoRefresh = false;
         } 
         if (_updateAfterEvent) {
            event.updateAfterEvent();
         }
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         if (!_vetoRefresh) {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            _graphControlLayer.width = unscaledWidth;
            _graphControlLayer.height = unscaledHeight;
         }

      }
      public function ensureDragEnd(event:MouseEvent):void {
         dragEnd(event);
      }
      
      override protected function dragEnd(event:MouseEvent):void {
         _canvas.stage.removeEventListener(Event.MOUSE_LEAVE, dragEndEventSafe);
         _canvas.stage.removeEventListener(MouseEvent.MOUSE_UP, dragEndEventSafe);
         ApplicationManager.flexApplication.systemManager.removeEventListener(MouseEvent.MOUSE_UP, dragEndEventSafe);
         
         var mycomp:UIComponent;
         var myback:DisplayObject;
         var myvnode:IVisualNode;
         
         if(_backgroundDragInProgress) {
            
            /* if it was a background drag we stop it here */
            _backgroundDragInProgress = false;
            
            /* get the background drag object, which is usually
            * the canvasm so we just set it to this */
            
            myback = (this as DisplayObject);
            
            /*
            if(myback == (this as DisplayObject)) {
            trace("we found ourselves as the background object GREAT");
            } else {
            trace("we got something else as the background, HMPF");
            }
            */
            
            /* no longer needed
            if(myback == null) {
            /* this can happen if we let go of the button
            * outside of the window *
            trace("dragEnd: background drop event target was no DisplayObject but "+event.currentTarget.toString());
            }
            */
            
            /* unregister event handler */              
            myback.removeEventListener(MouseEvent.MOUSE_MOVE,backgroundDragContinue);

            /* and inform the layouter about the dropEvent */
            if(_layouter) {
               _layouter.bgDropEvent(event);
            }
            controls.scrollControl.setForceShowControls(false);
            
         } else {
            
            /* if it was no background drag, the component
            * is the saved dragComponent */
            mycomp = _dragComponent;
            
            /* But sometimes the dragComponent was already null, 
            * in this case we have to ignore the thing. */
            if(mycomp == null) {
               
               return;
            }
            
            /* remove the event listeners */

            if (mycomp.stage != null)
            {
               mycomp.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDrag);
            }
            
            /* get the associated VNode to notify the layouter */
            myvnode = _viewToVNodeMap[mycomp];
            if(_layouter) {
               _layouter.dropEvent(event, myvnode);
            }
            delete _drag_x_offsetMap[mycomp];
            delete _drag_y_offsetMap[mycomp];
            /* reset the dragComponent */
            _dragComponent = null;
            
         }
         
         /* and stop propagation, as otherwise we could get the
         * event multiple times */
         
      }    
      
      public function linkNodesAtIndex(v1:IVisualNode, v2:IVisualNode, index:int):IVisualEdge {
         
         var n1:IPTNode;
         var n2:IPTNode;
         var e:IEdge;
         var ve:IVisualEdge;
         
         /* make sure both nodes do exist */
         if(v1 == null || v2 == null) {
            throw Error("linkNodes: one of the nodes does not exist");
            
         }
         
         n1 = IPTNode(v1.node);
         n2 = IPTNode(v2.node);
         
         /* now first link the graph nodes and create the corresponding edge */
         e = (_graph as IPTGraph).linkAtIndex(n1 ,n2, index,null);
         
         /* if the edge existed already, e is just the
         * already existing edge. But if it existed
         * previously it might already have a VEdge.
         * So we only create a new VEdge, if it did not exist
         * already. */      
         if(e == null) {
            throw Error("Could not create or find Graph edge!!");
         } else {
            if(e.vedge == null) {
               /* we have a new edge, so we create a new VEdge */
               ve = createVEdge(e);
            } else {
               /* existing one, so we use the existing vedge */
               trace("Edge already existed, returning existing vedge");
               ve = e.vedge;
            }
         }

         /* this changes the layout, so we have to do a full redraw */
         
         /* just refresh the edges */
         refresh();
         return completeVEdgeBuild(ve);
      }
      override public function linkNodes(v1:IVisualNode, v2:IVisualNode):IVisualEdge {
         return completeVEdgeBuild(super.linkNodes(v1,v2));
      }
      override public function unlinkNodes(v1:IVisualNode, v2:IVisualNode):void {
         
         super.unlinkNodes(v1,v2);
         _endNodeVisibilityManager.onUnlinkNode(v1,v2);
      }

      override public function createNode(sid:String = "", o:Object = null):IVisualNode {
         var rn:IVisualNode = _currentRootVNode;
         var ret:IVisualNode = super.createNode(sid, o);
         _currentRootVNode = rn;
         return ret;
      }

      override public function removeNode(vn:IVisualNode):void {

         if (vn == null) {
            return;
         }
         var n:IPTNode = vn.node as IPTNode;
         _displayModel.onNodeRemovedFromGraph(n);
         _logger.info("Remove component {0} ({1})", n, PTNode(n).nodeInstanceName());
         
         var rn:IVisualNode = _currentRootVNode;
         super.removeNode(vn);
         if (_currentRootVNode != rn) {
            _currentRootVNode =null;
         }
         _endNodeVisibilityManager.onRemoveNode(vn);
         if (n) {
            n.end();
         }
      }
      
      public function moveNodeTo(v:IVisualNode,x:int, y:int, duration:int=300, play:Boolean=true):Move {
         return _moveNodeManager.playMoveEffectOnNode(v, x, y, duration, play);
      }
      
      public function get PTLayouter():IPTLayouter {
         return super.layouter as IPTLayouter;
      }
      
      private function completeVEdgeBuild(vedge:IVisualEdge):IVisualEdge {
         vedge.data = (vedge.edge.data = new EdgeData());
         _endNodeVisibilityManager.onLinkNode(vedge.edge.node1, vedge.edge.node2);
         return vedge;
      }
      
      override protected function setNodeVisibility(vn:IVisualNode, visible:Boolean):void {
         var node:IPTNode = vn.node as IPTNode;
         if(node && !node.getDock()){
            super.setNodeVisibility(vn, visible);
         }   
      }  
      
      public function isAnimating():Boolean{
         return !_moveNodeManager.isView2MoveEmpty();
      }
      
      public function showNodeTitle(pearlRenderer:IUIPearl, above:Boolean, onTop:Boolean, inDockedSpace:Boolean):void{          
         _titleRendererManager.showNodeTitle(pearlRenderer, above, onTop, inDockedSpace);
      }
      
      public function handleDragPearl(event:MouseEvent):void {
         handleDrag(event);
      } 
      
      override protected function handleDrag(event:MouseEvent):void {
         if (WeightEdgeComponent.USE_EDGE_COMPONENT) {
            _vetoRefresh = true;
         }
         
         handleDragOverriden(event);
         _vetoRefresh = false;
         var pearlRenderer:PearlRendererBase = _dragComponent as PearlRendererBase;
         if(pearlRenderer && pearlRenderer.titleRenderer){
            pearlRenderer.titleRenderer.reposition();
         } 
      }

      protected function handleDragOverriden(event:MouseEvent):void {
         var myvnode:IVisualNode;
         var sp:UIComponent;

         /* we set our Component to be the saved
         * dragComponent, because we cannot access it
         * through the event. */
         sp = _dragComponent;
         
         /* Sometimes we get spurious events */
         if(_dragComponent == null) {
            trace("received handleDrag event but _dragComponent is null, ignoring");
            return;
         }
         
         /* bounds are not implemented:
         bounds = _drag_boundsMap[sp];
         */
         if (_moveNodeInDrag) {
            /* update the coordinates with the current
            * event's stage coordinates (i.e. current mouse position),
            * modified by the lock-center offset */

            sp.move(event.stageX / scaleX - _drag_x_offsetMap[sp] , event.stageY / scaleY - _drag_y_offsetMap[sp]);
            
            /* bounds code, currently unused 
            if ( bounds != null ) {
            if ( sp.x < bounds.left ) {
            sp.x = bounds.left;
            } else if ( sp.x > bounds.right ) {
            sp.x = bounds.right;
            }  
            if ( sp.y < bounds.top ) {
            sp.y = bounds.top;   
            } else if ( sp.y > bounds.bottom ) {
            sp.y = bounds.bottom;   
            }
            }
            */
         }
         
         /* and inform the layouter about the dragEvent */
         myvnode = _viewToVNodeMap[_dragComponent];
         _layouter.dragContinue(event, myvnode);
         
         /* make sure flashplayer does an update after the event */
         refresh();
         event.updateAfterEvent();        
      }

      override public function refresh():void {
         if (!_vetoRefresh) {
            super.refresh();
            refreshEdges();
            
         }
      }
      public function refreshEdges():void {
         for each(var view:UIComponent in _vedgeToComponents) {
            view.invalidateProperties();
         }
         
      }
      public function refreshNodes():void {
         for each(var vnode:IVisualNode in visibleVNodes) {
            if (vnode.isVisible && vnode.view) {
               vnode.view.invalidateProperties();
            }
         }
         refreshEdges();
      }
      override protected function removeComponent(component:UIComponent, honorEffect:Boolean = true):void {     
         var pearlRenderer:IUIPearl = component as IUIPearl;
         if(pearlRenderer) {
            _titleRendererManager.removeTitleRenderer(pearlRenderer);
            pearlRenderer.pearl.showRings = false;       
         }
         if(pearlRenderer && ( !honorEffect  || removeItemEffect == null)) {
            pearlRenderer.end();
         } else {
            _playingRemoveComponentEffectsCount ++;
         }
         super.removeComponent(component, honorEffect);         
      }
      override protected function removeEffectDone(event:EffectEvent):void {
         _playingRemoveComponentEffectsCount --;
         super.removeEffectDone(event);
         
      }
      
      public function backgroundDragInProgress():Boolean{
         return _backgroundDragInProgress;
      }
      
      public function getEditedGraphVisualModification():EditedGraphVisualModification {
         return _editedGraphVisualModification;
      }
      
      public override function redrawEdges():void{
         if (!WeightEdgeComponent.USE_EDGE_COMPONENT) {
            super.redrawEdges();
         }         
      }
      public function redrawAllComponentEdges():void {
         for each (var c:WeightEdgeComponent in _vedgeToComponents) {
            c.forceRedraw();
         }
      }
      
      protected override function measure():void {
         
      }
      public function get endNodeVisibilityManager():EndNodeVisibilityManager {
         return _endNodeVisibilityManager;
      }
      
      public override function get scale():Number {
         return _scaleValue;
      }
      public override function set scale (value:Number):void
      {
         _scaleValue = value;
      }

      override public function set currentRootVNode(vn:IVisualNode):void {
         
         if (currentRootVNode != vn && currentRootVNode != null && vn != null) {
            if (IPTNode(currentRootVNode.node).wasSameNode(IPTNode(vn.node))) {
               super._currentRootVNode = vn;
               return;
            }
         } 
         if (vn == null) {
            trace("setting null current root node");
         }
         super.currentRootVNode= vn;
      }
      public function getDraggedComponent():UIComponent {
         return super._dragComponent;
      }
      public function get zoomModel():ZoomModel {
         return _zoomModel;
      }
      public function isBackdroungDragInProgress():Boolean {
         return super._backgroundDragInProgress;
      }
      public function getDisplayModel():GraphicalDisplayedModel {
         return _displayModel;
      }
      
      private function isValidCenter(center:Point ):Boolean {
         return center.x  >=  1 && center.y > (_navbarOffset / 2);
         
      }
      override public function get center():Point {
         var currentCenter:Point;
         
         if (_offsetIfAnonymous > 0) {
            _offsetIfAnonymous = ApplicationManager.getInstance().components.windowController.offsetHeightDueToSignupBanner();
            var scrollUI:ScrollUi= controls.scrollControl.scrollUi;
            _logger.info("scrollUI.height = {0}  offesetIfAnonymous = {1} ", scrollUI.height, _offsetIfAnonymous);
            if (scrollUI.height>0 && _offsetIfAnonymous > 0) {
               currentCenter = new Point(stage.stageWidth/2.0, _offsetIfAnonymous +  scrollUI.y + (scrollUI.height - _offsetIfAnonymous) /2.0);
            }
            else {
               currentCenter = new Point(stage.stageWidth/2.0, ( _offsetIfAnonymous + _navbarOffset + stage.stageHeight) /2.0);
               if (_offsetIfAnonymous > 0 ) {
                  return currentCenter;  
               }
            }
            if (_offsetIfAnonymous == 0) {
               currentCenter.y = stage.stageHeight / 2.0;
               if (currentCenter.y  > _navbarOffset) {
                  _previousCenter = currentCenter;   
               }
               return currentCenter;
            } 
         }
         else {
            currentCenter = new Point(stage.stageWidth/2.0, stage.stageHeight /2.0);
         }

         _logger.info("center {0} , {1}", currentCenter.x, currentCenter.y);
         
         if (!isValidCenter(currentCenter) || (_previousCenter && _previousCenter.equals(currentCenter))) {
            return currentCenter;
         } else {
            if(_previousCenter && _previousCenter.x >= 1) {
               _logger.info("Change from previous offseting {0} , {1}, origin was before offset : {2}, {3}  after offset: {4}, {5}", _previousCenter.x, _previousCenter.y,
                  origin.x, origin.y, origin.x + _previousCenter.x - currentCenter.x, origin.y + _previousCenter.y - currentCenter.y);
               offsetOrigin(_previousCenter.x - currentCenter.x, _previousCenter.y - currentCenter.y);
            }
            _previousCenter = currentCenter;
         }
         return _previousCenter;
         
      }
      
      override public function get origin():Point {
         var p:Point = super.origin;
         
         return p;
      }
      public function offsetOrigin(x:Number, y:Number):void {
         super.origin.offset(x,y);
      }
      
      private function isBoundingBoxHitScreen(boundingBox:Rectangle):Boolean  {
         if (boundingBox.left + 30 > this.width || boundingBox.right < 30) {
            return false;
         } 
         if (boundingBox.y + 30 > this.height|| boundingBox.bottom< 30) {
            return false;
         } 
         return true;
         
      }
      override public function invalidateDisplayList():void {
         if (!_vetoRefresh) {
            super.invalidateDisplayList();
         }
      }
      public function getPtwPearlRecyclingMananager():IPearlRecyclingManager {
         return _pearlRendererFactories.getPtwPearlRecyclingMananager();
      }
      
      public function containsSubTrees():Boolean {
         var rootNode:IPTNode = currentRootVNode ? currentRootVNode.node as IPTNode:null;
         if (rootNode) {
            var subTrees:Array = rootNode.getDescendantsAndSelf();
            for each (var n:IPTNode in subTrees) {
               var r:PTRootNode = n as PTRootNode;
               if (r && r != rootNode && r.isOpen() && !r.containedPearlTreeModel.businessTree.isEmpty() && r.containedPearlTreeModel.openingState != OpeningState.CLOSING) {
                  return true;
               }
            }
         }
         return false;
      }
   }
}
