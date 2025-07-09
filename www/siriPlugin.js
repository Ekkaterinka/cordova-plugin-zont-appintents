var exec = require('cordova/exec');

exports.SiriPlugin = function (success, error) {
    exec(success, error, 'siriPlugin', 'SiriPlugin', []);
};
