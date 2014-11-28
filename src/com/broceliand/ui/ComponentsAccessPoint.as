package com.broceliand.ui
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.extra.delegates.ContextualHelpDelegate;
   import com.broceliand.graphLayout.controller.GraphicalAnimationRequestProcessor;
   import com.broceliand.player.IPearlTreePlayer;
   import com.broceliand.player.PlayerModuleLoader;
   import com.broceliand.ui.assemblerinfotip.IPTInfotipManager;
   import com.broceliand.ui.assemblerinfotip.PTInfotipManager;
   import com.broceliand.ui.controller.IPearlbarInfo;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.embed.window.WindowControllerEmbed;
   import com.broceliand.ui.panel.MainPanel;
   import com.broceliand.ui.panel.TopPanel;
   import com.broceliand.ui.pearlBar.Footer;
   import com.broceliand.ui.pearlBar.IFooter;
   import com.broceliand.ui.pearlTree.IPearlTreeViewer;
   import com.broceliand.ui.pearlTree.RavisPearlTreeViewer;
   import com.broceliand.ui.screenwindow.IScreenLine;
   import com.broceliand.ui.settings.ISettings;
   import com.broceliand.ui.settings.SettingsModuleLoader;
   import com.broceliand.ui.sticker.help.IContextualHelp;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.ui.window.ui.signUpBanner.SignUpBanner;

   public class ComponentsAccessPoint
   {
      private var _pearlTreePlayer:IPearlTreePlayer;
      private var _screenLine:IScreenLine;
      private var _pearlTreeViewer:RavisPearlTreeViewer;
      private var _windowController:IWindowController;
      private var _settings:ISettings;
      private var _mainPanel:MainPanel;
      private var _topPanel:TopPanel;
      private var _pearlbarInfo:IPearlbarInfo;
      private var _contextualHelp:ContextualHelpDelegate;
      private var _infotipManager:IPTInfotipManager;
      
      public function ComponentsAccessPoint(garp:GraphicalAnimationRequestProcessor) {
         var am:ApplicationManager = ApplicationManager.getInstance();
         _pearlTreeViewer = new RavisPearlTreeViewer(garp);
         if(am.isEmbed() || am.isEmbedWindowMode() || am.isOverlay()) {
            _windowController = new WindowControllerEmbed();
         }else{
            _windowController = new WindowController();
         }
         _pearlTreePlayer = PlayerModuleLoader.getInstance();
         _screenLine = PlayerModuleLoader.getInstance();
         _settings = new SettingsModuleLoader();
         _infotipManager = new PTInfotipManager;
      }
      
      public function get windowController():IWindowController {
         return _windowController;
      }
      
      public function get pearlTreePlayer():IPearlTreePlayer {
         return _pearlTreePlayer;
      }
      
      public function get screenLine():IScreenLine {
         return _screenLine;
      } 
      
      public function get pearlTreeViewer():IPearlTreeViewer {
         return _pearlTreeViewer;
      }
      
      public function get settings():ISettings {
         return _settings;
      }
      
      public function getContextualHelp(instanciate:Boolean= true):IContextualHelp {
         if (!_contextualHelp && instanciate){
            _contextualHelp = new ContextualHelpDelegate();
         }
         return _contextualHelp;
      }
      
      public function set mainPanel(mainPanel:MainPanel):void {
         _mainPanel = mainPanel;
      }      
      
      public function get mainPanel():MainPanel {
         if (!_mainPanel) {
            return ApplicationManager.getInstance().components.topPanel.mainPanel;
         }
         return _mainPanel;
      }
      
      public function set topPanel(value:TopPanel):void {
         _topPanel = value;
      }
      
      public function get topPanel():TopPanel {
         return _topPanel;
      }
      
      public function set pearlbarInfo(value:IPearlbarInfo):void {
         _pearlbarInfo = value;
      }
      
      public function get pearlbarInfo():IPearlbarInfo {
         return _pearlbarInfo;
      }
      
      public function get footer():IFooter {
         return _pearlTreeViewer.vgraph.controls.footer;
      }
      
      public function get infotipManager():IPTInfotipManager {
         return _infotipManager;
      }
   }
}