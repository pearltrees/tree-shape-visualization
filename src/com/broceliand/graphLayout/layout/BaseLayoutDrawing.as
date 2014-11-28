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
package com.broceliand.graphLayout.layout {
   
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class BaseLayoutDrawing	{
      
      /* we create a virtual origin, that is used as an offset
      * to the (0,0) origin of the root node */
      private var _originOffset:Point;
      
      /* this is the current center offset of the 
      * canvas, which can be applied as well */
      private var _centerOffset:Point;

      private var _scaleFactor:Number;

      private var _centeredLayout:Boolean = true;
      
      /* we need the polar coordinates AND the relative
      * origin AND the "zero degrees" ray angle of every
      * node and of course the cartesian coordinates */
      
      /* node coordinates in polar and cartesian form, these
      * are all "relative" coordinates. */
      private var _nodePolarRs:Dictionary;
      private var _nodePolarPhis:Dictionary;
      private var _nodeCartCoordinates:Dictionary;
      
      /* we need a flag to indicate if the node 
      * in the current layout is valid or not
      */
      private var _nodeDataValid:Dictionary;

      public function BaseLayoutDrawing():void {
         
         _nodePolarRs = new Dictionary;
         _nodePolarPhis = new Dictionary;
         _nodeCartCoordinates = new Dictionary;
         _nodeDataValid = new Dictionary;
         
         _originOffset = new Point(0,0);
         _centerOffset = new Point(0,0);
         _centeredLayout = true;
      }
      
      /*
      * getters and setters 
      * */

      [Bindable]
      public function get originOffset():Point {
         return _originOffset;
      }
      
      public function set originOffset(o:Point):void {
         _originOffset = o;
      }

      [Bindable]
      public function get centerOffset():Point {
         return _centerOffset;
      }
      
      public function set centerOffset(o:Point):void {
         _centerOffset = o;
      }

      [Bindable]
      public function get centeredLayout():Boolean {
         return _centeredLayout;
      }
      
      public function set centeredLayout(c:Boolean):void {
         _centeredLayout = c;
      }

      public function nodeDataValid(n:INode):Boolean {
         return _nodeDataValid[n];
      }

      public function invalidateNodeData():void {
         _nodeDataValid = new Dictionary;
      }

      public function setPolarCoordinates(n:INode, polarR:Number, polarPhi:Number):void {
         
         /* we have to void NaN values */
         if(isNaN(polarR)) {
            throw Error("polarR tried to set to NaN");
         }
         if(isNaN(polarPhi)) {
            throw Error("polarPhi tried to set to NaN");
         }	
         
         _nodePolarRs[n] = polarR;
         _nodePolarPhis[n] = polarPhi;
         _nodeCartCoordinates[n] = Geometry.cartFromPolarDeg(polarR*scaleFactor, polarPhi) ;

         _nodeDataValid[n] = true;
      }

      public function setCartCoordinates(n:INode, p:Point):void {
         
         /*
         if(isNaN(p.x) || isNaN(p.y) || !isFinite(p.x) || !isFinite(p.y)) {
         throw Error("Target Point:"+p.toString()+" of node:"+n.id+" is not valid");
         }
         */
         
         _nodePolarRs[n] = p.length;
         _nodePolarPhis[n] = Geometry.polarAngleDeg(p);
         _nodeCartCoordinates[n] = p;
         
         /*
         LogUtil.debug(_LOG, "SetCartCoordinates of node:"+n.id+" polarRadius:"+_nodePolarRs[n]+
         " polarPhi:"+_nodePolarPhis[n]+" and in cartesian:"+
         (_nodeCartCoordinates[n] as Point).toString());
         */
         _nodeDataValid[n] = true;
      }		

      public function getPolarR(n:INode):Number {
         return _nodePolarRs[n];
      }

      public function getPolarPhi(n:INode):Number {
         return _nodePolarPhis[n];
      }

      public function getRelCartCoordinates(n:INode):Point {
         
         /* these may not yet have been initialised
         * in this case, we preset them to the current
         * Relative coordinates, i.e. minus the originOffset 
         */
         var c:Point;
         
         c = _nodeCartCoordinates[n];
         
         if(c == null) {
            n.vnode.refresh();	
            c =	new Point(n.vnode.x, n.vnode.y);
            c = c.subtract(_originOffset);
            
            if(_centeredLayout) {
               c = c.subtract(_centerOffset);
            }
            
            setCartCoordinates(n,c);
         }
         return c;
      }

      public function getAbsCartCoordinates(n:INode):Point {
         var res:Point;
         
         res = getRelCartCoordinates(n).add(_originOffset);
         
         if(_centeredLayout) {
            res = res.add(_centerOffset);
         }
         
         return res;
      }
      public function set scaleFactor (value:Number):void
      {
         _scaleFactor = value;
      }
      
      public function get scaleFactor ():Number
      {
         return _scaleFactor;
      }
      
   }
}
