function getStartLocationFromURL() {
   var curUrl = window.location.toString();
   var anchor_index = curUrl.indexOf('#/');
   if (anchor_index != -1) {
      return curUrl.substring(anchor_index + 2);
   }else{
      return null;
   }
}

function getUrlParameterByName(name) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

function raiseCommandEvent(commandName, params) {
   var element = document.createElement("flexCommandEvent");
   element.setAttribute("commandName", commandName);
   for(var index in params) {
      element.setAttribute(index, params[index]);
   }
   document.documentElement.appendChild(element);

   var evt = document.createEvent("Events");
   evt.initEvent("flexCommandEvent", true, false);
   element.dispatchEvent(evt);   
}
function setisScrollableWindow(isScrollable) {
   setisOnScrollableWindow(isScrollable);
}
function notifyLogin() {
   raiseCommandEvent("login");
}
function notifyLogout() {
   raiseCommandEvent("logout");
}
function notifyPearlDeleted(pearlUrl) {
   var params = [];
   params['pearlUrl'] = pearlUrl;
   raiseCommandEvent("pearlDeleted", params);
}
function detectPearlbar() {
   raiseCommandEvent("detectPearlbar");
   raiseCommandEvent("getPearlbarVersion");
}
function updateFirefoxAddon(addonTitle, addonURL, addonIcon) {

   if(getOSName() == "Linux") {
      
      openNewPopup(getWebSiteUrl()+"collector/downloadProxy.html?url="+addonURL, 300, 100);
   }
   else {
      openWindow(addonURL, "_top");
   }



}

function callPearlbarCommand(commandName, param) {
   getMainApplication().pearlbarCommand(commandName, param);
}
function onPearlbarCommandEvent(event) {
   var commandName = event.target.getAttribute("commandName");
   if(commandName == "pearlbarIsInstalled") {
      pearlbarIsInstalled = true;
      callPearlbarCommand("pearlbarIsInstalled");
   }
   else if(commandName == "returnPearlbarVersion") {
      var value = event.target.getAttribute("value");
      callPearlbarCommand("setPearlbarVersion", value);
   }
}
if (window.addEventListener) {
   window.addEventListener("pearlbarCommandEvent", onPearlbarCommandEvent, false);
}
else if (window.attachEvent) {
   window.attachEvent("pearlbarCommandEvent", onPearlbarCommandEvent)
}

function notifyNewAccountCreated(userId) {
   
   if(self.location.hostname == "www.pearltrees.com") {

      
      if(pingbackUrl) {
         (new Image).src = pingbackUrl+"&userId="+userId;
      }

      
      if(_gaq) {
         _gaq.push(['_setAllowAnchor', true]);
         _gaq.push(['_trackPageview']);
         _gaq.push(['_trackEvent', 'Home', 'Create Account', self.location.search]);
      }
   }

   
   if(piwikTracker) {
      var pearltreesPingBackUrl = pkBaseURL+"piwik.php?url=" +
      encodeURIComponent(getServicesUrl()+"piwik/logAccountCreated/"+self.location.search) +
      "&action_name=create_account&idsite=" + pkSite + "&title=create_account&urlref=" + encodeURIComponent(document.referrer)+"&rec=1&rand=" + Math.random();
           
      (new Image).src = pearltreesPingBackUrl;
   }
}

function notifyUserHasDockedPearlWindow(userId) {
   (new Image).src = getServicesUrl()+"check/userHasDockedPearlWindow/?userId="+userId;
}

function getBrowserName() {
   return BrowserDetect.browser;
}
function getOSName() {
   return BrowserDetect.OS;
}
function getBrowserVersion() {
   return BrowserDetect.version;
}
function getSessionID() {
   return readCookie('PEARLTREES-AUTH');
}
function readCookie(name) {
   var nameEQ = name + "=";
   var ca = document.cookie.split(';');
   for(var i=0;i < ca.length;i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') c = c.substring(1,c.length);
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
   }
   return null;
}

function getUserLang() {
   return userLang;
}

function createCookie(name,value,seconds) {
   if (seconds) {
      var date = new Date();
      date.setTime(date.getTime()+(seconds*1000));
      var expires = "; expires="+date.toGMTString();
   }
   else var expires = "";
   document.cookie = name+"="+value+expires+"; path=/";
}

function eraseCookie(name) {
   createCookie(name,"",-1);
}

function hideWaitingPanel() {
   stopPreloader();
   getMainApplication().style.width='100%';
   getMainApplication().style.height='100%';
   document.getElementById('page').style.display='none';
   document.getElementById('page').innerHTML='';
}
function onApplicationExit(){
   var app = getMainApplication();
   if(app && app.onApplicationExit) {
      app.onApplicationExit();
   }
}
function getInvitationEmail(){
   return invitationEmail;
}
function getInvitationKey(){
   return invitationKey;
}
function getFbRequestId(){
   return fbRequestId;
}
function getAbModel(){
   return abModel;
}
function getLostPasswordToken(){
   return lostPasswordToken;
}
function getOrigin() {
   return origin;
}
function getUserName() {
   return userName;
}
function getUserId() {
   return userId;
}
function getWebSiteUrl() {
   return webSiteUrl;
}
function getStaticContentUrl() {
   return staticContentUrl;
}
function getFbAppId() {
   return fbAppId;
}
function getLogoUrl() {
   return logoUrl;
}
function getMetaLogoUrl() {
   return metaLogoUrl;
}
function getThumbLogoUrl() {
   return thumbLogoUrl;
}
function getScrapLogoUrl() {
   return scrapLogoUrl;
}
function getAvatarUrl() {
   return avatarUrl;
}
function getBackgroundUrl() {
   return backgroundUrl;
}
function getBiblioUrl() {
   return biblioUrl;
}
function getThumbshotUrl() {
   return thumbshotUrl;
}
function getServicesUrl() {
   return servicesUrl;
}
function getMediaUrl() {
   return mediaUrl;
}
function getShortenerDomain() {
   return shortenerDomain;
}
function getClientLang() {
   var urlParam = getUrlParameterByName("lang");
   if(urlParam) {
      return urlParam;
   }else{
      return clientLang;
   }
}
function getClientId() {
   return clientId;
}
function getLoginUsername() {
   return loginUsername;
}
function getStartTime() {
   return startTime;
}
function getStartupMessage() {
   return startupMessage;
}
function getUserInvitingYou() {
   return userInvitingYou;
}
function getPromoBigWindow() {
   return promoBigWindow;
}

function getAdPermission() {
   var curUrl = window.location.toString();
   if (curUrl.indexOf("ad=no") > 0) {
      return false;
   }
   else {
      return true;
   }
}

function getTeaserMode() {
   return teaserMode;
}
function getAbModel() {
   return abModel;
}
function getCountryCode() {
   return countryCode;
}
function getAddPearlEmail() {
   return pearlByMail;
}
function getPearlWindowStatus() {
   return pearlWindowStatus;
}

function getPromoLittleWindow() {
   return promoLittleWindow;
}

function getArrivalTreeId() {
   return arrivalTreeId;
}

function getPlayerStartUrl() {
   return startPlayerWithUrl;
}
function changeParentUrl(parentUrl) {
   top.location = parentUrl;
}
function getInnerWidth() {
   var windowWidth = window.innerWidth;
   if(!windowWidth) { windowWidth = document.documentElement.clientWidth; }
   if(windowWidth <= 0) { windowWidth = document.body.clientWidth; }
   return windowWidth;
}
function getInnerHeight() {
   var windowHeight = window.innerHeight;
   if(!windowHeight) { windowHeight = document.documentElement.clientHeight; }
   if(windowHeight <= 0) { windowHeight = document.body.clientHeight; }
   return windowHeight;
}
function loadIFrame(frameID, iframeID, url) {
   document.getElementById(iframeID).src = url;
}
function sendStats(title) {
   
   if(self.location.href.indexOf("/#/embedWindow=1") != -1) {
      return;
   }
   
   else if(noStats) {
      
      if(self.location.href.indexOf("DP-n=tunnel") != -1) {
         noStats = false;
      }else{
         return;
      }
   }

   
   if (typeof _gaq !== "undefined") {
      if(_gaq && self.location.hostname == "www.pearltrees.com") {
         _gaq.push(['_setAllowAnchor', true]);
         _gaq.push(['_trackPageview']);
      }
   }

   
   if(typeof piwikTracker != "undefined") {
      (new Image).src = pkBaseURL+"piwik.php?url=" +
      encodeURIComponent(window.location) + "&action_name=" + encodeURIComponent(title) + "&idsite=" + pkSite + "&title=" +
      encodeURIComponent(title) + "&urlref=" + encodeURIComponent(document.referrer)+"&rec=1&rand=" + Math.random(); 
   }
   
   
   var app = getMainApplication();
   if(app && app.onSendPageViewStat) {
      app.onSendPageViewStat();
   }
}

var isReloadingPage = false;
function reloadPage() {
   if (!isReloadingPage){
      isReloadingPage = true;
      self.location.reload(true);
   }
}

function getLocalLastSaveDate() {
   var lastSaveDate = readCookie("lastSaveDate");
   if (lastSaveDate==null) {
      return 0;
   }
   return lastSaveDate
}
function setLocalLastSaveDate(lastSaveDate) {
   createCookie("lastSaveDate", lastSaveDate,5);
}

var prefetchFrameCounter = 0;

function loadPageInIframe(url) {
}

function loadPageInCache(url, keepUrl) {
   var f = document.createElement("iframe");
   f.style.display = "none";
   f.id = "prefetchFrame" + (prefetchFrameCounter++);

   if (keepUrl) {
      f.src  = url;
   } else {
      f.src = staticContentUrl + "s/prefetch/" + (ff ? "link" : "load") + "?url=" + encodeURIComponent(url);
   }
   
   f.onload = function () {pageInCacheLoaded(f.id);};
   document.body.appendChild(f);
   return f.id;
   return loadPageInFrame(cachedUrl);
}

function removePageInCache(id) {
   var f = document.getElementById(id);
   if (f) document.body.removeChild(f);
}

/*function loadPageInCache(url) {
   var v = readCookie("prefetch");
   if (v == "1") {
      setTimeout('loadPageInCache0("' + url + '")', 5000);
   }
}*/

function pageInCacheLoaded(id) {
   var app = getMainApplication();
   if(app && app.onPageInCacheLoaded) {
      app.onPageInCacheLoaded(id);
   }
}
/*
function moveIFrame(frameID, iframeID, x,y,w,h)
{
   var frameRef=document.getElementById(frameID);
   if (frameRef) {
      frameRef.style.left=x;
      frameRef.style.top=y;
      frameRef.width = w;
      frameRef.height = h;
   }
   var iFrameRef=document.getElementById(iframeID);
   if (iFrameRef) {
      iFrameRef.width=w;
      iFrameRef.height=h;
   }
}
 */

function testCookieEnabled(){

   var cookieEnabled=(navigator.cookieEnabled)? true : false
         
         if (typeof navigator.cookieEnabled=="undefined" && !cookieEnabled){
            document.cookie="testcookie"
               cookieEnabled=(document.cookie.indexOf("testcookie")!=-1)? true : false
         }
   return cookieEnabled;
}

function getPotentialBadFrameId() {
   return readCookie("potentialBadFrameId");
}
function savePotentialBadFrameId(lastPearlId) {
   createCookie("potentialBadFrameId", lastPearlId, 60);
}

function openWindow(url, target) {
   var newWin = window.open(url, target);
   return  newWin && !newWin.closed && typeof newWin != 'undefined' && typeof newWin.closed != 'undefined';
}

function openNewPopup(url, width, height) {
   var coordinates = getCenteredCoords(width, height);
   var newWin = window.open(url, "_blank", "location=0,menubar=0,scrollbars=1,toolbar=0,resizable=1,status=0,directories=0,width=" + width + ",height=" + height + ",left=" + coordinates[0] +",top=" + coordinates[1]);
   return  newWin && !newWin.closed && typeof newWin != 'undefined' && typeof newWin.closed != 'undefined';
}

var monitoredPopup;
var intervalChecker;
var monitoredPopupAnswer;

function openMonitoredPopup(url, width, height) {
   var coordinates = getCenteredCoords(width, height);
   monitoredPopupAnswer = null;
   monitoredPopup = window.open(url, "_blank", "location=0,menubar=0,scrollbars=1,toolbar=0,resizable=1,status=0,directories=0," +
         "width=" + width + ",height=" + height + ",left=" + coordinates[0] +",top=" + coordinates[1]);
   if (isMonitoredPopupClosed()) {
      return false;
   }
   intervalChecker = window.setInterval(waitForPopupClose, 80);
   return true;
}

function closeMonitoredPopup() {
   if (monitoredPopup) {
      monitoredPopup.close();
      if ((null !== intervalChecker)) {
         window.clearInterval(intervalChecker);
         intervalChecker = null;
      }
   }
}


function isMonitoredPopupClosed() {
   if (monitoredPopup && monitoredPopupAnswer == null) {
      try {
         monitoredPopupUrl = monitoredPopup.location.href;
         if(monitoredPopupUrl) {
            monitoredPopupAnswer = monitoredPopup.answer;
            if (monitoredPopupAnswer) {
               closeMonitoredPopup();
               return true;
            }
         }
      }catch(error){
      }
   }
   try {
      return !monitoredPopup || monitoredPopup.closed || typeof monitoredPopup == 'undefined' || typeof monitoredPopup.closed=='undefined';
   }
   catch (err) { 
      return true;
   }
}



function waitForPopupClose() {
   if (isMonitoredPopupClosed()) {
      monitoredPopup = null;
      if(getMainApplication()) {
         getMainApplication().onMonitoredPopupClose();
      }

      if ((null !== intervalChecker)) {
         window.clearInterval(intervalChecker);
         intervalChecker = null;
      }
   }
}

function getMonitoredPopupAnswer() {
   return monitoredPopupAnswer;
}



function getCenteredCoords(width, height) {
   var parentSize = this.getWindowInnerSize();
   var parentPos = this.getParentCoords();
   var xPos = parentPos[0] +
   Math.max(0, Math.floor((parentSize[0] - width) / 2));
   var yPos = parentPos[1] +
   Math.max(0, Math.floor((parentSize[1] - height) / 2));
   return [xPos, yPos];
}




function getWindowInnerSize() {
   var width = 0;
   var height = 0;
   var elem = null;
   if ('innerWidth' in window) {
      
      width = window.innerWidth;
      height = window.innerHeight;
   } else {
      
      if (('BackCompat' === window.document.compatMode)
            && ('body' in window.document)) {
         elem = window.document.body;
      } else if ('documentElement' in window.document) {
         elem = window.document.documentElement;
      }
      if (elem !== null) {
         width = elem.offsetWidth;
         height = elem.offsetHeight;
      }
   }
   return [width, height];
}



function getParentCoords() {
   var width = 0;
   var height = 0;
   if ('screenLeft' in window) {
      
      width = window.screenLeft;
      height = window.screenTop;
   } else if ('screenX' in window) {
      
      width = window.screenX;
      height = window.screenY;
   }
   return [width, height];
}



function isBrowserMSIE() { return (getBrowserName() == 'Explorer') }
function isBrowserFirefoxOnMac() { return ( (getBrowserName() == 'Firefox') && (BrowserDetect.OS == "Mac") ) }

function getZoom() { 
   var zoomFactor = getZoomFactor(); 
   return zoomFactor;
}

function isZoomFactorNotOne() {
   var zoomFactor = getZoom();
   if ((zoomFactor < 0.98) || (zoomFactor > 1.02)) return 1;
   return 0;
}

function closeNodeById(id) {
   var node = document.getElementById(id);
   if (node != null) node.parentNode.removeChild(node);
}

function applyStyleToNode(node, styleString) {
   if (isBrowserMSIE()) {
      node.style.setAttribute('cssText', styleString); 
   } else {
      node.setAttribute('style', styleString); 
   }
}

function closeFacepile() {
   closeNodeById("facepileSolidBackground");
   closeNodeById("facepile");
}

function styleFacePile(z_index, absolute_top, absolute_left, _width, _height) {
   var styleString = "";
   styleString += "z-index:" + z_index + "; ";
   styleString += "position: absolute; ";
   styleString += "top:"     + absolute_top  + "px; ";
   styleString += "left:"    + absolute_left + "px; ";
   styleString += "width:"   + _width  + "px; ";
   styleString += "height:"  + _height + "px;";
   return styleString;
}

function openFacepileSolidBackground(z_index, _top, _left, _width, _height) {
   var id = "facepileSolidBackground";
   var node = document.getElementById(id);
   if (node != null) return;
   var body = document.getElementsByTagName("body")[0];
   if (body == null) return;

   var div  = document.createElement('div');
   div.setAttribute('id', id);
   var myStaticContentUrl = getStaticContentUrl();

   var url = getStaticContentUrl() + "flash/solidBackground-ffffff.swf"; 
   

   var styleString  = styleFacePile(z_index, _top, _left, _width, _height);

   applyStyleToNode(div, styleString);

   var flashObject = document.createElement('object');
   flashObject.setAttribute("width",  "100%");
   flashObject.setAttribute("height", "100%");
   flashObject.setAttribute("type",   "application/x-shockwave-flash");
   flashObject.setAttribute("data",   url);

   var flashParamMovie = document.createElement('param');
   flashParamMovie.setAttribute("name",  "movie");
   flashParamMovie.setAttribute("value", url);

   var flashParamWMode = document.createElement('param');
   flashParamWMode.setAttribute("name",  "wmode");
   flashParamWMode.setAttribute("value", "opaque");

   flashObject.appendChild(flashParamMovie);
   flashObject.appendChild(flashParamWMode);

   div.appendChild(flashObject);
   body.appendChild(div);
}

function resizeFacepile(z_index, banner_width, offset_x, offset_y, _width, _height) {
   var absolute_top  = offset_y;
   var absolute_left = newLeft + offset_x;
   var styleString = styleFacePile(z_index, absolute_top, absolute_left, _width, _height);
   var divNode = document.getElementById("facepile");
   if (divNode != null) applyStyleToNode(divNode, styleString);
   var divSolidNode = document.getElementById("facepileSolidBackground");
   if (divNode != null) applyStyleToNode(divSolidNode, styleString);
}

function openFacepile(z_index, banner_width, offset_x, offset_y, _width, _height, url) {
   
   
   var node = document.getElementById("facepile");
   if (node != null) return;
   var body = document.getElementsByTagName("body")[0];
   if (body == null) return;
   var div  = document.createElement('div');
   div.setAttribute('id',    "facepile");
   var absolute_top  = offset_y;
   var absolute_left = offset_x;

   openFacepileSolidBackground(z_index, absolute_top, absolute_left, _width, _height);

   var styleString = styleFacePile(z_index, absolute_top, absolute_left, _width, _height);
   applyStyleToNode(div, styleString);

   var iframe = document.createElement('iframe');
   iframe.setAttribute('src',         url);
   iframe.setAttribute('scrolling',  "no");
   iframe.setAttribute('frameBorder', '0'); 

   var delta = -3;
   var iFrameStyleString = "";
   iFrameStyleString += "border: none; ";
   iFrameStyleString += "overflow: hidden; ";
   iFrameStyleString += "width:"   + _width  + "px; ";
   iFrameStyleString += "height:"  + (_height -2*delta) + "px;";
   iFrameStyleString += "position: relative;";
   iFrameStyleString += "top: " + delta + "px;";
   iFrameStyleString += "background-color: white;";
   applyStyleToNode(iframe, iFrameStyleString);

   div.appendChild(iframe);
   body.appendChild(div);
}





   var fbSdkInitialized;
   var facebookId = null;
   var facebookIdIsLoading = true;

   window.fbAsyncInit = function() {
      
      fbSdkInitialized = false;
       FB.init({
         appId      : getFbAppId(),
         channelUrl : getWebSiteUrl() + 'channel.html', 
         status     : true, 
         cookie     : true, 
         xfbml      : true  
       });
      fbSdkInitialized = true;
      
      FB.getLoginStatus(function(response) {
        facebookIdIsLoading = false;
        if (response.status === 'connected') {
          facebookId = response.authResponse.userID;
        } 
       });
      
    
  };

  
  function loadFacebookSdk(d){
     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement('script'); js.id = id; js.async = true;
     js.src = "//connect.facebook.net/en_US/all.js";
     status: true;
     ref.parentNode.insertBefore(js, ref);
   }

  function getFacebookId() {
    return facebookId;
  }
  
  function getFacebookIdIsLoading() {
    return facebookIdIsLoading;
  }
  
  function updateFacebookToken(updateUrl) {
     var timeout = 10000;
     var listenInterval = 1000;
     $('#fbAuthIframe').get(0).src = updateUrl;
     listenFbAuthIframe(function(result) {
        if(result == "timeout") {
        }else{
        }
           if(getMainApplication()) {
               getMainApplication().onIFrameFilled();
           }
        $('#fbAuthIframe').get(0).src = null;
     }, (new Date()).getTime(), timeout, listenInterval);
  }
  
  function listenFbAuthIframe(callback, startTime, timeout, listenInterval) {
     var iframeUrl = null;
     var iframeContent = null;
     var duration = (new Date()).getTime() - startTime;
     try {
         iframeUrl = $('#fbAuthIframe').get(0).contentWindow.location.href;
         if(iframeUrl && iframeUrl.indexOf(getWebSiteUrl()) == 0) {
            iframeContent = $('#fbAuthIframe').contents().text();
            if(iframeContent == "") iframeContent = null;
         }
     }catch(error){
     }
     if(iframeContent) {
        callback(iframeContent);        
     }
     else {
        if(duration <= timeout) {
           setTimeout("listenFbAuthIframe("+callback+", "+startTime+", "+timeout+", "+listenInterval+")", listenInterval);
        }else {
           callback("timeout");
        }
     }
  }
  




  









  


function installChromeExtension() {
    var apiAvailable = typeof chrome !== 'undefined' && chrome.webstore && chrome.webstore.install;
    if (apiAvailable) { 
        try {
            chrome.webstore.install(undefined, undefined, function(err) {
                apiAvailable = false;
                console.log('inline install failed: ' + err);
            });
        } catch(err) {
           
           console.log('inline install failed: ' + err)
           apiAvailable = false;
        }
    }
    if(!apiAvailable) {
        window.open("https://chrome.google.com/webstore/detail/bgngjfgpahnnncnimlhjgjhdajmaeeoa", "_blank");
    }
}


function getLocationName() {
   return locationName;
}

function getBackgroundHash() {
   return backgroundHash;
}






function downloadURL(url) {
    var hiddenIFrameID = 'hiddenDownloader',
        iframe = document.getElementById(hiddenIFrameID);
    if (iframe === null) {
        iframe = document.createElement('iframe');
        iframe.id = hiddenIFrameID;
        iframe.style.display = 'none';
        document.body.appendChild(iframe);
    }
    iframe.src = url;
};



function isFileApiSupported() {
   return (window.File !== undefined
           && window.FileReader !== undefined 
           && window.FileList != undefined 
           && window.Blob !== undefined);
}

function protectTabDuringUpload(message) {
   window.onbeforeunload = function() {
      onApplicationExit();
      return message;
   }
}

function unprotectTabAfterUpload() {
   window.onbeforeunload = onApplicationExit;
}



var UploadHelper = (function () {
    function UploadHelper() {
    }
    UploadHelper.getHTMLContainer = function () {
        return mainContainer;
    };

    UploadHelper.getFileSelector = function () {
        return document.getElementById("fileSelector");
    };
    return UploadHelper;
})();

var FileBatch = (function () {
    function FileBatch(files, urlIds) {
        this.files = [];
        this.urlIds = [];
        this.excludedFiles = [];
        for (var i = 0; i < files.length; i++) {
            this.files[i] = files[i];
            var file_to_big = files[i].size > Uploader.MAX_FILE_SIZE;
            this.excludedFiles[i] = file_to_big;
        }
        this.urlIds = urlIds;
    }
    FileBatch.prototype.excludeFile = function (position) {
        if (position < this.excludedFiles.length) {
            this.excludedFiles[position] = true;
        }
    };
    return FileBatch;
})();

var Uploader = (function () {
    function Uploader(action) {
        var _this = this;
        this.lastFileSentPosition = -1;
        this.fileBatches = [];
        this.lastBatchSentPosition = -1;
        this.batchNumber = 0;
        this.currentBatchUrlIds = [];
        this.currentBatchSize = 0;
        this.isUploading = false;
        this.sizeFilesSentComplete = 0;
        this.sizeCurrentFileSent = 0;
        this.onFilesSelect = function (evt) {
            _this.waitingFiles = evt.target.files;
            var mainApp = getMainApplication();
            if (mainApp) {
                var fileInfoArray = FileInfo.makeFileInfoArray(_this.waitingFiles);
                mainApp.notifySelectFiles(fileInfoArray, _this.fileBatches.length + 1);
            }
            refreshFileSelectorInHtml();
            
        };
        this.upload_url = getServicesUrl() + action;
        this.uploadStatus_url = getServicesUrl() + 'file/status';
        this.isUploading = false;
    }
    Uploader.getInstance = function () {
        if (!Uploader.instance) {
            Uploader.instance = new Uploader('file/chunks');
        }
        return Uploader.instance;
    };

    Uploader.newInstance = function () {
        Uploader.instance = new Uploader('file/chunks');
        return Uploader.instance;
    };

    Uploader.prototype.openFileSelector = function () {
        var fileSelector = UploadHelper.getFileSelector();
        fileSelector.addEventListener('change', this.onFilesSelect, false);
        fileSelector.click();
    };

    Uploader.prototype.sendCurrentFileSuccess = function () {
        this.lastFileSentPosition++;
        this.sizeFilesSentComplete += this.getCurrentBatchFiles()[this.lastFileSentPosition].size;
        this.sizeCurrentFileSent = 0;

        
        var mainApp = getMainApplication();
        if (mainApp) {
            mainApp.notifyUploadFileComplete(this.lastFileSentPosition, this.lastBatchSentPosition + 1);
        }
        if (this.lastFileSentPosition > this.getCurrentBatchFiles().length - 2) {
            this.sendCurrentBatchComplete();
        } else {
            this.sendNextFileIfExist();
        }
    };

    Uploader.prototype.getCurrentBatchFiles = function () {
        return this.fileBatches[this.lastBatchSentPosition + 1].files;
    };

    Uploader.prototype.getCurrentBatchUrlIds = function () {
        return this.fileBatches[this.lastBatchSentPosition + 1].urlIds;
    };

    Uploader.prototype.sendCurrentBatchComplete = function () {
        this.lastBatchSentPosition++;
        var mainApp = getMainApplication();
        if (mainApp) {
            mainApp.notifyUploadBatchComplete(this.lastBatchSentPosition);
        }
        if (this.lastBatchSentPosition > this.fileBatches.length - 2) {
            this.sendAllFilesSuccess();
        } else {
            this.sendNextBatchIfExist();
        }
    };

    Uploader.prototype.sendCurrentFileError = function () {
        this.excludeFile(this.lastFileSentPosition + 1, this.lastBatchSentPosition + 1);
        var mainApp = getMainApplication();
        if (mainApp) {
            mainApp.notifyUploadFileError(this.lastFileSentPosition + 1, this.lastBatchSentPosition + 1);
        }
        if (this.lastFileSentPosition > this.getCurrentBatchFiles().length - 2) {
            this.sendCurrentBatchComplete();
        } else {
            this.sendNextFileIfExist();
        }
        this.lastFileSentPosition++;
    };

    Uploader.prototype.excludeFile = function (positionFile, positionBatch) {
        if (positionBatch < this.fileBatches.length) {
            var batch = this.fileBatches[positionBatch];
            batch.excludeFile(positionFile);
            if (positionBatch == this.lastBatchSentPosition + 1) {
                this.currentBatchSize -= batch.files[positionFile].size;
            }
        }
    };

    Uploader.prototype.sendNextBatchIfExist = function () {
        this.lastFileSentPosition = -1;
        this.sizeFilesSentComplete = 0;
        var batchToSendPosition = this.lastBatchSentPosition + 1;
        if (batchToSendPosition < this.fileBatches.length) {
            var currentBatch = this.fileBatches[batchToSendPosition];
            this.computeBatchSize();
            this.sendNextFileIfExist();
        } else {
            this.sendAllFilesSuccess();
        }
    };

    Uploader.prototype.sendNextFileIfExist = function () {
        var fileToSendPosition = this.lastFileSentPosition + 1;
        if (fileToSendPosition < this.getCurrentBatchFiles().length) {
            if (this.fileBatches[this.lastBatchSentPosition + 1].excludedFiles[fileToSendPosition]) {
                this.lastFileSentPosition++;
                this.sendNextFileIfExist();
                return;
            }
            var file;
            file = this.getCurrentBatchFiles()[this.lastFileSentPosition + 1];
            this.fileUploader = new FileUploader(file, this, this.getCurrentBatchUrlIds()[fileToSendPosition]);
            this.fileUploader.upload();
            this.sizeCurrentFileSent = 0;
        } else {
            this.sendCurrentBatchComplete();
        }
    };

    Uploader.prototype.computeBatchSize = function () {
        this.currentBatchSize = 0;
        for (var i = 0; i < this.getCurrentBatchFiles().length; i++) {
            if (!this.fileBatches[this.lastBatchSentPosition + 1].excludedFiles[i])
                this.currentBatchSize += this.getCurrentBatchFiles()[i].size;
        }
    };

    Uploader.prototype.computeSentFilesSize = function () {
        var result = 0;
        for (var i = 0; i < this.lastFileSentPosition + 1; i++) {
            if (!this.fileBatches[this.lastBatchSentPosition + 1].excludedFiles[i])
                result += this.getCurrentBatchFiles()[i].size;
        }
        return result;
    };

    Uploader.prototype.notifyUploadStart = function () {
        if (!this.isUploading) {
            this.isUploading = true;
            var mainApp = getMainApplication();
            if (mainApp) {
                mainApp.notifyUploadStart();
            }
        }
    };

    Uploader.prototype.sendAllFilesSuccess = function () {
        this.isUploading = false;
        var mainApp = getMainApplication();
        if (mainApp) {
            mainApp.uploadFilesDone();
        }
    };

    Uploader.prototype.setUrlIdsToWaitingFiles = function (urlIds) {
        if (urlIds.length != this.waitingFiles.length) {
            var mainApp = getMainApplication();
            if (mainApp) {
                mainApp.notifyUploadBatchError(this.fileBatches.length);
            }
            return;
        }
        var newFileBatch = new FileBatch(this.waitingFiles, urlIds);
        this.fileBatches.push(newFileBatch);
        if (!this.isUploading) {
            this.sendNextBatchIfExist();
        }
    };

    Uploader.prototype.removeUploadFile = function (filePosition, batchPosition) {
        this.excludeFile(filePosition, batchPosition);
        if (filePosition == this.lastFileSentPosition + 1 && batchPosition == this.lastBatchSentPosition + 1) {
            this.fileUploader.cancelUpload();
            this.sendNextFileIfExist();
        } else {
        }
        this.updateProgress(this.sizeCurrentFileSent);
    };

    Uploader.prototype.updateProgress = function (bytesSentCurrentFile) {
        this.sizeCurrentFileSent = bytesSentCurrentFile;
        var progressBatch = Math.round((this.sizeCurrentFileSent + this.sizeFilesSentComplete) * 100 / this.currentBatchSize);
        var progressFile = Math.round(this.sizeCurrentFileSent * 100 / this.getCurrentBatchFiles()[this.lastFileSentPosition + 1].size);
        this.fireProgress(progressBatch, progressFile);
    };

    Uploader.prototype.fireProgress = function (batchProgress, fileProgress) {
        var mainApp = getMainApplication();
        if (mainApp) {
            mainApp.updateUploadProgress(batchProgress, fileProgress, this.lastFileSentPosition + 1, this.lastBatchSentPosition + 1);
        }
    };

    Uploader.prototype.cancelUpload = function () {
        this.isUploading = false;
        this.fileUploader.cancelUpload();
    };
    Uploader.MEGABYTE = 1024 * 1024;
    Uploader.CHUNK_SIZE = Uploader.MEGABYTE;
    Uploader.MAX_FILE_SIZE = 300 * Uploader.MEGABYTE;
    return Uploader;
})();

var FileUploader = (function () {
    function FileUploader(file, uploader, urlId) {
        var _this = this;
        this.lastByteSentBeforeCurrentChunk = -1;
        this.retryCount = 0;
        this.isPausing = false;
        this.onXhrStart = function (evt) {
            if (_this.uploader.isUploading) {
            } else {
                _this.uploader.notifyUploadStart();
            }
        };
        this.onXhrLoadEnd = function (evt) {
        };
        this.onXhrLoad = function (evt) {
            _this.handleXhrStatus();
        };
        this.onXhrError = function (evt) {
            _this.handleXhrStatus();
        };
        this.onXhrProgress = function (evt) {
            var bytesSent = _this.lastByteSentBeforeCurrentChunk + evt.loaded;
            _this.uploader.updateProgress(bytesSent);
        };
        this.onXhrAbort = function (evt) {
        };
        this.onXhrStateChange = function (evt) {
        };
        this.file = file;
        this.uploader = uploader;
        this.urlId = parseInt(urlId);
    }
    FileUploader.prototype.cancelUpload = function () {
        if (this.xhr) {
            this.xhr.abort();
            clearInterval(this.restarter);
        }
    };

    FileUploader.prototype.reset = function (file) {
        this.file = file;
        this.lastByteSentBeforeCurrentChunk = -1;
        clearInterval(this.restarter);
    };

    FileUploader.prototype.upload = function () {
        this.uploader.updateProgress(0);
        this.sendNextFileChunk();
    };

    FileUploader.prototype.makeChunk = function (startByte, stopByte) {
        startByte = startByte >= 0 ? startByte : 0;
        stopByte = stopByte >= startByte ? stopByte : this.file.size - 1;
        stopByte = Math.min(stopByte, this.file.size - 1);
        var blob;
        if (Blob.prototype.slice !== undefined) {
            blob = this.file.slice(startByte, stopByte + 1);
        } else if (Blob.prototype.webkitSlice !== undefined) {
            blob = this.file.webkitSlice(startByte, stopByte + 1);
        } else if (Blob.prototype.mozSlice !== undefined) {
            blob = this.file.slice(startByte, stopByte + 1);
        }
        this.currentBlobSize = blob.size;
        return blob;
    };

    FileUploader.prototype.sendNextFileChunk = function () {
        if (this.lastByteSentBeforeCurrentChunk > this.file.size - 2) {
            return;
        }
        var start = this.lastByteSentBeforeCurrentChunk + 1;
        var nextStop = start + Uploader.CHUNK_SIZE;
        if (nextStop > this.file.size - 1) {
            nextStop = this.file.size - 1;
        }
        this.initXHR();
        var chunk = this.makeChunk(start, nextStop);
        var fd = this.addParamsToChunk(chunk);
        this.xhr.send(fd);
    };

    FileUploader.prototype.initXHR = function () {
        this.xhr = new XMLHttpRequest();
        this.xhr.onload = this.onXhrLoad;
        this.xhr.onloadend = this.onXhrLoadEnd;
        this.xhr.onerror = this.onXhrError;
        this.xhr.upload.onprogress = this.onXhrProgress;
        this.xhr.onloadstart = this.onXhrStart;
        this.xhr.onabort = this.onXhrAbort;
        this.xhr.onreadystatechange = this.onXhrStateChange;
        this.xhr.open('POST', this.uploader.upload_url);
    };

    FileUploader.prototype.addParamsToChunk = function (chunk) {
        var fd = new FormData();
        fd.append('urlId', this.urlId.toString());
        fd.append('size', this.file.size.toString());
        fd.append('position', (this.lastByteSentBeforeCurrentChunk + 1).toString());
        fd.append('content', chunk);
        return fd;
    };

    FileUploader.prototype.handleXhrStatus = function () {
        var uploader = Uploader.getInstance();
        if (this.xhr.status == 200) {
            this.lastByteSentBeforeCurrentChunk += this.currentBlobSize;
            this.uploader.updateProgress(this.lastByteSentBeforeCurrentChunk + 1);
            if (this.lastByteSentBeforeCurrentChunk > this.file.size - 2) {
                this.sendFileSuccess();
            } else {
                this.sendNextFileChunk();
            }
        } else if (this.xhr.status == 400) {
            cancelUpload();
            uploader.sendCurrentFileError();
        } else if (this.xhr.status == 409) {
            this.isPausing = true;
            this.tryToRestartUploadingPeriodically();
        } else {
            this.isPausing = true;
            this.tryToRestartUploadingPeriodically();
        }
    };

    FileUploader.prototype.checkUploadStatusFromServer = function () {
        var _this = this;
        var uploader = Uploader.getInstance();
        var uploadStatusRequest = new XMLHttpRequest();
        uploadStatusRequest.open("GET", uploader.uploadStatus_url + "?urlId=" + this.urlId.toString());
        try  {
            uploadStatusRequest.send();
            var that = this;
            uploadStatusRequest.onloadend = function (evt) {
                if (_this.isPausing) {
                    var hasConnection = uploadStatusRequest.status >= 200 && uploadStatusRequest.status < 300 || uploadStatusRequest.status === 304;
                    if (hasConnection) {
                        var json = JSON.parse(uploadStatusRequest.responseText);
                        var uploadStatus = json["FILE_CREATION_STATUS"];
                        if (uploadStatus == 0) {
                            var filePosition = json["FILE_POSITION"];
                            _this.lastByteSentBeforeCurrentChunk = filePosition - 1;
                            _this.checkSuccess();
                        } else if (uploadStatus == 1) {
                            _this.uploader.cancelUpload();
                            _this.uploader.sendCurrentFileError();
                        } else if (uploadStatus == 2) {
                            _this.checkAgain();
                        }
                    } else {
                        _this.checkAgain();
                    }
                }
            };
        } catch (error) {
            this.checkAgain();
        }
    };

    FileUploader.prototype.checkSuccess = function () {
        clearInterval(this.restarter);
        this.resumeUploading();
        this.retryCount = 0;
    };

    FileUploader.prototype.checkAgain = function () {
        this.retryCount++;
    };

    FileUploader.prototype.tryToRestartUploadingPeriodically = function () {
        var that = this;
        this.restarter = setInterval(function () {
            that.checkUploadStatusFromServer();
        }, 3000);
    };

    FileUploader.prototype.resumeUploading = function () {
        if (this.isPausing) {
            this.isPausing = false;
            this.uploader.updateProgress(this.lastByteSentBeforeCurrentChunk + 1);
            this.sendNextFileChunk();
        }
    };

    FileUploader.prototype.sendFileSuccess = function () {
        this.uploader.sendCurrentFileSuccess();
    };
    FileUploader.MAX_RETRY_ACCEPTED = 120;
    return FileUploader;
})();

var FileInfo = (function () {
    function FileInfo(fileName, fileSize) {
        this.fileName = fileName;
        this.fileSize = fileSize;
    }
    FileInfo.makeFileInfoArray = function (fl) {
        var result = [];
        for (var i = 0; i < fl.length; i++) {
            var file = fl[i];
            result[i] = new FileInfo(file.name, file.size);
        }
        return result;
    };

    FileInfo.makeFileInfo = function (f) {
        var fileInfo = new FileInfo(f.name, f.size);
        return fileInfo;
    };
    return FileInfo;
})();

function refreshFileSelectorInHtml() {
    var fileSelector = document.getElementById("fileSelector");
    if (fileSelector) {
        fileSelector.parentNode.removeChild(fileSelector);
    }
    fileSelector = document.createElement('input');
    fileSelector.setAttribute('type', 'file');
    fileSelector.setAttribute('id', 'fileSelector');
    fileSelector.setAttribute('multiple', 'multiple');
    fileSelector.setAttribute('width', '1000');
    fileSelector.setAttribute('height', '1000');
    fileSelector.setAttribute('top', '0');
    fileSelector.setAttribute('left', '0');
    UploadHelper.getHTMLContainer().appendChild(fileSelector);
}

function uploadDocuments() {
    Uploader.getInstance().openFileSelector();
}

function applyUrlIdToUploadingFiles(urlIds) {
    var uploader = Uploader.getInstance();
    uploader.setUrlIdsToWaitingFiles(urlIds);
}

function cancelUpload() {
    var uploader = Uploader.getInstance();
    if (uploader) {
        uploader.cancelUpload();
    }
}

function removeUploadFile(filePosition, batchPosition) {
    var uploader = Uploader.getInstance();
    uploader.removeUploadFile(filePosition, batchPosition);
}

function listenToFireFoxAddonInstallation() {
   if (window.addEventListener !== undefined) {
      window.addEventListener('addonPearltreesInstalled', function() { notifyAddonInstalledFF() });
   }
}

function notifyAddonInstalledFF() {
   var app = getMainApplication();
   if(app) {
      app.notifyAddonInstalledFF();
   }
}

function isBrowserMSIEMetro() {
   return isBrowserMSIE() && getBrowserVersion() > 9 && !isActivexSupported();
}

function isActivexSupported() {
   var supported = null; 
   try {
      new ActiveXObject("");
   }
   catch (e) {
      
      errorName = e.name; 
   }     
   try {
      supported = !!new ActiveXObject("htmlfile");
   } catch (e) {
      supported = false;
   }
   if(errorName != 'ReferenceError' && supported==false){
      supported = false;
   }else{
      supported = true;
   }
   return supported;
}

function openAlert(message) {
   alert(message);
}