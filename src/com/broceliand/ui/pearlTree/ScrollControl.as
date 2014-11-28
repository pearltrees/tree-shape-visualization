package com.broceliand.ui.pearlTree
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.interactors.scroll.ExcitableImage;
   import com.broceliand.ui.interactors.scroll.ScrollUi;
   import com.broceliand.ui.model.ScrollModel;
   import com.broceliand.ui.navBar.NavBar;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.util.BroceliandMath;
   
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ScrollControl implements IScrollControl
   {
      
      private var _scrollUi:ScrollUi = null;
      
      private var _pointToCompareWith:Point = null;
      
      private static var VERTICAL:int = 0;
      private static var HORIZONTAL:int = 1;
      private var _scrollDirection:int;
      
      private var _hideWhileNotOncePassedBottomLine:Boolean = false;
      private var _forceShowControls:Boolean;
      private var _isEnabled:Boolean = true;
      private var _wc:IWindowController;
      private var _isDiscoverMode:Boolean;
      private var _scrollModel:ScrollModel;
      
      public function ScrollControl(scrollUi:ScrollUi, scrollModel:ScrollModel){
         _scrollUi = scrollUi;
         _scrollModel = scrollModel;
         clear();
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navigationManager: INavigationManager = am.visualModel.navigationModel;
         am.addEventListener(ApplicationManager.FOCUS_CHANGE_EVENT, onApplicationFocusChange);
         
         navigationManager.addEventListener(NavigationEvent.PLAY_EVENT, onPlayStateChange);
         if(am.isEmbed()) {
            _scrollUi.visible = am.isApplicationFocused;
         }
      }
      
      private function onApplicationFocusChange(event:Event):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed()) {
            _scrollUi.visible = am.isApplicationFocused;
         }
         else if(!am.isApplicationFocused && !_isDiscoverMode) {
            _scrollUi.visible = false;
         }
      }
      
      private function onPlayStateChange(event:NavigationEvent):void {
         if (event.playState == event.oldPlayState) {
            return;
         }
         if(ApplicationManager.getInstance().visualModel.navigationModel.isInScreenLine()) {
            enableScrollControl(false);
            clear();
         } else {
            enableScrollControl(true);
         }
      }
      
      public function getScrollDescriptor(point:Point, isDragging:Boolean):ScrollDescriptor{
         if(!_pointToCompareWith || _scrollUi.excitedButtonId == ScrollUi.NONE_BUTTON || windowController.isPointOverMenuWindow(point.x, point.y)) {
            return null;
         }
         
         var heightOffsetIfAnonymous:int = windowController.offsetHeightDueToSignupBanner(); 
         
         var ret:ScrollDescriptor = new ScrollDescriptor();
         var w:int = _scrollUi.width;
         var h:int = _scrollUi.height - heightOffsetIfAnonymous;
         var mousePoint:Point = _scrollUi.globalToLocal(point);
         var distanceToPoint:Number;
         var warp:Boolean = false;

         if (_scrollDirection == HORIZONTAL) {
            distanceToPoint = BroceliandMath.getSquareDistanceBetweenPoints(_pointToCompareWith, mousePoint);
         }
         else {
            distanceToPoint = BroceliandMath.getSquareDistanceBetweenPointsWithWeight(_pointToCompareWith, mousePoint, 1 / GeometricalConstants.SCROLL_ZONE_VERTICAL_HEIGHT_REDUCTION);
         }
         
         if(_scrollUi.isPointOverExcitedButton(point)){
            
            if(ApplicationManager.getInstance().visualModel.navigationModel.isShowingDiscover()) {
               ret.speed = isDragging? GeometricalConstants.SCROLL_MAX_SPEED_DRAGGING : GeometricalConstants.SCROLL_MAX_SPEED_ON_BUTTON_IMAGE_PTW;
            }else{
               ret.speed = isDragging? GeometricalConstants.SCROLL_MAX_SPEED_DRAGGING : GeometricalConstants.SCROLL_MAX_SPEED_ON_BUTTON_IMAGE;
            }
            warp = true;
         } else{
            const SD_ACTIVATE:int = h * GeometricalConstants.SCROLL_ZONE_FRACTION_OF_HEIGHT;
            const SD_ACTIVATE_SQ:int = SD_ACTIVATE * SD_ACTIVATE;
            var maxSpeed:Number= isDragging ? GeometricalConstants.SCROLL_MAX_SPEED_DRAGGING :GeometricalConstants.SCROLL_MAX_SPEED; 
            if ((distanceToPoint/ SD_ACTIVATE_SQ) > 0.25) {
               ret.speed = GeometricalConstants.SCROLL_MIN_SPEED; 
            } else {
               ret.speed = GeometricalConstants.SCROLL_MIN_SPEED + maxSpeed * (distanceToPoint - SD_ACTIVATE_SQ)/ (GeometricalConstants.SCROLL_BTN_SQUARE_DEPTH- SD_ACTIVATE_SQ)  ;
            }
         }

         var xLength:Number = mousePoint.x - w / 2;
         var yLength:Number = mousePoint.y - (heightOffsetIfAnonymous + h / 2);
         var hypotenuseLength:Number = Math.sqrt(Math.pow(xLength, 2) + Math.pow(yLength, 2));
         if (hypotenuseLength != 0) {
            ret.xMultiplier = - w * ret.speed * xLength / hypotenuseLength;
            ret.yMultiplier = - h * ret.speed * yLength / hypotenuseLength;
         }
         if (_scrollDirection == VERTICAL) {
            if (warp == true) {
               ret.xMultiplier = 0;
            }
            else {
               ret.xMultiplier = ret.xMultiplier * GeometricalConstants.SCROLL_HORIZONTAL_FACTOR_IN_VERTCALSCROLL;
            }
         }
         else {
            if (warp == true) {
               ret.yMultiplier = 0;
            }
            else {
               ret.yMultiplier = ret.yMultiplier * GeometricalConstants.SCROLL_VERTICAL_FACTOR_IN_HORIZONTALSCROLL;
            }
         } 
         
         return ret;
      }

      private function clear():void {
         if(!ApplicationManager.getInstance().isEmbed() && !_isDiscoverMode) {
            _scrollUi.visible = false;
         }
         _scrollUi.excitedButtonId = ScrollUi.NONE_BUTTON;         
      }
      
      public function updateOnMouseMove(posX:Number, posY:Number, isDragging:Boolean):void{
         if (!_isEnabled ) {
            clear();
            return;
         }
         if(_forceShowControls){
            _scrollUi.excitedButtonId = ScrollUi.NONE_BUTTON; 
            return;
         } 
         if(_hideWhileNotOncePassedBottomLine){
            if(posY < _scrollUi.stage.stageHeight - GeometricalConstants.SCROLL_DISTANCE_ABOVE_WHICH_HIDE_FOR_DOCKED_INVALID){
               _hideWhileNotOncePassedBottomLine = false;
            }else{
               _pointToCompareWith = null;
               clear();
               return;
            }
         }
         
         var heightOffsetIfAnonymous:int = windowController.offsetHeightDueToSignupBanner();
         
         var heightWithScrollDisabled:int = (heightOffsetIfAnonymous>0? heightOffsetIfAnonymous+8 : 0);
         
         var w:int = _scrollUi.width;
         var h:int = _scrollUi.height - heightOffsetIfAnonymous;
         var mousePoint:Point = _scrollUi.globalToLocal(new Point(posX, posY));
         var candidateExcitedButton:uint = ScrollUi.NONE_BUTTON;
         var disabledButton:uint = ScrollUi.NONE_BUTTON;

         if((mousePoint.x <= 0) || (mousePoint.x >= w) || (mousePoint.y <= 0) || (mousePoint.y >= _scrollUi.height)){
            _pointToCompareWith = null;
            clear();
            return;
         }

         var SD_ACTIVATE:int = h * GeometricalConstants.SCROLL_ZONE_FRACTION_OF_HEIGHT;
         var SD_ACTIVATE_SQ:int = SD_ACTIVATE * SD_ACTIVATE;
         const SD_SHOW:int = SD_ACTIVATE * 1.9;
         const SD_SHOW_SQ:int = SD_SHOW * SD_SHOW;

         _pointToCompareWith = null;
         if(mousePoint.x < SD_SHOW  && !ApplicationManager.getInstance().components.topPanel.isSideBarVisible){
            _pointToCompareWith = new Point(0, heightOffsetIfAnonymous + h / 2);
            candidateExcitedButton = ScrollUi.LEFT_BUTTON;
            _scrollDirection = HORIZONTAL;
         } else if(w - mousePoint.x < SD_SHOW && !ApplicationManager.getInstance().components.windowController.isNoveltyFeedWindowOpen()){
            _pointToCompareWith = new Point(w, heightOffsetIfAnonymous + h / 2);
            candidateExcitedButton = ScrollUi.RIGHT_BUTTON;
            _scrollDirection = HORIZONTAL;
         } else if(mousePoint.y < (heightOffsetIfAnonymous + SD_SHOW * GeometricalConstants.SCROLL_ZONE_VERTICAL_HEIGHT_REDUCTION)
            && mousePoint.y > heightWithScrollDisabled){
            _pointToCompareWith = new Point(w / 2, heightOffsetIfAnonymous);
            candidateExcitedButton = ScrollUi.TOP_BUTTON;
            _scrollDirection = VERTICAL;
         } else if(-scrollUi.height - mousePoint.y < (SD_SHOW * GeometricalConstants.SCROLL_ZONE_VERTICAL_HEIGHT_REDUCTION)){
            _pointToCompareWith = new Point(w / 2 , _scrollUi.height);
            candidateExcitedButton = ScrollUi.BOTTOM_BUTTON;
            _scrollDirection = VERTICAL;
         }
         if(_pointToCompareWith){
            var sDistanceToPoint:Number;
            if (_scrollDirection == HORIZONTAL) {
               SD_ACTIVATE_SQ /=4;
               sDistanceToPoint = BroceliandMath.getSquareDistanceBetweenPoints(_pointToCompareWith, mousePoint);
               
            }
            else {
               sDistanceToPoint = BroceliandMath.getSquareDistanceBetweenPointsWithWeight(_pointToCompareWith, mousePoint, 1 / GeometricalConstants.SCROLL_ZONE_VERTICAL_HEIGHT_REDUCTION);
            }
            if(sDistanceToPoint < SD_SHOW_SQ){
               
               _scrollUi.visible = !_scrollModel.isVetoOnScrollPeriod();
               if(sDistanceToPoint < SD_ACTIVATE_SQ){
                  _scrollUi.excitedButtonId = candidateExcitedButton;
               }else{
                  _scrollUi.excitedButtonId = ScrollUi.NONE_BUTTON;
               }            
            }else{
               clear();
            }
            
         }else{
            clear();
         }
         
      }      
      
      public function hideWhileNotOncePassedBottomLine():void{
         _hideWhileNotOncePassedBottomLine = true;
      }
      
      public function get forceShowControls():Boolean {
         return _forceShowControls;
      }
      
      public function setForceShowControls(value:Boolean):void {
         _forceShowControls = value;
         if(value && !ApplicationManager.getInstance().isEmbed()){
            _scrollUi.visible = true;
         }else{
            updateOnMouseMove(_scrollUi.mouseX, _scrollUi.mouseY, false);
         }
      }
      
      public function get scrollUi():ScrollUi {
         return _scrollUi;
      }
      
      public function enableScrollControl(isEnabled:Boolean):void {
         _isEnabled = isEnabled;
      }
      public function get windowController():IWindowController {
         if (!_wc) {
            _wc = ApplicationManager.getInstance().components.windowController;
         }
         return _wc;
      }     
      
      public function set isDiscoverMode(value:Boolean):void {
         _isDiscoverMode = value;
         if(!value) {
            _scrollUi.visible = false;
            _scrollUi.getButton(ScrollUi.TOP_BUTTON).visible = true;
            _scrollUi.getButton(ScrollUi.TOP_BUTTON).showArrowTail = false;
            _scrollUi.getButton(ScrollUi.RIGHT_BUTTON).visible = true;
            _scrollUi.getButton(ScrollUi.RIGHT_BUTTON).showArrowTail = false;
            _scrollUi.getButton(ScrollUi.LEFT_BUTTON).visible = true;
            _scrollUi.getButton(ScrollUi.LEFT_BUTTON).showArrowTail = false;
            _scrollUi.getButton(ScrollUi.BOTTOM_BUTTON).visible = true;
            _scrollUi.getButton(ScrollUi.BOTTOM_BUTTON).showArrowTail = false;
         }else{
            _scrollUi.visible = true;
            _scrollUi.getButton(ScrollUi.TOP_BUTTON).showArrowTail = true;
            _scrollUi.getButton(ScrollUi.RIGHT_BUTTON).showArrowTail = true;
            _scrollUi.getButton(ScrollUi.LEFT_BUTTON).showArrowTail = true;
            _scrollUi.getButton(ScrollUi.BOTTOM_BUTTON).showArrowTail = true;
         }
      }

   }
}