package com.broceliand.graphLayout.layout {
   
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.ui.renderers.TitleRenderer;
   
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   import org.un.cava.birdeye.ravis.utils.Geometry;
   import org.un.cava.birdeye.ravis.utils.GraphicUtils;

   public class AnimatedBaseLayout extends BaseLayouter implements ILayoutAlgorithm {

      public const ANIM_RADIAL:int = 1;

      public const ANIM_STRAIGHT:int = 2;

      private const _ANIMATIONSTEPS:int = 50;

      private const _ANIMATIONTIMINGINTERVALSIZE:Number = 10; 

      private const _MAXANIMTIMERDELAY:int = 100;

      protected var _animInProgress:Boolean = false;
      
      private var _animationType:int = ANIM_RADIAL;

      private var _animStep:int; 

      private var _animTimer:Timer;

      private var _currentDrawing:BaseLayoutDrawing;
      
      public function AnimatedBaseLayout(vg:IVisualGraph = null):void {
         super(vg);
         _animInProgress = false;
      }

      override public function get animInProgress():Boolean {
         return _animInProgress;
      }

      override public function resetAll():void {
         super.resetAll();
         killTimer();
      }

      override protected function set currentDrawing(dr:BaseLayoutDrawing):void {
         _currentDrawing = dr;
         
         /* also set in the super class */
         super.currentDrawing = dr;
      }

      protected function set animationType(type:int):void {
         _animationType = type;
      }

      protected function killTimer():void {
         if(_animTimer != null) {
            
            _animTimer.stop();
            _animTimer.reset();
            
         }
      }

      protected function resetAnimation():void {
         /* reset animation cycle */
         _animStep = 0;
      }

      protected function startAnimation():void {
         var cyclefinished:Boolean;
         
         if(!_disableAnimation) {
            
            /* indicate an animation in progress */
            _animInProgress = true;
            
            switch(_animationType) {
               case ANIM_RADIAL:
                  cyclefinished = interpolatePolarCoords();
                  break;
               case ANIM_STRAIGHT: 
                  cyclefinished = interpolateCartCoords();
                  break;
               default:
                  trace("Illegal animation Type, default to ANIM_RADIAL");
                  cyclefinished = interpolatePolarCoords();
                  break;
            }
         } else {
            cyclefinished = setCoords();
         }
         
         /* make sure the edges are redrawn */
         _layoutChanged = true;
         /* check if we ran out of anim cycles, but are not finished */
         if (cyclefinished) {
            
            _animInProgress = false;
         } else if(_animStep >= _ANIMATIONSTEPS) {
            trace("Exceeded animation steps, setting nodes to final positions...");
            applyTargetToNodes(_vgraph.visibleVNodes);
            _animInProgress = false;
         } else {
            ++_animStep;
            startAnimTimer();
         }
      }

      protected function interpolatePolarCoords():Boolean {
         var visVNodes:Dictionary;
         var vn:IVisualNode;
         var n:INode;
         var currRadius:Number;
         var currPhi:Number;
         var currPoint:Point;
         var targetRadius:Number;
         var targetPhi:Number;
         var deltaRadius:Number;
         var deltaPhi:Number;
         var stepRadius:Number;
         var stepPhi:Number;
         var stepPoint:Point;
         var cyclefinished:Boolean;
         
         cyclefinished = true; 
         
         /* careful for invisible nodes, the values are not
         * calculated (obviously), so we need to make sure
         * to exclude them */
         visVNodes = _vgraph.visibleVNodes;
         for each(vn in visVNodes) {
            
            /* should be visible otherwise somethings wrong */
            if(!vn.isVisible) {
               throw Error("received invisible vnode from list of visible vnodes");
            }
            
            n = vn.node;
            
            /* get relative target coordinates in polar form */
            targetRadius = _currentDrawing.getPolarR(n);
            targetPhi = _currentDrawing.getPolarPhi(n);
            
            /* when we get the current values, we have to make sure
            * that we convert the coordinates into relative ones,
            * i.e. we need to subtract the origin */
            n.vnode.refresh();
            currPoint = new Point(vn.x, vn.y);
            currPoint = currPoint.subtract(_currentDrawing.originOffset);
            
            if(_currentDrawing.centeredLayout) {
               currPoint = currPoint.subtract(_currentDrawing.centerOffset);
            }
            
            currRadius = Geometry.polarRadius(currPoint);
            currPhi = Geometry.polarAngleDeg(currPoint);
            
            /* not sure if this really fixes the animation end cycle ... */
            deltaRadius = (targetRadius - currRadius) * _animStep / _ANIMATIONSTEPS;
            
            /* New logic for interpolating polar angles
            * Take the minimum angle to the final position */
            
            if ( Math.abs(targetPhi - currPhi) < (360 - Math.abs(targetPhi - currPhi)) ) {
               deltaPhi = (targetPhi - currPhi) * _animStep / _ANIMATIONSTEPS;
            } else { 
               if (targetPhi < currPhi) {
                  
                  deltaPhi = (360 + targetPhi - currPhi) * _animStep / _ANIMATIONSTEPS;
               } else { 
                  
                  deltaPhi = (targetPhi - currPhi - 360) * _animStep / _ANIMATIONSTEPS;
               }
            }
            
            /* calculate the intermediate coordinates */
            stepRadius = currRadius + deltaRadius;
            stepPhi = currPhi + deltaPhi;
            
            /* check if we are already done or not */
            if(!GraphicUtils.equal(currPoint, _currentDrawing.getRelCartCoordinates(n))) {
               cyclefinished = false;
            }
            
            /* we cannot set the coordinates in the _currentDrawing,
            * as we store our target coordinates there,
            * we need to set them directly in the vnode */
            stepPoint = Geometry.cartFromPolarDeg(stepRadius,stepPhi);
            
            /* adjust the origin */
            stepPoint = stepPoint.add(_currentDrawing.originOffset);
            
            /* here we may need to add the center offset */
            if(_currentDrawing.centeredLayout) {
               stepPoint = stepPoint.add(_currentDrawing.centerOffset);
            }
            
            /*
            trace("interpolating node:"+n.id+" cP:"+currPoint.toString()+" cr:"+currRadius+" cp:"+currPhi+
            " tr:"+targetRadius+" tp:"+targetPhi+" sP:"+stepPoint.toString()+" sr:"+stepRadius+
            " sp:"+stepPhi); 
            */
            
            /* set into the vnode */
            vn.x = stepPoint.x;
            vn.y = stepPoint.y;
            
            /* commit, i.e. move the node */
            vn.commit();
         }
         return cyclefinished;
      }

      protected function interpolateCartCoords():Boolean {
         var visVNodes:Dictionary;
         var vn:IVisualNode;
         var n:INode;
         var currPoint:Point;
         var deltaPoint:Point;
         var stepPoint:Point;
         var targetPoint:Point;
         var cyclefinished:Boolean;
         
         cyclefinished = true; 
         
         /* careful for invisible nodes, the values are not
         * calculated (obviously), so we need to make sure
         * to exclude them */
         visVNodes = _vgraph.visibleVNodes;
         for each(vn in visVNodes) {
            
            /* should be visible otherwise somethings wrong */
            if(!vn.isVisible) {
               throw Error("received invisible vnode from list of visible vnodes");
            }
            
            n = vn.node;
            
            /* get relative target coordinates in cartesian form */
            targetPoint = _currentDrawing.getRelCartCoordinates(n);
            
            /* when we get the current values, we have to make sure
            * that we convert the coordinates into relative ones,
            * i.e. we need to subtract the origin */
            n.vnode.refresh();
            currPoint = new Point(vn.x, vn.y);
            currPoint = currPoint.subtract(_currentDrawing.originOffset);
            
            if(_currentDrawing.centeredLayout) {
               currPoint = currPoint.subtract(_currentDrawing.centerOffset);
            }
            
            /* check if we are already done or not */
            if(!GraphicUtils.equal(currPoint, targetPoint)) {
               cyclefinished = false;
            }
            
            deltaPoint = new Point( (targetPoint.x - currPoint.x) * _animStep / _ANIMATIONSTEPS,
               (targetPoint.y - currPoint.y) * _animStep / _ANIMATIONSTEPS);
            
            stepPoint = currPoint.add(deltaPoint);
            
            /* adjust the origin */
            stepPoint = stepPoint.add(_currentDrawing.originOffset);
            
            /* here we may need to add the center offset */
            if(_currentDrawing.centeredLayout) {
               stepPoint = stepPoint.add(_currentDrawing.centerOffset);
            }
            
            /* set into the vnode */
            vn.x = stepPoint.x;
            vn.y = stepPoint.y;
            
            vn.orientAngle = Geometry.rad2deg(Geometry.normaliseAngle(Geometry.deg2rad(_currentDrawing.getPolarPhi(vn.node))));
            /* commit, i.e. move the node */
            vn.commit();
         }
         return cyclefinished;
      }

      protected function setCoords():Boolean {
         var visVNodes:Dictionary;
         var vn:IVisualNode;
         var n:INode;
         var targetPoint:Point;
         
         /* careful for invisible nodes, the values are not
         * calculated (obviously), so we need to make sure
         * to exclude them */
         visVNodes = _vgraph.visibleVNodes;
         for each(vn in visVNodes) {
            
            /* should be visible otherwise somethings wrong */
            if(!vn.isVisible) {
               throw Error("received invisible vnode from list of visible vnodes");
            }

            n = vn.node;
            if((n is IPTNode) && ((n as IPTNode).getDock())){
               continue;
            }
            /* get relative target coordinates in cartesian form */
            targetPoint = _currentDrawing.getRelCartCoordinates(n);
            
            /* adjust the origin */
            targetPoint = targetPoint.add(_currentDrawing.originOffset);
            
            /* here we may need to add the center offset */
            if(_currentDrawing.centeredLayout) {
               targetPoint = targetPoint.add(_currentDrawing.centerOffset);
            }
            
            /* set into the vnode */
            vn.x = Math.round(targetPoint.x);
            vn.y = Math.round(targetPoint.y);
            
            /* commit, i.e. move the node */
            commitNode(vn);

            vn.orientAngle = Geometry.rad2deg(Geometry.normaliseAngle(Geometry.deg2rad(_currentDrawing.getPolarPhi(vn.node))));
            var tr:TitleRenderer = (vn as IPTVisualNode).pearlView.titleRenderer; 

         }
         return true;
      }
      
      protected function commitNode(vn: IVisualNode ):void {
         vn.commit();
      }
      
      private function startAnimTimer():void {
         var timerdelay:Number;
         var factor:Number;
         var signedAnimStep:int;
         var factorinput:Number;
         
         /* modify the current animation step to range from -/+ around 0 */
         signedAnimStep = _animStep - (_ANIMATIONSTEPS / 2); 
         
         /* this is the input into into the atan() function, which depends on the
         * timing interval and the current signed animation step */
         factorinput = _ANIMATIONTIMINGINTERVALSIZE * (signedAnimStep / _ANIMATIONSTEPS);            
         
         /* calculate the timing factor using the atan() function
         * since we take the absolute value, 
         * its range goes from PI / 2 to 0 back to PI / 2 */
         factor = Math.abs(Math.atan(factorinput));
         
         /* now the delay for our timer is now the factors fraction
         * of PI/2 times the maximum timer delay, i.e. the full timer
         * delay if the factor has a value of PI / 2 */
         timerdelay = (factor / (Math.PI / 2)) * _MAXANIMTIMERDELAY;
         
         /* now creating the new timer with the specified delay
         * and ask for one execution, then the event handler will be
         * called, which does nothing except to call the interpolation
         * method again */
         if (_animTimer == null) {
            _animTimer = new Timer(timerdelay, 1);
            _animTimer.addEventListener(TimerEvent.TIMER_COMPLETE, animTimerFired);
         } else {
            _animTimer.stop();
            if (timerdelay > 0) _animTimer.delay = timerdelay;
            _animTimer.reset();             
         }
         _animTimer.start();
      }
      
      private function animTimerFired(event:TimerEvent = null):void {
         
         startAnimation();
         
      }
      
   }
}