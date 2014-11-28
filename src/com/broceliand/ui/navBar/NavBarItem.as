package com.broceliand.ui.navBar {
   
   import com.broceliand.assets.NavBarAssets;
   import com.broceliand.ui.PTStyleManager;
   import com.broceliand.ui.button.PTButton;
   import com.broceliand.ui.button.PTLinkButton;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.ui.welcome.Facepile;
   
   import flash.events.Event;
   
   public class NavBarItem extends PTLinkButton {
      
      private static const RESIZE_MIN_WIDTH:Number = 0; 
      private static const MAX_TREE_ITEM_WIDTH:Number = Facepile.offset_x - 70;
      
      private var _item:NavBarModelItem;
      private var _index:int;      
      private var dataChanged:Boolean;
      private var _isSystemFamilyType:Boolean;
      private var _isSystemFamilyTypeChanged:Boolean;

      public function NavBarItem() {
         super();
         setStyle('color', 0xFFFFFF);
         setStyle('textRollOverColor', 0xFFFFFF);
         setStyle('textSelectedColor', 0xFFFFFF);
         _isSystemFamilyType = false;
         _isSystemFamilyTypeChanged = false; 
      }
      
      override protected function commitProperties():void {
         super.commitProperties();
         filters = NavBar.getNavBarTextFilters();
         
         if(dataChanged) {
            dataChanged = false;
            
            if(!_item || _index < 0) return;
            
            label = _item.text;
            if (_item is NavBarModelTreeItem && _item.resizeToFit) {
               maxWidth = MAX_TREE_ITEM_WIDTH;
            }

            if(enabled != _item.enabled) {
               callLater(setEnabled, new Array(_item.enabled));
            }
            if (_item.isBold){
               setStyle('fontSize', 14);

               setStyle('fontWeight', 'bold');
            }else{

               setStyle('fontWeight', 'normal');
               setStyle('fontSize', 14);
            }

            if(_item.selected) {
               
            }else{
               
            }
         }
         if (_isSystemFamilyTypeChanged) {
            var fontToApply:String = _isSystemFamilyType? PTStyleManager.SYSTEM_FONT_FAMILY : PTStyleManager.DEFAULT_FONT_FAMILY;
            setStyle("fontFamily" , fontToApply); 
         }
      }
      
      private function setEnabled(value:Boolean):void {
         enabled = value;
      }
      
      override public function get minWidth():Number {
         if(measuredMinWidth < RESIZE_MIN_WIDTH) {
            return measuredMinWidth;
         }else{
            return RESIZE_MIN_WIDTH;
         }
      }
      
      public function set item(value:NavBarModelItem):void {
         if(value != _item) {
            if(_item) {
               _item.removeEventListener(NavBarModelItem.MODEL_CHANGE, onItemModelChange);
            }
            _item = value;
            if(_item) {
               _item.addEventListener(NavBarModelItem.MODEL_CHANGE, onItemModelChange);
            }
            dataChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
         }
      }
      
      public function get item():NavBarModelItem {
         return _item;
      }
      
      public function set rollOverStyle(isRollingOver:Boolean):void{
         if (isRollingOver){
            filters = NavBar.getNavBarTextFilters(NavBar.FILTERS_OVER)
         }else{
            if (!selected){
               filters = NavBar.getNavBarTextFilters(NavBar.FILTERS_NOT_OVER);
            }
         }
      }

      private function onItemModelChange(event:Event):void {
         dataChanged = true;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         filters = NavBar.getNavBarTextFilters();
      }
      
      public function set index(value:int):void {
         if(value != _index) {
            _index = value;
            dataChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
         }
      }
      public function get index():int {
         return _index;
      }
      
      public function get resizableWidth():Number {
         var resizableWidth:Number = 0;
         if(_item && _item.resizeToFit) {
            resizableWidth = measuredMinWidth - minWidth;
            if(resizableWidth < 0) resizableWidth = 0;            
         }
         return resizableWidth;
      }
      
      private function resizeText():String {
         if (_item && _item.text) {
            if (width > MAX_TREE_ITEM_WIDTH) {
               return _item.text;
            }
            else {
               return _item.text;
            }
         }
         else {
            return "";
         }
      }
      
      public function set systemFontFamily(value:Boolean):void {
         if (_isSystemFamilyType != value) {
            _isSystemFamilyTypeChanged = true;
            _isSystemFamilyType = value;
            invalidateProperties();
         }
      }
   }
}