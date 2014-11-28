BrowserHistoryUtils = {
    addEvent: function(elm, evType, fn, useCapture) {
        useCapture = useCapture || false;
        if (elm.addEventListener) {
            elm.addEventListener(evType, fn, useCapture);
            return true;
        }
        else if (elm.attachEvent) {
            var r = elm.attachEvent('on' + evType, fn);
            return r;
        }
        else {
            elm['on' + evType] = fn;
        }
    }
}

BrowserHistory = (function() {
    
    var browser = {
        ie: false, 
        firefox: false, 
        safari: false, 
        opera: false,
        chrome: false,
        version: -1
    };

    
    
    

    
    

    
    var defaultHash = '';

    
    var currentHref = document.location.href;

    
    var initialHref = document.location.href;

    
    var initialHash = document.location.hash;
    var currentHash = document.location.hash;

    
    var historyFrameSourcePrefix = '@@web.path.root@@flash/history/historyFrame.html?';

    
    var currentHistoryLength = -1;

    var historyHash = [];

    var initialState = createState(initialHref, initialHref + '#' + initialHash, initialHash);

    var backStack = [];
    var forwardStack = [];

    var currentObjectId = null;

    
    var useragent = navigator.userAgent.toLowerCase();

    if (useragent.indexOf("opera") != -1) {
        browser.opera = true;
    } else if (useragent.indexOf("msie") != -1) {
        browser.ie = true;
        browser.version = parseFloat(useragent.substring(useragent.indexOf('msie') + 4));
    } else if (useragent.indexOf("chrome") != -1) {
        browser.chrome = true;
    } else if (useragent.indexOf("safari") != -1) {
        browser.safari = true;
        browser.version = parseFloat(useragent.substring(useragent.indexOf('safari') + 7));
    } else if (useragent.indexOf("gecko") != -1) {
        browser.firefox = true;
    }

    if (browser.ie == true && browser.version == 7) {
        window["_ie_firstload"] = false;
    }

    
    function getHistoryFrame()
    {
        return document.getElementById('ie_historyFrame');
    }

    function getAnchorElement()
    {
        return document.getElementById('firefox_anchorDiv');
    }

    function getFormElement()
    {
        return document.getElementById('safari_formDiv');
    }

    function getRememberElement()
    {
        return document.getElementById("safari_remember_field");
    }

    function getMainPlayer(){
      return getMainApplication();
    }

    /* Get the Flash player object for performing ExternalInterface callbacks. */
    function getPlayer(objectId) {
        var objectId = objectId || null;
        var player = null; /* AJH, needed?  = document.getElementById(getPlayerId()); */
        if (browser.ie && objectId != null) {
            player = document.getElementById(objectId);
        }
        if (player == null) {
            player = document.getElementsByTagName('object')[0];
        }
        
        if (player == null || player.object == null) {
            player = document.getElementsByTagName('embed')[0];
        }

        return player;
    }
    
    function getPlayers() {
        var players = [];
        if (players.length == 0) {
            var tmp = document.getElementsByTagName('object');
            players = tmp;
        }
        
        if (players.length == 0 || players[0].object == null) {
            var tmp = document.getElementsByTagName('embed');
            players = tmp;
        }
        return players;
    }

   function getIframeHash() {
      var doc = getHistoryFrame().contentWindow.document;
      var hash = String(doc.location.search);
      if (hash.length == 1 && hash.charAt(0) == "?") {
         hash = "";
      }
      else if (hash.length >= 2 && hash.charAt(0) == "?") {
         hash = hash.substring(1);
      }
      return hash;
   }

    /* Get the current location hash excluding the '#' symbol. */
    function getHash() {
       
       
       var idx = document.location.href.indexOf('#');
       return (idx >= 0) ? document.location.href.substr(idx+1) : '';
    }
   var _hashToUpdate;
   function updateHash() {
     document.location.hash = _hashToUpdate; 
   }

    /* Get the current location hash excluding the '#' symbol. */

   function setHashWithTimeout(hash, withTimeOut) {
       
       
     if (hash == '') hash = '#';
     _hashToUpdate = hash;
     if (withTimeOut) {
       setTimeout(updateHash, 100);
     } else {
       updateHash();
     }
   }

   function setHash(hash) {
     setHashWithTimeout(hash, false);
   }


    function createState(baseUrl, newUrl, flexAppUrl) {
        return { 'baseUrl': baseUrl, 'newUrl': newUrl, 'flexAppUrl': flexAppUrl, 'title': null };
    }

    /* Add a history entry to the browser.
     *   baseUrl: the portion of the location prior to the '#'
     *   newUrl: the entire new URL, including '#' and following fragment
     *   flexAppUrl: the portion of the location following the '#' only
     */
    function addHistoryEntry(baseUrl, newUrl, flexAppUrl) {

        
        forwardStack = [];

        if (browser.ie) {
            
            
            
            if (flexAppUrl == defaultHash && document.location.href == initialHref && window['_ie_firstload']) {
                currentHref = initialHref;
                return;
            }
            if ((!flexAppUrl || flexAppUrl == defaultHash) && window['_ie_firstload']) {
                newUrl = baseUrl + '#' + defaultHash;
                flexAppUrl = defaultHash;
            } else {
                
                
                getHistoryFrame().src = historyFrameSourcePrefix + flexAppUrl;
            }
            setHash(flexAppUrl);
        } else {

            
            if (backStack.length == 0 && initialState.flexAppUrl == flexAppUrl) {
                initialState = createState(baseUrl, newUrl, flexAppUrl);
            } else if(backStack.length > 0 && backStack[backStack.length - 1].flexAppUrl == flexAppUrl) {
                backStack[backStack.length - 1] = createState(baseUrl, newUrl, flexAppUrl);
            }
            if (browser.chrome) {
            	currentHash = flexAppUrl;
            	top.location.hash = flexAppUrl;
            } 
            if (browser.safari) {
                
                if (browser.version <= 419.3) {
                    var file = window.location.pathname.toString();
                    file = file.substring(file.lastIndexOf("/")+1);
                    getFormElement().innerHTML = '<form name="historyForm" action="'+file+'#' + flexAppUrl + '" method="GET"></form>';
                    
                    var qs = window.location.search.substring(1);
                    var qs_arr = qs.split("&");
                    for (var i = 0; i < qs_arr.length; i++) {
                        var tmp = qs_arr[i].split("=");
                        var elem = document.createElement("input");
                        elem.type = "hidden";
                        elem.name = tmp[0];
                        elem.value = tmp[1];
                        document.forms.historyForm.appendChild(elem);
                    }
                    document.forms.historyForm.submit();
                } else {
                    top.location.hash = flexAppUrl;
                }
                
                historyHash[history.length] = flexAppUrl;
                _storeStates();
            } else {
                
                addAnchor(flexAppUrl);
                setHashWithTimeout(flexAppUrl,true);
            }
        }
        backStack.push(createState(baseUrl, newUrl, flexAppUrl));
    }

    function _storeStates() {
        if (browser.safari) {
            getRememberElement().value = historyHash.join(",");
        }
    }

    function handleBackButton() {
        
        var current = backStack.pop();
        if (!current) { return; }
        var last = backStack[backStack.length - 1];
        if (!last && backStack.length == 0){
            last = initialState;
        }
        forwardStack.push(current);
    }

    function handleForwardButton() {
        

        var last = forwardStack.pop();
        if (!last) { return; }
        backStack.push(last);
    }

    function handleArbitraryUrl() {
        
        forwardStack = [];
    }

    /* Called periodically to poll to see if we need to detect navigation that has occurred */
    function checkForUrlChange() {
        var mainPlayer = getMainPlayer();
        
        if (browser.chrome) {
            if (currentHash != document.location.hash && '#'+currentHash != document.location.hash) {
            	currentHash = document.location.hash;
            	if(mainPlayer && mainPlayer.browserURLChangeWorkaround) {
            	    mainPlayer.browserURLChangeWorkaround(currentHash);
            	}
            }
        }

        if (browser.ie) {
            if (currentHref != document.location.href && currentHref + '#' != document.location.href) {
                
                
                
                
                
                
                if (browser.version < 7) {
                    currentHref = document.location.href;
                    document.location.reload();
                } else {
               if (getHash() != getIframeHash()) {
                  
                  var sourceToSet = historyFrameSourcePrefix + getHash();
                  getHistoryFrame().src = sourceToSet;
               }
                }
            }
        }

        if (browser.safari) {
            
            if (currentHistoryLength >= 0 && history.length != currentHistoryLength) {
                
                
                
                
                currentHistoryLength = history.length;
                var flexAppUrl = historyHash[currentHistoryLength];
                if (flexAppUrl == '') {
                    
                }
                try {
	                
	                if (typeof BrowserHistory_multiple != "undefined" && BrowserHistory_multiple == true) {
	                    var pl = getPlayers();
	                    for (var i = 0; i < pl.length; i++) {
	                        pl[i].browserURLChangeWorkaround(flexAppUrl);
	                    }
	                } else if(mainPlayer && mainPlayer.browserURLChangeWorkaround) {
	                    mainPlayer.browserURLChangeWorkaround(flexAppUrl);
	                }
                } catch (e){
                	alert("exception "+e);
                }
                _storeStates();
            }
        }
        if (browser.firefox) {
            if (currentHref != document.location.href) {
                var bsl = backStack.length;

                var urlActions = {
                    back: false, 
                    forward: false, 
                    set: false
                }

                if ((window.location.hash == initialHash || window.location.href == initialHref) && (bsl == 1)) {
                    urlActions.back = true;
                    
                    
                    
                    handleBackButton();
                }
                
                
                
                if (forwardStack.length > 0) {
                    if (forwardStack[forwardStack.length-1].flexAppUrl == getHash()) {
                        urlActions.forward = true;
                        handleForwardButton();
                    }
                }

                
                if ((bsl >= 2) && (backStack[bsl - 2])) {
                    if (backStack[bsl - 2].flexAppUrl == getHash()) {
                        urlActions.back = true;
                        handleBackButton();
                    }
                }
                
                if (!urlActions.back && !urlActions.forward) {
                    var foundInStacks = {
                        back: -1, 
                        forward: -1
                    }

                    for (var i = 0; i < backStack.length; i++) {
                        if (backStack[i].flexAppUrl == getHash() && i != (bsl - 2)) {
                            arbitraryUrl = true;
                            foundInStacks.back = i;
                        }
                    }
                    for (var i = 0; i < forwardStack.length; i++) {
                        if (forwardStack[i].flexAppUrl == getHash() && i != (bsl - 2)) {
                            arbitraryUrl = true;
                            foundInStacks.forward = i;
                        }
                    }
                    handleArbitraryUrl();
                }

                
                currentHref = document.location.href;
                var flexAppUrl = getHash();
                if (flexAppUrl == '') {
                    
                }
                
                if (typeof BrowserHistory_multiple != "undefined" && BrowserHistory_multiple == true) {
                    var pl = getPlayers();
                    for (var i = 0; i < pl.length; i++) {
                        pl[i].browserURLChangeWorkaround(flexAppUrl);
                    }
                } else if(mainPlayer && mainPlayer.browserURLChangeWorkaround) {
                    mainPlayer.browserURLChangeWorkaround(flexAppUrl);
                }
            }
        }
        
    }

    /* Write an anchor into the page to legitimize it as a URL for Firefox et al. */
    function addAnchor(flexAppUrl)
    {
       if (document.getElementsByName(flexAppUrl).length == 0) {
           getAnchorElement().innerHTML += "<a name='" + flexAppUrl + "'>" + flexAppUrl + "</a>";
       }
    }

    var _initialize = function () {
        if (browser.ie)
        {
            var scripts = document.getElementsByTagName('script');
            for (var i = 0, s; s = scripts[i]; i++) {
                if (s.src.indexOf("history.js") > -1) {
                    var iframe_location = (new String(s.src)).replace("history.js", "historyFrame.html");
                }
            }
            historyFrameSourcePrefix = iframe_location + "?";
            var src = historyFrameSourcePrefix;

            var iframe = document.createElement("iframe");
            iframe.id = 'ie_historyFrame';
            iframe.name = 'ie_historyFrame';
            
            try {
                document.body.appendChild(iframe);
            } catch(e) {
                setTimeout(function() {
                    document.body.appendChild(iframe);
                }, 0);
            }
        }

        if (browser.safari)
        {
            var rememberDiv = document.createElement("div");
            rememberDiv.id = 'safari_rememberDiv';
            document.body.appendChild(rememberDiv);
            rememberDiv.innerHTML = '<input type="text" id="safari_remember_field" style="width: 500px;">';

            var formDiv = document.createElement("div");
            formDiv.id = 'safari_formDiv';
            document.body.appendChild(formDiv);

            var reloader_content = document.createElement('div');
            reloader_content.id = 'safarireloader';
            var scripts = document.getElementsByTagName('script');
            for (var i = 0, s; s = scripts[i]; i++) {
                if (s.src.indexOf("history.js") > -1) {
                    html = (new String(s.src)).replace(".js", ".html");
                }
            }
            reloader_content.innerHTML = '<iframe id="safarireloader-iframe" src="about:blank" frameborder="no" scrolling="no"></iframe>';
            document.body.appendChild(reloader_content);
            reloader_content.style.position = 'absolute';
            reloader_content.style.left = reloader_content.style.top = '-9999px';
            iframe = reloader_content.getElementsByTagName('iframe')[0];
            if (document.getElementById("safari_remember_field") != null  && document.getElementById("safari_remember_field").value != "" ) {
                historyHash = document.getElementById("safari_remember_field").value.split(",");
            }

        }

        if (browser.firefox)
        {
            var anchorDiv = document.createElement("div");
            anchorDiv.id = 'firefox_anchorDiv';
            document.body.appendChild(anchorDiv);
        }
        
        
    }

    return {
        historyHash: historyHash, 
        backStack: function() { return backStack; }, 
        forwardStack: function() { return forwardStack }, 
        getPlayer: getPlayer, 
        initialize: function(src) {
            _initialize(src);
        }, 
        setURL: function(url) {
            document.location.href = url;
        }, 
        getURL: function() {
            return document.location.href;
        }, 
        getTitle: function() {
            return document.title;
        }, 
        setTitle: function(title) {
            try {
              if (backStack.length>0) {
                backStack[backStack.length - 1].title = title;
              }
            } catch(e) { }
            
            if (browser.safari) {
                if (title == "") {
                    try {
                    var tmp = window.location.href.toString();
                    title = tmp.substring((tmp.lastIndexOf("/")+1), tmp.lastIndexOf("#"));
                    } catch(e) {
                        title = "";
                    }
                }
            }
            document.title = title;
            sendStats(title);
        }, 
        setDefaultURL: function(def)
        {
            defaultHash = def;
            def = getHash();
            
            
            
            if (browser.ie)
            {
                window['_ie_firstload'] = true;
                var sourceToSet = historyFrameSourcePrefix + def;
                var func = function() {
                    getHistoryFrame().src = sourceToSet;
                    
                    
                    window.location.replace("#" + def);
                    setInterval(checkForUrlChange, 0);
                }
                try {
                    func();
                } catch(e) {
                    
                    
                    window.setTimeout(function() { func(); }, 0);
                }
            }

            if (browser.safari)
            {
                currentHistoryLength = history.length;
                if (historyHash.length == 0) {
                    historyHash[currentHistoryLength] = def;
                    var newloc = "#" + def;
                    window.location.replace(newloc);
                } else {
                    
                }
                
                setInterval(checkForUrlChange, 50);
            }
            
            
            if (browser.firefox || browser.opera)
            {
                var reg = new RegExp("#" + def + "$");
                if (window.location.toString().match(reg)) {
                } else {
                    var newloc ="#" + def;
                    window.location.replace(newloc);
                }
                setInterval(checkForUrlChange, 50);
                
            }

            if (browser.chrome)
            {
            	
                setInterval(checkForUrlChange, 50);
            }

        }, 

        /* Set the current browser URL; called from inside BrowserManager to propagate
         * the application state out to the container.
         */
        setBrowserURL: function(flexAppUrl, objectId) {
            if (browser.ie && typeof objectId != "undefined") {
                currentObjectId = objectId;
            }
           
           
           
           

           var pos = document.location.href.indexOf('#');
           var baseUrl = pos != -1 ? document.location.href.substr(0, pos) : document.location.href;
           var newUrl = baseUrl + '#' + flexAppUrl;

           if (document.location.href != newUrl && document.location.href + '#' != newUrl) {
               currentHref = newUrl;
               addHistoryEntry(baseUrl, newUrl, flexAppUrl);
               currentHistoryLength = history.length;
           }

           return false;
        }, 

        browserURLChange: function(flexAppUrl) {
            var objectId = null;
            if (browser.ie && currentObjectId != null) {
                objectId = currentObjectId;
            }
            pendingURL = '';
            
            if (typeof BrowserHistory_multiple != "undefined" && BrowserHistory_multiple == true) {
                var pl = getPlayers();
                for (var i = 0; i < pl.length; i++) {
                    try {
                        pl[i].browserURLChange(flexAppUrl);
                    } catch(e) { }
                }
            } else {
                try {
                    getPlayer(objectId).browserURLChange(flexAppUrl);
                } catch(e) { }
            }

            currentObjectId = null;
        }

    }

})();





function setURL(url)
{
    document.location.href = url;
}

function backButton()
{
    history.back();
}

function forwardButton()
{
    history.forward();
}

function goForwardOrBackInHistory(step)
{
    history.go(step);
}


(function(i) {
    var u =navigator.userAgent;var e=/*@cc_on!@*/false; 
    var st = setTimeout;
    if(/webkit/i.test(u)){
        st(function(){
            var dr=document.readyState;
            if(dr=="loaded"||dr=="complete"){i()}
            else{st(arguments.callee,10);}},10);
    } else if((/mozilla/i.test(u)&&!/(compati)/.test(u)) || (/opera/i.test(u))){
        document.addEventListener("DOMContentLoaded",i,false);
    } else if(e){
    (function(){
        var t=document.createElement('doc:rdy');
        try{t.doScroll('left');
            i();t=null;
        }catch(e){st(arguments.callee,0);}})();
    } else{
        window.onload=i;
    }
})( function() {BrowserHistory.initialize();} );