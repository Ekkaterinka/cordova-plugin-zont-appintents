var exec = require('cordova/exec');

exports.siriPlugin = function (success, error) {
    exec(success, error, 'siriPlugin', 'siriPlugin', []);
};
