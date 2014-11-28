package com.broceliand.ui.renderers.pageRenderers.pearl{

   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.view.IUIPearlView;
   import com.broceliand.util.GenericAction;
   import com.broceliand.util.resources.ImageFactory;
   
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.containers.Canvas;
   import mx.controls.Image;
   import mx.core.FlexSprite;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;
   import mx.skins.halo.HaloBorder;

   public class PearlBase extends Canvas implements IUIPearlView {
      
      static public const NORMAL_STATE:int =0;
      static public const OVER_STATE:int =1;
      static public const SELECTED_STATE:int =2;
      
      private var _scale:Number = 1;
      protected var _isWarmedHighlighted:Boolean= false;
      protected var _state:int = NORMAL_STATE;
      protected var _normalState:UIComponent;

      private var _selectedForeground:Image;
      private var _overForeground:Image;

      protected var _pearlWidth:Number;
      private var _markAsDisappearing:Boolean;
      private  var _pearlWidthChanged:Boolean;
      private var _inSelection:Boolean = true;
      private var _maskSprite :Sprite;

      public var _colorRing:PearlRing= null;
      protected var _node:IPTNode;
      protected var _pearlNotificationState:PearlNotificationState = new PearlNotificationState();
      protected var _background:UIComponent = null;
      protected var _pearlCenterPoint:Point;
      protected var _titleCenterPoint:Point;      
      protected var _isParentInLayout:Boolean = true;
      protected var _mask:UIComponent = null;
      protected var _nodeChanged:Boolean = false;
      
      public function PearlBase():void {
         _colorRing = new PearlRing(this);
         clipContent = false;
      } 
      
      public function get pearlCenter():Point {
         if(!_pearlCenterPoint) _pearlCenterPoint = new Point();
         if (width) {
            _pearlCenterPoint.x = x + scaleX * width/ 2.0;
            _pearlCenterPoint.y = y + scaleY * height/ 2.0;
         } else {
            _pearlCenterPoint.x = x + scaleX * excitedWidth /2.0;
            _pearlCenterPoint.y = y + scaleY * excitedWidth /2.0;
         }
         return _pearlCenterPoint;
      }
      
      public function get titleCenter():Point {
         if(!_titleCenterPoint) _titleCenterPoint = new Point();         
         
         _titleCenterPoint.x = pearlCenter.x;
         _titleCenterPoint.y = pearlCenter.y + scaleY * excitedWidth / 2.0 + titleMarginTop;
         return _titleCenterPoint;
      }
      
      protected function get titleMarginTop():Number {
         return 0;
      }
      
      public function get pearlWidth():Number {
         return _pearlWidth;
      }
      
      private function setPearlWidth(newWidth:Number):void {
         if (_pearlWidth != newWidth) {
            _pearlWidth = newWidth;
            _pearlWidthChanged = true;
            invalidateProperties();
         }
      }
      
      protected function get excitedWidth():Number {
         return 0;
      }
      
      protected function get normalWidth():Number {
         return 0;
      }
      
      override protected function createChildren():void {
         super.createChildren();
         clipContent = false;
         mouseChildren = false;
         showRings = false;
         addEventListener(FlexEvent.CREATION_COMPLETE, addRing);
         
         ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.ringLayer.addChild(_colorRing);
         
         _normalState = makeNormalState();
         addChild(_normalState);

         _overForeground = makeForegroundImage(OVER_STATE, _normalState);
         _selectedForeground = makeForegroundImage(SELECTED_STATE, _normalState);
         updtateVisibleState();
      }
      private function addRing(event:Event):void  {
         if (_colorRing) { 
            showRings = true;
         }
      } 

      protected function createBlackMask():void {
         if(!_mask) {
            _mask = new UIComponent();
            _mask.graphics.clear();
            _mask.graphics.beginFill(0x000000);
            _mask.graphics.drawCircle(excitedWidth / 2.0, excitedWidth / 2.0, excitedWidth / 2.0 - 1);
            _mask.graphics.endFill();
            _mask.visible = false;
            addChild(_mask);
         }
      }
      
      protected function createWhiteBackground(width:Number):UIComponent{
         var whiteBackground:UIComponent = new UIComponent();
         var g:Graphics = whiteBackground.graphics;
         g.clear();
         g.beginFill(0xFFFFFF);
         g.drawCircle(width/ 2.0, width / 2.0, width/ 2.0 - 2);
         g.endFill();
         return whiteBackground;
      }
      
      public function warm():void{
         setState(OVER_STATE);
      }
      public function unwarm():void{
         setState(NORMAL_STATE);
      }
      
      public function warmRing(useAnim:Boolean = true):void{
      }
      public function unwarmRing(useAnim:Boolean = true):void{
      }     
      
      public function blacken():void {
         if(!_mask) {
            createBlackMask();
         }
         showRings=false;
         _mask.visible = true;
      }
      
      public function unblacken():void {
         if(_mask) {
            _mask.visible = false;
            showRings=true;
         }
      }
      public function set markAsDisappearing (value:Boolean):void
      {
         _markAsDisappearing = value;
      }
      
      public function get markAsDisappearing ():Boolean
      {
         return _markAsDisappearing;
      }
      
      public function warmNoteRing():void{
         _colorRing.warmNoteRing();
      } 
      
      public function unwarmNoteRing():void{
         _colorRing.unwarmNoteRing();
      }   
      
      public function defaultNoteRing():void{
         _colorRing.defaultNoteRing();
      }
      
      public function warmNeighbourRing():void{
         _colorRing.warmNeighbourRing();
      }
      
      public function unwarmNeighbourRing():void{
         _colorRing.unwarmNeighbourRing();
      }
      
      public function defaultNeighbourRing():void{
         _colorRing.defaultNeighbourRing();
      }
      
      public function get node():IPTNode {
         return _node;
      }
      public function set node(value:IPTNode):void {
         if (_node != value) {
            if (_node !=null) {
               _nodeChanged = true;
               refreshAvatar();
               invalidateProperties();
            }
            _node = value;
            _colorRing.listenToNode(value);
         }
      }
      override protected function commitProperties():void{
         super.commitProperties();
         _colorRing.commitRingsProperties(_pearlWidthChanged);
         if (_pearlWidthChanged) {
            _pearlWidthChanged =false;
         }
         if (_nodeChanged) {
            _nodeChanged = false;
            updateOnNodeChanged();
         }
      }
      public function end():void {
         callLater(clearMemory); 
      }
      protected function updateOnNodeChanged():void {
         
      }
      
      protected function clearMemory():void {
         removeAllChildren();
         _mask = null;
         _node = null;
         _colorRing.clearMemory();
         _colorRing = null;
         
         _selectedForeground = _overForeground = null;
         _normalState = null;
      }
      
      public function refreshAvatar():void{
         
      }
      
      public function refreshLogo():void{
         
      }
      
      public function get showRings():Boolean {
         return _colorRing.showRings;
      }
      
      public function set showRings(value:Boolean):void {
         if (_mask && _mask.visible) {
            value =false;
         }
         if (markAsDisappearing) {
            value = false;
         }
         _colorRing.showRings = value;
      }
      
      public function set canRingBeVisible(value:Boolean):void {
         _colorRing.canRingBeVisible = value;
      }
      
      public static function getPearlRendererUnderPoint(point:Point):IUIPearl {                          
         if(!ApplicationManager.flexApplication.stage){
            return null;
         }        
         
         var pearlUnderPoint:IUIPearl = null; 
         var objUnderPoint:DisplayObject = null;
         var objParent:DisplayObjectContainer = null;
         
         var objectsUnderPoint:Array = ApplicationManager.flexApplication.stage.getObjectsUnderPoint(point);

         for each(objUnderPoint in objectsUnderPoint) {
            if (objUnderPoint is UIComponent && (objUnderPoint.name == GeometricalConstants.PEARL_CLOSE_BUTTON_MASK_NAME  || objUnderPoint.name == GeometricalConstants.PEARL_NEWS_BUTTON_MASK_NAME)) {
               objParent = objUnderPoint.parent;
               while(objParent) {
                  if(objParent is IUIPearl) {
                     pearlUnderPoint = objParent as IUIPearl;
                     break;
                  }
                  objParent = objParent.parent;
               }
            }
            if(pearlUnderPoint) break;
         }
         
         if(!pearlUnderPoint) {
            for (var i:int = objectsUnderPoint.length ; i-->0;) {
               objUnderPoint = objectsUnderPoint[i];
               
               if((objUnderPoint is HaloBorder) || (objUnderPoint is FlexSprite)) {
                  continue;
               }            

               objParent = objUnderPoint.parent;
               while(objParent) {
                  if(objParent is IUIPearl) {
                     var renderer:IUIPearl = objParent as IUIPearl;
                     if(renderer && renderer.isPointOnPearlOrAddon(point)) {                     
                        pearlUnderPoint = renderer;
                        break;
                     }
                  }
                  objParent = objParent.parent;
               }
               if(pearlUnderPoint) break;
            }
         }
         
         if(pearlUnderPoint && pearlUnderPoint.node is EndNode && !EndNode(pearlUnderPoint.node).canBeVisible) {
            return null;
         }
         return pearlUnderPoint;     
      }
      
      override public function set visible(value:Boolean):void {
         super.visible = value;
         _colorRing.visible = value;
      }
      public function moveRingInPearl():void {
         _colorRing.moveRingInPearl();
      }
      public function moveRingOutPearl():void {
         _colorRing.moveRingOutPearl();
      }
      public function repositionRing():void {
         _colorRing.reposition()
      }
      public function get pearlNotificationState():PearlNotificationState {
         return _pearlNotificationState;
         
      }
      
      private function setState(state:int):void {
         if (_state != state) {
            _state = state; 
            updtateVisibleState();
         }
      } 
      
      protected function updtateVisibleState():void {
         var selectedStateVisbile:Boolean = (state ==  NORMAL_STATE && _inSelection); 
         if (!_selectedForeground && selectedStateVisbile) {
            _selectedForeground = makeForegroundImage(SELECTED_STATE, _selectedForeground);
            _selectedForeground.visible = true;
            _selectedForeground.addEventListener(FlexEvent.UPDATE_COMPLETE, new GenericAction(null, this, updtateVisibleState).performActionOnFirstEvent);
            return;
         }
         if (_selectedForeground) {
            _selectedForeground.visible = selectedStateVisbile;
         } 
         
         _overForeground.visible = (state ==  OVER_STATE);
         setPearlWidth((state == OVER_STATE)? excitedWidth : normalWidth); 
      }
      
      protected function get state():int {
         return _state;
      }
      
      protected function makeNormalState():UIComponent {
         return makeBasicState(normalWidth);
      }
      
      protected function makeForegroundImage(state:int, basePearl:UIComponent):Image {
         var foregroundImage:Image = ImageFactory.newImage();
         foregroundImage.smoothBitmapContent=true;

         if (state == OVER_STATE) {
            foregroundImage.source = getForegroundOverAsset();
         } else {
            foregroundImage.source = getForegroundSelectedAsset();
         }
         foregroundImage.width = basePearl.width;
         foregroundImage.height = basePearl.height;
         basePearl.addChild(foregroundImage);
         return foregroundImage;
      }

      protected function getForegroundOverAsset():Class {
         return null;
      }
      protected function getForegroundSelectedAsset():Class {
         return null;
      }
      
      private function makeBasicState(size:Number):UIComponent {
         var normalState:UIComponent  = new UIComponent();
         normalState.width = normalState.height = size;
         normalState.x = normalState.y = (excitedWidth-size)/2;
         var whiteBackground:UIComponent = createWhiteBackground(size); 
         if (whiteBackground) {
            normalState.addChild(whiteBackground);
         }
         return normalState;   
      }
      
      public function setInSelection(value:Boolean):void {
         
         value = true;
         if (_inSelection != value ){
            _inSelection = value;
            updtateVisibleState();
         }
      }
      
      public function isInSelection():Boolean {
         return _inSelection;
      }
      
      public function restoreInitialState():void {
         _markAsDisappearing = false;
         _isWarmedHighlighted = false;
         _state = NORMAL_STATE;
         _inSelection = false;
         unblacken();
         _colorRing.restoreInitialState();
      }
      
      public function get scale():Number {
         return _scale;
      }
      public function setScale(value:Number):void {
         _scale = value;
      }

      public function getPearlVisibleWidth():Number {
         return pearlWidth;  
      }
      
      protected function makeAndAddMask(img:UIComponent):void {
         if (_maskSprite == null) {
            _maskSprite = new Sprite();
            img.mask = _maskSprite;
            img.addChild(_maskSprite);
            updateMask(img);
         }
      }
      
      protected function removeMask(img:UIComponent):void {
         if (_maskSprite !=null) {
            img.mask == null;
            img.removeChild(_maskSprite);
            _maskSprite = null;
         } 
      }
      
      protected function updateMask(img:UIComponent):void {
         if (_maskSprite) {
            var radius:Number = img.width  /2;
            var g:Graphics = _maskSprite.graphics;
            g.clear();
            g.beginFill(0xff0000);
            g.drawCircle(radius, radius, radius);
            g.endFill();
         }
      }
   }
}

