import AppIntents

@available(iOS 16.0, *)
private func performDeviceRequest(short: Short, apiUrl: String) async throws -> String {
    guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]],
          let device = items.first(where: { ($0["device_id"] as? Int) == short.id }) else {
       return  "Не найдено устройство"
    }
    
    guard let token = device["auth_token"] as? String else {
        return "Пожалуйста авторизуйтесь в приложении ZONT"
    }

    guard let url = URL(string: apiUrl) else {
        return "Ошибка: не верный URL"
    }

    var request = URLRequest(url: url)
    let head = "X-ZONT-Token"
    request.httpMethod = "POST"
    request.setValue("https", forHTTPHeaderField: "scheme")
    request.setValue("my.zont.online/api", forHTTPHeaderField: "host")
    request.addValue("\(token)", forHTTPHeaderField: "\(head)")
    print("request", request)

    let (data, _) = try await URLSession.shared.data(for: request)
    return String(data: data, encoding: .utf8) ?? "Нет ответа"
}

@available(iOS 16.0, *)
struct DeviceActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск двигателя автомобиля"
    
    @Parameter(
        title: "Выберите устройство",
        optionsProvider: DeviceOptionsProvider()
    )
    var short: Short

    func perform() async throws -> some ProvidesDialog & IntentResult {
        
        let response = try await performDeviceRequest(short: short, apiUrl: "/devices/\(short.id)/vehicle/actions/start")
        
        print("response", response)

        return .result(
            value: response,
            dialog: .init("\(response)"))
    }
}

@available(iOS 16.0, *)
struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open"
    
    static var openAppWhenRun: Bool = true


    func perform() async throws -> some IntentResult {
        return .result()
    }
}