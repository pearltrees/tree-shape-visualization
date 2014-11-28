package com.broceliand.ui.util
{
   import com.broceliand.ApplicationManager;
   
   import flash.net.SharedObject;
   
   [Bindable]
   public class ColorPalette
   {
      private static var _singleton:ColorPalette;
      
      public static const PEARLTREES_WELCOME_LIGHT_GRAY:int = 0xCDCDCD;
      public static const PEARLTREES_WELCOME_DARK_GRAY:int = 0x989898;
      public static const PEARLTREES_WELCOME_LIGHT_BLUE:int = 0x619AC2;
      public static const PEARLTREES_WELCOME_DARK_BLUE:int = 0x446B87;
      
      public static const PEARLTREES_LIGHT_COLOR:int = 0x4cbbe9;
      public static const PEARLTREES_COLOR:int = 0x505050;
      public static const PEARLTREES_COLOR_FOR_SYSTEM_FONT:int = 0x5E5E5E;
      public static const PEARLTREES_COLOR_FOR_SYSTEM_FONT_LIGHT:int = 0x909090;
      public static const PEARLTREES_PW_LIGHT_COLOR:Number = 0x8a8a8a;
      public static const PEARLTREES_DARK_COLOR:int = 0x009EE0;
      public static const PEARLTREES_ULTRADARK_COLOR:int = 0x0055E0;
      public static const PEARLTREES_LIGHT_GRAY_COLOR:int= 0xA0A0A0;
      public static const PEARLTREES_ULTRALIGHT_GRAY_COLOR:Number= 0xC1C1C1;      
      public static const PEARLTREES_GREEN_COLOR:int = 0x05C900;
      public static const PEARLTREES_BADGE_START_COLOR:int  = 0xFF0000;
      public static const PEARLTREES_BADGE_END_COLOR:int  = 0xB30303;
      
      public static const PEARLTREES_DARK_GREEN_COLOR:int = 0x05AB01;
      public static const PEARLTREES_BOX_ALPHA:Number = 1;
      public static const PEARLTREES_BAR_ALPHA:Number = 0.84;
      public static const NOTE_LIGHT_COLOR:int = 0xFFE400;
      public static const NOTE_COLOR:int = 0xFFBA00;
      public static const NOTE_TEXT_COLOR:int = 0xAAAAAA;
      public static const NOTE_DARK_COLOR:int = 0xFF9C00;
      
      public static const CONNECTION_LIGHT_COLOR:int = 0x00D8FF;
      public static const CONNECTION_COLOR:int = 0x00A8FF;
      public static const CONNECTION_DARK_COLOR:int = 0x0072FF;
      
      public static const ERROR_COLOR:int = 0xFF6C00;
      public static const PEARLTREES_EMBED_COLOR:int = 0x000000;
      public static const BACKGROUND_COLOR:int = 0xFFFFFF;
      
      private var _pearltreesColor:int = PEARLTREES_COLOR;
      private var _pearltreesColorForSystemFont:int = PEARLTREES_COLOR_FOR_SYSTEM_FONT;
      private var _pearltreesColorForSystemFontLight:int = PEARLTREES_COLOR_FOR_SYSTEM_FONT_LIGHT;
      private var _pearltreesDarkColor:int = PEARLTREES_DARK_COLOR;
      private var _pearltreesUltraDarkColor:int = PEARLTREES_ULTRADARK_COLOR;
      private var _pearltreesLightColor:int = PEARLTREES_LIGHT_COLOR;
      private var _noteColor:int = NOTE_COLOR;
      private var _noteTextColor:int = NOTE_TEXT_COLOR;
      private var _noteDarkColor:int = NOTE_DARK_COLOR;
      private var _noteLightColor:int = NOTE_LIGHT_COLOR;
      private var _connectionColor:int = CONNECTION_COLOR;
      private var _connectionDarkColor:int = CONNECTION_DARK_COLOR;
      private var _connectionLightColor:int = CONNECTION_LIGHT_COLOR;
      private var _backgroundColor:int = BACKGROUND_COLOR;
      private var _errorColor:int = ERROR_COLOR;
      private var _pearltreesEmbedColor:int = PEARLTREES_EMBED_COLOR;
      
      private var _homeLightColor:int = PEARLTREES_WELCOME_LIGHT_GRAY;
      private var _homeDarkColor:int = PEARLTREES_WELCOME_DARK_GRAY;
      private var _homeLightBlueColor:int = PEARLTREES_WELCOME_LIGHT_BLUE;
      private var _homeDarkBlueColor:int = PEARLTREES_WELCOME_DARK_BLUE;
      
      private var _customColors:SharedObject;
      
      public function ColorPalette()
      {
      }
      
      public static function getInstance():ColorPalette {
         if (!_singleton) {
            _singleton = new ColorPalette();
            _singleton.init();
         }
         return _singleton;
      }
      
      private function init():void {
         loadCustomColorsFromCache();
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed() || am.isEmbedWindowMode() || am.isOverlay()) {
            pearltreesColor = PEARLTREES_EMBED_COLOR;
         }
      }
      
      public static function uintToHex(value:uint):String {
         var prefix:String = "000000";
         var str:String = String(prefix + value.toString(16));
         return str.substr(-6).toUpperCase();
      }
      
      private function loadCustomColorsFromCache():void {
         try {
            _customColors = SharedObject.getLocal("customColors");
         } catch (e:Error) {
            return;
         }
         var colors:Object = _customColors.data as Object;
         if(colors) {
            if(colors.pearltreesColor != null) {
               _pearltreesColor = colors.pearltreesColor;
            }
            if(colors.pearltreesColorForSystemFont != null) {
               _pearltreesColorForSystemFont = colors.pearltreesColorForSystemFont;
            }
            if(colors.pearltreesDarkColor != null) {
               _pearltreesDarkColor = colors.pearltreesDarkColor;
            }
            if(colors.pearltreesUltraDarkColor != null) {
               _pearltreesUltraDarkColor = colors.pearltreesUltraDarkColor;
            }
            if(colors.pearltreesLightColor != null) {
               _pearltreesLightColor = colors.pearltreesLightColor;
            }
            if(colors.noteColor != null) {
               _noteColor = colors.noteColor;
            }
            if(colors.noteDarkColor != null) {
               _noteDarkColor = colors.noteDarkColor;
            }
            if(colors.noteLightColor != null) {
               _noteLightColor = colors.noteLightColor;
            }
            if(colors.connectionColor != null) {
               _connectionColor = colors.connectionColor;
            }
            if(colors.connectionDarkColor != null) {
               _connectionDarkColor = colors.connectionDarkColor;
            }
            if(colors.connectionLightColor != null) {
               _connectionLightColor = colors.connectionLightColor;
            }
            if(colors.backgroundColor != null) {
               _backgroundColor = colors.backgroundColor;
            }
            if(colors.errorColor != null) {
               _errorColor = colors.errorColor;
            }
            if(colors.homeLightColor != null) {
               _homeLightColor = colors.homeLightColor;
            }
            if(colors.homeLightColor != null) {
               _homeDarkColor = colors.homeDarkColor;
            }
         }
      }
      public function saveColorsInCache():void {
         if (_customColors) {
            var colors:Object = _customColors.data as Object;
            colors.pearltreesColor = _pearltreesColor;
            colors.pearltreesColorForSystemFont = _pearltreesColorForSystemFont;
            colors.pearltreesDarkColor = _pearltreesDarkColor;
            colors.pearltreesUltraDarkColor = _pearltreesUltraDarkColor;
            colors.pearltreesLightColor = _pearltreesLightColor;
            colors.noteColor = _noteColor;
            colors.noteDarkColor = _noteDarkColor;
            colors.noteLightColor = _noteLightColor;
            colors.connectionColor = _connectionColor;
            colors.connectionDarkColor = _connectionDarkColor;
            colors.connectionLightColor = _connectionLightColor;
            colors.backgroundColor = _backgroundColor;
            colors.errorColor = _errorColor;
            colors.homeLightColor = _homeLightColor;
            colors.homeDarkColor = _homeDarkColor;
         }
         try {
            _customColors.flush();
         } catch (e:Error) {
            
         }
      }

      public function get pearltreesColor():int {
         return _pearltreesColor;
      }
      public function set pearltreesColor(value:int):void {
         _pearltreesColor = value;
      }
      
      public function get pearltreesColorForSystemFont():int {
         return _pearltreesColorForSystemFont;
      }
      public function set pearltreesColorForSystemFont(value:int):void {
         _pearltreesColorForSystemFont = value;
      }
      
      public function get pearltreesColorForSystemFontLight():int {
         return _pearltreesColorForSystemFontLight;
      }
      public function set pearltreesColorForSystemFontLight(value:int):void {
         _pearltreesColorForSystemFontLight = value;
      }

      public function get pearltreesDarkColor():int {
         return _pearltreesDarkColor;
      }
      public function set pearltreesDarkColor(value:int):void {
         _pearltreesDarkColor = value;
      }
      
      public function get pearltreesUltraDarkColor():int {
         return _pearltreesUltraDarkColor;
      }
      public function set pearltreesUltraDarkColor(value:int):void {
         _pearltreesUltraDarkColor = value;
      }
      
      public function get pearltreesLightColor():int {
         return _pearltreesLightColor;
      }
      public function set pearltreesLightColor(value:int):void {
         _pearltreesLightColor = value;
      }

      public function get noteColor():int {
         return _noteColor;
      }
      public function set noteColor(value:int):void {
         _noteColor = value;
      }
      
      public function get noteTextColor():int {
         return _noteTextColor;
      }
      public function set noteTextColor(value:int):void {
         _noteTextColor = value;
      }
      
      public function get noteDarkColor():int {
         return _noteDarkColor;
      }
      public function set noteDarkColor(value:int):void {
         _noteDarkColor = value;
      }

      public function get noteLightColor():int {
         return _noteLightColor;
      }
      public function set noteLightColor(value:int):void {
         _noteLightColor = value;
      }

      public function get connectionColor():int {
         return _connectionColor;
      }
      public function set connectionColor(value:int):void {
         _connectionColor = value;
      }

      public function get connectionDarkColor():int {
         return _connectionDarkColor;
      }
      public function set connectionDarkColor(value:int):void {
         _connectionDarkColor = value;
      }
      
      public function get connectionLightColor():int {
         return _connectionLightColor;
      }
      public function set connectionLightColor(value:int):void {
         _connectionLightColor = value;
      }
      
      public function get backgroundColor():int {
         return _backgroundColor;
      }
      public function set backgroundColor(value:int):void {
         _backgroundColor = value;
      }

      public function get errorColor():int {
         return _errorColor;
      }
      public function set errorColor(value:int):void {
         _errorColor = value;
      }
      public function set pearltreesEmbedColor (value:int):void {
         _pearltreesEmbedColor = value;
      }
      
      public function get pearltreesEmbedColor ():int
      {
         return _pearltreesEmbedColor;
      }
      
      public function set homeLightColor (value:int):void {
         _homeLightColor  = value;
      }
      
      public function get homeLightColor  ():int
      {
         return _homeLightColor ;
      }
      
      public function set homeDarkColor (value:int):void {
         _homeDarkColor  = value;
      }
      
      public function get homeDarkColor  ():int
      {
         return _homeDarkColor ;
      }
      
      public function get homeBlue():int
      {
         return _homeLightBlueColor;
      }
      
      public function set homeBlue(value:int):void
      {
         _homeLightBlueColor = value;
      }
      
      public function get homeDarkBlue():int
      {
         return _homeDarkBlueColor;
      }
      
      public function set homeDarkBlue(value:int):void
      {
         _homeDarkBlueColor = value;
      }

   }
}