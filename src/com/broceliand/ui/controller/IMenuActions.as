package com.broceliand.ui.controller
{
   
   public interface IMenuActions
   {
      function login(goHomeOnLogin:Boolean=true):void;		
      function signUp(goHomeOnLogin:Boolean=true):void;
      function logout():void;			
      function showSettings():void;		
      function giveFeedback():void;
      function givePremiumSupport():void;
      function configurePearlByMail():void;
      function contact():void;		
      function showBlog():void;
      function showPress():void;
      function showTwitter():void;
      function showFacebook():void;
      function showJobs():void;
      function showIdentitySettings():void;
      function showAccountSettings():void;
      function showPremiumSettings():void;
      function showNotificationSettings():void;
      function showExportSettings():void;
      function showInviteWindow(findMode:Boolean = false):void;    
      function showForum():void;
      function gettingStarted():void;
      function openTeam():void;
      function openAbout():void;
      function openFaqTab():void;
      function openIOSTab():void;
      function openYoutubeVideoTab():void;
      function hideFaq():void;
      function openPremiumTab():void;
   }
}