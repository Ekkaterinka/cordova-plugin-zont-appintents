import Foundation
import AppIntents
import Cordova

@objc(SiriPlugin)
class SiriPlugin: CDVPlugin {
    
    static var commandDelegate: CDVCommandDelegate?
    static var commandCallback: String?
    
    @objc(registerForSiriCommands:)
    func registerForSiriCommands(command: CDVInvokedUrlCommand) {
        SiriPlugin.commandDelegate = self.commandDelegate
        SiriPlugin.commandCallback = command.callbackId
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    
    static func executeJSFunction(functionName: String, parameters: [String: Any]?) {
        guard let callbackId = commandCallback, let delegate = commandDelegate else { return }
        
        var resultDict: [String: Any] = ["functionName": functionName]
        if let params = parameters {
            resultDict["parameters"] = params
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: resultDict)
        pluginResult?.keepCallback = true
        delegate.send(pluginResult, callbackId: callbackId)
    }
}