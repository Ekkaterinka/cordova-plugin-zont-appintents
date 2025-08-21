import AppIntents


struct DeviceActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск двигателя автомобиля"

    @Parameter(
        title: "Выберите устройство",
        optionsProvider: DeviceOptionsProvider()
    )
    var short: Short

    func perform() async throws -> some IntentResult {
        guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]],
              let device = items.first(where: { ($0["device_id"] as? Int) == short.id }),
              let apiUrl = device["api_url"] as? String,
              let valueId = device["device_id"] as? Int else {
            return .result(value: "Ошибка: не найдено устройство или api_url")
        }

        let path = apiUrl.replacingOccurrences(of: "{deviceId}", with: "\(valueId)")
        guard let url = URL(string: path) else {
            return .result(value: "Ошибка: не верный URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseText = String(data: data, encoding: .utf8) ?? "Нет ответа"

        return .result(value: "Ответ API: \(responseText)")
    }
}