package com.broceliand.ui.effects
{

   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.effects.EffectInstance;
   import mx.effects.IEffectInstance;
   import mx.effects.effectClasses.CompositeEffectInstance;
   import mx.effects.effectClasses.RotateInstance;
   
   use namespace mx_internal;

   public class ParallelFixedInstance extends CompositeEffectInstance
   {
      private var finishEffectCalled:Boolean = false;
      
      public function ParallelFixedInstance(target:Object)
      {
         super(target);
      }
      
      private var doneEffectQueue:Array /* of EffectInstance */;

      private var replayEffectQueue:Array /* of EffectInstance */;

      private var isReversed:Boolean = false;	

      private var timer:Timer;

      override mx_internal function get durationWithoutRepeat():Number
      {
         var _duration:Number = 0;

         var n:int = childSets.length;
         for (var i:int = 0; i < n; i++)
         {
            var instances:Array = childSets[i];
            _duration = Math.max(instances[0].actualDuration, _duration);
         }
         
         return _duration;
      }
      
      override public function addChildSet(childSet:Array):void
      {
         super.addChildSet(childSet);
         if (childSet.length > 0)
         {
            var compChild:CompositeEffectInstance = childSet[0] as CompositeEffectInstance;

            if (childSet[0] is RotateInstance || (compChild != null && compChild.hasRotateInstance()))
            {
               childSets.pop();
               childSets.unshift(childSet);
            }
         }
      }

      override public function play():void
      {
         doneEffectQueue = [];
         activeEffectQueue = [];
         replayEffectQueue = [];

         super.play();
         
         var n:int;
         var i:int;
         
         n = childSets.length;
         for (i = 0; i < n; i++)
         {
            var instances:Array = childSets[i];
            
            var m:int = instances.length;
            for (var j:int = 0; j < m && activeEffectQueue != null; j++)
            {
               var childEffect:EffectInstance = instances[j];

               if (playReversed &&
                  childEffect.actualDuration < durationWithoutRepeat)
               {
                  replayEffectQueue.push(childEffect);
                  startTimer();
               }
               else
               {
                  childEffect.playReversed = playReversed;
                  activeEffectQueue.push(childEffect);
               }

               if (childEffect.suspendBackgroundProcessing)
                  UIComponent.suspendBackgroundProcessing();		
               
            }		
         }
         
         if (activeEffectQueue.length > 0)
         {

            var queueCopy:Array = activeEffectQueue.slice(0);
            
            for (i = 0; i < queueCopy.length; i++)
            {
               queueCopy[i].startEffect();
            }
         }
      }

      override public function pause():void
      {	
         super.pause();

         var n:int = activeEffectQueue.length;
         for (var i:int = 0; i < n; i++)
         {
            activeEffectQueue[i].pause();
         }
      }

      override public function stop():void
      {
         stopTimer();
         
         if (activeEffectQueue)
         {
            var queueCopy:Array = activeEffectQueue.concat();
            activeEffectQueue = null;
            var n:int = queueCopy.length;
            for (var i:int = 0; i < n; i++)
            {
               if (queueCopy[i])
                  queueCopy[i].stop();
            }
         }
         
         super.stop();
      }

      override public function resume():void
      {
         super.resume();

         var n:int = activeEffectQueue.length;
         for (var i:int = 0; i < n; i++)
         {
            activeEffectQueue[i].resume();
         }
      }

      override public function reverse():void
      {
         
         super.reverse();
         
         var n:int;
         var i:int;
         
         if (isReversed)
         {

            n = activeEffectQueue.length;
            for (i = 0; i < n; i++)
            {
               activeEffectQueue[i].reverse();
            } 
            
            stopTimer();
         }
         else
         {
            replayEffectQueue = doneEffectQueue.splice(0);

            n = activeEffectQueue.length;
            for (i = 0; i < n; i++)
            {
               activeEffectQueue[i].reverse();
            } 
            
            startTimer();
         }
         
         isReversed = !isReversed;
      }

      override public function end():void
      {
         endEffectCalled = true;
         stopTimer();
         
         if (activeEffectQueue)
         {
            var queueCopy:Array = activeEffectQueue.concat();
            activeEffectQueue = null;
            var n:int = queueCopy.length;
            for (var i:int = 0; i < n; i++)
            {
               if (queueCopy[i])
                  queueCopy[i].end();
            }
         }
         
         super.end();
      }

      override protected function onEffectEnd(childEffect:IEffectInstance):void
      {
         if (Object(childEffect).suspendBackgroundProcessing)
            UIComponent.resumeBackgroundProcessing();

         if (endEffectCalled || activeEffectQueue == null)
            return;
         
         var n:int = activeEffectQueue.length;	
         for (var i:int = 0; i < n; i++)
         {
            if (childEffect == activeEffectQueue[i])
            {
               doneEffectQueue.push(childEffect);
               activeEffectQueue.splice(i, 1);
               break;
            }
         }	
         
         if (n == 1)
         {
            finishRepeat();
         }
      }

      private function startTimer():void
      {
         if (!timer)
         {
            timer = new Timer(10);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
         }
         timer.start();
      }
      
      private function stopTimer():void
      {
         if (timer)
            timer.reset();
      }

      private function timerHandler(event:TimerEvent):void
      {
         var position:Number = durationWithoutRepeat - playheadTime;
         var numDone:int = replayEffectQueue.length;	
         
         if(finishEffectCalled){
            return;
         }
         if (numDone == 0)
         {
            stopTimer();
            return;
         }
         
         for (var i:int = numDone - 1; i >= 0; i--)
         {
            var childEffect:EffectInstance = replayEffectQueue[i];
            
            if (position <= childEffect.actualDuration)
            {
               
               activeEffectQueue.push(childEffect);
               replayEffectQueue.splice(i,1);
               
               childEffect.playReversed =playReversed;
               childEffect.startEffect();
            }
         }
         
      }
      override public function finishEffect():void
      {
         finishEffectCalled = true;
         super.finishEffect();
      }
      
   }
}
