// mch2 main component
//
// Copyright (c) 2013 tamura shingo

var gMch2 = null;

function Mch2() {
}

Mch2.prototype.init = function() {
}

Mch2.prototype.getMailobj = function() {
    var mailobj = {
        addr_to: [],
        addr_cc: [],
        addr_bcc: [],
        addr_from: "",
        subject: "",
        content: "",
        attach: []
    };

    var getAddress = function() {
        var cnt = 1;
        var addr = null;
        while (addr = document.getElementById("addressCol2#" + cnt)) {
            var type = document.getElementById("addressCol1#" + cnt).value;
            switch (type) {
            case "addr_to":
                mailobj.addr_to.push(addr.value);
                break;
            case "addr_cc":
                mailobj.addr_cc.push(addr.value);
                break;
            case "addr_bcc":
                mailobj.addr_bcc.push(addr.value);
                break;
            }
            cnt = cnt + 1;
        }
        var user = nsPreferences.copyUnicharPref("mch2.user", "xxxx@xxxxx");
        mailobj.addr_from = user;
    };

    var getSubject = function() {
        var subject = document.getElementById("msgSubject");
        if (subject) {
            mailobj.subject = subject.value;
        }
    };

    var getContent = function() {
        var content = document.getElementById("content-frame");
        if (content) {
            mailobj.content = content.contentDocument.body.innerHTML;
        }
    };

    var getAttach = function() {
        var bucket = document.getElementById("attachmentBucket");
        var rowCount = bucket.getRowCount();
        for (var i = 0; i < rowCount; ++i) {
            var attachment = bucket.getItemAtIndex(i).attachment;
            if (attachment) {
                var url = attachment.url;
                var ios = Components.classes["@mozilla.org/network/io-service;1"]
                    .getService(Components.interfaces.nsIIOService);
                var fileHandler = ios.getProtocolHandler("file")
                    .QueryInterface(Components.interfaces.nsIFileProtocolHandler);
                var file = fileHandler.getFileFromURLSpec(url);
                mailobj.attach.push({attach_filename: url,
                                     attach_content: file});
            }
        }
    };

    getAddress();
    getSubject();
    getContent();
    getAttach();

    return mailobj;
}


Mch2.prototype.check = function() {
    var mailobj = this.getMailobj();
    window.openDialog("chrome://mch2/content/check.xul", "mch2check", "chrome,dialog,modal,centerscreen,resizable,width=600,height=300", {mailobj: mailobj});
}

gMch2 = new Mch2();
gMch2.init();

