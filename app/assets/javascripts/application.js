// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require ./fancybox/jquery.fancybox
//= #require_tree .
//= #require ./bootstrap/bootstrap

// MENU SCRIPT

var persistmenu = null;
var persisttype = null;
function SwitchMenu(obj){
    if(document.getElementById){
        var el = document.getElementById(obj);
        el.style.display = (el.style.display == "block" ? "none" : "block");
    }
}

function get_cookie(Name) {
    var search = Name + "="
    var returnvalue = "";
    if (document.cookie.length > 0) {
        offset = document.cookie.indexOf(search)
        if (offset != -1) {
            offset += search.length
            end = document.cookie.indexOf(";", offset);
            if (end == -1) end = document.cookie.length;
            returnvalue=unescape(document.cookie.substring(offset, end))
        }
    }
    return returnvalue;
}

function onloadfunction(){
    if (persistmenu=="yes"){
        var cookiename=(persisttype=="sitewide")? "switchmenu" : window.location.pathname
        var cookievalue=get_cookie(cookiename)
        if (cookievalue!="")
            document.getElementById(cookievalue).style.display="block"
    }
}

function savemenustate(){
    var inc=1, blockid=""
    while (document.getElementById("sub"+inc)){
        if (document.getElementById("sub"+inc).style.display=="block"){
            blockid="sub"+inc
            break
        }
        inc++
    }
    var cookiename=(persisttype=="sitewide")? "switchmenu" : window.location.pathname
    var cookievalue=(persisttype=="sitewide")? blockid+";path=/" : blockid
    document.cookie=cookiename+"="+cookievalue
}

function startup(){
    persistmenu="yes" //"yes" or "no". Make sure each SPAN content contains an incrementing ID starting at 1 (id="sub1", id="sub2", etc)
    persisttype="sitewide" //enter "sitewide" for menu to persist across site, "local" for this page only

    if (window.addEventListener)
        window.addEventListener("load", onloadfunction, false)
    else if (window.attachEvent)
        window.attachEvent("onload", onloadfunction)
    else if (document.getElementById)
        window.onload=onloadfunction

    if (persistmenu=="yes" && document.getElementById)
        window.onunload=savemenustate
}

function swfsVisibility(visible){
    $('#flash-ice').toggle(visible);
    $('#flash-top').toggle(visible);
    $('#flash-bottom').toggle(visible);
}

startup();