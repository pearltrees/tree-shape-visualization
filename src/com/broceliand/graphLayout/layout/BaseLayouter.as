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
package com.broceliand.graphLayout.layout{
   
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
   import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
   import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.LogUtil;

   public class BaseLayouter extends EventDispatcher implements ILayoutAlgorithm {
      
      private static const _LOG:String = "graphLayout.layout.BaseLayouter";

      public static const MINIMUM_NODE_HEIGHT:Number = 5;

      public static const MINIMUM_NODE_WIDTH:Number = 5;

      public static const DEFAULT_MARGIN:Number = 30;

      protected var _disableAnimation:Boolean = false;

      protected var _vgraph:IVisualGraph = null;

      protected var _graph:IGraph = null;

      protected var _layoutChanged:Boolean = false;

      protected var _stree:IGTree;

      protected var _root:INode;

      protected var _autoFitEnabled:Boolean = false;

      private var _currentDrawing:BaseLayoutDrawing;

      public function BaseLayouter(vg:IVisualGraph = null):void {
         
         _vgraph = vg;
         if(vg) {
            _graph = _vgraph.graph;
         } else {
            _graph = new Graph("dummyID");
         }
         
         /* this is required to smooth the animation */
         _vgraph.addEventListener("forceRedrawEvent",forceRedraw);
      }

      public function resetAll():void {
         _layoutChanged = true;
      }

      public function set vgraph(vg:IVisualGraph):void {
         if(_vgraph == null) {
            _vgraph = vg;
            _graph = _vgraph.graph;
         } else {
            LogUtil.warn(_LOG, "vgraph was already set in layouter");
         }
      }

      public function set graph(g:IGraph):void {
         _graph = g;
      }

      public function get layoutChanged():Boolean {
         return _layoutChanged;
      }

      public function set layoutChanged(lc:Boolean):void {
         _layoutChanged = lc;
      }

      [Bindable]	 
      public function get autoFitEnabled():Boolean {
         return _autoFitEnabled;	
      }

      public function set autoFitEnabled(af:Boolean):void {
         _autoFitEnabled = af;
      }

      [Bindable]
      public function set linkLength(r:Number):void {
         /* NOP */
      }

      public function get linkLength():Number {
         /* NOP
         * but must not return 0, since some layouter
         * do not care about LL, but the vgraph will
         * not draw if LL is 0
         * so default is something else, like 1
         */
         return 1;
      }

      public function get animInProgress():Boolean {
         /* since the base layouter is ignorant of animation
         * it would always return false. The AnimatedBaseLayouter
         * though needs to override this to always return the
         * correct value. */
         return false;
      }

      public function set disableAnimation(d:Boolean):void {
         _disableAnimation = d;
      };

      public function get disableAnimation():Boolean {
         return _disableAnimation;
      }

      public function layoutPass():Boolean {
         /* NOP */
         return true;
      }

      public function refreshInit():void {
         /* NOP */
      }

      public function dragEvent(event:MouseEvent, vn:IVisualNode):void {
         /* NOP */
         
      }

      public function dragContinue(event:MouseEvent, vn:IVisualNode):void {
         /* NOP */
         
      }

      public function dropEvent(event:MouseEvent, vn:IVisualNode):void {
         /* NOP */
         
      }

      public function bgDragEvent(event:MouseEvent):void {
         /* NOP */
         
      }

      public function bgDragContinue(event:MouseEvent):void {
         /* NOP */
         
      }

      public function bgDropEvent(event:MouseEvent):void {
         /* NOP */
         
      }

      protected function set currentDrawing(dr:BaseLayoutDrawing):void {
         _currentDrawing = dr;
      }

      protected function applyTargetCoordinates(n:INode):void {
         
         var coords:Point;
         /* add the points coordinates to its origin */		
         coords = _currentDrawing.getAbsCartCoordinates(n);
         
         n.vnode.x = coords.x;
         n.vnode.y = coords.y;
      }

      protected function applyTargetToNodes(vns:Dictionary):void {
         var vn:IVisualNode;
         for each(vn in vns) {			
            /* should be visible otherwise somethings wrong */
            if(!vn.isVisible) {
               throw Error("received invisible vnode from list of visible vnodes");
            }
            applyTargetCoordinates(vn.node);
            vn.commit();
         }			
      }
      
      private function forceRedraw(e:MouseEvent):void {
         e.updateAfterEvent();
      }
   }
}
