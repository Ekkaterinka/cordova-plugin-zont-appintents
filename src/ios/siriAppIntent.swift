import AppIntents

@available(iOS 16.0, *)
struct siriAppIntent: AppIntent {
    static var title = LocalizedStringResource("Открой машину")
    static var description = IntentDescription("Откроет машину")
    
    @Parameter(title: "Function Name")
    var functionName: String

    
    static var parameterSummary: some ParameterSummary {
        Summary("Execute")
    }
    
    func perform() async throws -> some IntentResult {
        siriPlugin.executeJSFunction(
            functionName: functionName)
        return .result()
    }
}

