function getMainApplication() {
   return document.getElementById('main');
}

function embedFlash(flashFile, flashVersion, expressInstall) {
    var browserName = getBrowserName();
    var osName = getOSName();

    var flashvars = {};
    if(this.flashvars) {
       flashvars = this.flashvars;
    }
    else {
       flashvars = {inPearltrees:true};
    }
    var params = {};
    params.quality = "high";
    if(isEmbedWindowMode()) {
       params.wmode = "opaque";
    }else{
       params.wmode = "window";
    }
    params.bgcolor = "#ffffff";
    params.allowfullscreen = "true";
    params.allowScriptAccess = "always";
    var attributes = {};
    attributes.id = "main";
    attributes.name = "main";
    attributes.align = "middle";
    attributes.tabIndex = 0;
    swfobject.embedSWF(flashFile, "htmlContent", "100%", "100%", flashVersion, expressInstall, flashvars, params, attributes);
}

function loadjsfile(filename) {
   var fileref=document.createElement('script');
   fileref.setAttribute("type","text/javascript");
   fileref.setAttribute("src", filename);
   document.getElementsByTagName("head")[0].appendChild(fileref);
}

var isUpdatingState = false;
function doOnResize() {
   if(getBrowserName() == 'Explorer') {
      
      if(!isUpdatingState) {
         isUpdatingState = true;
         setTimeout("updateStateWithDelay()", 20);
      }
   }else{
      updateState();
   }
}
function updateStateWithDelay() {
   updateState();
   isUpdatingState = false;   
}

function breakOutOfFbFrame() {

	u = location + "";
	if (u.indexOf("FB") != -1) {
		if (top.location != location) {
				top.location.href = document.location.href;
		}
	}
}

function onDocumentLoad() {
   var app = getMainApplication();
   if(app) {
      
      app.focus();  
      updateState();
   }
   if (isBrowserMSIEMetro()) {
      
      $.ajax({
         url: getServicesUrl()+"login/logIEMetroVisit",
         type: 'POST',
         async: true,
         dataType: 'text'
      });
   }
   else if(isBrowserMSIE()) {
      
   }
}

function focusOnElement(hash) {
	BrowserHistory.setBrowserURL(hash, null);
}

function isEmbedWindowMode() {
   var curUrl = window.location.toString();
   return (curUrl.indexOf("embedWindow") != -1);
}

function onDocumentUnload() {
   
}
function onWindowUnfocus() {

}
function onWindowFocus() {
   
}

window.onblur = function() {
   onWindowUnfocus();
}
