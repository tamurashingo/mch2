// mch2 check component
//
// Copyright (c) 2013 tamura shingo

var gMch2Chk = null;

function Mch2Chk() {
    this.rules = [];
    this.mailobj = null;
    this.mch2server = "";
}

Mch2Chk.prototype.init = function() {
    // load setting
    var server = nsPreferences.copyUnicharPref("mch2.server", "");
    this.mch2server = server;

    this.loadRule();
    this.updateRule();

}


Mch2Chk.prototype.loadRule = function() {
    Components.classes["@mozilla.org/moz/jssubscript-loader;1"]
        .getService(Components.interfaces.mozIJSSubScriptLoader)
        .loadSubScript("chrome://messenger/content/jquery.js");

    var inv = new XMLHttpRequest();
    var url = "http://" + this.mch2server + "/rules.cgi";

    inv.open('GET', url, false);
    inv.send();

    var data = inv.responseText.split(/\r\n|\r|\n/);

    this.rules = [];
    for (var i = 0; i < data.length; ++i) {
        if (data[i] != "") {
            this.rules.push(data[i]);
        }
    }
}

Mch2Chk.prototype.updateRule = function() {
    const XUL_NS = "http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul";

    var menu = document.getElementById("rules-menu");

    while (menu.hasChildNodes()) {
        menu.removeChild(menu.firstChild);
    }

    for (var i = 0; i < this.rules.length; ++i) {
        var item = document.createElementNS(XUL_NS, "menuitem");
        item.setAttribute("label", this.rules[i]);
        item.setAttribute("value", this.rules[i]);
        
        menu.appendChild(item);
    }
}

Mch2Chk.prototype.doCheck = function() {
    var rule = document.getElementById("rules").selectedItem.value;
    var url = "http://" + this.mch2server + "/check/" + rule;

    var encodedHtmlForm = function(data) {
        var params = [];
        for (var name in data) {
            var value = data[name];
            var param = encodeURIComponent(name).replace(/%20/g, "+")
                + '=' + encodeURIComponent(value).replace(/%20/g, "+");

            params.push(param);
        }

        return params.join('&');
    };

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("checkresult").setAttribute("src", "data:text/html;charset=utf-8," + encodeURIComponent(this.responseText));
        }
    };
    xhr.open("POST", url);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

    var req = encodedHtmlForm(this.mailobj);

    xhr.send(encodedHtmlForm(this.mailobj));
}



function onLoad() {
    var arguments = window.arguments[0];
    gMch2Chk = new Mch2Chk();
    gMch2Chk.init();

    gMch2Chk.mailobj = arguments.mailobj
}

