import Foundation
import AppIntents
import SwiftUI


@available(iOS 16.0, *)
@objc(CDVSiriPlugin)
class CDVSiriPlugin: CDVPlugin {
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(command: CDVInvokedUrlCommand) {
        guard let items = command.argument(at: 0) as? [String: Any] else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid arguments")
            self.commandDelegate.send(result, callbackId: command.callbackId)
            return
        }
        
        if let itemwithToken = items["auth_token"]  {
                UserDefaults.standard.set(itemwithToken, forKey: "ZONT_token")
                UserDefaults.standard.synchronize()
        }
        if let itemwithDevices = items["devices"]  {
            UserDefaults.standard.set(itemwithDevices, forKey: "ZONT_devices")
            UserDefaults.standard.synchronize()
        }
  
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Devices saved")
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
}