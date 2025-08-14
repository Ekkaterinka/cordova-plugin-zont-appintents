import Foundation
import AppIntents


@available(iOS 16.0, *)
@objc(CDVSiriPlugin)
class CDVSiriPlugin: CDVPlugin {
    
    static var commandDelegate: CDVCommandDelegate?
    static var commandCallback: String?
    static var title: String?
    static var description: String?
    static var is_auth: Bool?
    static var list_action: Array<Any>?
    static var list_device: Array<Any>?

    
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(_ command: CDVInvokedUrlCommand) {

        CDVSiriPlugin.title = command.options[0]
        CDVSiriPlugin.description = command.options[1]
        CDVSiriPlugin.is_auth = command.options[2]
        CDVSiriPlugin.list_action = command.options[3]
        CDVSiriPlugin.list_devices = command.options[4]
        
        CDVSiriPlugin.commandDelegate = self.commandDelegate
        CDVSiriPlugin.commandCallback = command.callbackId
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    
    static func executeJSFunction(functionName: String) {
        guard let callbackId = commandCallback, let delegate = commandDelegate else { return }
        
        let resultDict: [String: Any] = ["functionName": functionName]
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: resultDict)
        pluginResult?.keepCallback = true
        delegate.send(pluginResult, callbackId: callbackId)
    }
}