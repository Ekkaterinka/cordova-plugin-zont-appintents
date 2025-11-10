module.exports = function(context) {
    var Q = require('q');
    var deferral = Q.defer();
    var fs = require('fs');
    var path = require('path');
    
    function checkIOS18Requirement() {
        var iosPlatform = context.opts.platforms && context.opts.platforms.indexOf('ios') !== -1;
        
        if (!iosPlatform) {
            return Q.resolve(); // Не iOS, пропускаем проверку
        }

        return Q.fcall(function() {
            // Получаем версию iOS разными способами
            var version = null;
            
            // Из config.xml
            try {
                var ConfigParser = require('cordova-common').ConfigParser;
                var config = new ConfigParser('config.xml');
                version = config.getPreference('deployment-target', 'ios');
            } catch (e) {
                console.log('Не удалось прочитать config.xml: ' + e.message);
            }
            
            // Если версия не найдена, используем дефолтную логику
            if (!version) {
                console.log('Версия iOS не указана в config.xml. Используем strict режим.');
                // В strict режиме требуем явного указания версии
                throw new Error('Требуется явное указание deployment-target в config.xml для iOS');
            }
            
            // Парсим версию
            var majorVersion = parseInt(version.split('.')[0]);
            console.log('Определена версия iOS: ' + version + ' (major: ' + majorVersion + ')');
            
            if (majorVersion >= 18) {
                console.log('✅ Версия iOS ' + version + ' поддерживается');
                return true;
            } else {
                console.log('❌ Версия iOS ' + version + ' не поддерживается. Требуется 18.0+');
                return false;
            }
        });
    }

    // Выполняем проверку
    checkIOS18Requirement()
        .then(function(supported) {
            if (supported) {
                deferral.resolve(); // Установка разрешена
            } else {
                deferral.reject(new Error('IOS_VERSION_NOT_SUPPORTED')); // Установка заблокирована
            }
        })
        .catch(function(error) {
            console.log('🚨 Ошибка проверки версии iOS: ' + error.message);
            // В зависимости от требований:
            // deferral.resolve(); // Разрешить установку при ошибке
            deferral.reject(error); // Или заблокировать установку при ошибке
        });

    return deferral.promise;
};