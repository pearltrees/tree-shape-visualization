package com.broceliand.ui.effects
{
   
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPearl;
   import com.broceliand.util.IMoveOnValidation;
   
   import flash.geom.Point;
   
   import mx.core.Container;
   import mx.core.EdgeMetrics;
   import mx.core.mx_internal;
   import mx.effects.EffectManager;
   import mx.effects.effectClasses.MoveInstance;

   public class MoveWithScrollInstance extends MoveInstance
   {
      private var _startOrigin:Point;
      public function MoveWithScrollInstance(target:Object)
      {
         super(target);
      }

      private var forceClipping:Boolean = false;
      
      private var checkClipping:Boolean = true;

      override public function play():void
      {
         if (target is IUIPearl && IUIPearl(target).vnode ) {
            
            xFrom = UIPearl(target).positionWithoutZoom.x;
            yFrom = UIPearl(target).positionWithoutZoom.y;
            _startOrigin = IUIPearl(target).vnode.vgraph.origin.clone();
         }
         super.play();
         var p:Container = target.parent as Container;
         if (p)
         {
            var vm:EdgeMetrics = p.viewMetrics;
            var l:Number = vm.left;
            var r:Number = p.width - vm.right;
            var t:Number = vm.top;
            var b:Number = p.height - vm.bottom;
            
            if (xFrom < l || xTo < l ||
               xFrom + target.width > r || xTo + target.width > r ||
               yFrom < t || yTo < t ||
               yFrom + target.height > b || yTo + target.height > b)
            {
               forceClipping = true;
            }
            
         }
      }
      
      override public function onTweenUpdate(value:Object):void 
      {        
         EffectManager.suspendEventHandling();
         
         if (!forceClipping && checkClipping)
         {
            var p:Container = target.parent as Container;
            
            if (p)
            {
               var vm:EdgeMetrics = p.viewMetrics;
               var l:Number = vm.left;
               var r:Number = p.width - vm.right;
               var t:Number = vm.top;
               var b:Number = p.height - vm.bottom;
               
               if (value[0] < l || value[0] + target.width > r ||
                  value[1] < t || value[1] + target.height > b)
               {
                  forceClipping = true;
                  p.mx_internal::forceClipping = true;
               }
            }
         }
         var cancelDragged:Boolean = false;
         if (_startOrigin  && target is IUIPearl) {
            if (!target || !IUIPearl(target).vnode) {
               return 
            }
            
            var vgraph:IPTVisualGraph = IUIPearl(target).vnode.vgraph as IPTVisualGraph;
            var origin:Point = IUIPearl(target).vnode.vgraph.origin;
            value[0] += (origin.x - _startOrigin.x);
            value[1] += (origin.y - _startOrigin.y);
            if (vgraph.getDraggedComponent() ==  target) {
               
               cancelDragged= true;
            }
         }
         if (!cancelDragged) {

            if (target is IUIPearl) {
               IUIPearl(target).moveWithoutZoomOffset(value[0], value[1]);
            } else {
               target.move(value[0], value[1]);  
            }
         }
         EffectManager.resumeEventHandling();
      }

      override public function onTweenEnd(value:Object):void
      {
         if (forceClipping)
         {
            var p:Container = target.parent as Container;
            
            if (p) 
            {
               forceClipping = false;
            }
         }  
         
         checkClipping = false;
         super.onTweenEnd(value);
      }
   }
   
}
