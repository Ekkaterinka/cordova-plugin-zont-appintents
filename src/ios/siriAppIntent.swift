import AppIntents

struct DeviceActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Управление устройством"

    @Parameter(
        title: "Устройство",
        optionsProvider: DeviceOptionsProvider()
    )
    var deviceId: Int

    func perform() async throws -> some IntentResult {
        guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]],
              let device = items.first(where: { ($0["device_id"] as? Int) == deviceId }),
              let apiUrl = device["api_url"] as? String,
              let path = apiUrl.replacingOccurrences(of: "{deviceId}", with: device)
              let url = URL(string: path) else {
            return .result(value: "Ошибка: не найдено устройство или api_url")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseText = String(data: data, encoding: .utf8) ?? "Нет ответа"

        return .result(value: "Ответ API: \(responseText)")
    }
}