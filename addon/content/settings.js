// mch2 settings
//
// Copyright (c) 2013 tamura shingo

var gMch2Set = null;

function onLoad() {
    gMch2Set = new Mch2Set();
    gMch2Set.init();
}

function Mch2Set() {
}

Mch2Set.prototype.init = function() {
    gMch2Set.loadPrefs();
}

Mch2Set.prototype.savePrefs = function() {
    // mch2-server
    var server = document.getElementById("mch2server");
    if (server) {
        nsPreferences.setUnicharPref("mch2.server", server.value);
    }

    // mch2-user
    var user = document.getElementById("mch2user");
    if (user) {
        nsPreferences.setUnicharPref("mch2.user", user.value);
    }

    return true;
}

Mch2Set.prototype.cancelPrefs = function() {
    return true;
}

Mch2Set.prototype.loadPrefs = function() {
    var server = document.getElementById("mch2server");
    var serverstr = nsPreferences.copyUnicharPref("mch2.server", "");
    if (server) {
        server.value = serverstr;
    }

    var user = document.getElementById("mch2user");
    var userstr = nsPreferences.copyUnicharPref("mch2.user", "xxxx@xxxxxx");
    if (user) {
        user.value = userstr;
    }
}

