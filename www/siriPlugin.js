var exec = require('cordova/exec');

module.exports = {
    registerForSiriCommands: function (options, successCallback, failCallback) {
        exec(successCallback, failCallback, "ZontAppintents", "registerForSiriCommands", options);
    },
}