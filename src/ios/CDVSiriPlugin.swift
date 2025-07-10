import Foundation
import AppIntents


@available(iOS 16.0, *)
@objc(CDVSiriPlugin)
class CDVSiriPlugin: CDVPlugin {
    
    static var commandDelegate: CDVCommandDelegate?
    static var commandCallback: String?
    
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(_ command: CDVInvokedUrlCommand) {
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