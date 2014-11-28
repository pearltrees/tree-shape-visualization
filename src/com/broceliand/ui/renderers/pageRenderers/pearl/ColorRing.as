package com.broceliand.ui.renderers.pageRenderers.pearl
{
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.util.ColorPalette;
   
   import flash.display.Graphics;
   import flash.geom.ColorTransform;
   
   import mx.core.UIComponent;
   import mx.managers.ISystemManager;
   
   public class ColorRing extends UIComponent 
   {
      protected var _noteRing:UIComponent = null;
      protected var _neighbourRing:UIComponent = null;
      private var _showRings:Boolean = true;
      private var _showRingsChanged:Boolean = true;
      protected var _noteRingThickNess:Number;
      protected var _neighbourRingThickNess:Number;
      private var _canRingBeVisible:Boolean = true;
      protected static const MIN_RING_THICKNESS:Number = 1;
      protected static const MAX_RING_THICKNESS:Number = 5;
      
      protected static const RING_THICKNESS_ADJUSTMENT_LOG:Number = 6;
      
      protected static const RING_THICKNESS_ADJUSTMENT_LOG_NOTES:Number = 6;
      protected static const RING_THICKNESS_ADJUSTMENT_LOG_PICKS:Number = 7;
      
      protected static var NOTE_RING_COLOR:Number;
      protected static var NOTE_RING_NOTIFIED_COLOR:Number;
      protected static var NOTE_RING_NOTIFIED_COLOR_2:Number;
      
      protected static var NEIGHBOUR_RING_COLOR:Number;
      protected static var NEIGHBOUR_RING_NOTIFIED_COLOR:Number;
      protected static var NEIGHBOUR_RING_NOTIFIED_COLOR_2:Number;
      
      public function ColorRing()
      {
         NOTE_RING_COLOR = ColorPalette.getInstance().noteColor;
         NOTE_RING_NOTIFIED_COLOR = ColorPalette.getInstance().noteLightColor;
         NOTE_RING_NOTIFIED_COLOR_2 = ColorPalette.getInstance().noteDarkColor;
         
         NEIGHBOUR_RING_COLOR = ColorPalette.getInstance().connectionColor;
         NEIGHBOUR_RING_NOTIFIED_COLOR = ColorPalette.getInstance().connectionLightColor;
         NEIGHBOUR_RING_NOTIFIED_COLOR_2 = ColorPalette.getInstance().connectionDarkColor;         
      }
      
      override protected function createChildren():void {
         super.createChildren(); 
         
         _noteRing = new UIComponent();
         addChild(_noteRing);
         
         _neighbourRing = new UIComponent();
         addChild(_neighbourRing);
      }
      public function hasRings():Boolean {
         return _neighbourRingThickNess>0 || _noteRingThickNess>0;
      }
      public function warmNoteRing():void{

         if (_noteRing)
            _noteRing.transform.colorTransform = new ColorTransform(0, 0, 0, 1, NOTE_RING_NOTIFIED_COLOR_2 >> 16, (NOTE_RING_NOTIFIED_COLOR_2  >> 8)& 0xFF, NOTE_RING_NOTIFIED_COLOR_2 & 0x0000FF, 0);
      }    
      public function unwarmNoteRing():void{
         if (_noteRing)
            _noteRing.transform.colorTransform = new ColorTransform(0, 0, 0, 1, NOTE_RING_NOTIFIED_COLOR >> 16, (NOTE_RING_NOTIFIED_COLOR  >> 8)& 0xFF, NOTE_RING_NOTIFIED_COLOR & 0x0000FF, 0);
      }     
      public function defaultNoteRing():void{
         if (_noteRing)
            _noteRing.transform.colorTransform = new ColorTransform(0, 0, 0, 1, NOTE_RING_COLOR >> 16, (NOTE_RING_COLOR  >> 8)& 0xFF, NOTE_RING_COLOR & 0x0000FF, 0);
      }      
      
      public function warmNeighbourRing():void{ 
         if (_neighbourRing)
            _neighbourRing.transform.colorTransform = new ColorTransform(0, 0, 0, 1, NEIGHBOUR_RING_NOTIFIED_COLOR_2 >> 16, (NEIGHBOUR_RING_NOTIFIED_COLOR_2  >> 8)& 0xFF, NEIGHBOUR_RING_NOTIFIED_COLOR_2 & 0x0000FF, 0);
      } 
      public function unwarmNeighbourRing():void{ 
         if (_neighbourRing)
            _neighbourRing.transform.colorTransform = new ColorTransform(0, 0, 0, 1, NEIGHBOUR_RING_NOTIFIED_COLOR >> 16, (NEIGHBOUR_RING_NOTIFIED_COLOR  >> 8)& 0xFF, NEIGHBOUR_RING_NOTIFIED_COLOR & 0x0000FF, 0);
      }      
      public function defaultNeighbourRing():void{ 
         if (_neighbourRing)
            _neighbourRing.transform.colorTransform = new ColorTransform(0, 0, 0, 1, NEIGHBOUR_RING_COLOR >> 16, (NEIGHBOUR_RING_COLOR  >> 8)& 0xFF, NEIGHBOUR_RING_COLOR & 0x0000FF, 0);
      }  
      protected function getPearlRadius():Number { 
         return 0; 
      }   
      protected function getPearlCenterX():Number { 
         return 0; 
      } 
      
      protected function drawNoteRing():void {
         var g:Graphics = _noteRing.graphics;
         g.clear();
         if(getPearlRadius()> 0 && _noteRingThickNess > 0) {
            g.beginFill(NOTE_RING_COLOR);
            var pearlRadius:Number = getPearlCenterX();
            var noteRingRadius:Number = getPearlRadius()+
               _neighbourRingThickNess +  
               _noteRingThickNess;
            g.drawCircle(pearlRadius, pearlRadius, noteRingRadius);
         }
         g.endFill();
      }
      
      protected function drawNeighbourRing():void {
         var g:Graphics = _neighbourRing.graphics;
         g.clear();
         if(getPearlRadius()> 0 && _neighbourRingThickNess > 0) {
            g.beginFill(NEIGHBOUR_RING_COLOR);
            var pearlRadius:Number = getPearlCenterX();
            var neighbourRingRadius:Number = getPearlRadius()+ 
               _neighbourRingThickNess;
            g.drawCircle(pearlRadius, pearlRadius, neighbourRingRadius);
         }
         g.endFill();
      }
      
      protected function neighbourRingThickNessChanged():Boolean {
         return (_neighbourRingThickNess != getNeighbourRingThickNess());
      }
      
      protected function noteRingThickNessChanged():Boolean {
         return (_noteRingThickNess != getNoteRingThickNess());
      }
      
      protected function get node():BroPTNode {
         return null;
      }
      
      protected function get showNoteRing():Boolean {
         return false;
      }
      
      protected function get showNeighbourRing():Boolean {
         return false;
      }
      
      protected function get noteCount():Number {
         var count:Number = (node)?node.noteCount:0;
         return (count < 0)?0:count;
      }
      protected function get neighbourCount():Number {
         var count:Number = (node)?node.neighbourCount:0;
         return (count < 0)?0:count;
      }
      
      private function getNoteRingThickNess():uint {
         if(showNoteRing) {
            return getRingThickNessFromCount(noteCount, RING_THICKNESS_ADJUSTMENT_LOG_NOTES);
         }
         else{
            return 0;
         }
      }      
      
      private function getNeighbourRingThickNess():uint {
         if(showNeighbourRing) {       
            return getRingThickNessFromCount(neighbourCount, RING_THICKNESS_ADJUSTMENT_LOG_PICKS);
         }else{
            return 0;
         }
      }
      
      protected function getRingThickNessFromCount(count:uint, adjustementValue:Number = RING_THICKNESS_ADJUSTMENT_LOG):uint{
         var ringThickness:int = 0;
         const epsilon:Number = 0.000001;
         if (count > 0) {
            var countLog:Number = Math.log(count - epsilon);
            var adjustmentLog:Number = Math.log(adjustementValue);
            var intermediate:Number = (countLog / adjustmentLog) + MIN_RING_THICKNESS;
            
            if(intermediate < MIN_RING_THICKNESS) {
               intermediate = MIN_RING_THICKNESS;
            }
            ringThickness = Math.floor(Math.min(intermediate, MAX_RING_THICKNESS));
         }
         return ringThickness;
      }
      
      protected function commitColorRingsProperties(zoomChanged:Boolean):void {        
         if(_showRingsChanged) {
            _showRingsChanged = false; 
            _neighbourRing.visible = _showRings && _canRingBeVisible;
            _noteRing.visible = _showRings && _canRingBeVisible;
         }
         
         var neighbourRingChanged:Boolean = neighbourRingThickNessChanged() || zoomChanged;
         var noteRingChanged:Boolean = noteRingThickNessChanged() || zoomChanged;
         
         if(neighbourRingChanged){
            _neighbourRingThickNess = getNeighbourRingThickNess();
            drawNeighbourRing();
         }     
         if(noteRingChanged || neighbourRingChanged) {
            _noteRingThickNess = getNoteRingThickNess();  
            drawNoteRing();
         }
         var hasRing:Boolean = (_neighbourRingThickNess >0 )|| (_noteRingThickNess > 0);
         hasRing = hasRing && _showRings;

      }
      
      public function get showRings():Boolean {
         return _showRings;
      }
      
      public function set canRingBeVisible(value:Boolean):void {
         if (_canRingBeVisible != value) {
            _canRingBeVisible = value;
            if (_showRings) {
               _showRingsChanged = true;
               invalidateProperties()
            }
         }
      }
      public function set showRings(value:Boolean):void {
         if(_showRings != value){
            _showRings = value;
            _showRingsChanged = true;
            invalidateProperties();
         }
      }
      public function restoreInitialState():void { 
         _showRings = true;
         _showRingsChanged = true;
         _canRingBeVisible = true;
      }
      
   }
}