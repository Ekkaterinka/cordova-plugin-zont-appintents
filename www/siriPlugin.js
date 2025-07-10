var exec = require('cordova/exec');

exports.registerForSiriCommands = function (success, error) {
    exec(success, error, 'ZontAppintents', 'registerForSiriCommands', []);
};
