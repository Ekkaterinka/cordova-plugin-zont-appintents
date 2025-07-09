import AppIntents

struct SiriAppIntent: AppIntent {
    static var title= LocalizedStringResource("Открой машину")
    static var description = IntentDescription("Откроет машину")
    
    @Parameter(title: "Function Name")
    var functionName: String
    
    @Parameter(title: "Parameters", default: [:])
    var parameters: [String: String]
    
    static var parameterSummary: some ParameterSummary {
        Summary("Execute \(\.$functionName) with parameters \(\.$parameters)")
    }
    
    func perform() async throws -> some IntentResult {
        SiriPlugin.executeJSFunction(
            functionName: functionName,
            parameters: parameters
        )
        return .result()
    }
}

