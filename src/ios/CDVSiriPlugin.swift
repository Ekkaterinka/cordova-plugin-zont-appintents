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

    @objc(setToken:)
    func setToken(command: CDVInvokedUrlCommand) {
        guard let token = command.argument(at: 0) as? String else {
            let result = CDVPluginResult(status: .error, messageAs: "Token is required")
            self.commandDelegate?.send(result, callbackId: command.callbackId)
            return
        }
        
        TokenManager.shared.token = token
        
        let result = CDVPluginResult(status: .ok)
        self.commandDelegate?.send(result, callbackId: command.callbackId)
    }

    @objc(setParamsShort:)
    func setParamsShort(_ command: CDVInvokedUrlCommand) {
        return [title:command.arguments[0] , description: command.arguments[1], is_auth: command.arguments[2]]
    }
    
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(_ command: CDVInvokedUrlCommand) {
        guard TokenManager.shared.hasValidToken() else {
            let result = CDVPluginResult(status: .error, messageAs: "No valid token available")
            self.commandDelegate?.send(result, callbackId: command.callbackId)
            return
        }

        [title:command.arguments[0] , description: command.arguments[1], is_auth: command.arguments[2]]

        CDVSiriPlugin.title = command.arguments[0]
        CDVSiriPlugin.description = command.arguments[1]
        CDVSiriPlugin.is_auth = command.arguments[2]
        CDVSiriPlugin.list_action = command.arguments[3]
        CDVSiriPlugin.list_devices = command.arguments[4]
        
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