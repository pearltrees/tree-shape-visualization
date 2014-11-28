package com.broceliand.graphLayout.visual
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.IRepositionable;
   import com.broceliand.ui.renderers.MoveNotifier;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.core.UIComponent;
   import mx.effects.Effect;
   import mx.effects.Move;
   import mx.events.EffectEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.VisualNode;
   
   public class PTVisualNodeBase extends VisualNode implements IRepositionable, IPTVisualNode 
   {
      private var _targetToMoveToX:Number;
      private var _targetToMoveToY:Number;
      private var _excitedState:Boolean = false;
      private var _isMoving:Boolean;
      private var _moveNotifier:MoveNotifier = new MoveNotifier();
      private var _viewNotifier:MoveNotifier = null;
      private var _isCommiting:Boolean=false;
      protected var _pearlRenderer:IUIPearl= null;
      private var _distanceToClosestBrother:Number;
      
      public function PTVisualNodeBase(vg:IVisualGraph, node:INode, id:int, view:UIComponent = null, data:Object = null, mv:Boolean = true):void {
         super(vg, node, id, view, data, mv);
      }
      public function reposition():void {
         _moveNotifier.afterMove();
      }
      public function notifyInMove(effect:Move):void {
         if (view) {
            if (viewX != effect.xTo || viewY != effect.yTo)
               effect.addEventListener(EffectEvent.EFFECT_END, endMoveListener);
            _isMoving=true;
            var prb:PearlRendererBase = view as PearlRendererBase;
            if (prb) {
               prb.refresh();  
            }
         } 
      }
      override public function set view(v:UIComponent):void {
         if (view != v) {
            if (_viewNotifier) {
               _viewNotifier.removeMoveListener(this);
            }
            if (v && v is IUIPearl) {
               _viewNotifier =  IUIPearl(v).moveNotifier;
               _viewNotifier.addMoveListener(this);
            }
         }
         super.view = v;
      }
      
      public function get pearlView():IUIPearl {
         return view as IUIPearl;
      }
      
      public function get moveNotifier():MoveNotifier{
         return _moveNotifier;
      }
      
      private function endMoveListener(event:Event):void {
         var effect:Effect = event.target as Effect;
         var prb:PearlRendererBase = view as PearlRendererBase;
         _isMoving =false;
         moveNotifier.afterMove();
         if (prb) {
            prb.refresh();  
         }
         if (effect){ 
            effect.removeEventListener(EffectEvent.EFFECT_END, endMoveListener);
         }
      }
      public function set isMoving (value:Boolean):void
      {
         _isMoving = value;
      }
      
      public function get isMoving ():Boolean
      {
         return _isMoving;
      }
      override public function get viewCenter():Point {
         return pearlView.pearlCenter;
      }	
      override public function set viewX(n:Number):void {
         if (_isCommiting) {
            _targetToMoveToX =n;
         } else {
            super.viewX=n;
         }
      }
      
      public override function set viewY(n:Number):void {
         if (_isCommiting) {
            _targetToMoveToY =n;
         } else {
            super.viewY=n;
         }
      }       
      
      public override function commit():void {
         try {
            _isCommiting=false;
            var pearlXOffset:Number = pearlView.pearlCenter.x - pearlView.x;
            var pearlYOffset:Number = pearlView.pearlCenter.y - pearlView.y;	        	
            this.view .move(x - pearlXOffset, y - pearlYOffset);
         } finally {
            _isCommiting =false;
         }
      }
      
      override public function refresh():void {
         if(centered && (view is PearlRendererBase)){ 
            x = pearlView.pearlCenter.x;
            y = pearlView.pearlCenter.y;
         }else{
            super.refresh();
         }
      }       
      public function get ptNode():IPTNode {
         return node as IPTNode;
      }
      public function set isExcited(isExcitedV:Boolean):void {
         if (_excitedState != isExcitedV) {
            _excitedState = isExcitedV;
            pearlView.invalidateProperties();
         }   
         
      }
      public function get isExcited():Boolean {
         return _excitedState;
      }
      
      public function get distanceToClosestBrother():Number
      {
         return _distanceToClosestBrother;
      }
      
      public function set distanceToClosestBrother(value:Number):void
      {
         _distanceToClosestBrother = value;
      }

   }
}