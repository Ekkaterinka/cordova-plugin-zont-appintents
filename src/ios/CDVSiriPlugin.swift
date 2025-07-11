import Foundation
import AppIntents


@available(iOS 16.0, *)
@objc(CDVSiriPlugin)
class CDVSiriPlugin: CDVPlugin {
    
    static var commandDelegate: CDVCommandDelegate?
    static var commandCallback: String?

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
    
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(_ command: CDVInvokedUrlCommand) {
        guard TokenManager.shared.hasValidToken() else {
            let result = CDVPluginResult(status: .error, messageAs: "No valid token available")
            self.commandDelegate?.send(result, callbackId: command.callbackId)
            return
        }
        
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