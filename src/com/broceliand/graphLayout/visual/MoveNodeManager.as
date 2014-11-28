package com.broceliand.graphLayout.visual
{
   import com.broceliand.ui.effects.MoveWithScroll;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.util.logging.Log;
   
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   import mx.core.UIComponent;
   import mx.effects.Move;
   import mx.events.TweenEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class MoveNodeManager
   {
      private var _view2Move:Dictionary  = new Dictionary();
      private var _vgraph:IVisualGraph;
      public function MoveNodeManager(vgraph:IVisualGraph)	{
         _vgraph = vgraph;
      }
      public function playMoveEffectOnNode(target:IVisualNode, x:Number, y:Number, duration:int, play:Boolean) :Move{
         var m:MoveWithScroll = _view2Move[target.view] ; 
         if (m!=null) {
            m.stop();
         } else {
            m= new MoveWithScroll(target.view);
            m.duration=duration;
            if (x== Math.floor(target.view.x) && y== Math.floor(target.view.y)){
               return m;
            }
            m.addEventListener(TweenEvent.TWEEN_END, unregister);
            
            addToView2Move(target.view, m);
            
         }
         m.xTo = x;
         m.yTo = y;
         if (play)
            m.play();
         return m;    
      }

      private function unregister(event:Event):void {
         var m:Move = Move(event.currentTarget);
         m.removeEventListener(TweenEvent.TWEEN_END, unregister);
         removeFromView2Move(m.target);
      }
      
      public function isView2MoveEmpty():Boolean{
         for each(var obj:Object in _view2Move){
            return false;
         }
         return true;
      }
      
      private function addToView2Move(view:UIComponent, move:Move):void{
         _view2Move[view] = move;
      }
      
      private function removeFromView2Move(key:Object):void{
         delete _view2Move[key];   
      }
   }
}