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
//= #require_tree .
//= #require ./bootstrap/bootstrap

var node1='/thm/light/light/node1.gif';
var node2='/thm/light/light/node2.gif';
var dom = (document.getElementById)? true : false;

function getelem(id){
    return (dom)?document.getElementById(id):document.all[id]
}

function relPosX(which) {
    var elem = document.all[which];
    var pos = elem.offsetLeft;
    while (elem.offsetParent != null) {
        elem = elem.offsetParent;
        pos += elem.offsetLeft;
        if (elem.tagName == 'BODY') break;
    } return pos;
}

function relPosY(which) {
    var elem = document.all[which];
    var pos = elem.offsetTop;
    while (elem.offsetParent != null) {
        elem = elem.offsetParent;
        pos += elem.offsetTop;
        if (elem.tagName == 'BODY') break;
    } return pos;
}

function sh(id){
    var el=getelem(id)
    el.style.display=(el.style.display=='block')?'none':'block'
    return (el.style.display)
}

function sv(id){
    var el=getelem(id)
    el.style.visibility=(el.style.visibility=='hidden')?'visible':'hidden'
    return (el.style.visibility)
}

function svo(id){
    var el=getelem(id)
    el.style.visibility=(el.style.visibility=='hidden')?'visible':'hidden'
    if(getelem("pct"+id) && el.style.left=="1px"){
        el.style.left=17+relPosX("pct"+id);
        el.style.top=14+relPosY("pct"+id);
    }
    if(el.style.visibility=="hidden"){
        el.style.left=1;
        el.style.top=1;
    }
    return (el.style.visibility)
}

function op(id){
    ret=sh(id);
    if (document.images["mimg"+id]) document.images["mimg"+id].src=(ret=='block'?node2:node1)
    document.cookie = 'menu'+id+'='+escape(ret)
}

function cim(im,pic){
    document.images[im].src=pic;
}

function check(which){
    var frm=eval('document.forms.'+which)
    var la=0
    for (var e = 0; e < frm.elements.length; e++){
        var el = frm.elements[e];
        if (el.tc){
            if (!la && el.tc=='email'  && (el.value.indexOf("@")<0 || el.value.indexOf(".")<1)){ alert('яПНяПНяПНяПНяПНяПНяПНяПН email'); la=1 }
            if (!la && el.tc=='яПНяПНяПНяПНяПНяПН') var password1=el.value
            if (!la && el.tc=='яПНяПНяПНяПНяПНяПН2' && password1!=el.value){ alert('яПНяПНяПНяПНяПНяПН яПНяПН яПНяПНяПНяПНяПНяПНяПНяПНяПН'); la=1 }
            if (!la && el.value==""){
                alert('яПНяПНяПНяПНяПНяПН яПНяПНяПНяПН "'+el.tc+'"')
                la=1;
            }
        }
    }
    return (!la)?true:false;
}

function inop(formname, elem, vall, txt){
    var opt = parent.document.createElement("OPTION")
    el=eval("parent.document.forms."+formname+"."+elem)
    el.options.add(opt)
    opt.value=txt
    opt.innerText=vall
}

function buy(id,type){
    var value=getelem('v_'+id)
//  var urla='summ.php?act='+(type==1?"set":($type==2?"add":"del"))+"&id="+id+(type==1?"&num="+value.value:""))
    var urla='summ.php?act='+(type==1?"set":($type==2?"add":"del"))+"&id="+id+(type==1?"&num="+value.value:"")
    var sfd=getelem("summframediv");
    sfd.innerHTML='<iframe id=summframe name=summframe src="'+urla+'" style="display:none;visibility:hidden;height:0px;width:0px"></iframe>';
    return false
}

function buy2(id,type){
    var value=getelem('v_'+id)
    document.frames.summ.document.location='summ.php?fromcart=1&act='+(type==1?"set":$type==2?"add":"del")+"&id="+id+(type==1?"&num="+value.value:"")
    return false
}

function s_buy(id,colvo){
    var value=getelem('o_'+id)
    var summ=getelem('summ_view')
    if (value) value.innerHTML=colvo;
}

function cp(src, dst){
    var src=eval(src);
    var dst=eval(dst);
    dst.innerHTML=src.innerHTML
}

function wo(hrf, width, height){
    window.open(hrf,'','resizable=yes,scrollbars=yes,width='+width+',height='+height);
}

function wno(strn){
    var wn=window.open('','wn','width=400,height=250');
    wn.document.open();
    wn.document.write('<html><head><title>яПНяПНяПНяПНяПНяПНяПНяПНяПН</title><style>.tx{font-family:verdana; font-size:8pt;color:black; text-decoration:none}</style></head><body class=tx bgcolor=white><div align=right><a class=tx href="#" style="font-size: 7pt" onclick="window.print()">&nbsp;яПНяПНяПНяПНяПНяПН&nbsp;</a><a class=tx href="#" style="font-size: 7pt"  onclick="window.close()">&nbsp;яПНяПНяПНяПНяПНяПНяПН&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></div><br><center>'+strn+'</center><script>self.moveTo((screen.width/2)-200,(screen.height/2)-120)</script></body></html>');
    wn.document.close();
}

function show_cart(txt){
    var smd=getelem('summdiv')
    if(smd) smd.innerHTML=txt;
}

// MENU SCRIPT

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
    var persistmenu="yes" //"yes" or "no". Make sure each SPAN content contains an incrementing ID starting at 1 (id="sub1", id="sub2", etc)
    var persisttype="sitewide" //enter "sitewide" for menu to persist across site, "local" for this page only

    if (window.addEventListener)
        window.addEventListener("load", onloadfunction, false)
    else if (window.attachEvent)
        window.attachEvent("onload", onloadfunction)
    else if (document.getElementById)
        window.onload=onloadfunction

    if (persistmenu=="yes" && document.getElementById)
        window.onunload=savemenustate
}

startup();