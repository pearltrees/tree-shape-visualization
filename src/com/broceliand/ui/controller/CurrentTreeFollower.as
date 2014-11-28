package com.broceliand.ui.controller
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroLink;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;

   public class CurrentTreeFollower
   {
      private var _myWorld:BroPearlTree;
      private var _currentTreeRef:BroPTNode;
      private var _timer :Timer;
      public function CurrentTreeFollower(myWorld:BroPearlTree, nodeToFollow:BroLocalTreeRefNode=null) 
      {
         _myWorld = myWorld;
         if (nodeToFollow) {
            _currentTreeRef = nodeToFollow;
         } else {
            _currentTreeRef = getLastNode();
         }
         if (_currentTreeRef is BroLocalTreeRefNode) {
            _timer = new Timer(1000);
            _timer.addEventListener(TimerEvent.TIMER, checkCurrentTree);
            _timer.start();
         } 
      }

      private function getLastNode():BroPTNode {
         var node:BroPTNode = _myWorld.getRootNode();
         while (node.childLinks.length>0) {

            node = BroLink(node.childLinks[0]).toPTNode;
         }
         return node;
      }
      private  function isLastNodeTheSame():Boolean {
         
         if (getLastNode()== _currentTreeRef) {
            return true;
         }
         return false;
         
      }
      
      public function checkCurrentTree(event:Event):void {
         if (!isLastNodeTheSame()) {
            _timer.stop();
            ApplicationManager.getInstance().distantServices.stopCurrentHistoryOnce();
         }
      }

   }
}