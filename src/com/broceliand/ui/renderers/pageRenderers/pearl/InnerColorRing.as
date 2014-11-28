package com.broceliand.ui.renderers.pageRenderers.pearl
{  
   import com.broceliand.pearlTree.model.BroPTNode;
   
   import flash.display.Graphics;
   
   public class InnerColorRing extends ColorRing
   {
      
      private var _pearl:PearlBase;
      
      public function InnerColorRing(pearl:PearlBase)
      {
         _pearl = pearl;
      }
      
      override protected function getPearlRadius():Number {
         return _pearl.pearlWidth/2.0;
      }
      
      override  protected function getPearlCenterX():Number {
         return _pearl.width/2.0;
      }
      
      override protected function drawNeighbourRing():void {
         var g:Graphics = _neighbourRing.graphics;  
         g.clear();
         if(getPearlRadius()> 0 && _neighbourRingThickNess > 0) {
            var ringThickness:Number = _neighbourRingThickNess;
            g.lineStyle(ringThickness + 5, 0X0000FF);
            var pearlRadius:Number = getPearlRadius() - ringThickness/2;            
            g.drawCircle(getPearlCenterX(), getPearlCenterX(), pearlRadius);
         }
         g.endFill();
      }
      
      override protected function drawNoteRing():void {
         var g:Graphics = _noteRing.graphics;
         g.clear();
         if(getPearlRadius()> 0 && _noteRingThickNess > 0) {
            var ringThickness:Number = _noteRingThickNess;
            g.lineStyle(ringThickness + 5 , 0XFF0000);
            var pearlRadius:Number = getPearlRadius()- ringThickness/2;            
            g.drawCircle(getPearlCenterX(), getPearlCenterX(), pearlRadius);
         }
         g.endFill();
      }
      
      override protected function get noteCount():Number{
         var count:Number = super.noteCount;
         if (count == 0 && _pearl.pearlNotificationState.notifyingNewNote) {
            count = 1;
         }
         return count;
      }
      
      override protected function get neighbourCount():Number {
         var count:Number = super.neighbourCount;
         if (count == 0 && _pearl.pearlNotificationState.notifyingNewCross) {
            count = 1;
         }  
         return count;
      }
      
      public function commitRingsProperties():void {
         if (_pearl.width ==0) {
            
            return;
         }
         if (processedDescriptors) {
            super.commitColorRingsProperties(true);
         } 
      }
      
      override protected function get node():BroPTNode {
         if(_pearl.node) {
            return _pearl.node.getBusinessNode();
         }
         else{
            return null;
         }
      }
      
      override protected function get showNeighbourRing():Boolean {
         return true;

      }
      
      override protected function get showNoteRing():Boolean {
         return true; 
         
      }      
   }
}