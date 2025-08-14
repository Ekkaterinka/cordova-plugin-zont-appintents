var exec = require('cordova/exec');

// exports.registerForSiriCommands = function (success, error) {
//     exec(success, error, 'ZontAppintents', 'registerForSiriCommands', []);
// };


var exec = require('cordova/exec');

module.exports = {
    registerForSiriCommands: function (options, successCallback, failCallback) {
        exec(successCallback, failCallback, "ZontAppintents", "registerForSiriCommands", [options]);
    },
    // setParamsShort: function (successCallback, failCallback) {
    //     exec(successCallback, failCallback, "wifi", "getConnectedInfo", [options]);
    // },
    //   scan: function (options, successCallback, failCallback) {
    //     exec(successCallback, failCallback, "wifi", "scan", [options]);
    //   },
    //   connect: function (ssid, password, successCallback, failCallback) {
    //     exec(successCallback, failCallback, "wifi", "connect", [ssid, password]);
    //   },
    //   disconnect: function (ssid, successCallback, failCallback) {
    //     exec(successCallback, failCallback, "wifi", "disconnect", [ssid]);
    //   }
}