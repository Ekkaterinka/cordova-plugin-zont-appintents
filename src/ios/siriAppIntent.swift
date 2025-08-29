import AppIntents

@available(iOS 16.0, *)
private func performDeviceRequest(short: Short, apiUrl: String, funcParse: ([String: Any])->String, command: [String: Any]) async throws -> String {
    guard short.id != -1 else {
        return "Выберите устройство"
    }
    guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]],
          let device = items.first(where: { ($0["device_id"] as? Int) == short.id }) else {
       return  "Не найдено устройство"
    }
    
    guard let token = device["auth_token"] as? String else {
        return "Пожалуйста авторизуйтесь в приложении ZONT"
    }
    
    let baseUrl = "https://my.zont.online/api/widget/v3"

    guard let url = URL(string: baseUrl + apiUrl) else {
        return "Ошибка: не верный URL"
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("\(token)", forHTTPHeaderField: "X-ZONT-Token")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("app-widget-ios", forHTTPHeaderField: "X-ZONT-Client")
    request.httpBody = try JSONSerialization.data(withJSONObject: command, options: [])

    let (data, _) = try await URLSession.shared.data(for: request)
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return String(data: data, encoding: .utf8) ?? "Нет ответа"
    }
    print("jsonError", json)
    if json["ok"] as? Bool == true {
        return funcParse(json)
    }  else {
        if json["error"] != nil {
            switch json["error"] as? String {
            case "bad_device_response":
                return "прибор ответил ошибкой"
            case "command_failed":
                return "Команда не выполнена"
            case "command_ok_confirmation_not_received":
                return "Команда отправлена, но подтверждение не получено"
            case "device_is_offline":
                return "устройство офлайн"
            case "device_not_found":
                return "устройство не найдено"
            case "timeout":
                return "таймаут"
            case "unsupported_device_type":
                return "тип устройства не поддерживается"
            case "engine_is_already_running":
                return "двигатель уже запущен"
            default:
                return "Ошибка запроса: \(json["error_ui"] ?? ""))"
            }
        } else {
            return "Устройство не на связи"
        }
    }
}

@available(iOS 16.0, *)
struct VehicleGuardActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Управление состоянием охраны автомобиля"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        optionsProvider: VehicleGuardActionProvider())
    
    var short: Short

    func parseResponse(_ data: [String: Any]) -> String {
        if let device = data["device"] as? [String: Any],
           let guard_zones = device["guard_zones"] as? [String: Any],
           let items = guard_zones["Items"] as? [String: Any],
           let state = items["state"] as? String {
            if state == "unknown" {
                return "статус неизвестен"
            }
            if state == "disabled" {
                return " охрана снята"
            }
            if state == "enabled" {
                return "под охраной"
            }
            if state == "disabling" {
                return "в процессе снятия с охраны"
            }
            if state == "enabling" {
                return "в процессе постановки"
            }
            return state
        }
        return "Нет ответа"
    }
    
    @Parameter(title: "Команда", description: "Выберите целевое состояние охраны")
    
    var enable: EnableGuardEnum

    func perform() async throws -> some ProvidesDialog & IntentResult {
        var enableBool: Bool
        if enable == EnableGuardEnum.tab1 {
            enableBool = true
        } else {
            enableBool = false
        }
        
        let response = try await performDeviceRequest(short: short, apiUrl: "/devices/\(short.id)/vehicle/actions/guard",funcParse: parseResponse, command: ["enable": enableBool])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 16.0, *)
struct VehicleStartActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск двигателя автомобиля"
    static var description: IntentDescription = "Активация системы автозапуска транспортного средства"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        optionsProvider: VehicleStartActionProvider()
    )
    var short: Short
    
    @Parameter(
        title: "Команда", description: "Выберите вариант автозапуска"
    )
    
    var commands:CommandStartEnum
    
    @Parameter(
        title: "Время автозапуска")
    var time_delay: Int
    
    static var parameterSummary: some ParameterSummary {
        When(\.$commands, .equalTo, CommandStartEnum.delay, {
            Summary("Укажите на сколько увеличить время автозапуска \(\.$time_delay)")
        }, otherwise: {
            Summary()
        })
    }
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let device = data["device"] as? [String: Any],
           let car = device["car_state"] as? [String: Any],
           let state = car["autostart"] as? [String: Any],
           let status = state["status"] as? String {
            if status == "disabled" {
                return "неактивен"
            }
            if status == "enabling" {
                return "в процессе запуска"
            }
            if status == "enabled" {
                return "запущен"
            }
            if status == "webasto" {
                return "запускается подогреватель"
            }
            if status == "webasto-confirmed" {
                return "подогреватель запущен"
            }
            return status
        }
        return "Нет ответа"
    }

    func perform() async throws -> some ProvidesDialog & IntentResult {
        
        let response = try await performDeviceRequest(short: short, apiUrl: "/devices/\(short.id)/vehicle/actions/start", funcParse: parseResponse,command: ["command": commands])
        
        print("response11", response)

        return .result(
            dialog: .init("\(response)"))
    }
}

@available(iOS 16.0, *)
struct VehicleSirenActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Управление звуковой сигнализацией"
    static var description: IntentDescription = "Контроль состояния автомобильной сирены"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        optionsProvider: VehicleSirenActionProvider()
    )
    var short: Short
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let device = data["device"] as? [String: Any],
           let car_state = device["car_state"] as? [String: Any],
           let siren = car_state["siren"] as? Bool {
            if siren == true {
                return "Сирена включена"
            } else  {
                return "Сирена выключена"
            }
        }
        return "Нет ответа"
    }
    
    @Parameter(title: "Команда", description: "Выберите целевое состояние сирены")
    
    var enable: EnableGuardEnum

    func perform() async throws -> some ProvidesDialog & IntentResult {
        var enableBool: Bool
        if enable == EnableGuardEnum.tab1 {
            enableBool = true
        } else {
            enableBool = false
        }
        
        let response = try await performDeviceRequest(short: short, apiUrl: "/devices/\(short.id)/vehicle/actions/siren", funcParse: parseResponse, command: ["enable":enableBool])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 16.0, *)
struct VehicleBlockActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Блокировка двигателя"
    static var description: IntentDescription = "Активация/деактивация блокировки транспортного средства"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        optionsProvider: VehicleBlockActionProvider()
    )
    var short: Short
    func parseResponse(_ data: [String: Any]) -> String {
        if let device = data["device"] as? [String: Any],
           let car_state = device["car_state"] as? [String: Any],
           let engine_block = car_state["engine_block"] as? Bool {
            if engine_block == true {
                return "Блокировка двигателя включена"
            } else  {
                return "Блокировка двигателя выключена"
            }
        }
        return "Нет ответа"
    }
    
    @Parameter(title: "Команда", description: "Выберите целевое состояние блокировки двигателя")
    
    var enable: EnableGuardEnum

    func perform() async throws -> some ProvidesDialog & IntentResult {
        var enableBool: Bool
        if enable == EnableGuardEnum.tab1 {
            enableBool = true
        } else {
            enableBool = false
        }
        
        let response = try await performDeviceRequest(short: short, apiUrl: "/devices/\(short.id)/vehicle/actions/block", funcParse: parseResponse, command: ["enable": enableBool])
        
        print("response11", response)

        return .result(
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