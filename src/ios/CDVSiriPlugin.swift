import Foundation
import AppIntents

@objc(CDVSiriPlugin) 
class CDVSiriPlugin: CDVPlugin {
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(command: CDVInvokedUrlCommand) {
        guard let items = command.argument(at: 0) as? [[String: Any]] else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid arguments")
            self.commandDelegate.send(result, callbackId: command.callbackId)
            return
        }

        UserDefaults.standard.set(items, forKey: "device_shortcuts")
        UserDefaults.standard.synchronize()

        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Devices saved")
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
}