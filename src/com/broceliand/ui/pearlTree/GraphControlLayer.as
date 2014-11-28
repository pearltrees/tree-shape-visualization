package com.broceliand.ui.pearlTree {
   import com.broceliand.ApplicationManager;
   import com.broceliand.ApplicationMessageBroadcaster;
   import com.broceliand.EmbedManager;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.ComponentsAccessPoint;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.embed.footer.EmbedFooter;
   import com.broceliand.ui.embed.header.EmbedHeader;
   import com.broceliand.ui.interactors.scroll.ScrollUi;
   import com.broceliand.ui.mouse.MouseManager;
   import com.broceliand.ui.navBar.NavBar;
   import com.broceliand.ui.pearlBar.Footer;
   import com.broceliand.ui.pearlBar.IFooter;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   import com.broceliand.ui.pearlBar.dropZone.DropZoneDeckModel;
   import com.broceliand.ui.pearlBar.footerBanner.FooterBanner;
   import com.broceliand.ui.pearlBar.view.AnonymousUserSettings;
   import com.broceliand.ui.pearlBar.view.ZoomScale;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.ui.util.SkinHelper;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.ui.window.WindowEvent;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.externalServices.IShortener;
   
   import flash.events.Event;
   import flash.geom.Point;
   
   import mx.containers.Canvas;
   import mx.controls.Label;
   import mx.core.IUIComponent;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.events.FlexEvent;
   
   public class GraphControlLayer extends Canvas implements IUIComponent, IGraphControls
   {
      private var _scrollUi:ScrollUi = null;
      private var _footer:IFooter = null;
      private var _dropZoneDeckModel:IDeckModel = null;
      private var _scrollControl:ScrollControl = null;
      private var _unfocusButton:UnfocusButton= null;
      private var _backFromAliasButton:BackFromAliasButton= null;
      private var _emptyFocusTree:EmptyFocusMapText= null;
      private var _emptyMapText:EmptyMapText= null;
      private var _addOns:Array= new Array;
      private var _addOnsLayer:UIComponent = new Canvas();
      private var _zoomScale:ZoomScale;
      private var _discoverHelpLabel:Label;
      private var _newsButton:Array = new Array();
      
      public function GraphControlLayer() {
         super();
         var am:ApplicationManager = ApplicationManager.getInstance();
         _unfocusButton = new UnfocusButton();
         _backFromAliasButton = new BackFromAliasButton();
         _emptyFocusTree = new EmptyFocusMapText();
         _emptyMapText = new EmptyMapText();
         if(!am.isEmbed()) {
            _footer = new Footer();
         } else {
            _footer = new EmbedFooter();
         }
         _scrollUi = new ScrollUi();
         _scrollControl = new ScrollControl(_scrollUi, am.visualModel.scrollModel);
         _zoomScale = new ZoomScale();
         
         _discoverHelpLabel = new Label();
         _discoverHelpLabel.visible = _discoverHelpLabel.includeInLayout = false;
         _zoomScale.visible = false;
         _dropZoneDeckModel = new DropZoneDeckModel();
         if(am.isEmbed()) {
            if(_zoomScale.model) {
               _zoomScale.model.setVisible(true);
            }else{
               _zoomScale.visible = true;
            }
         }
         if (_footer) {
            _footer.addEventListener(FlexEvent.SHOW, onFooterShown);
         }
      }
      
      override protected function createChildren():void {
         super.createChildren();
         
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         horizontalScrollPolicy = ScrollPolicy.OFF;
         verticalScrollPolicy = ScrollPolicy.OFF;
         addChild(_addOnsLayer);
         Canvas(_addOnsLayer).horizontalScrollPolicy = ScrollPolicy.OFF;
         Canvas(_addOnsLayer).verticalScrollPolicy =  ScrollPolicy.OFF;
         Canvas(_addOnsLayer).percentHeight = 100;
         Canvas(_addOnsLayer).percentWidth = 100;
         
         addChild(_scrollUi);
         if(_footer) {
            addChild(_footer as UIComponent);
         }
         if(am.isEmbed()) {
            am.components.mainPanel.addChild(_zoomScale);
         } else {
            addChild(_zoomScale);
         }
         
         _discoverHelpLabel.setStyle('fontSize', 15);
         _discoverHelpLabel.setStyle('fontWeight', 'bold');
         _discoverHelpLabel.setStyle('color', ColorPalette.getInstance().pearltreesColor);
         _discoverHelpLabel.filters = [SkinHelper.getDropShadowFilter()];
         _discoverHelpLabel.text = BroLocale.getInstance().getText('ptw.help');
         addChild(_discoverHelpLabel);
         
         addPearlAddOn(_emptyFocusTree);
         addPearlAddOn(_emptyMapText);
         addPearlAddOn(_unfocusButton);
         addPearlAddOn(_backFromAliasButton);
         
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if (_zoomScale.isEmbedMode()) {
            _zoomScale.x = 0;
            _zoomScale.y = unscaledHeight  - EmbedManager.BORDER_THICKNESS - _zoomScale.height;
         } else {
            var footerHeight:int = (_footer) ? _footer.height : 0;
            if (am.currentUser.isAnonymous()) {
               _zoomScale.y = unscaledHeight - _zoomScale.height - 8;
               _zoomScale.x = unscaledWidth - _zoomScale.width - 10 - 73;
               _discoverHelpLabel.y = unscaledHeight - footerHeight - 45;
               _discoverHelpLabel.x = 10;
            } else {
               _zoomScale.y = unscaledHeight - _zoomScale.height - 8;
               _zoomScale.x = unscaledWidth - _zoomScale.width - 10 - 73;
               _discoverHelpLabel.y = unscaledHeight - footerHeight - 30;
               _discoverHelpLabel.x = 10;
            }
            
         }
         _zoomScale.updateScaleSliderWidth();
         
         _scrollUi.width = width;
         if(am.isEmbed()) {
            if (am.embedManager.isModeSmall()) {
               _scrollUi.y = 30;
               _scrollUi.height = height - _scrollUi.y - 30;
            } else {
               _scrollUi.y = 0;
               _scrollUi.height = height - _scrollUi.y;
            }
         }else{
            _scrollUi.y = NavBar.NAVBAR_HEIGHT;
            if(am.currentUser.isAnonymous()) {
               _scrollUi.height = height - _scrollUi.y - (_footer && _footer.isDeckVisible() ? FooterBanner.HEIGHT : 22) + 17;
            }else{
               
               _scrollUi.height = height - _scrollUi.y - Footer.DECK_HEIGHT;
            }
         }
         
      }
      
      private function onApplicationFocusChange(event:Event):void {
         updateZoomScaleVisibility();
      }
      
      private function onFooterShown(event:Event):void {
         updateZoomScaleVisibility();
         invalidateDisplayList();
      }
      
      private function updateZoomScaleVisibility():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var navModel:INavigationManager = am.visualModel.navigationModel;
         if(am.isEmbed()) {
            _zoomScale.model.setVisible(am.isApplicationFocused);
         }else{
            if (am.currentUser.isAnonymous()) {
               _zoomScale.model.setVisible(am.components.footer.isDeckVisible() && !am.isWhiteMark());  
            }
            else {
               _zoomScale.model.setVisible(am.components.footer.isDeckVisible());
            }
         }
      }
      
      public function get scrollControl():IScrollControl{
         return _scrollControl;
      }
      
      public function showDiscoverHelpLabel(value:Boolean):void {
         if(_discoverHelpLabel) {
            _discoverHelpLabel.visible = _discoverHelpLabel.includeInLayout = value;
         }
      }
      
      public function get dropZoneDeckModel():IDeckModel{
         return _dropZoneDeckModel;
      }
      
      public function isPointOverAControl(point:Point):Boolean{
         if (isPointOverUnfocusButton(point) ||
            isPointOverBackFromAliasButton(point) ||
            isPointOverPearlButton(point) ||
            isPointBelowDeck(point) ||
            isPointOverZooom(point) ) {
            return true;
         }else{
            return false;
         }
         
      }
      public function isPointBelowDeck(point:Point):Boolean {
         if (_footer && _footer.visible && point.y > _footer.y) {
            return true;
         }
         return false;
      }
      
      public function isPointOverTopButtons(point:Point):Boolean {
         return ApplicationManager.getInstance().components.mainPanel.isPointOverTopButtons(point);
      }
      
      public function isPointOverPearlButton(point:Point):Boolean {
         for each (var uiComponents:UIComponent in _addOns) {
            if  (uiComponents.visible && uiComponents.hitTestPoint(point.x, point.y)) {
               return true;
            }
         }
         return false;
      }
      public function isPointOverUnfocusButton(point:Point):Boolean {
         return _unfocusButton.visible && _unfocusButton.hitTestPoint(point.x, point.y);
      }
      public function isPointOverBackFromAliasButton(point:Point):Boolean {
         return _backFromAliasButton.visible && _backFromAliasButton.hitTestPoint(point.x, point.y);
      }
      
      public function isPointOverTrash(point:Point):Boolean {
         return _footer && !_footer.isTrashBoxRecovering && _footer.isPointOverTrashBox(point);
      }
      
      public function isPointOverZooom(point:Point):Boolean{
         return _zoomScale.visible && _zoomScale.hitTestPoint(point.x, point.y);
      }
      
      public function isPointOverDropZoneDeck(point:Point):Boolean {
         return _footer && _footer.isPointOverDropZoneDeck(point);
      }
      
      public function getDeckUnderPoint(point:Point):IDeckModel {
         if(isPointOverDropZoneDeck(point)){
            return _dropZoneDeckModel;
         } else{
            return null;
         }
      }
      
      public function getDepthInParent():int{
         if(parent){
            return parent.getChildIndex(this);
         }else{
            return 0;
         }
      }
      
      /*private function onVisibleWindowChange(event:WindowEvent):void {
      var am:ApplicationManager = ApplicationManager.getInstance();
      var wc:IWindowController = am.components.windowController;
      if(am.isEmbed()) {
      if (wc.isAllWindowClosed()) {
      enableScrollControl(true);
      }else{
      enableScrollControl(false);
      }
      }
      }*/
      
      public function enableScrollControl(isEnabled:Boolean):void {
         _scrollControl.enableScrollControl(isEnabled);
      }
      
      public function get footer():IFooter {
         return _footer;
      }
      
      public function getWantedCursor(stageX:Number, stageY:Number, isMouseDown:Boolean, distanceToMouseDown:Number):String{
         var p:Point = new Point(stageX,stageY);
         
         if (isPointOverUnfocusButton(p) || isPointOverPearlButton(p)  || isPointOverBackFromAliasButton(p)) {
            return MouseManager.CURSOR_TYPE_NONE;
         }else{
            return null;
         }
      }
      
      public function isVisible():Boolean{
         return !ApplicationManager.getInstance().currentUser.isAnonymous();
      }
      public function get unfocusButton():UnfocusButton{
         return _unfocusButton;
      }
      public function get backFromAliasButton():BackFromAliasButton{
         return _backFromAliasButton;
      }
      public function get emptyMapText():EmptyMapText {
         return _emptyMapText;
      }
      
      public function addButtonToControlLayer(pearlAddOns:PearlComponentAddOn):void{
         addPearlAddOn(pearlAddOns);
         _addOns.push(pearlAddOns);
      }
      
      private function addPearlAddOn(component:UIComponent):void {
         component.visible=false;
         component.includeInLayout=false;
         _addOnsLayer.addChildAt(component, 0);
      }
      
      public function removeButtonToControlLayer(pearlAddOns:PearlComponentAddOn):void {
         _addOnsLayer.removeChild(pearlAddOns);
         var index:int= _addOns.lastIndexOf(pearlAddOns);
         if (index>=0) {
            _addOns.splice(index,1);
         }
         
      }
      
      public function get zoomControl():ZoomScale {
         return _zoomScale;
      }
      
      public function getAddOnLayer():UIComponent {
         return _addOnsLayer;
      }
      
      public function makeNewsButton():NewsLabel {
         if (_newsButton.length>0) {
            return _newsButton.pop();
         }
         return new NewsLabel();
      }
      
      public function releaseNewsButton(newsButton:NewsLabel):void {
         _newsButton.push(newsButton);
      }
   }
}
