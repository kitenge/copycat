///////////////////////////////////////////////////////////////////////////////////////////////
// Doc-O-Matic(R) 4 script file.
// Copyright (C) 2000-2004 by toolsfactory software inc.
// http://www.toolsfactory.com
// http://www.doc-o-matic.com
//
// Distribution permitted as part of browser-based
// Help systems generated by Doc-O-Matic(R).
///////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////
// Available variables which are resolved when Doc-O-Matic use the file:
//
//    HEADER_FILE, TOCIDX_FILE, DEFAULT_TITLE_FILE, DEFAULT_TOPIC_FILE
//
//    SCRIPT_FILE, SCRIPT_FUNCTION_ONLOAD
//    STYLESHEET_FILE
//
//    WINDOW_NAME_HEADER, WINDOW_NAME_TOPIC, WINDOW_NAME_NAVIGATION
//    WINDOW_NAME_ADDINFO, WINDOW_NAME_HIERARCHY, WINDOW_NAME_SEEALSO,
//    WINDOW_NAME_LEGEND, WINDOW_NAME_BODYSOURCE, WINDOW_NAME_TOCIDX
//
//    TOC_IMAGE_PLUS, TOC_IMAGE_MINUS, SECTION_IMAGE_PLUS, SECTION_IMAGE_MINUS,
//    COLLAPSE_COOKIE_NAME, COLLAPSE_PERSISTENTSTORE_NAME,
//    COLLAPSE_STATESAVE_USECOOKIES, COLLAPSE_STATESAVE_USEPERSISTENCE
///////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////
// retrieves a variable from the search string
function getStringVar(varname) {
    var searchstr = document.location.search;
    var varidx = searchstr.indexOf(varname);

    if(varidx >= 0) {
        var startpos = varidx + varname.length +1;
        searchstr = searchstr.substring(startpos, searchstr.length);

        var nextpos = searchstr.length;
        if (searchstr.indexOf('&') >= 0) {
            nextpos = searchstr.indexOf('&');
        }

        searchstr = searchstr.substring(0, nextpos);
    } else {
        searchstr = '';
    }

    return unescape(searchstr);
};

///////////////////////////////////////////////////////////////////////////////////////////////
// searches the entire frameset and returns
// the frame with name frmname
function findFrame(w, frmname) {
    var res = null;

    if (frmname != '') {
        res = w.frames[frmname];

        // if it's not in the current window
        // search the sub-frames
        if (res == null) {
            var L = w.frames.length;
            var i;

            for (i = 0; i < L; i++) {
                res = findFrame(w.frames[i], frmname);
                if (res != null) {
                    break;
                }
            }
        }
    } else {
        result = this;
    }

    return res;
};

///////////////////////////////////////////////////////////////////////////////////////////////
// loads frame frmname with frmfile
function fillFrame(frmname, frmfile) {
    var theframe = findFrame(top, frmname);

    if (theframe != null) {
        theframe.location.replace(frmfile);
    }
    return true;
};

///////////////////////////////////////////////////////////////////////////////////////////////
// Called when the frameset file is loaded.
// Loads the framefile passed on the
// search string into the frame also passed
// on the search string
function loadTopicFrame() {
    var frmname = getStringVar('frmname');
    var frmfile = getStringVar('frmfile');

    if ((frmname != '') && (frmfile != '')) {
        fillFrame(frmname, frmfile);
    }
    
    return true;
};


var called = false;

///////////////////////////////////////////////////////////////////////////////////////////////
// ensures the current file is displayed within
// a frameset, if not loads the frame set which
// loads the file itself into the frameset.
function loadFrameSetOrTitle(framesetfile, targetframe, topicfile)
{
    if (!called) {
        called = true;
        if (self == top) {
            top.location.replace(framesetfile + '?frmname=' + escape(targetframe) + '&frmfile=' + escape(topicfile));
        }
    }

    return true;
};

///////////////////////////////////////////////////////////////////////////////////////////////
// shows or hides a DIV based on whether
// it's visible or not. Also toggles the corresponding
// expand/collaps graphic.
function internalToggleVisibilityEx(imgID, divID, storeVisibilityState, storeID, forceHide, forceShow, imgplussrc, imgminussrc)
{
    var div = document.getElementById(divID);
    var img = document.getElementById(imgID);

    if (div != null) {
        // Unfold the branch if it isn't visible
        if (((!forceHide) || forceShow) && (div.style.display == 'none')) {
            if (img != null) {
                img.src = imgminussrc;
            }
            div.style.display = '';

            // store the state so we can recreate it
            if (storeVisibilityState) {
                saveVisibilityState(storeID, true);
            }
        // Collapse the branch if it IS visible
        } else if (!forceShow) {
            if (img != null) {
                img.src = imgplussrc;
            }
            div.style.display = 'none';

            // store the state so we can recreate it
            if (storeVisibilityState) {
                saveVisibilityState(storeID, false);
            }
        }
    }
}

// toggles the visibility of divID and
// changes the img accordingly.
function toggleVisibilityTOC(imgID, divID)
{
    internalToggleVisibilityEx(imgID, divID, false, "", false, false, "tocplus.png", "tocminus.png");
}

function toggleVisibilitySection(imgID, divID)
{
    internalToggleVisibilityEx(imgID, divID, false, "", false, false, "sectionplus.png", "sectionminus.png");
}

// toggles the visibility of an item identified
// by storeID. To get the corresponding img
// and div ids, storeID is prefixed by 
// "img" and "div".
function toggleVisibilityStored(storeID)
{
    var imgID = "img" + storeID;
    var divID = "div" + storeID;
    internalToggleVisibilityEx(imgID, divID, true, storeID, false, false, "sectionplus.png", "sectionminus.png");
}


///////////////////////////////////////////////////////////////////////////////////////////////
// Copies the content of the element identified by ID
// to the clipboard. Works with Internet Explorer only.
function CopyElementToClipboard(ID)
{
    var element = document.getElementById(ID);

    if (element != null) {
        window.clipboardData.setData("Text", element.innerText);
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// Popup and Fixed Header
//

///////////////////////////////////////////////////////////////////////////////////////////////
// support functions

// Returns a rectangle object initialized
// with the given parameters.
function Rectangle(left, top, width, height)
{
	this.left = left;
	this.top = top;
	this.width = width;
	this.height = height;
}

// Hides or shows a popup element
function setElementVisible(element, v) {
    if (v) {
        element.style.visibility = "visible";
    } else {
        element.style.visibility = "hidden";
    }
}

// This function fills a rectange structure (r) with
// the window coordinates of the page client area
function getWindowClientArea(r)
{
    if (navigator.family == 'ie4') {
	   r.left = document.body.scrollLeft;
	} else {
	   r.left = window.pageXOffset;
	}

    if (navigator.family == 'ie4') {
	   r.top = document.body.scrollTop;
	} else {
	   r.top = window.pageYOffset;
	}

	r.width = window.document.body.clientWidth;
	if (!r.width) {
	    r.width = window.innerWidth;
	}
	if (!r.width) {
	    r.width = window.outerWidth;
	}

	r.height = window.document.body.clientHeight;
	if (!r.height) {
	   r.height = window.innerHeight;
	}
	if (!r.height) {
	   r.height = window.outerHeight;
	}
}

// Returns the absolute X coordinate of an element
// Source: DHTML Lab
function getRealLeft(theElement) {
    xPos = theElement.offsetLeft;
    tempEl = theElement.offsetParent;
    while (tempEl != null) {
        xPos += tempEl.offsetLeft;
        tempEl = tempEl.offsetParent;
    }
    return xPos;
}

// Returns the absolute Y coordinate of an element
// Source: DHTML Lab
function getRealTop(theElement) {
    yPos = theElement.offsetTop;
    tempEl = theElement.offsetParent;
    while (tempEl != null) {
        yPos += tempEl.offsetTop;
        tempEl = tempEl.offsetParent;
    }
    return yPos;
}

// This gets the extent of the given object
function getElementBounds(element, rect)
{
	if (typeof element.offsetLeft != 'undefined') {
		rect.left = getRealLeft(element);
		rect.top = getRealTop(element);
		rect.width = element.offsetWidth;
		rect.height = element.offsetHeight;
	} else {
		rect.left = 0;
		rect.top = 0;
		rect.width = 0;
		rect.height = 0;
	}
}

// Sets the x/y coordinates and the popup width but
// not the height, which auto-adjusts to the content.
function setElementBounds(element, rect)
{
	element.style.left = rect.left + "px";
	element.style.top = rect.top + "px";
	element.style.width = rect.width + "px";
	element.style.height = ""; //rect.height + "px";
}

// Browser dependent GetElementById version
function findElement(id)
{
    var ie = document.all;

    if (ie) {
	    return document.all(id);
    } else {
	    return document.getElementById(id);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Popup Functions
//

var hidetimer = null;       // Helper timer. During the lifetime
                            // of this timer OnMouseDown events
                            // from the body will be ignored
var closetimer = null;      // Timer used to close a popup upon
                            // mouse click. Since the mouse click
                            // could be on a link, the browser would
                            // not load the target if we remove the
                            // popup immediately.
var thePopup = null;        // Holds the popup element, if one is active

// Fired when the hidetimer expires, simply
// deactivates and initializes the timer
// which signals that Body.OnMouseDown events
// will be processed.
function activateOnHide()
{
	clearTimeout(hidetimer);
	hidetimer = null;
}

// Shows a popup div
// Parameters:
//  trigger -           Element triggering the popup action. The
//                      popup will be aligned on the lower left
//                      edge of the TriggerElement.
//  divid -             The id of the DIV element that contains
//                      the popup content.
function showPopup(trigger, divid)
{
    // if there is a popup visible at the
    // moment, we need to close it.
    if (thePopup != null) {
        doClosePopup();
    }

    thePopup = findElement(divid);

    if (thePopup == null)
        return;

	var clientarea = new Rectangle;
	var popuprect = new Rectangle;
	var triggerrect = new Rectangle;

	getWindowClientArea(clientarea);
	getElementBounds(thePopup, popuprect);
	getElementBounds(trigger, triggerrect);

    // set the initial size, the height
    // will adjust automatically
	popuprect.left = 0;
	popuprect.top = triggerrect.top + triggerrect.height;
	popuprect.width = clientarea.width / 2;

	setElementBounds(thePopup, popuprect);

    // check if the popup is taller than
    // the client area and reset it in that
    // case
	getElementBounds(thePopup, popuprect);

    var maxheight = clientarea.height - popuprect.top - 20;

	if ((maxheight > 0) && (popuprect.height > maxheight)) {
        thePopup.style.overflow = "auto";
        thePopup.style.height = maxheight;
	}

    // show it
	setElementVisible(thePopup, true);

    // prevent the popup from closing
    // through a OnMouseDown on the body
    // for a short period of time
    hidetimer = setTimeout("activateOnHide();", 200);
}

// Closes the current popup (if any) and
// kills the close timer.
function doClosePopup()
{
	clearTimeout(closetimer);
	closetimer = null;

	if (thePopup != null) {
		setElementVisible(thePopup, false);
		thePopup = null;
	}
}

// Initiates closing the popup if
//  * Hiding is not blocked by the hidetimer, or
//  * the popup is already being closed
function closePopup()
{
    if ((hidetimer != null) || (closetimer != null)) {
        return;
    }

    // to give clicked links a chance for
    // begin activated, the actual closing
    // is delayed a little.
    closetimer = setTimeout("doClosePopup();", 400);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Fixed header area functions

var scrollbaroffsetright = 0;
var scrollbaroffsetbottom = 4;

// Sets up the non-scrolling region and scroll area
// must be called whenever the window size changes
function doSetupFixedHeader(){
	if (document.body.clientWidth==0) return;

	var divFixed = findElement("areafixed");
	var divScroll = findElement("areascroll");
	if (divScroll == null) return;

	if (divFixed != null){

        if (navigator.family == 'ie4') {
		    document.body.scroll = "no"
 		    divFixed.style.width = document.body.offsetWidth - 2;
		    divScroll.style.paddingRight = "20px";
        }

		divScroll.style.overflow= "auto";

	    var clientarea = new Rectangle;
	    getWindowClientArea(clientarea);

		divScroll.style.width = clientarea.width - scrollbaroffsetright;
		divScroll.style.top=0;

		if (clientarea.height > divFixed.offsetHeight + scrollbaroffsetbottom) {
            var h = clientarea.height - (divFixed.offsetHeight + scrollbaroffsetbottom);
    		divScroll.style.height = h;
        }
		else {
		    divScroll.style.height = 0
		}
	}
}

// makes the page scoll normally so
// the print out will look ok.
function doBeforePrinting() {
	var i;

	if (window.text) {
        document.all.text.style.height = "auto";
    }

	for (i=0; i < document.all.length; i++){
		if (document.all[i].tagName == "BODY") {
			document.all[i].scroll = "yes";
		}
		if (document.all[i].id == "areafixed") {
			document.all[i].style.margin = "0px 0px 0px 0px";
			document.all[i].style.width = "100%";
		}
		if (document.all[i].id == "areascroll") {
			document.all[i].style.overflow = "visible";
			document.all[i].style.top = "5px";
			document.all[i].style.width = "100%";
			document.all[i].style.padding = "0px 10px 0px 30px";
		}
	}

    return;
}

// reloads the page to reset after changes
// in doBeforePrinting().
function reloadPage() {
    document.location.reload();
    return;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Expand/Collapse storage functions

var collapseStateCookieName = "DOM_Collapsed_Sections"
var collapsePersistenceName = "domdocSettings"

// If we create browser based HTML files, this variable will be true
var useCookies = false;

// If we create HTML Help or Help 2, this variable will be true
var usePersistence = true;

///////////////////////////////////////////////////////////////////////////////////////////////
// Cookie helper functions
// from http://www.quirksmode.org/js/cookies.html

function createCookie(name,value,days)
{
    var expires = "";

    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        expires = "; expires="+date.toGMTString();
    }

    document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name)
{
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name)
{
	createCookie(name,"",-1);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Persistence functions for use in HTML Help and Help 2

// This variable temporarily holds the collapsed section
// ids until the get stored using persistence.
var persistentCollapsedIDs = "";

// Saves the persistent data from our temporary
// variable which holds the value to the persistent
// storage.
function savePersistentData()
{
    var pdiv = document.getElementById("persistenceDiv");
    if (pdiv != null) {
        try {
            pdiv.setAttribute("collapsedIDs", persistentCollapsedIDs);
            pdiv.save(collapsePersistenceName);
        } catch (e) {
            // HTML Help may trigger an exception
        }
    }
    return;
}

// Loads the persistent data from the persistent
// storage into our temporary variable which holds
// the value for further use.
function loadPersistentData()
{
    persistentCollapsedIDs = "";

    var pdiv = document.getElementById("persistenceDiv");
    if (pdiv != null) {
        try {
            pdiv.load(collapsePersistenceName);
            var data = pdiv.getAttribute("collapsedIDs");
            if (data != null) {
                persistentCollapsedIDs = data;
            }
        }
        catch (e) {
            // HTML Help may trigger an exception
        }
    }
    return;
}

// Removes the persistent data from the storage.
function removePersistenceData()
{
    var pdiv = document.getElementById("persistenceDiv");
    if (pdiv != null) {
        try {
            pdiv.removeAttribute("collapsedIDs");
    	    pdiv.save(collapsePersistenceName);
        }
        catch (e) {
            // HTML Help may trigger an exception
        }
	}
	return;
}

// Saves the persistent data to our temporary variable that
// acts as storage while the page is being displayed.
function savePersistentKey(key, value)
{
    persistentCollapsedIDs = value;
    return;
}

// Returns the content in our temporary variable that
// acts as storage while the page is being displayed.
function loadPersistentKey(key)
{
    return persistentCollapsedIDs;
}

// Clears our temporary variable and erases
// the value from the persistent storage.
function removePersitentKey(key)
{
    persistentCollapsedIDs = "";
    removePersistenceData();
    return;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Collapsed section storage functions

// Saves the ID list in ids either using
// cookies or persistent storage,
// depending on what we use right now.
function saveExpandState(ids)
{
    if (useCookies) {
        createCookie(collapseStateCookieName, ids, 14);  // we store the cookie for 14 days
    } else if (usePersistence) {
        savePersistentKey(collapsePersistenceName, ids);
    }

    return;
}

// Loads the collapsed ID list either from
// cookies or persistent storage,
// depending on what we use right now.
function loadExpandState()
{
    var data = "";
    if (useCookies) {
        data = readCookie(collapseStateCookieName);
    } else if (usePersistence) {
        data = loadPersistentKey(collapsePersistenceName);
    }

    return data;
}

// Removes the collapsed ID list either from
// cookies or persistent storage,
// depending on what we use right now.
function eraseExpandState()
{
    if (useCookies) {
        eraseCookie(collapseStateCookieName);
    } else if (usePersistence) {
        removePersitentKey(collapsePersistenceName);
    }

    return;
}

//////////////////////////////////////////////////////////////////////////////////////////////

// Adds an ID to a list of IDs
function doAddId(res, addId)
{
    var result = res;

    if (result != "") {
        result = result + ",";
    }

    result = result + addId;

    return result;
}

// Converts the stored id into a div and
// img Id an calls the showing function
function doShowHideCollapsedId(id, visible)
{
    var imgid = "img" + id;
    var divid = "div" + id;

    internalToggleVisibilityEx(imgid, divid, false, "", !visible, visible, "sectionplus.png", "sectionminus.png");
}

// Goes through the list of Ids passed in ids and
// either adds a new ID, remove an ID, collapses
// or expands the elements in the list.
// Returns:
//   The new list of IDs.
// Parameters:
//   ids -        a string with the list of IDs, separated
//                by commas, ("ID1,ID2,ID3").
//   addId -      an ID to be added to the list.
//   removeId -   an ID to be removed from the list.
//   collapsIds - a boolean that indicates if the elements
//                in the list shall be collapsed.
//   expandIds -  a boolean that indicates if the elements
//                in the list shall be expanded.
function processCollapsedIds(ids, addId, removeId, collapsIds, expandIds)
{
    var result = "";
    var idlist = ids;

    while (idlist.length > 0) {
        var id = "";
        var idx = idlist.indexOf(',');

        if (idx >= 0) {
            id = idlist.substring(0, idx);
            idlist = idlist.substring(idx+1);
        } else {
            id = idlist;
            idlist = "";
        }

        if (collapsIds) {
            doShowHideCollapsedId(id, false);
        }

        if (expandIds) {
            doShowHideCollapsedId(id, true);
        }

        // check if add Id is
        // already in the list
        // so we don't add it twice
        if (addId.length > 0) {
            if (id == addId) {
                addId = "";
            }
        }

        // if the Id doesn't match
        // removeId, we preserve it.
        if (removeId.length > 0) {
            if (id == removeId) {
                id = "";
            }
        }

        if (id.length > 0) {
            result = doAddId(result, id);
        }
    }

    // if addId was not removed
    // we add it.
    if (addId != "") {
        result = doAddId(result, addId);
    }

    return result;
}

// Reads the current collapse list and adds or
// removes an ID to/from it.
function modifyCollapseState(addid, removeid)
{
    var ids = loadExpandState();

    if (ids == null) {
        ids = "";
    }

    ids = processCollapsedIds(ids, addid, removeid, false, false);

    if (ids != "") {
        saveExpandState(ids);
    } else {
        eraseExpandState();
    }
}

// Depending on visibility, removes or adds
// an ID to the collaps list.
function saveVisibilityState(id, visible)
{
    if (visible) {
        modifyCollapseState("", id);
    } else {
        modifyCollapseState(id, "");
    }
}

// Restores the collaps states of all
// stored elements.
function loadCollapseStates()
{
    var ids = loadExpandState();

    if (ids != null) {
        processCollapsedIds(ids, "", "", true, false);
    }
}

// expands all currently collapsed
// elements and clears the storage.
function showAllElements()
{
    var ids = loadExpandState();

    if (ids != null) {
        processCollapsedIds(ids, "", "", false, true);
        eraseExpandState();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// event handlers

// Process key input
function ieKey()
{
	if (window.event.keyCode == 27) {
        closePopup();
		doSetupFixedHeader();
		onResizeWindow();
	}
}

// Called when the brower window resizes
function onResizeWindow()
{
	doSetupFixedHeader();  //resize the scroll area
    return;
}

// Initialize the Header
function onBodyLoad()
{
    doSetupFixedHeader();
	document.onkeypress = ieKey;
	window.onresize = onResizeWindow;

    if (navigator.family == 'ie4') {
	    window.onbeforeprint = doBeforePrinting;
	    window.onafterprint = reloadPage;
	}
	
    // if we use persistence we
    // load the settings now
    if (usePersistence) {
        loadPersistentData();
        window.onunload = onUnloadWindow;
    }

    // restore collapsed sections
	loadCollapseStates();
}

// used to save settings to the persistent
// storage if we use it.
function onUnloadWindow()
{
    if (usePersistence) {
        savePersistentData();
    }
    return;
}

// called if we're using framesets in
function onBodyLoadEx(framesetfile, targetframe, topicfile)
{
    loadFrameSetOrTitle(framesetfile, targetframe, topicfile);
    onBodyLoad();
    return true;
}

// Process mouse down events, close open popups
// and realign the fixed header area.
function onBodyMouseDown()
{
    closePopup();
    doSetupFixedHeader();
}

// Opens the big version of an image in a secondary window
function openBigImage(image)
{
    window.open(image, "_blank", "toolbar=no,status=no,menubar=no,resizable=yes");
}

// opens a mail window and fills the
// address, subject and body
function sendFeedback(mailto, subject, body)
{
    var href = "mailto:" + mailto + "?subject=" + subject + "&body=" + body;
    window.open(href, "_top");
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Browser detection
// Source: http://devedge.netscape.com/toolbox/examples/2002/xb/ua/

/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Netscape code.
 *
 * The Initial Developer of the Original Code is
 * Netscape Corporation.
 * Portions created by the Initial Developer are Copyright (C) 2001
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Bob Clary <bclary@netscape.com>
 *
 * ***** END LICENSE BLOCK ***** */

function xbDetectBrowser()
{
  var oldOnError = window.onerror;
  var element = null;

  window.onerror = null;
  
  // work around bug in xpcdom Mozilla 0.9.1
  window.saveNavigator = window.navigator;

  navigator.OS    = '';
  navigator.version  = parseFloat(navigator.appVersion);
  navigator.org    = '';
  navigator.family  = '';

  var platform;
  if (typeof(window.navigator.platform) != 'undefined')
  {
    platform = window.navigator.platform.toLowerCase();
    if (platform.indexOf('win') != -1)
      navigator.OS = 'win';
    else if (platform.indexOf('mac') != -1)
      navigator.OS = 'mac';
    else if (platform.indexOf('unix') != -1 || platform.indexOf('linux') != -1 || platform.indexOf('sun') != -1)
      navigator.OS = 'nix';
  }

  var i = 0;
  var ua = window.navigator.userAgent.toLowerCase();
  
  if (ua.indexOf('opera') != -1)
  {
    i = ua.indexOf('opera');
    navigator.family  = 'opera';
    navigator.org    = 'opera';
    navigator.version  = parseFloat('0' + ua.substr(i+6), 10);
  }
  else if ((i = ua.indexOf('msie')) != -1)
  {
    navigator.org    = 'microsoft';
    navigator.version  = parseFloat('0' + ua.substr(i+5), 10);
    
    if (navigator.version < 4)
      navigator.family = 'ie3';
    else
      navigator.family = 'ie4'
  }
  else if (ua.indexOf('gecko') != -1)
  {
    navigator.family = 'gecko';
    var rvStart = ua.indexOf('rv:');
    var rvEnd   = ua.indexOf(')', rvStart);
    var rv      = ua.substring(rvStart+3, rvEnd);
    var rvParts = rv.split('.');
    var rvValue = 0;
    var exp     = 1;

    for (var i = 0; i < rvParts.length; i++)
    {
      var val = parseInt(rvParts[i]);
      rvValue += val / exp;
      exp *= 100;
    }
    navigator.version = rvValue;

    if (ua.indexOf('netscape') != -1)
      navigator.org = 'netscape';
    else if (ua.indexOf('compuserve') != -1)
      navigator.org = 'compuserve';
    else
      navigator.org = 'mozilla';
  }
  else if ((ua.indexOf('mozilla') !=-1) && (ua.indexOf('spoofer')==-1) && (ua.indexOf('compatible') == -1) && (ua.indexOf('opera')==-1)&& (ua.indexOf('webtv')==-1) && (ua.indexOf('hotjava')==-1))
  {
    var is_major = parseFloat(navigator.appVersion);
    
    if (is_major < 4)
      navigator.version = is_major;
    else
    {
      i = ua.lastIndexOf('/')
      navigator.version = parseFloat('0' + ua.substr(i+1), 10);
    }
    navigator.org = 'netscape';
    navigator.family = 'nn' + parseInt(navigator.appVersion);
  }
  else if ((i = ua.indexOf('aol')) != -1 )
  {
    // aol
    navigator.family  = 'aol';
    navigator.org    = 'aol';
    navigator.version  = parseFloat('0' + ua.substr(i+4), 10);
  }
  else if ((i = ua.indexOf('hotjava')) != -1 )
  {
    // hotjava
    navigator.family  = 'hotjava';
    navigator.org    = 'sun';
    navigator.version  = parseFloat(navigator.appVersion);
  }

  window.onerror = oldOnError;
}

xbDetectBrowser();
