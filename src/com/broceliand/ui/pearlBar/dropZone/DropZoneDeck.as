package com.broceliand.ui.pearlBar.dropZone {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.pearlTree.navigation.impl.NavigationManagerImpl;
   import com.broceliand.ui.navBar.NavBar;
   import com.broceliand.ui.pearlBar.Footer;
   import com.broceliand.ui.pearlBar.deck.Deck;
   import com.broceliand.ui.pearlBar.deck.DeckModel;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.logging.BroLogger;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   import mx.controls.Label;
   import mx.core.Application;
   import mx.formatters.SwitchSymbolFormatter;

   public class DropZoneDeck extends Deck {
      
      private var _holdingLabel:Label;
      private var _previousMsgType:int;
      private var _holdingLabelText:String;
      public function DropZoneDeck() {
         super();
         var graphControls:IGraphControls = ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.controls;
         if(graphControls.dropZoneDeckModel is DropZoneDeckModel) {
            deckModel = graphControls.dropZoneDeckModel;
         }else{
            deckModel = new DropZoneDeckModel();
         }
         _previousMsgType = -1;
         this.addEventListener(Event.ADDED_TO_STAGE, elementOnStage);
         this.addEventListener(MouseEvent.CLICK, onClick);
         super.model.addEventListener(DeckModel.MODEL_CHANGE, updateHoldingTextOnEvent);
      }
      
      public function elementOnStage(event:Event):void{
         stage.addEventListener(MouseEvent.MOUSE_MOVE,updateHoldingTextOnEvent);
         stage.addEventListener(MouseEvent.MOUSE_UP,updateHoldingTextOnEvent);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,updateHoldingTextOnEvent);
         var navigationManager:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         navigationManager.addEventListener(NavigationEvent.NAVIGATION_EVENT, updateHoldingTextOnEvent);
      }
      
      override protected function commitProperties():void {
         super.commitProperties();
         
         if (model.isHighlighted){
            _holdingLabel.filters = NavBar.getNavBarTextFilters(NavBar.FILTERS_OVER);
            
         }else{
            _holdingLabel.filters = NavBar.getNavBarTextFilters(NavBar.FILTERS_NOT_OVER);
            
         }    
      }
      
      override protected function updateDisplayList(w:Number, h:Number):void {
         super.updateDisplayList(w, h);

         _holdingLabel.width=w-2*Deck.NAV_BUTTON_WIDTH;
         _holdingLabel.height=25;
         _holdingLabel.y = h - _holdingLabel.height/2 - 27;
         _holdingLabel.x=Deck.NAV_BUTTON_WIDTH;
         _holdingLabel.setStyle("textAlign","center");
         _holdingLabel.setStyle("fontSize",Footer.FONT_SIZE_LABEL + 7);
         _holdingLabel.setStyle("backgroundColor",0xd6d6d6);
         _holdingLabel.setStyle('color', 0xFFFFFF);
      }
      
      override protected function createChildren():void {
         super.createChildren();
         _holdingLabel = new Label();
         _holdingLabel.visible=false;
         
         addChild(_holdingLabel);
      }
      
      private function updateHoldingTextOnEvent(event:Event):void{
         updateHoldingText();
         if (_holdingLabel!=null){
            if (_holdingLabelText==null){
               _holdingLabel.text="";
               _holdingLabel.visible=false;
            }else{
               _holdingLabel.text=_holdingLabelText;
               _holdingLabel.visible=true;
            }
         }
      }
      
      private function updateHoldingText():void{
         if (ApplicationManager.getInstance().currentUser.isAnonymous()){
            _holdingLabelText = null;
            return;
         }
         var msgType:int = (deckModel as DropZoneDeckModel).holdingMsgType;
         if (msgType==_previousMsgType){
            return;
         }
         var i18nKey:String = "bottombar.dropzone.empty";
         if (msgType==DropZoneDeckModel.HOLDING_NO_MSG){
            i18nKey=null;
         }else if (model.timesHasBeenClicked == 0) {
            i18nKey=null;
            
         }else if (model.timesHasBeenClicked == 1) {
            
         }else if (model.timesHasBeenClicked > 2) {
            i18nKey = null;
            
         }else if (msgType==DropZoneDeckModel.HOLDING_MY_ASSO_EMPTY){
            i18nKey = i18nKey.concat(".myassociation");
         }else if (msgType==DropZoneDeckModel.HOLDING_MY_ASSO_DRAGGED){
            i18nKey = i18nKey.concat(".myassociationdrag");
         }else if (msgType==DropZoneDeckModel.HOLDING_OTHER_ASSO_EMPTY){
            i18nKey = i18nKey.concat(".othersassociation");
         }else if (msgType==DropZoneDeckModel.HOLDING_OTHER_ASSO_DRAGGED){
            i18nKey = i18nKey.concat(".othersassociationdrag");
         }else if (msgType==DropZoneDeckModel.HOLDING_PTW_EMPTY){
            i18nKey = i18nKey.concat(".ptw");
         }

         if (i18nKey==null){
            _holdingLabelText = null;
         }else{
            if (this.width<800){
               i18nKey = i18nKey.concat(".small");
            }else{
               i18nKey = i18nKey.concat(".large");
            }
            _holdingLabelText = BroLocale.getInstance().getText(i18nKey);
         }
         this.invalidateProperties();
      }
      
      override protected function get extraPaddingLeft():Number {
         return 10;
      }
      
      private function onClick(event:Event):void {
         model.registerNewClick();
      }
   }
}