var TRACE_DEBUG = false;

var STATE_NO_SPLIT = 0;
var STATE_SPLIT_WITH_CONTAINED_PAGE = 1;
var STATE_SPLIT_WITH_BIG_FLASH = 2;
var STATE_FAST_PLAYER_LOAD = 3;

var state = STATE_NO_SPLIT;
var isAnimating = false;
var currentIFrame = null;
var targetIFrame = null;
var iframesContainer = null;
var shadowContainer = null;
var flashContainer = null;
var BLANK_PAGE = 'about:blank';
var UNLOAD_DELAY = 100;
var isAnimationPaused = false;
var EFFECT_SPEED = 500;
var lastStepPercentTime = 0;
var lastStepPercentValue = 0;
var PLAYER_HEIGHT = 42;
var pearltreesButton = null;
var vDeltaX = 0;
var vDeltaY = 0;
var cumDeltaX = 0;
var cumDeltaY = 0;
var trackpadCounter = 0;
var STEPS = 2;
var isLocked = false;

function iframeLog(value) {
   if(TRACE_DEBUG && typeof(console) != "undefined" && typeof(console.log) != "undefined") {
      console.log(value); 
   }
}

$(document).ready(function() {
   iframesContainer = $('#iframesContainer');
   flashContainer = $('#mainContainer');
   shadowContainer = $('#shadowContainer');

   var curUrl = window.location.toString();
   if(!swfobject.hasFlashPlayerVersion(minFlashVersion)) {
      
   }
   else if(typeof(startPlayerWithUrl) != "undefined" && startPlayerWithUrl != null && startPlayerWithUrl != "") {
      
   }
   else if(curUrl.indexOf("N-play-url=") != -1) {
      startPlayerWithUrl = curUrl.substring(curUrl.indexOf("N-play-url=") + 11);
      if(startPlayerWithUrl.indexOf("&") != -1) {
         startPlayerWithUrl = startPlayerWithUrl.substring(0, startPlayerWithUrl.indexOf("&"));
      }
      startPlayerWithUrl = decodeURIComponent(startPlayerWithUrl);
   }
   else if(curUrl.indexOf("N-play=1") != -1) {
      var pearlId = curUrl.substring(curUrl.indexOf("N-p=") + 4);
      if(pearlId.indexOf("&") != -1) {
         pearlId = pearlId.substring(0, pearlId.indexOf("&"));
      }
      var pearlIdToUrlQuery = getServicesUrl()+"player/pearlUrl?id="+pearlId;
      startPlayerWithUrl = $.ajax({
         url: pearlIdToUrlQuery,
         type: 'GET',
         async: false,
         dataType: 'text'
      }).responseText;
   }
   
   if(typeof(startPlayerWithUrl) != "undefined" && startPlayerWithUrl != null && startPlayerWithUrl != "") {
      
      startupMessage = null;
      promoBigWindow = false;
      promoLittleWindow = "0";
      setPlayerMode(STATE_FAST_PLAYER_LOAD);
      loadIFrame(startPlayerWithUrl, false, true);
   }
   
   if(window.addEventListener) {
            var eventType = "mousewheel";
            if ((getOSName() == "Mac") && (getBrowserName() == "Safari")) {
            	window.addEventListener(eventType, handleWheel, false);
            }
   }

   function handleWheel(event) {
     var app = getMainApplication();
     var edelta = event.wheelDelta/40;
     if (event.preventDefault) {
       event.preventDefault();
     }
     if (edelta > 0.0) {
       edelta += 1.0;
     }
     var o = {x: event.screenX, y: event.screenY, 
              delta: edelta,
              ctrlKey: event.ctrlKey, altKey: event.altKey, 
              shiftKey: event.shiftKey};
     app.handleWheel(o);
     if (event.stopPropagation) event.stopPropagation();    
     if (event.returnValue) event.returnValue = false;
     if (event.cancelBubble) event.cancelBubble = true;
     return true;
   }
   flashContainer.mousewheel(function(event, delta, deltaX, deltaY) {
       if (getOSName() == "Mac" && getBrowserName() != "Firefox") {
         if (isOnScrollableWindow()) {
            return true;
         }
         setDeltaX(deltaX);
         setDeltaY(deltaY);
         event.stopPropagation();
         event.preventDefault();
         cumDeltaX += getDeltaX();
         cumDeltaY += getDeltaY();
       
         if (trackpadCounter < STEPS || (cumDeltaX * cumDeltaX + cumDeltaY * cumDeltaY) < 1 ) {
           trackpadCounter++;
         } 
         else {
           if (getMainApplication() && getMainApplication().startTrackpadDrag) {
             try {
               if (getBrowserName() == "Chrome") {
                 getMainApplication().startTrackpadDrag(- 6 * cumDeltaX,6 * cumDeltaY, trackpadCounter);
               }
               else if (getBrowserName() == "Safari") {
                 getMainApplication().startTrackpadDrag(- 5 * cumDeltaX,5 * cumDeltaY, trackpadCounter);
               }
               else if (getBrowserName() == "Firefox") {
                 getMainApplication().startTrackpadDrag(- 3 * cumDeltaX,3 * cumDeltaY, trackpadCounter);
               }
             } catch(e){console.log(e)}
           }
           
           cumDeltaX = 0;
           cumDeltaY = 0;
           trackpadCounter = 0;
         }	
         return false;
       }
     }
     );
  });

(function($) {

var types = ['DOMMouseScroll', 'mousewheel'];

if ($.event.fixHooks) {
    for ( var i=types.length; i; ) {
        $.event.fixHooks[ types[--i] ] = $.event.mouseHooks;
    }
}

$.event.special.mousewheel = {
    setup: function() {
        if ( this.addEventListener ) {
            for ( var i=types.length; i; ) {
                this.addEventListener( types[--i], handler, false );
            }
        } else {
            this.onmousewheel = handler;
        }
    },
    
    teardown: function() {
        if ( this.removeEventListener ) {
            for ( var i=types.length; i; ) {
                this.removeEventListener( types[--i], handler, false );
            }
        } else {
            this.onmousewheel = null;
        }
    }
};

$.fn.extend({
    mousewheel: function(fn) {
        return fn ? this.bind("mousewheel", fn) : this.trigger("mousewheel");
    },
    
    unmousewheel: function(fn) {
        return this.unbind("mousewheel", fn);
    }
});

function handler(event) {
    var orgEvent = event || window.event, args = [].slice.call( arguments, 1 ), delta = 0, returnValue = true, deltaX = 0, deltaY = 0;
    event = $.event.fix(orgEvent);
    event.type = "mousewheel";

    if ( orgEvent.wheelDelta ) { delta = orgEvent.wheelDelta/120; }
    if ( orgEvent.detail     ) { delta = -orgEvent.detail/3; }

    deltaY = delta;

    if ( orgEvent.axis !== undefined && orgEvent.axis === orgEvent.HORIZONTAL_AXIS ) {
        deltaY = 0;
        deltaX = -1*delta;
    }

    if ( orgEvent.wheelDeltaY !== undefined ) { deltaY = orgEvent.wheelDeltaY/120; }
    if ( orgEvent.wheelDeltaX !== undefined ) { deltaX = -1*orgEvent.wheelDeltaX/120; }

    args.unshift(event, delta, deltaX, deltaY);
    
    return ($.event.dispatch || $.event.handle).apply(this, args);
}

})(jQuery);

function loadIFrame(url, isBackward, skipEffect) {
   
   var currentIFrameSource = getCurrentIFrameSource();
   var targetIFrameSource = getTargetIFrameSource();
   var windowWidth = $(window).width();
   var zoomFactor = getZoomFactor();
   if(url.indexOf("/s/index/player") != -1){
      url += "&zoomFactor="+zoomFactor;
   }
   
   if((currentIFrameSource == BLANK_PAGE && !isAnimating) || skipEffect) {
      iframeLog("set without animation: "+url);
      setCurrentIFrameSource(url);
      showCurrentIFrame();
      currentIFrame.css("z-index", 2);
      hideTargetIFrame();
      currentIFrame.adaptToScreen();
   }
   
   else if(currentIFrameSource != BLANK_PAGE && !isAnimating) {
      iframeLog("start animation: "+url);
      setTargetIFrameSource(url);
      if(!isBackward) {
         currentIFrame.css("z-index", 2)
         setTimeout("animateCurrentIframe()", 1000);
         targetIFrame.css("left", null);
         targetIFrame.css("right", 0);
         targetIFrame.css("z-index", 1);
         showTargetIFrame();
      }else{
         currentIFrame.css("z-index", 1)
         setTimeout("animateTargetIframe()", 1000);
         targetIFrame.css("left", null);
         targetIFrame.css("right", windowWidth);
         targetIFrame.css("z-index", 2);
         
      }
      showTargetIFrame();
      targetIFrame.adaptToScreen();

      isAnimating = true;
   }
   
   else if(currentIFrameSource != BLANK_PAGE && isAnimating) {
      iframeLog("update during animation: "+url);
      setTargetIFrameSource(url);
   }
}

function clearIFrame() {
   iframeLog("clear iframes");
   
   setCurrentIFrameSource(BLANK_PAGE);
   setTargetIFrameSource(BLANK_PAGE);
   isAnimating = false;
   isAnimationPaused = false;
}

function animateCurrentIframe(startValue, endValue, duration) {
   if(!currentIFrame) return;
   
   if(typeof(startValue) == "undefined") {
      startValue = 0;
   }
   if(typeof(endValue) == "undefined") {
      endValue = $(window).width();
   }
   if(typeof(duration) == "undefined") {
      duration = EFFECT_SPEED;
   }

   setCurrentIFrameToDefaultPosition(startValue);
   
   currentIFrame.animate({right: endValue}, 
                         {duration: duration,
                          easing: "easeInCubic",
                          complete: onCurrentIFrameAnimationEnd,
                          step: onCurrentIFrameAnimationStep});   
}

function animateTargetIframe(startValue, endValue, duration) {
   if(typeof(startValue) == "undefined") {
      startValue = $(window).width();
   }
   if(typeof(endValue) == "undefined") {
      endValue = 0;
   }
   if(typeof(duration) == "undefined") {
      duration = EFFECT_SPEED;
   }

   setTargetIFrameToDefaultPosition(startValue);
   
   targetIFrame.animate({right: endValue}, 
                        {duration: duration,
                         easing: "easeInCubic",
                         complete: onTargetIFrameAnimationEnd,
                         step: onTargetIFrameAnimationStep});
}

function onCurrentIFrameAnimationStep(curValue, effectEvent) {
   var targetElement = effectEvent.elem;
   var startValue = effectEvent.start;   
   var endValue = effectEvent.end;
   curValue = Math.round(curValue);
   var duration = effectEvent.options.duration;
   var percentValue = Math.round(effectEvent.pos*100);
   var percentTime = Math.round(effectEvent.state*100); 
   var restValue = endValue - curValue;
   var restTime = Math.round(duration - (duration * effectEvent.state));
   
   iframeLog("progress: (t:"+percentTime+"% v:"+percentValue+"%) "+
             "rest: ("+restValue+"px "+restTime+"ms)");
   
   if(percentTime == 100 && percentValue == 100 && lastStepPercentTime == 0 && lastStepPercentValue == 0) {
      iframeLog("pause animation");
      isAnimationPaused = true;
      if(currentIFrame) {
         currentIFrame.stop(true, false);
      }
      setTimeout("setCurrentIFrameToDefaultPosition()", 10);
      setTimeout("animateCurrentIframe(0,"+endValue+","+duration+")", 3000);   
   }
   
   lastStepPercentTime = percentTime;
   lastStepPercentValue = percentValue;
}

function onTargetIFrameAnimationStep(curValue, effectEvent) {
   var targetElement = effectEvent.elem;
   var startValue = effectEvent.start;   
   var endValue = effectEvent.end;
   curValue = Math.round(curValue);
   var duration = effectEvent.options.duration;
   var percentValue = Math.round(effectEvent.pos*100);
   var percentTime = Math.round(effectEvent.state*100); 
   var restValue = endValue - curValue;
   var restTime = Math.round(duration - (duration * effectEvent.state));
   
   iframeLog("progress: (t:"+percentTime+"% v:"+percentValue+"%) "+
             "rest: ("+restValue+"px "+restTime+"ms)");
   
   if(percentTime == 100 && percentValue == 100 && lastStepPercentTime == 0 && lastStepPercentValue == 0) {
      iframeLog("pause animation");
      isAnimationPaused = true;
      if(targetIFrame) {
         targetIFrame.stop(true, false);
      }
      setTimeout("setTargetIFrameToDefaultPosition()", 10);
      setTimeout("animateTargetIframe("+$(window).width()+","+endValue+","+duration+")", 3000);   
   }
   
   lastStepPercentTime = percentTime;
   lastStepPercentValue = percentValue;
}

function setCurrentIFrameToDefaultPosition(rightValue) {
   if(typeof(rightValue) == "undefined") {
      rightValue = 0;
   }

   if(currentIFrame) {
      currentIFrame.css("left", null);
      currentIFrame.css("right", rightValue);
      currentIFrame.css("z-index", 2);
   }
}

function setTargetIFrameToDefaultPosition(rightValue) {
   if(typeof(rightValue) == "undefined") {
      rightValue = $(window).width();
   }
   
   if(targetIFrame) {
      targetIFrame.css("left", null);
      targetIFrame.css("right", rightValue);
      targetIFrame.css("z-index", 2);
   }
}

function onCurrentIFrameAnimationEnd() {   
   if(isAnimationPaused) {
      isAnimationPaused = false;
      setCurrentIFrameToDefaultPosition();
      return;
   }   
   iframeLog("end animation");   
   
   isAnimating = false;
   
   var previousCurrentIframe = currentIFrame;
   currentIFrame = targetIFrame;
   targetIFrame = previousCurrentIframe;
   
   if(currentIFrame) {
      currentIFrame.css("z-index", 2);
   }
   
   var windowWidth = $(window).width();
   
   if(targetIFrame) {
      targetIFrame.css("z-index", 1);
   }
   hideTargetIFrame();
   setTimeout("unloadTargetIFrameIfPossible('"+getTargetIFrameSource()+"')", UNLOAD_DELAY);

}

function onTargetIFrameAnimationEnd() {
   if(isAnimationPaused) {
      isAnimationPaused = false;
      setTargetIFrameToDefaultPosition();
      return;
   }   
   iframeLog("end target animation");   
   
   isAnimating = false;
   
   var previousCurrentIframe = currentIFrame;
   currentIFrame = targetIFrame;
   targetIFrame = previousCurrentIframe;
   
   if(currentIFrame) {
      currentIFrame.css("z-index", 1);
   }
   
   var windowWidth = $(window).width();
   if(targetIFrame) {
      targetIFrame.css("overflow","auto");
      targetIFrame.css("z-index", 2);
   }
   hideTargetIFrame();
   setTimeout("unloadTargetIFrameIfPossible('"+getTargetIFrameSource()+"')", UNLOAD_DELAY);

}

function unloadTargetIFrameIfPossible(sourceToUnload) {
   if(!isAnimating && getTargetIFrameSource() == sourceToUnload) {
      iframeLog("unload :" + sourceToUnload);
      setTargetIFrameSource(BLANK_PAGE);
   }
}

function getCurrentIFrameSource() {
   if(currentIFrame) {
      return currentIFrame.get(0).src;
   }else{
      return BLANK_PAGE;
   }
}
function setCurrentIFrameSource(value) {
   if((typeof(currentIFrame) == "undefined" || currentIFrame == null) && value != BLANK_PAGE) {
      var iFrameStyle = "position:absolute;background-color:#FFFFFF;width:0px;height:0px;";
      currentIFrame = $('<iframe style="'+iFrameStyle+'" '+
                                'src="'+value+'" '+
                                'frameborder="0" '+
                                'allowtransparency="false" '+
                                'onLoad="onCurrentIFrameLoaded()"></iframe>');   
      iframesContainer.prepend(currentIFrame);
   }
   else if(currentIFrame) {
      currentIFrame.get(0).src = value;
   }
   
   if(value == BLANK_PAGE && currentIFrame) {
      hideCurrentIFrame();
      currentIFrame.remove();
      currentIFrame = null;
      updateState();
   }
}

function getTargetIFrameSource() {
   if(targetIFrame) {
      return targetIFrame.get(0).src;
   }else{
      return BLANK_PAGE;
   }
}
function setTargetIFrameSource(value) {
   if((typeof(targetIFrame) == "undefined" || targetIFrame == null) && value != BLANK_PAGE) {
      var iFrameStyle = "position:absolute;background-color:#FFFFFF;width:0px;height:0px;";
      targetIFrame = $('<iframe style="'+iFrameStyle+'" '+
                                'src="'+value+'" '+
                                'frameborder="0" '+
                                'allowtransparency="false" '+
                                'onLoad="onTargetIFrameLoaded()"></iframe>')
      iframesContainer.prepend(targetIFrame);
   }
   else if(targetIFrame) {
      targetIFrame.get(0).src = value;
   }
   
   if(value == BLANK_PAGE && targetIFrame) {
      hideTargetIFrame();
      targetIFrame.remove();
      targetIFrame = null;
      updateState();
   }   
}

function getDeltaX() {
  return vDeltaX;
}

function setDeltaX(x) {
  vDeltaX = x;
}

function getDeltaY() {
  return vDeltaY;
}

function setDeltaY(y) {
  vDeltaY = y;
}

function setisOnScrollableWindow(isScrollable) {
  isLocked = isScrollable;
}

function isOnScrollableWindow() {
  return isLocked;
}

function hideCurrentIFrame() {
   if(currentIFrame) {
      currentIFrame.hide();
   }
   updateState();
}
function showCurrentIFrame() {
   if(currentIFrame) {
      currentIFrame.show();
   }
   updateState();
}

function hideTargetIFrame() {
   if(targetIFrame) {
      targetIFrame.hide();
   }
   updateState();
}
function showTargetIFrame() {
   if(targetIFrame) {
      targetIFrame.show();
   }
   updateState();
}

function isCurrentIFrameVisible() {
   return (currentIFrame && currentIFrame.css('display') != 'none');
}
function isTargetIFrameVisible() {
   return (targetIFrame && targetIFrame.css('display') != 'none');
}

function onCurrentIFrameLoaded() {
   var app = getMainApplication();
   if (currentIFrame && app && app.onBrowserIFrameLoaded) {
      try {
         app.onBrowserIFrameLoaded(getCurrentIFrameSource());
      }catch(e){}
   }
}

function onTargetIFrameLoaded() {
   var app = getMainApplication();
   if (targetIFrame && app && app.onBrowserIFrameLoaded) {
      try {
         app.onBrowserIFrameLoaded(getTargetIFrameSource());
      }catch(e){}
   }
}
 
function getPlayerMode() {
   return state;
}
 
function setPlayerMode(value) {
   var updateStateDelay = 0;
   if("Opera" == getBrowserName()) {
      updateStateDelay = 1;
   }
   
   if(value == 0) {
      state = STATE_NO_SPLIT;
   } else if(value == 1) {
      state = STATE_SPLIT_WITH_CONTAINED_PAGE;
   } else if (value == 2 && state != STATE_FAST_PLAYER_LOAD) {
      state = STATE_SPLIT_WITH_BIG_FLASH;
   } else if(value ==3) {
      state = STATE_FAST_PLAYER_LOAD;
   }   

   if(updateStateDelay > 0){ 
      setTimeout("updateState()", updateStateDelay);
   }else{
      updateState();
   }
}

function getPlayerHeight() {
   return PLAYER_HEIGHT;
}
function getZoomFactor() {
   var flashStageHeight;
   if(getMainApplication() && getMainApplication().getStageHeight) {
      try {
         flashStageHeight = getMainApplication().getStageHeight();
      }catch(e){}
   }
     
   var flashContainerHeight = flashContainer.height();
   var zoomFactor = 1;
     
   if(!flashStageHeight || flashStageHeight <= 1 || !flashContainerHeight || flashContainerHeight <=0) {
      iframeLog("flashStageHeight is not available");
   }else{
      zoomFactor = flashContainerHeight / flashStageHeight;
   }
   return zoomFactor;
}

function updateState() {
   if(!flashContainer) return;
   
   flashContainer.parent().height("100%");
   
   var windowHeight = $(window).height();
   var windowWidth = $(window).width();   
   
   if(isCurrentIFrameVisible()) {
      currentIFrame.css({width:windowWidth});
   }
   else if(currentIFrame) {
      currentIFrame.css({width:0});
      currentIFrame.css({height:0});
   }
   if(isTargetIFrameVisible()) {
      targetIFrame.css({width:windowWidth});
   }
   else if(targetIFrame) {
      targetIFrame.css({width:0});
      targetIFrame.css({height:0});
   }
   if(iframesContainer) {
      if(isCurrentIFrameVisible() || isTargetIFrameVisible()) {
         iframesContainer.css({width:windowWidth});
      }else{
         iframesContainer.css({width:0});
      }
   }

   if(state == STATE_NO_SPLIT) {
      if(currentIFrame) {    
         currentIFrame.height(0);
      }
      if(targetIFrame) {
         targetIFrame.height(0);
      }
      flashContainer.css({top:0});
      if(flashContainer.css('height') != '100%') {
         flashContainer.height('100%');
      }
      if(flashContainer.css('width') != '100%') {
         flashContainer.width('100%');
      }
   }

   else if(state == STATE_SPLIT_WITH_CONTAINED_PAGE || state == STATE_SPLIT_WITH_BIG_FLASH || state == STATE_FAST_PLAYER_LOAD) {
      
      var zoomFactor = getZoomFactor();
      
      var playerHeight =  zoomFactor * getPlayerHeight();
      
      var iframeHeight = windowHeight - playerHeight;
      
      var playerHeightPercent = Math.round(1000 * playerHeight/windowHeight) / 10;
      
      if($.browser.opera) {
         playerHeightPercent = Math.round(playerHeightPercent + 0.5);
      }
      
      if($.browser.safari || $.browser.webkit) {
         var playerHeightDiff = (playerHeightPercent / 100 * windowHeight) - playerHeight;
         if(playerHeightDiff < 0) {
            playerHeightPercent = playerHeightPercent + (100/windowHeight);
         }
      }
      
      if(playerHeightPercent > 100) playerHeightPercent = 100;

      var errorMargin = 100/windowHeight; 
      var flashContainerHeightPercent = flashContainer.css('height');
      if(flashContainerHeightPercent && typeof(flashContainerHeightPercent) != "undefined") {
         if(flashContainerHeightPercent.indexOf("px") != -1) {
            flashContainerHeightPercent = Math.round(1000 * flashContainer.height()/windowHeight) / 10;
         }
         else if(flashContainerHeightPercent.indexOf("%") != -1) {
            flashContainerHeightPercent = flashContainerHeight.split("%")[0];
         }
         else{
            flashContainerHeightPercent = 100;
         }
      }else{
         flashContainerHeightPercent = 100;
      }
      var diff = Math.abs(flashContainerHeightPercent - playerHeightPercent);
      if(diff > errorMargin) {
          iframesContainer.height((100-playerHeightPercent)+"%");
          flashContainer.height(playerHeightPercent+"%");
          flashContainer.width('100%');

          iframesContainer.css({top:playerHeightPercent+"%"});
      }

      if (state == STATE_SPLIT_WITH_BIG_FLASH) {
         flashContainer.height("100%");
      }
      else if(state == STATE_FAST_PLAYER_LOAD) {
         flashContainer.height(1);
         flashContainer.width(1);
         /*
         if(!pearltreesButton) {
            pearltreesButton = $("<img src='"+getStaticContentUrl()+"images/html/pearltreesBrowser.png' />");
            pearltreesButton.css({position:'absolute', left:10, top:4, 'z-index':4});
            pearltreesButton.click(function(){
               window.location.href = window.location.href.replace("N-play=1", "N-play=0");
               setPlayerMode(STATE_NO_SPLIT);
            });
            $(document.body).append(pearltreesButton);
         }
         */
      }
      else if(state != STATE_FAST_PLAYER_LOAD && pearltreesButton) {
         pearltreesButton.remove();
      }
      
      if(isCurrentIFrameVisible()) {
         currentIFrame.height("100%");
      }
      if(isTargetIFrameVisible()) {
         targetIFrame.height("100%");
      }

      iframeLog("update state: "+state);
   }
   
   if(shadowContainer) {
      if((currentIFrame && currentIFrame.height() != 0) || (targetIFrame && targetIFrame.height() != 0)) {
         shadowContainer.css({width:windowWidth});
      }else{
         shadowContainer.css({width:0});
      }
   }
   
   forceElementRendering(flashContainer.get(0));   
}

function forceElementRendering(element) {
   if(!element || !element.style) return;
   iframeLog("force DOM rendering");
   
   if(element.style.display) {
      element.style.display="";
   }
   var renderFix = element.offsetTop;
   if(element.style.display) {
      element.style.display="block";
   }
}

function forceStateRendering() {   
   forceElementRendering(flashContainer.get(0)); 
}
