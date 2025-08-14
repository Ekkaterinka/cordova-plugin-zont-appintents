import AppIntents

@available(iOS 16.0, *)
struct siriAppIntent: AppIntent {
    static var title = LocalizedStringResource(CDVSiriPlugin.title)
    static var description = IntentDescription(CDVSiriPlugin.description)
    
    // @Parameter(title: "Function Name")
    // var functionName: String


    
    func perform() async throws -> some IntentResult {
        CDVSiriPlugin.executeJSFunction()
        return .result()
    }
}

