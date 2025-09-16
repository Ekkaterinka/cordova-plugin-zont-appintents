import AppIntents
import SwiftUI

@available(iOS 18.0, *)
private func performDeviceRequest(device: DeviceEntity, apiUrl: String, funcParse: ([String: Any])->String, params: [String: Any]? = nil) async throws -> String {
    guard device.device_id != -1 else {
        return "Выберите устройство"
    }
    
    guard let token = UserDefaults.standard.object(forKey: "ZONT_token") as? String else {
        return "Пожалуйста авторизуйтесь в приложении ZONT"
    }
    
    //zont.microline.ru
    
    let baseUrl = "https://my.zont.online/api/widget/v3"

    guard let url = URL(string: baseUrl + apiUrl) else {
        return "Ошибка: не верный URL"
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("\(token)", forHTTPHeaderField: "X-ZONT-Token")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("app-widget-ios", forHTTPHeaderField: "X-ZONT-Client")
    
    if let params = params {
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
    }

    let (data, _) = try await URLSession.shared.data(for: request)
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return String(data: data, encoding: .utf8) ?? "Нет ответа"
    }
    print("performDeviceRequest", json)
    if json["ok"] as? Bool == true {
        return funcParse(json)
    }  else {
        if json["error_ui"] != nil {
            return "Ошибка: \(json["error_ui"] ?? ""))"
        } else if json["error"] != nil {
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
                return "Ошибка запроса: \(json["error"] ?? ""))"
            }
        } else {
            return "Устройство не на связи"
        }
    }
}


@available(iOS 18.0, *)
struct VehicleGuardActionIntentEnable: AppIntent {
    static var title: LocalizedStringResource = "Авто под охрану"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.vehicle_guard.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .vehicle_guard))
    
    var device: DeviceEntity
    
    init() {}
    
    init(device: DeviceEntity) {
        self.device = device
    }

    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let guard_zones = data_device["guard_zones"] as? [String: Any],
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

    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .vehicle_guard
        if device.device_id == -1{
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/vehicle/actions/guard",funcParse: parseResponse, params: ["enable": true])

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleGuardActionIntentDisable: AppIntent {
    static var title: LocalizedStringResource = "Авто снять с охраны"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.vehicle_guard.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .vehicle_guard))
    
    var device: DeviceEntity
    
    init() {}
    
    init(device: DeviceEntity) {
        self.device = device
    }

    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let guard_zones = data_device["guard_zones"] as? [String: Any],
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

    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .vehicle_guard
        if device.device_id == -1{
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/vehicle/actions/guard",funcParse: parseResponse, params: ["enable": false])

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleStartActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск авто"
    static var description: IntentDescription = "Активация системы автозапуска автомобиля"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.vehicle_start.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .vehicle_start))
    var device: DeviceEntity
    
    @Parameter(
        title: LocalizedStringResource("Команда"),
        description: "Выберите вариант автозапуска",
        default: CommandStartEnum.enabled
    )
    
    var commands:CommandStartEnum
    
    @Parameter(
        title: "Время автозапуска, мин",
        default: 10)
    var time_delay: Int?
    
    static var parameterSummary: some ParameterSummary {
        When(\.$commands, .equalTo, CommandStartEnum.delay, {
            Summary {
                \.$device
                \.$commands
                \.$time_delay
            }
        }, otherwise: {
            Summary {
                \.$device
                \.$commands
            }
        })
    }
    
    init() {}
    
    init(device: DeviceEntity, commands:CommandStartEnum, time_delay: Int? ) {
        self.device = device
        self.commands = commands
        if let time_delay {
            self.time_delay = time_delay
        }
    }
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let car = data_device["car_state"] as? [String: Any],
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
        DeviceQueryContext.shared.targetType = .vehicle_start
  
        if device.device_id == -1{
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        let coomandStr: [String: Any]
        
        if commands == CommandStartEnum.delay {
            coomandStr = ["command": String(describing: commands), "time": time_delay! * 60]
        } else {
            coomandStr = ["command": String(describing: commands)]
        }

        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/vehicle/actions/start", funcParse: parseResponse,params: coomandStr)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}


@available(iOS 18.0, *)
struct ControlCircuitsActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Установить температуру в контуре отопления"
    static var description: IntentDescription = "Устанавливает заданную температуру для отопительного контура. Переводит контур в ручной режим управления."
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.circuits_target_temp.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .circuits_target_temp))
    var device: DeviceEntity
    
    @Parameter(
        title: "Контур",
        description: "Выберите отопительный контур",
        default: DeviceElementControlCircuits(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderCircuits(for: .circuits_target_temp)
    )
    var heating_circuit: DeviceElementControlCircuits
    
    @Parameter(
        title: "Целевая температура"
    )
    var target_temp: Int
    
    init() {}
    
    init(device: DeviceEntity, heating_circuit: DeviceElementControlCircuits, target_temp: Int) {
        self.device = device
        self.heating_circuit = heating_circuit
        self.target_temp = target_temp
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        
        DeviceQueryContext.shared.targetType = .circuits_target_temp
        
        if device.device_id == -1 {
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        if heating_circuit.id == -1 {
            throw $heating_circuit.needsValueError("Выберите отопительный контур")
        }

        func parseResponse(_ data: [String: Any]) -> String {
            if let data_device = data["device"] as? [String: Any],
               let circuits = data_device["circuits"] as? [[String: Any]],
               let circuit = circuits.filter({ ($0["id"] as? Int) == heating_circuit.id }).first,
               let new_target_temp = circuit["target_temp"] as? Int {
                    return "Установлена целевая температура \(new_target_temp)"
            }
            return "Нет ответа"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/circuits/\(heating_circuit.id)/actions/target-temp", funcParse: parseResponse,params: ["target_temp": target_temp])

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

@available(iOS 18.0, *)
struct ControlModesActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Активация режима"
    static var description: IntentDescription = "Активирует заданный режим отопления ко всем контурам"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.modes_activate.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .modes_activate))
    var device: DeviceEntity
    
    @Parameter(
        title: "Режим отопления",
        description: "Выберите режим отопления",
        default: DeviceElementControlModes(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderModes(for: .modes_activate)
    )
    var mode: DeviceElementControlModes
    
    init() {}
    
    init(device: DeviceEntity, mode: DeviceElementControlModes) {
        self.device = device
        self.mode = mode
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .modes_activate
        if device.device_id == -1 {
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
       
        if mode.id == -1 {
            throw $mode.needsValueError("Выберите режим отопления")
        }
        
        func parseResponse(_ data: [String: Any]) -> String {
            if let data_device = data["device"] as? [String: Any],
               let modes = data_device["modes"] as? [[String: Any]],
               let modeOne = modes.filter({ ($0["id"] as? Int) == mode.id }).first,
               let current_mode = modeOne["applied"] as? [Int] {
                return "В контуре установлен режим \(mode.element_name)"
            }
            return "Нет ответа"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/modes/\(mode.id)/actions/activate", funcParse: parseResponse)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))
    }
}

@available(iOS 18.0, *)
struct ControlTriggerActionIntentComplex: AppIntent {
    static var title: LocalizedStringResource = "Активация кнопки"
    static var description: IntentDescription = "Отправляет команду активации пользовательского элемента управления"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.controls_trigger.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .controls_trigger))
    var device: DeviceEntity
    
    @Parameter(
        title: "Кнопка",
        description: "Выберите кнопку управления",
        default: DeviceElementControlTriggerComplex(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderTriggerComplex(for: .controls_trigger)
    )
    var button: DeviceElementControlTriggerComplex
    
    @Parameter(
        title: "Действие",
        description: "Выберите действие для кнопки",
        default: ComplexActionEnum.enabled)
    var action_button: ComplexActionEnum
        
    init() {}
    
    init(device: DeviceEntity, button: DeviceElementControlTriggerComplex) {
        self.device = device
        self.button = button
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .controls_trigger
        
        if device.device_id == -1 {
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        if button.id == -1 {
            throw $button.needsValueError("Выберите кнопку управления")
        }
        let paramsStr = action_button == ComplexActionEnum.enabled ? true: false
        
        func parseResponse(_ data: [String: Any]) -> String {
            return "Команда отправлена"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/controls/\(button.id)/actions/trigger", funcParse: parseResponse, params: ["target_state":paramsStr])

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}


@available(iOS 18.0, *)
struct ControlGuardActionIntentEnable: AppIntent {
    static var title: LocalizedStringResource = "Поставить на охрану"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.guard_zones_activate.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .guard_zones_activate))
    
    var device: DeviceEntity
    
    @Parameter(
        title: "Охранная зона",
        description: "Выберите охранную зону",
        default: DeviceElementControlGuard(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderGuard(for: .guard_zones_activate)
    )
    var guard_zone: DeviceElementControlGuard
    
    init() {}
    
    init(device: DeviceEntity, guard_zone: DeviceElementControlGuard) {
        self.device = device
        self.guard_zone = guard_zone
    }

    func parseResponse(_ data: [String: Any]) -> String {
        return "Команда отправлена"
    }

    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .guard_zones_activate
        
        if device.device_id == -1{
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        if guard_zone.id == -1{
            throw $guard_zone.needsValueError("Выберите охранную зону")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/guard-zones/\(guard_zone.id)/actions/activate",funcParse: parseResponse, params: ["enable": true])

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct ControlGuardActionIntentDisable: AppIntent {
    static var title: LocalizedStringResource = "Снять с охраны"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.guard_zones_activate.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .guard_zones_activate))
    
    var device: DeviceEntity
    
    @Parameter(
        title: "Охранная зона",
        description: "Выберите охранную зону",
        default: DeviceElementControlGuardDisable(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderGuardDisable(for: .guard_zones_activate)
    )
    var guard_zone: DeviceElementControlGuardDisable
    
    init() {}
    
    init(device: DeviceEntity, guard_zone: DeviceElementControlGuardDisable) {
        self.device = device
        self.guard_zone = guard_zone
    }

    func parseResponse(_ data: [String: Any]) -> String {
        return "Команда отправлена"
    }

    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .guard_zones_activate
        
        if device.device_id == -1{
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        if guard_zone.id == -1{
            throw $guard_zone.needsValueError("Выберите охранную зону")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/guard-zones/\(guard_zone.id)/actions/activate",funcParse: parseResponse, params: ["enable": false])

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct ControlScenariosActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск сценария"
    static var description: IntentDescription = "Активириует выполнение сценария на выбранном устройстве"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: TypeIntent.scenarios_activate.defaultDeviceValue(),
        optionsProvider: DeviceActionProvider(for: .scenarios_activate))
    var device: DeviceEntity
    
    @Parameter(
        title: "Сценарий",
        description: "Выберите сценарий",
        default: DeviceElementControlScenarios(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderScenarios(for: .scenarios_activate)
    )
    var scenarios: DeviceElementControlScenarios
    
    init() {}
    
    init(device: DeviceEntity, scenarios: DeviceElementControlScenarios) {
        self.device = device
        self.scenarios = scenarios
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        DeviceQueryContext.shared.targetType = .scenarios_activate
        
        if device.device_id == -1 {
            return .result(
                dialog: IntentDialog("Устройства не найдены"))
        }
        
        if scenarios.id == -1 {
            throw $scenarios.needsValueError("Выберите сценарий")
        }
        
        func parseResponse(_ data: [String: Any]) -> String {
            return "Команда отправлена"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.device_id)/scenarios/\(scenarios.id)/actions/activate", funcParse: parseResponse)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

