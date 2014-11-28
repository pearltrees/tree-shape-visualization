package com.broceliand.ui.panel {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.InfoPanelAssets;
   import com.broceliand.pearlTree.io.services.AmfUserService;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.impl.SpecialPearltreesConst;
   import com.broceliand.ui.controller.IMenuActions;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.faq.FaqTypes;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearlByMail.PearlByMailWindowHelper;
   import com.broceliand.ui.pearlWindow.PremiumWindowHelper;
   import com.broceliand.ui.sticker.help.IContextualHelp;
   import com.broceliand.ui.welcome.HomePageModel;
   import com.broceliand.ui.welcome.tunnel.TunnelNavigationModel;
   import com.broceliand.ui.window.PTWindowModel;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.ui.window.ui.infoWindow.InfoWindow;
   import com.broceliand.ui.window.ui.infoWindow.InfoWindowModel;
   import com.broceliand.util.Alert;
   import com.broceliand.util.BroLocale;
   import com.broceliand.util.EmailClientHelper;
   
   import flash.events.Event;
   
   public class MenuActions implements IMenuActions {
      
      private var am:ApplicationManager;
      private var bl:BroLocale;
      
      public function MenuActions(){
         super();
         am = ApplicationManager.getInstance();
         am.menuActions = this;
      }
      
      private function get homePageModel():HomePageModel {
         return ApplicationManager.getInstance().visualModel.homePageModel;
      }
      
      public function logout():void {
         am.accountManager.logout();
      }
      
      private function hidePlayer():void {
         am.components.pearlTreePlayer.hidePlayer();
      }
      
      private function hideTunnel():void {
         am.visualModel.navigationModel.getTunnelModel().exitTunnelNow();
      }
      
      public function login(goHomeOnLogin:Boolean=true):void {
         showHomePage(true, goHomeOnLogin);
      }
      
      public function signUp(goHomeOnLogin:Boolean=true):void {
         showHomePage(false, goHomeOnLogin);
      }
      
      private function showHomePage(showLoginForm:Boolean=false, goHomeOnLogin:Boolean=true):void {
         hidePlayer();
         hideFaq();
         hideTunnel();
         homePageModel.goHomeOnLogin = goHomeOnLogin;
         if (showLoginForm) {
            homePageModel.homeDisplayState = HomePageModel.DISPLAY_MODE_LOGIN;
         }
         else {
            if (ApplicationManager.getInstance().currentUser.isLoggedOnFacebook()) {
               homePageModel.homeDisplayState = HomePageModel.DISPLAY_MODE_FACEBOOK_ACCELERATED;
            }
            else {
               homePageModel.homeDisplayState = HomePageModel.DISPLAY_MODE_SIGN_UP;
            }
         }
         homePageModel.visible = true;
      }
      
      public function help():void {
         hideFaq();
         hidePlayer();
         if (BroLocale.languageIsFrench()) {
            am.visualModel.navigationModel.goTo(SpecialPearltreesConst.TEAM_ASSOCIATION_ID,
               SpecialPearltreesConst.HELP_USER_ID,
               SpecialPearltreesConst.HELP_FR_TREE_ID,
               SpecialPearltreesConst.HELP_FR_TREE_ID,
               SpecialPearltreesConst.HELP_FR_PEARL_ID,
               -1, 0, -1);
         } else {
            am.visualModel.navigationModel.goTo(SpecialPearltreesConst.HELP_ASSOCIATION_ID,
               SpecialPearltreesConst.HELP_USER_ID,
               SpecialPearltreesConst.HELP_EN_TREE_ID,
               SpecialPearltreesConst.HELP_EN_TREE_ID,
               SpecialPearltreesConst.HELP_EN_PEARL_ID,
               -1, 0, -1);
         }
      }

      private function hideContextualHelp(am:ApplicationManager):void {
         var help:IContextualHelp = am.components.getContextualHelp(false);
         if (help) {
            help.hide();
         }
      }

      public function gettingStarted():void{
         hidePlayer();
         hideFaq();
         if (am.currentUser.isAnonymous()) {
            homePageModel.homeDisplayState = HomePageModel.DISPLAY_MODE_SIGN_UP;
         } else {
            am.components.getContextualHelp(true).show();
         }
      }
      
      public function showSettings():void {
         hidePlayer();
         hideFaq();
         hideContextualHelp(am);
         am.components.settings.visible = true;
      }
      
      public function showIdentitySettings():void {
         showSettings();
         am.components.settings.showIdentityForm();
      }
      public function showAccountSettings():void {
         showSettings();
         am.components.settings.showAccountForm();
      }
      public function showPremiumSettings():void {
         PremiumWindowHelper.openSettingsPage();
      }
      public function showNotificationSettings():void {
         showSettings();
         am.components.settings.showNotificationsForm();
      }
      
      public function showExportSettings():void {
         showSettings();
         am.components.settings.showExportForm();
      }
      
      public function showInviteWindow(findMode:Boolean = false):void {
         var wc:IWindowController = am.components.windowController;
         if(wc.isInviteWindowOpen()) {
            wc.closeInviteWindow();
         }
         else{
            wc.openInviteWindow(null, false, findMode);
         }
      }
      
      public function giveFeedback():void {
         hideFaq();
         var subject:String= BroLocale.getText('feedback.mail.subject');
         var body:String= BroLocale.getText('feedback.mail.body');
         
         EmailClientHelper.openNewEmail("participation@pearltrees.com", subject, body);
      }
      
      public function givePremiumSupport():void {
         hideFaq();
         var textKey:String = "premium.support";
         var windowController:IWindowController = ApplicationManager.getInstance().components.windowController;
         var infoWindowModel:InfoWindowModel = windowController.openInfoWindow(
            textKey, 
            InfoPanelAssets.MAIL_PREMIUM, 
            InfoWindowModel.BUTTON_TYPE_OK,
            [BroLocale.getInstance().getText("information.panel.premium.support.link")]
         );
         if (infoWindowModel) {
            infoWindowModel.addEventListener(PTWindowModel.WINDOW_CLOSE, onClickCancelMailSupport);
            infoWindowModel.addEventListener(InfoWindowModel.CLICK_BUTTON, onClickCancelMailSupport);
            infoWindowModel.addEventListener(InfoWindowModel.LINK + 0, onClickMailSupport);
         }
      }
      
      private function onClickMailSupport(event:Event):void {
         removeInfoWindowListenersForMailSupport(event);
         var subject:String= BroLocale.getText('premium.support.mail.subject');
         var UserName:String= ApplicationManager.getInstance().currentUser.name;
         var body:String= BroLocale.getText('premium.support.mail.body',[UserName]);
         EmailClientHelper.openNewEmail("premium@pearltrees.com", subject, body);
      }
      
      private function onClickCancelMailSupport(event:Event):void{
         removeInfoWindowListenersForMailSupport(event);
      }
      
      private function removeInfoWindowListenersForMailSupport (event:Event):void{
         if (event && event.target && event.target is InfoWindowModel) {
            var infoWindowModel:InfoWindowModel = InfoWindowModel(event.target);
            infoWindowModel.removeEventListener(PTWindowModel.WINDOW_CLOSE, onClickCancelMailSupport);
            infoWindowModel.removeEventListener(InfoWindowModel.CLICK_BUTTON, onClickCancelMailSupport);
            infoWindowModel.removeEventListener(InfoWindowModel.LINK, onClickCancelMailSupport);
         }
      }
      
      public function configurePearlByMail():void {
         hideFaq();
         var service:AmfUserService = ApplicationManager.getInstance().distantServices.amfUserService;
         var currentUser:User = ApplicationManager.getInstance().currentUser;
         var pbm:PearlByMailWindowHelper = new PearlByMailWindowHelper();
         service.isPearlByMailActivated(currentUser, pbm);
         /*var im:InteractorManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager;
         ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.turnOffSelectionOnOver(true, WindowController.INFO_PANEL_WINDOW);*/
      }
      
      public function contact():void {
         am.getExternalInterface().openWindow('http://blog.pearltrees.com/?page_id=6637', "_blank");
      }
      public function showBlog():void{
         am.getExternalInterface().openWindow('http://blog.pearltrees.com/', "_blank");
      }
      public function showPress():void{
         am.getExternalInterface().openWindow(BroLocale.getText("menu.action.pressUrl"), "_blank");
      }
      
      public function showTwitter():void{
         hideContextualHelp(am);
         am.getExternalInterface().openWindow('http://twitter.com/pearltrees', "_blank");
      }
      public function showFacebook():void{
         hideContextualHelp(am);
         am.getExternalInterface().openWindow('http://www.facebook.com/pearltrees', "_blank");
      }
      public function showJobs():void{
         hideContextualHelp(am);
         am.getExternalInterface().openWindow('http://blog.pearltrees.com/?page_id=8119', "_blank");
      }
      public function showForum():void{
         hideContextualHelp(am);
         am.getExternalInterface().openWindow('http://www.pearltrees.com/forum/', "_blank");
      }
      
      public function openAbout():void{
         hideFaq();
         if (BroLocale.languageIsFrench()) {
            am.visualModel.navigationModel.goTo(SpecialPearltreesConst.ABOUT_ASSOCIATION_ID,
               SpecialPearltreesConst.ABOUT_USER_ID,
               SpecialPearltreesConst.ABOUT_FR_TREE_ID,
               SpecialPearltreesConst.ABOUT_FR_TREE_ID,
               SpecialPearltreesConst.ABOUT_FR_PEARL_ID,
               -1, 0, -1);
         } else {
            am.visualModel.navigationModel.goTo(SpecialPearltreesConst.ABOUT_ASSOCIATION_ID,
               SpecialPearltreesConst.ABOUT_USER_ID,
               SpecialPearltreesConst.ABOUT_EN_TREE_ID,
               SpecialPearltreesConst.ABOUT_EN_TREE_ID,
               SpecialPearltreesConst.ABOUT_EN_PEARL_ID,
               -1, 0, -1);
         }
         
      }
      
      public function openTeam():void{
         hideContextualHelp(am);
         hideFaq();
         am.visualModel.navigationModel.goTo(SpecialPearltreesConst.TEAM_ASSOCIATION_ID,
            SpecialPearltreesConst.TEAM_USER_ID,
            SpecialPearltreesConst.TEAM_TREE_ID,
            SpecialPearltreesConst.TEAM_TREE_ID,
            SpecialPearltreesConst.TEAM_PEARL_ID,
            -1, 0, -1);
      }
      
      public function openFaqTab():void{
         hideContextualHelp(am);
         var faqURL:String = am.getServicesUrl();
         bl=BroLocale.getInstance();
         if (bl.lang==BroLocale.ENGLISH){
            faqURL+=BroLocale.FAQ_URL_EN;
         }
         else if (bl.lang==BroLocale.FRENCH){
            faqURL+=BroLocale.FAQ_URL_FR;
         }
         else{
            faqURL+=BroLocale.DEFAULT_FAQ_URL;
         }
         am.getExternalInterface().openWindow(faqURL,"_blank");
      } 
      
      public function openIOSTab():void{
         hideContextualHelp(am);
         bl=BroLocale.getInstance();
         if (bl.lang==BroLocale.ENGLISH){
            am.getExternalInterface().openWindow("http://itunes.apple.com/app/pearltrees/id463462134?mt=8", "_blank");
         }
         else if (bl.lang==BroLocale.FRENCH){
            am.getExternalInterface().openWindow("http://itunes.apple.com/fr/app/pearltrees/id463462134?mt=8", "_blank");
         }
         else {
            am.getExternalInterface().openWindow("http://itunes.apple.com/app/pearltrees/id463462134?mt=8", "_blank");
         }
      } 
      
      public function openYoutubeVideoTab():void {
         hideContextualHelp(am);
         var videoId:String= BroLocale.getText('welcome.video.youtubeVideoId');
         am.getExternalInterface().openWindow("http://www.youtube.com/watch?v=" + videoId, "_blank");
      }
      
      public function hideFaq():void {
         am.visualModel.homePageModel.setFaqVisible(FaqTypes.TYPE_FAQ, false);
      }
      
      public function openPremiumTab():void{
         hideContextualHelp(am);
         var premiumURL:String = am.getServicesUrl();
         bl=BroLocale.getInstance();
         if (bl.lang==BroLocale.ENGLISH){
            premiumURL+=BroLocale.PREMIUM_URL_EN;
         }
         else if (bl.lang==BroLocale.FRENCH){
            premiumURL+=BroLocale.PREMIUM_URL_FR;
         }
         else{
            premiumURL+=BroLocale.DEFAULT_PREMIUM_URL;
         }
         am.getExternalInterface().openWindow(premiumURL,"_blank");
      } 
      
   }
}