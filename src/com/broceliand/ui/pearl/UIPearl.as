package com.broceliand.ui.pearl
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.view.IUIPearlView;
   import com.broceliand.ui.pearlBar.deck.Deck;
   import com.broceliand.ui.pearlTree.NewsLabel;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererBase;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PTRootPearl;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.util.MoveOnValidation;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.controls.Image;
   import mx.events.PropertyChangeEvent;

   public class UIPearl extends PearlRendererBase implements IUIPearl
   {
      
      public static const MAX_PEARL_WIDTH:Number = PTRootPearl.PEARL_WIDTH_EXCITED;
      public static const WILL_MOVE_EVENT:String= "willMoveEvent";
      
      private static const _MousePoint:Point = new Point();
      protected var _pearlCenterPoint:Point;
      protected var _titleCenterPoint:Point;
      private var _moveOnValidation:MoveOnValidation;
      
      private var _shouldCommitProperties:Boolean = false;
      
      private var _newLabel:PearlNewsConnector;
      private var _newLabelInSelection:Boolean;
      private var _positionWithoutZoom:Point;
      private var _hasNotificationsForNewLabel:Boolean;
      private var _doNotMarkNewLabelSeenAtNextEvent:Boolean = false;
      private var _newLabelSeen:Boolean;
      private var _isMouveOver:Boolean;
      private var _scale:Number;
      private var _isMovingTakingAccountOffset:Boolean;
      private var _padlockImage:Image;
      private var _wasActive:Boolean;
      
      override public function set mask(value:DisplayObject):void {
         if(value != mask) {
            super.mask = value;
         }
      }
      
      public function UIPearl(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager)
      {
         super(stateManager, remoteResourceManager);
         
         _moveOnValidation = new MoveOnValidation(this);
         _hasNotificationsForNewLabel = false;
         
         clipContent = false;
         _positionWithoutZoom = new Point();
      }
      
      override protected function createChildren():void {
         
         super.createChildren();
         _pearl.setScale(getScale());
      }

      public function isPointOnPearlOrAddon(point:Point):Boolean {
         if (super.isPointOnPearl(point)) {
            return true;

         }
         else if (_newLabel) {
            return _newLabel.isPointOnComponentAddOn(point);
         }
         else {
            return false;
         }

      }
      override protected function commitProperties():void {
         commitMove();
         if (_nodeChanged) {
            _isMouveOver = false;
         }
         if (_shouldCommitProperties) {
            super.commitProperties();
            _shouldCommitProperties = false;
         }
      }
      
      public function markHasNotificationsForNewLabel(value:Boolean):void {
         _hasNotificationsForNewLabel = value;
         refreshNewLabelVisibility();
      }
      
      private function refreshNewLabelVisibility():void {
         if (_hasNotificationsForNewLabel) {
            showNewLabel();
         }
         else {
            hideNewLabel();
         }
      }
      
      private function showNewLabel():void {
         if(!isNewLabelVisible()) {
            if(!_newLabel) {
               var _newsButton:NewsLabel = IPTVisualGraph(_vnode.vgraph).controls.makeNewsButton();
               _newsButton.pearl = this;
               _newLabel = new PearlNewsConnector(this, _newsButton);
            }
            _newLabel.createChildren();
            _newLabel.setComponentAddOnTemporaryVisible(true);
         }
      }
      
      private function hideNewLabel():void {
         if(isNewLabelVisible()) {
            _newLabel.setComponentAddOnTemporaryVisible(false);
            
         }
      }

      public function isNewLabelVisible():Boolean  {
         return  _newLabel && _newLabel.addOn.visible;
      }

      protected function setNewLabelInSelection(value:Boolean):void {
         if (value != _newLabelInSelection) {
            _newLabelInSelection = value;
            if(_newLabel && _newLabel.addOn && _newLabel.addOn.visible) {
               if(_newLabelInSelection) {
                  _newLabel.addOn.setFilterColor(0x000000);
               }
               else{
                  _newLabel.addOn.setFilterColor(0xA8A8A8);
               }
            }
         }
      }

      public function get pearlCenter():Point {
         if(!_pearlCenterPoint) _pearlCenterPoint = new Point();
         if(view) {
            var pc:Point = view.pearlCenter;
            _pearlCenterPoint.x = x + scaleX * pc.x;
            _pearlCenterPoint.y = y + scaleY * pc.y;
         }else{
            _pearlCenterPoint.x = x + scaleX * pearlWidth / 2.0;
            _pearlCenterPoint.y = y + scaleY *pearlWidth / 2.0;
         }
         return _pearlCenterPoint;
      }
      public function get titleCenter():Point {
         if(!_titleCenterPoint) _titleCenterPoint = new Point();
         if(view) {
            var viewTitleCenter:Point = view.titleCenter;
            if (_animationFactor>1){
               _titleCenterPoint.x = int(0.5 + _positionWithoutZoom.x + scaleX * viewTitleCenter.x / _animationFactor);
               _titleCenterPoint.y = int (0.5 + _positionWithoutZoom.y + scaleY * viewTitleCenter.y / _animationFactor);
            } else {
               _titleCenterPoint.x = int(0.5 + x + scaleX * viewTitleCenter.x);
               _titleCenterPoint.y = int (0.5 + y + scaleY * viewTitleCenter.y);
            }
            
         }else{
            _titleCenterPoint.x = pearlCenter.x;
            _titleCenterPoint.y = pearlCenter.y + scaleY * pearlMaxWidth / 2.0;
         }
         return _titleCenterPoint;
      }
      
      public function get pearlWidth():Number {
         if(view && !isNaN(view.pearlWidth)) {
            return view.pearlWidth;
         }
         else {
            return pearlDefaultWidth * scaleX;
         }
      }
      public function get pearlMaxWidth():Number {
         return MAX_PEARL_WIDTH;
      }
      protected function get pearlDefaultWidth():Number {
         return MAX_PEARL_WIDTH;
      }
      
      protected function get view():IUIPearlView {
         return _pearl as IUIPearlView;
      }
      override protected function updateVisualState():void {
         _stateManager.updateVisualState(this);
      }
      override public function set visible(value:Boolean):void {
         if (value != super.visible) {
            super.visible = value;
            _pearl.visible = value;
            if (_newLabel) {
               _newLabel.updateButtonVisibility();
            }
         } else {
            _pearl.visible = value;
         }
      }
      
      public function setInSelection(value:Boolean):void {
         _pearl.setInSelection(value);
         setNewLabelInSelection(value);
      }
      
      override public function set alpha(value:Number):void {
         if (alpha != value) {
            super.alpha = value;
            dispatchEvent(new PropertyChangeEvent("alpha"));
         }
      }
      
      override protected function clearMemory():void {
         super.clearMemory();
         if (_newLabel) {
            _newLabel.end();
            _newLabel = null;
         }
      }
      
      public function moveOnValidation(x:Number, y:Number):Boolean{
         if (_moveOnValidation.moveOnValidation(x,y)) {
            dispatchEvent(new Event(WILL_MOVE_EVENT));
            super.invalidateProperties();
            return true;
         }
         return false;
      }
      override public function move(toX:Number, toY:Number):void {
         if (_animationFactor != 1 && !_isMovingTakingAccountOffset) {
            if (x != toX  || y != toY) {
               
               _positionWithoutZoom.x += (toX-x);
               _positionWithoutZoom.y += (toY-y);
            }
         }
         _moveOnValidation.resetMove();
         super.move(toX,toY);
         if (stage && isPearlUnderCursor() ) {
            _MousePoint.x= stage.mouseX;
            _MousePoint.y= stage.mouseY;
            if (!isPointOnPearl(_MousePoint)) {
               var interactorManager:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
               if (!interactorManager.draggedPearl) {
                  
                  ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.updatePearlRendererUnderCursor(_MousePoint);
               }
               
            }
         }
      }
      
      override public function invalidateProperties():void {
         if (!isEnded()) {
            _shouldCommitProperties=true;
            super.invalidateProperties();
         }
      }
      public function getTargetMove():Point {
         return _moveOnValidation.getTargetMove();
      }
      public function commitMove():Boolean {
         return _moveOnValidation.commitMove();
      }
      override public function end():void {
         if (!pearlRecyclingManager.recyclePearl(this)) {
            super.end();
         }
      }
      
      private function isPearlUnderCursor():Boolean{
         return ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.pearlRendererUnderCursor ==  this
      }
      override public function restoreInitialState():void {
         super.restoreInitialState();
         super.visible = true;
         if (_newLabel) {
            _newLabel.end();
            _newLabel = null;
         }
         alpha = 1;
      }
      
      public function setScale(value:Number):void {
         if (node && node.isDocked) {
            value = ApplicationManager.getInstance().isEmbed() ? Deck.EMBED_PEARL_SCALE : Deck.PEARL_SCALE;
         }
         _scale = value
         value = value * _animationFactor;
         scaleX = value;
         scaleY = value;
         if (_pearl) {
            _pearl.setScale(value);
         }
      }
      public function getScale():Number {
         return scaleX;
      }
      
      public function get animationZoomFactor():Number {
         return _animationFactor;
      }
      public function set animationZoomFactor(value:Number):void {
         if (false ||  _animationFactor != value) {
            if (_animationFactor == 1) {
               
               _positionWithoutZoom.x = x;
               _positionWithoutZoom.y = y;
            }
            if (_pearl) {
               var pc:Point = _pearl.pearlCenter;
               _isMovingTakingAccountOffset = true;
               move(int(0.5 +  _positionWithoutZoom.x + _scale * pc.x * (1 - value)), int(0.5 + _positionWithoutZoom.y + _scale * pc.y * (1 - value)));
               _isMovingTakingAccountOffset = false;
            }
            _animationFactor = value;
            setScale(_scale);
         }
      }
      public function moveWithoutZoomOffset(toX:Number, toY:Number):void {
         _isMovingTakingAccountOffset = true;
         try {
            if (_animationFactor != 1 && pearl) {
               var pc:Point = _pearl.pearlCenter;
               _positionWithoutZoom.x = toX;
               _positionWithoutZoom.y = toY;
               toX +=  _scale * pc.x * (1 - _animationFactor);
               toY +=  _scale * pc.y * (1 - _animationFactor);
            }
            move(int(toX + 0.5), int(toY + 0.5));
         } finally {
            _isMovingTakingAccountOffset = false
         }
      }
      public function get positionWithoutZoom():Point {
         if (_animationFactor == 1) {
            if (_positionWithoutZoom.x != x) {
               _positionWithoutZoom.x = x;
            }
            _positionWithoutZoom.y = y;
            return _positionWithoutZoom;
         } else {
            
            return _positionWithoutZoom;
         }
         
      }

      public function showPadlock(isActive:Boolean, isTeam:Boolean):void {
         if (_wasActive != isActive) {
            if (_padlockImage) {
               removeChild(_padlockImage);
            }
            _padlockImage = makePadlockImage(isActive, isTeam);
            addChild(_padlockImage);
            _padlockImage.width = PTRootPearl.PRIVATE_PADLOCK_WIDTH;
            _padlockImage.height= PTRootPearl.PRIVATE_PADLOCK_HEIGHT;
            /*if (isTeam) {
            _padlockImage.setStyle("left", 37);
            _padlockImage.setStyle("top", 37);
            } else {*/
            _padlockImage.move(42,37);

            _padlockImage.visible = _padlockImage.includeInLayout = true;
            _wasActive = isActive;
         }
      }
      
      public function hidePadlock():void {
         if (_padlockImage) {
            _padlockImage.visible = _padlockImage.includeInLayout = false;
            _wasActive = false;
         }
      }
      
      private function makePadlockImage(isActive:Boolean, isTeam:Boolean):Image {
         var padlockImage:Image = new Image();
         padlockImage.smoothBitmapContent = true;
         /*if (isTeam) {
         padlockImage.source = AssetsManager.getEmbededAsset(PearlAssets.PRIVATE_PADLOCK_SMALL_TEAM);
         } else {*/
         padlockImage.source = AssetsManager.getEmbededAsset(PearlAssets.PRIVATE_PADLOCK_SMALL_ACTIVE);
         
         return padlockImage;
      }
   }
}