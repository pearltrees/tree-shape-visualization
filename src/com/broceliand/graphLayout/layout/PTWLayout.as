package com.broceliand.graphLayout.layout
{

   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroRadialPosition;
   import com.broceliand.util.BroceliandMath;
   
   import flash.geom.Point;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class PTWLayout extends ConcentricRadialLayout implements ILayoutAlgorithm{

      public var centeredLayout:Boolean;

      public function PTWLayout(vg:IVisualGraph = null):void {
         super(vg);
         disableAnimation=true;
         
      }

      override public function layoutPass():Boolean {

         if(!_vgraph) {
            trace("No Vgraph set in ConcentricRadialLayouter, aborting");
            return false;
         }
         
         if(!_vgraph.currentRootVNode) {
            trace("This Layouter always requires a root node!");
            return false;
         }
         
         /* nothing to do if we have no nodes */
         if(_graph.noNodes < 1) {
            return false;
         }
         
         killTimer();
         
         /* establish the current root, if it has 
         * changed we need to reinit the drawing */
         if(_root != _vgraph.currentRootVNode.node) {
            /* don't forget to save the root here */
            
            _root = _vgraph.currentRootVNode.node;
            _layoutChanged = true;
         }
         
         /* we test to always reinit the drawing */
         if(_layoutChanged) {
            super.initDrawing();
         }

         /* set the coordinates in the drawing of root
         * to 0,0 */
         _currentDrawing.setCartCoordinates(_root,new Point(0,0));
         
         /* establish the spanning tree, but have it restricted to
         * visible nodes */
         _stree = _graph.getTree(_root, true, false);
         computeLayout();
         /* calculate the relative width and the
         * new max Depth */

         /* calculate the radius increment to fit the screen */

         /* we may have preset angular bounds
         * XXX this is untested, yet */

         /* now if we have no previous drawing we can just
         * apply the result and display it
         * if we do have (but maybe even if we don't have)
         * we interpolate the polar coordinates of the nodes */
         resetAnimation();
         
         /* start the animation by interpolating polar coordinates */
         startAnimation();
         
         _layoutChanged = true;
         return false;
      }
      
      public function computeLayout():void {
         var nodes:Array = _stree.getChildren(_stree.root);
         var r:Number=50;
         var lastTeta:Number=0;
         var lastTetaRad:Number =0;
         var newTeta:Number=0;
         var lastR:Number = 50;
         var p1:Point = new Point();
         var p2:Point = new Point();
         var maxR:Number = 0; 
         for each (var n:IPTNode in nodes) {
            if (n.getBusinessNode() is BroPTWDistantTreeRefNode) {
               var distantPTWRefNode:BroPTWDistantTreeRefNode = n.getBusinessNode() as BroPTWDistantTreeRefNode; 
               var preferredPosition:BroRadialPosition =  distantPTWRefNode.preferredRadialPosition;
               if(preferredPosition) {
                  r = preferredPosition.radius;
                  newTeta = preferredPosition.angleInDeg;
               }
               
            } 
            if (maxR<r) {
               maxR= r;
               
            }
            
            _currentDrawing.setPolarCoordinates(n,r , newTeta);
            lastTeta = newTeta;
         }
         if (maxR<50) maxR=50;
         var coef:Number = _vgraph.height/maxR;
         if (nodes && nodes.length <10 && coef> 5) {
            coef = 5;
         }
         
         for each (n in nodes) {
            _currentDrawing.setPolarCoordinates(n, _currentDrawing.getPolarR(n) * coefFromCenter( coef, _currentDrawing.getPolarR(n), maxR), _currentDrawing.getPolarPhi(n));
            
         }
      }
      private function coefFromCenter(coef:Number, radius:Number, maxR:Number):Number {
         
         return coef>2?coef/2:1;
         
      }
   }
   
}