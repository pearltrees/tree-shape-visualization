package com.broceliand.ui.renderers
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.IScrollable;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.PTStyleManager;
   import com.broceliand.ui.TitleManager;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearl.UIPagePearl;
   import com.broceliand.ui.pearlTree.TitleLayer;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PagePearl;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.logging.Log;
   
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.sensors.Geolocation;
   import flash.text.TextLineMetrics;
   import flash.utils.flash_proxy;
   
   import mx.controls.Label;
   import mx.core.Application;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.skins.halo.HaloBorder;
   
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class TitleRenderer extends UIComponent implements ITextRenderer, IRepositionable, IScrollable
   {
      
      public static const START_END_SELECT_COLOR:String = "#"+ColorPalette.uintToHex(ColorPalette.getInstance().pearltreesDarkColor);
      public static const DEBUG_ORIENTATION:Boolean = false;
      public static const NEUTRAL_SIZE:int = 0;
      public static const HORIZONTAL_SIZE:int = 1;
      public static const VERTICAL_SIZE:int = 2;
      public static const BIG_SIZE:int =3;
      
      public static var HORIZONTAL_LABEL_FACTOR:Number = 1.15;
      public static var VERTICAL_LABEL_FACTOR:Number = 0.9;
      
      public static var TITLE_FONT_SIZE:Number = 12;
      public static var PEARL_TITLE_HEIGHT_BETWEEN_LINES:int = 11; 
      private static const PEARL_TITLE_LINE_HEIGHT:int = 19;
      
      private static const PAGE_PEARL_TITLE_WIDTH:Number = 90;
      private static const PAGE_PEARL_TITLE_WIDTH_EXPANDED:Number = 120; 
      
      public static const ROOT_PEARL_TITLE_WIDTH:Number = 110;
      private static const ROOT_PEARL_TITLE_WIDTH_EXPANDED:Number = 140;
      
      private static const FONT_SCALING_FACTOR:Number = 0.25;
      private static const FONT_SCALING_OUT_FACTOR:Number = 0.70;

      public static const DOCKED_TITLE_FONT_SIZE:Number = 12;
      private static const DOCKED_TITLE_HEIGHT_BETWEEN_LINES:int = 11;
      private static const DOCKED_TITLE_LINE_HEIGHT:int = 21;
      
      private static const PAGE_PEARL_DOCKED_TITLE_WIDTH:Number = 96; 
      private static const PAGE_PEARL_DOCKED_TITLE_WIDTH_EXPANDED:Number = 116; 
      
      private static const ROOT_PEARL_DOCKED_TITLE_WIDTH:Number = 96; 
      private static const ROOT_PEARL_DOCKED_TITLE_WIDTH_EXPANDED:Number = 116; 

      private static const TITLE_WIDTH_MEGA_EXPANDED:Number = 400;
      private static const TITLE_FONT_SIZE_MEGA_EXPANDED:Number = 15;
      private static const PEARL_TITLE_LINE_HEIGHT_MEGA_EXPANDED:int = 20;
      
      private var _orientation:int = 0;
      private var _titleTextLine1:Label = null;
      private var _titleTextLine2:Label = null;
      private var _titleTextLine3:Label = null;
      private var _titleTextLine4:Label = null;
      
      private var _pearlRenderer:IUIPearl= null;
      private var _isTitleExpanded:Boolean = false;
      private var _isTitleMegaExpanded:Boolean = false;
      
      private var _isMarkedForDestruction:Boolean;
      private var _dirtyLabelsContent:Boolean = false;
      private var _mainTitleText:String;
      private var _senderInfoText:String;
      private var _editable:Boolean;
      private var _showStartEndSign:Boolean = true;  
      private var _showTextInBold:Boolean = false;
      private var _positionChanges:Boolean = false;
      private var _currentColorCode:int;
      private var _dirtyStyle:Boolean = false;
      private var _recycled:Boolean;
      private var _visibleWidth:Number; 
      private var _labelSizeScale:Number =1;
      private var _messageOnTrashBoxMode:Boolean = true; 
      
      private var _pearlScale:Number = 1;
      private static const D:int = 2; 
      
      public function TitleRenderer(aPearlRenderer:IUIPearl) {
         super();
         aPearlRenderer.titleRenderer = this;
         pearlRenderer = aPearlRenderer;
         updateScale();
      }
      
      override protected function createChildren():void {
         super.createChildren();
         if(_titleTextLine1){
            return;
            
         }
         
         var textFilters:Array = getTextFilters();
         
         _titleTextLine1 = new Label();
         _titleTextLine1.height = PEARL_TITLE_LINE_HEIGHT;
         _titleTextLine1.setStyle("textAlign", "center");
         _titleTextLine1.setStyle('fontSize', TITLE_FONT_SIZE);
         _titleTextLine1.setStyle('fontFamily', PTStyleManager.SYSTEM_FONT_FAMILY);
         _titleTextLine1.filters = textFilters;
         _titleTextLine1.selectable = false;
         addChild(_titleTextLine1);
         
         _titleTextLine2 = new Label();
         _titleTextLine2.height = PEARL_TITLE_LINE_HEIGHT;
         _titleTextLine2.setStyle("textAlign", "center");
         _titleTextLine2.setStyle('fontSize', TITLE_FONT_SIZE);
         _titleTextLine2.setStyle('fontFamily', PTStyleManager.SYSTEM_FONT_FAMILY);
         _titleTextLine2.y = PEARL_TITLE_HEIGHT_BETWEEN_LINES;
         _titleTextLine2.filters = textFilters;
         _titleTextLine2.selectable = false;
         _titleTextLine2.visible = false;
         addChild(_titleTextLine2);
         
         _titleTextLine3 = new Label();
         _titleTextLine3.height = PEARL_TITLE_LINE_HEIGHT;
         _titleTextLine3.setStyle("textAlign", "center");
         _titleTextLine3.setStyle('fontSize', TITLE_FONT_SIZE);
         _titleTextLine3.setStyle('fontFamily', PTStyleManager.SYSTEM_FONT_FAMILY);
         _titleTextLine3.y = 2 * PEARL_TITLE_HEIGHT_BETWEEN_LINES;
         _titleTextLine3.filters = textFilters;
         _titleTextLine3.selectable = false;
         _titleTextLine3.visible = false;
         addChild(_titleTextLine3);
         
         _titleTextLine4 = new Label();
         _titleTextLine4.height = PEARL_TITLE_LINE_HEIGHT;
         _titleTextLine4.setStyle("textAlign", "center");
         _titleTextLine4.setStyle('fontSize', TITLE_FONT_SIZE);
         _titleTextLine4.setStyle('fontFamily', PTStyleManager.SYSTEM_FONT_FAMILY);
         _titleTextLine4.y = 2 * PEARL_TITLE_HEIGHT_BETWEEN_LINES;
         _titleTextLine4.filters = textFilters;
         _titleTextLine4.selectable = false;
         _titleTextLine4.visible = false;
         addChild(_titleTextLine4);
         
      }
      
      public function get showTextInBold():Boolean{
         return _showTextInBold;
      }
      
      public function set showTextInBold(value:Boolean):void{
         if(_showTextInBold != value){
            _showTextInBold = value;
            _dirtyStyle= true;
            invalidateProperties();
         }
      }
      
      public function set titleExpanded(value:Boolean):void {
         _isTitleExpanded = value;
      }
      
      public function set titleMegaExpanded(value:Boolean):void {
         _isTitleMegaExpanded = value;
      }
      
      public static function getTextFilters():Array{
         var color:Number = ColorPalette.getInstance().backgroundColor;
         var alpha:Number = 1;
         var blurX:Number = 2;
         var blurY:Number = 2;
         var strength:Number = 10;
         var inner:Boolean = false;
         var knockout:Boolean = false;
         var quality:Number = BitmapFilterQuality.LOW;
         var filter:GlowFilter = new GlowFilter(color, alpha, blurX,blurY,strength,quality,inner, knockout);
         var ret:Array = new Array();
         ret.push(filter);
         var dropShadowFilter:DropShadowFilter = new DropShadowFilter(1, 90, color, 1, 0, 0, 250, BitmapFilterQuality.LOW);
         ret.push(dropShadowFilter);
         return ret;
      }
      
      public function setText(mainTitleText:String, senderInfoText:String):void{
         if (_mainTitleText != mainTitleText) {
            _mainTitleText = mainTitleText;
            _dirtyLabelsContent = true;
         }
         if (_senderInfoText != senderInfoText) {
            _senderInfoText = senderInfoText;
            _dirtyLabelsContent = true;
         }
         if (_dirtyLabelsContent) {
            _visibleWidth = NaN;
            invalidateProperties();
         }
      }
      
      public function get senderInfoText():String {
         return _senderInfoText;
      }
      
      public function initFromTitleRenderer(value:TitleRenderer):void {
         _mainTitleText = value.text;
         _senderInfoText = senderInfoText;
         _orientation = value.orientation;
         invalidateProperties();
      }
      
      public function setColor(colorCode:int):void{
         if(_currentColorCode != colorCode){
            _currentColorCode = colorCode;
            _dirtyStyle= true;
            invalidateProperties();
         }
      }
      
      public function reposition():void{
         _positionChanges = true;
         updateScale();
         invalidateProperties();
      }
      
      override protected function commitProperties():void{
         refreshLines();
         super.commitProperties();
         
      }
      
      private  function updateScale():void {
         if (_pearlRenderer && _pearlRenderer.getScale() != _pearlScale) {
            _pearlScale = _pearlRenderer.getScale();
            
            var pScale:Number = (_pearlRenderer.getScale() / _pearlRenderer.animationZoomFactor) / GeometricalConstants.DEFAULT_ZOOM_VALUE;
            if (_pearlScale<1) {
               scaleX = 1 + (pScale-1) * FONT_SCALING_OUT_FACTOR;
               _labelSizeScale = 1 + (pScale -1) * GeometricalConstants.ZOOM_DENSITY_FACTOR_ZOOM_OUT;
            } else {
               scaleX = 1 + (pScale -1) * FONT_SCALING_FACTOR;
               _labelSizeScale = 1 + (pScale -1) * GeometricalConstants.ZOOM_DENSITY_FACTOR;
            }
            scaleY = scaleX;
            
            if (_pearlRenderer.vnode) {
               var vgraph:IPTVisualGraph = _pearlRenderer.vnode.vgraph as IPTVisualGraph;
               if (vgraph.zoomModel.isZoomSet()) {
                  updateLabelSize();
               }
            }
            
         }
      }

      private function updateLabelSize():void {
         _dirtyLabelsContent = true;
         invalidateProperties();
      }
      
      private function refreshLines():void {
         if(_dirtyLabelsContent) {
            
            var titleMaxWidth:Number = getTitleMaxWidth();
            if (_messageOnTrashBoxMode) {
               titleMaxWidth = titleMaxWidth * 0.63; 
            }
            _titleTextLine4.width = titleMaxWidth;
            _titleTextLine3.width = titleMaxWidth;
            _titleTextLine2.width = titleMaxWidth;
            _titleTextLine1.width = titleMaxWidth;
            
            var titleFontSize:int = getTitleFontSize();
            _titleTextLine4.setStyle("fontSize", titleFontSize);
            _titleTextLine3.setStyle("fontSize", titleFontSize);
            _titleTextLine2.setStyle("fontSize", titleFontSize);
            _titleTextLine1.setStyle("fontSize", titleFontSize);
            var titleLineHeight:int = getTitleLineHeight();
            _titleTextLine1.height = titleLineHeight
            _titleTextLine2.height = titleLineHeight;
            _titleTextLine3.height = titleLineHeight;
            _titleTextLine4.height = titleLineHeight;
            
            var titleHeightBetweenLines:int = getTitleHeightBetweenLines();
            _titleTextLine2.y = titleHeightBetweenLines;
            _titleTextLine3.y = 2 * titleHeightBetweenLines;
            _titleTextLine4.y = 3 * titleHeightBetweenLines;

            if(_senderInfoText) {
               _titleTextLine1.text = _mainTitleText;
               _titleTextLine2.text = _senderInfoText;
               _titleTextLine2.visible = _titleTextLine2.includeInLayout = true;
            }
               
            else {
               _titleTextLine1.setStyle("fontWeight", "bold"); 
               
               var maxLines:int = 2;

               if (_pearlRenderer && _pearlRenderer.node && !_pearlRenderer.node.isDocked) {
                  if (_orientation == VERTICAL_SIZE || _orientation ==  BIG_SIZE || _isTitleExpanded || true) {
                     maxLines = 4;
                  } else {
                     maxLines = 3;
                  }
                  if (ApplicationManager.getInstance().isEmbed()) {
                     maxLines = 2;
                  }
               } else if (pearlRenderer && _pearlRenderer.node && _pearlRenderer.node.isDocked) {
                  
                  if (_pearlRenderer.pearl is PagePearl) {
                     maxLines = 3;
                  } else {
                     maxLines = 2;
                  }
               }

               var formattedTitle:Array = null;
               
               if (_isTitleMegaExpanded) {
                  formattedTitle = TitleManager.formatTitleLines(_mainTitleText, _titleTextLine1, maxLines);  
               }  else {
                  formattedTitle = TitleManager.formatPearlTitle(_mainTitleText, _titleTextLine1, maxLines);
               }
               _titleTextLine1.text = formattedTitle[0];
               if(formattedTitle[1]) {
                  _titleTextLine2.text = formattedTitle[1];
                  _titleTextLine2.visible = _titleTextLine2.includeInLayout = true;
               }
               else{
                  _titleTextLine2.visible = _titleTextLine2.includeInLayout = false;
               }
               if(formattedTitle[2]) {
                  _titleTextLine3.text = formattedTitle[2];
                  _titleTextLine3.visible = _titleTextLine3.includeInLayout = true;
               }
               else{
                  _titleTextLine3.visible = _titleTextLine3.includeInLayout = false;
               }
               if (formattedTitle[3]) {
                  _titleTextLine4.text = formattedTitle[3];
                  _titleTextLine4.visible = _titleTextLine4.includeInLayout = true;
               }
               else{
                  _titleTextLine4.visible = _titleTextLine4.includeInLayout = false;
               }
            }
         }
         
         if (_dirtyStyle || _dirtyLabelsContent) {
            
            if(_showTextInBold){
               _titleTextLine1.setStyle("fontWeight", "bold");
               _titleTextLine2.setStyle("fontWeight", "bold");
               _titleTextLine3.setStyle("fontWeight", "bold");
               _titleTextLine4.setStyle("fontWeight", "bold");               
            }else{
               _titleTextLine1.setStyle("fontWeight", "normal");
               _titleTextLine2.setStyle("fontWeight", "normal");
               _titleTextLine3.setStyle("fontWeight", "normal");
               _titleTextLine4.setStyle("fontWeight", "normal");
            }

            _titleTextLine1.setStyle('color', _currentColorCode);
            if (!InteractorRightsManager.PREVENT_TOO_MANY_DESCENDANT && _pearlRenderer != null && _pearlRenderer.node.getBusinessNode() && _pearlRenderer.node.getBusinessNode().isEdited()) {
               _titleTextLine1.setStyle("color", ColorPalette.getInstance().connectionDarkColor);
            } 
            
            _titleTextLine2.setStyle('color', _currentColorCode);
            _titleTextLine3.setStyle('color', _currentColorCode);
            _titleTextLine4.setStyle('color', _currentColorCode);
         }
         
         _dirtyLabelsContent = false;
         _dirtyStyle = false;
         
         if (_positionChanges) {
            _positionChanges = false;
            commitNewPosition();
         }
      }
      
      private function commitNewPosition():void {
         if(!_isMarkedForDestruction && _pearlRenderer is IUIPearl){
            var pearlView:IUIPearl = _pearlRenderer as IUIPearl;
            var targetPoint:Point = pearlView.getTargetMove();
            var titleCenter:Point = pearlView.titleCenter;
            var toX:Number = titleCenter.x - scaleX * getTitleMaxWidth() / 2.0;
            var toY:Number = titleCenter.y;
            if (targetPoint) {
               toX +=targetPoint.x - pearlView.x;
               toY += targetPoint.y - pearlView.y;
            }
            move(toX, toY);
            if (_pearlRenderer.alpha >= 0.7) {
               alpha = _pearlRenderer.alpha;
            } else {
               alpha = 0;
               visible = false;
            }
         }
      }
      
      public function getTitleMaxWidth():int {
         var titleMaxWidth:int;
         
         if(_pearlRenderer && _pearlRenderer.node && _pearlRenderer.node.isDocked) {
            _orientation = NEUTRAL_SIZE;
            if(_pearlRenderer is UIPagePearl) {
               if (_isTitleExpanded) {
                  titleMaxWidth = PAGE_PEARL_DOCKED_TITLE_WIDTH_EXPANDED;
               }
               else if(_pearlRenderer.node.isInDropZone) {
                  titleMaxWidth = PAGE_PEARL_DOCKED_TITLE_WIDTH;
               }
            }
            else{
               if (_isTitleExpanded) {
                  titleMaxWidth = ROOT_PEARL_DOCKED_TITLE_WIDTH_EXPANDED;
               }
               else if(_pearlRenderer.node.isInDropZone) {
                  titleMaxWidth = ROOT_PEARL_DOCKED_TITLE_WIDTH;
               }
            }
         }
            
         else {
            if(_pearlRenderer is UIPagePearl) {
               if (_isTitleExpanded && _orientation == VERTICAL_SIZE) {
                  titleMaxWidth = PAGE_PEARL_TITLE_WIDTH_EXPANDED;
               }
               else {
                  titleMaxWidth = PAGE_PEARL_TITLE_WIDTH;
               }
            }
            else{
               if (_isTitleExpanded && _orientation == VERTICAL_SIZE) {
                  titleMaxWidth = ROOT_PEARL_TITLE_WIDTH_EXPANDED;
               }
               else {
                  titleMaxWidth = ROOT_PEARL_TITLE_WIDTH;
               }
               
            }
            if (_orientation == HORIZONTAL_SIZE) {
               titleMaxWidth *= HORIZONTAL_LABEL_FACTOR;
            } else if (_orientation == VERTICAL_SIZE) {
               titleMaxWidth *= VERTICAL_LABEL_FACTOR;
            }
            
         }
         
         if (_isTitleMegaExpanded) {
            titleMaxWidth = TITLE_WIDTH_MEGA_EXPANDED;
         }
         titleMaxWidth = increaseTitleSizeWithScale(titleMaxWidth);
         return titleMaxWidth;
      }

      private function increaseTitleSizeWithScale(titleMaxWidth:Number):Number {
         titleMaxWidth = titleMaxWidth * _labelSizeScale / scaleX;
         return titleMaxWidth;
      }
      public function getTitleFontSize():int {
         var titleFontSize:int;

         if(_pearlRenderer && _pearlRenderer.node && _pearlRenderer.node.isDocked) {
            titleFontSize = DOCKED_TITLE_FONT_SIZE;
         }
            
         else {
            titleFontSize = TITLE_FONT_SIZE;
         }

         if (_isTitleMegaExpanded) {
            titleFontSize = TITLE_FONT_SIZE_MEGA_EXPANDED;
         }
         
         return titleFontSize;
      }
      
      public function getTitleLineHeight():int {
         var titleLineHeight:int;

         if(_pearlRenderer && _pearlRenderer.node && _pearlRenderer.node.isDocked) {
            titleLineHeight = DOCKED_TITLE_LINE_HEIGHT;
         }
            
         else {
            titleLineHeight = PEARL_TITLE_LINE_HEIGHT;
         }

         if (_isTitleMegaExpanded) {
            titleLineHeight = PEARL_TITLE_LINE_HEIGHT_MEGA_EXPANDED;
         }
         
         return titleLineHeight;
      }
      
      public function getTitleHeightBetweenLines():int {
         
         if(_pearlRenderer && _pearlRenderer.node && _pearlRenderer.node.isDocked) {
            return DOCKED_TITLE_HEIGHT_BETWEEN_LINES;
         }
            
         else {
            return PEARL_TITLE_HEIGHT_BETWEEN_LINES;
         }
      }
      
      public function get text():String {
         return _mainTitleText;
      }
      
      public function set pearlRenderer(value:IUIPearl):void {
         if(_pearlRenderer != value) {
            _pearlRenderer = value;
            _dirtyLabelsContent = true;
            if (value) {
               commitNewPosition();
               invalidateProperties();
            }
         }
      }
      public function get pearlRenderer():IUIPearl{
         return _pearlRenderer;
      }

      public function end():void{
         callLater(clearMemory);
      }
      
      protected function clearMemory():void {
         _isMarkedForDestruction=true;
         _pearlRenderer=null;
         _titleTextLine1=null;
         _titleTextLine2 =null;
      }
      
      public function getPointToCenterOn():Point {
         var titleMaxWidth:Number = 0;
         if(_pearlRenderer is UIPagePearl) {
            titleMaxWidth = PAGE_PEARL_TITLE_WIDTH;
         }else{
            titleMaxWidth = ROOT_PEARL_TITLE_WIDTH;
         }
         return new Point(x + titleMaxWidth / 2.0, y + measuredHeight / 2.0);
      }

      public function calculateVisibleWidth():Number {
         var result:Number;
         refreshLines();
         if(isNaN(_visibleWidth)) {
            _visibleWidth = 0;
            if(_titleTextLine4.visible) {
               var line4Width:Number = _titleTextLine3.measureText(_titleTextLine4.text).width;
               if(line4Width > _visibleWidth) _visibleWidth = line4Width;
            }
            if(_titleTextLine3.visible) {
               var line3Width:Number = _titleTextLine3.measureText(_titleTextLine3.text).width;
               if(line3Width > _visibleWidth) _visibleWidth = line3Width;
            }
            if(_titleTextLine2.visible) {
               var line2Width:Number = _titleTextLine2.measureText(_titleTextLine2.text).width;
               if(line2Width > _visibleWidth) _visibleWidth = line2Width;
            }
            if(_titleTextLine1.visible) {
               var line1Width:Number = _titleTextLine1.measureText(_titleTextLine1.text).width;
               if(line1Width > _visibleWidth) _visibleWidth = line1Width;
            }

         }
         var titleMaxWidth:Number = getTitleMaxWidth();
         if(_visibleWidth > titleMaxWidth) {
            result = titleMaxWidth;
         }else{
            result = _visibleWidth;
         }
         if (_messageOnTrashBoxMode) {
            result = result * 0.6;
         }
         return result;
         
      }
      
      public function get editable():Boolean {
         return _editable;
      }
      
      public function set editable(value:Boolean):void {
         _editable = value;
      }

      public function get showStartEndSign():Boolean {
         return _showStartEndSign;
      }
      
      public function set showStartEndSign(value:Boolean):void {
         if(value != _showStartEndSign){
            _showStartEndSign = value;
            _dirtyLabelsContent = true;
            invalidateProperties();
         }
      }
      
      public function get isMarkedForDestruction():Boolean {
         return _isMarkedForDestruction;
      }

      public function set recycled (value:Boolean):void
      {
         _recycled = value;
      }
      
      public function get recycled ():Boolean
      {
         return _recycled;
      }
      
      override public function set visible(value:Boolean):void {
         if(value != super.visible) {
            if (_recycled) {
               super.visible = false;
            } else {
               super.visible =value;
            }
         }
      }
      public function isScrollable():Boolean {
         if (visible && _pearlRenderer) {
            return _pearlRenderer.isScrollable();
         }
         return false;
      }

      public static function getTitleRendererUnderPoint(point:Point):TitleRenderer{
         var objectsUnderPoint:Array = ApplicationManager.flexApplication.stage.getObjectsUnderPoint(point);
         var candidate:TitleRenderer = null;
         
         for each(var objUnderPoint:DisplayObject in objectsUnderPoint) {

            if((objUnderPoint is HaloBorder) || (objUnderPoint is Sprite)){
               continue;
            }
            
            if(objUnderPoint is UITextField) {
               var textField:UITextField = objUnderPoint as UITextField;
               if(textField.parent && textField.parent.parent is TitleRenderer){
                  candidate = textField.parent.parent as TitleRenderer;
                  var localCoords:Point = textField.globalToLocal(point);
                  var lineMetrics:TextLineMetrics = textField.getLineMetrics(0);
                  localCoords.x -=  lineMetrics.x; 
                  if((localCoords.x > D) && (lineMetrics.width - localCoords.x > D) &&
                     (localCoords.y > D) && (lineMetrics.height - localCoords.y > D)){
                     return candidate;
                  }
               }
            }
         }
         return null;
      }
      
      public function get orientation():int {
         return _orientation;
      }
      
      public function set orientation(newOrientation:int):void {
         if (_orientation != newOrientation) {
            if (DEBUG_ORIENTATION) {
               Log.getLogger("com.broceliand.ui.renderers.TitleRenderer").info("change orientation of {0} old one :{1} new one:{2}",
                  text, _orientation, newOrientation);
            }
            _orientation = newOrientation;
            _dirtyLabelsContent = true;
            reposition();
            invalidateProperties();
         }
      }
      public function updateOrientation():void {
         if (_pearlRenderer && _pearlRenderer.node && _pearlRenderer.vnode && !_pearlRenderer.node.isDocked) {
            var orientationAngle:Number = _pearlRenderer.vnode.orientAngle;
            if (isNaN(orientationAngle)) {
               orientation = NEUTRAL_SIZE;
            }
            else if (_pearlRenderer.vnode == _pearlRenderer.vnode.vgraph.currentRootVNode) {
               orientation = BIG_SIZE;
            } else {
               if ((orientationAngle > 45 && orientationAngle < 135) || (orientationAngle> 225 && orientationAngle < 315)) {
                  orientation = VERTICAL_SIZE;
               } else {
                  orientation = HORIZONTAL_SIZE;
               }
               
            }
         } else {
            orientation = NEUTRAL_SIZE;
         }
      }
      
      public function get messageOnTrashBoxMode():Boolean
      {
         return _messageOnTrashBoxMode;
      }
      
      public function set messageOnTrashBoxMode(value:Boolean):void
      {
         _messageOnTrashBoxMode = value;
      }
      
   }
}