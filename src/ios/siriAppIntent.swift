import AppIntents
import SwiftUI

@available(iOS 18.0, *)
struct VehicleGuardActionIntentEnable: AppIntent {
    static var title: LocalizedStringResource = "Поставить на охрану автомобиль"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_guard),
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
        if device.id == -1{
            device = try await $device.requestValue("Выберите устройство")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/guard",funcParse: parseResponse, params: ["enable": true])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleGuardActionIntentDisable: AppIntent {
    static var title: LocalizedStringResource = "Снять с охраны автомобиль"
    static var description: IntentDescription = "Изменяет состояние охраны"

    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_guard),
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
        if device.id == -1{
            device = try await $device.requestValue("Выберите устройство")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/guard",funcParse: parseResponse, params: ["enable": false])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleStartActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск двигателя автомобиля"
    static var description: IntentDescription = "Активация системы автозапуска автомобиля"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_start),
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
  
        if device.id == -1{
            device = try await $device.requestValue("Выберите устройство")
        }
        
        let coomandStr: [String: Any]
        
        if commands == CommandStartEnum.delay {
            coomandStr = ["command": String(describing: commands), "time": time_delay! * 60]
        } else {
            coomandStr = ["command": String(describing: commands)]
        }

        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/start", funcParse: parseResponse,params: coomandStr)
        
        print("response11", response)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

@available(iOS 18.0, *)
struct VehicleSirenActionIntentEnable: AppIntent {
    static var title: LocalizedStringResource = "Включить сирену"
    static var description: IntentDescription = "Контроль состояния автомобильной сирены"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_siren),
        optionsProvider: DeviceActionProvider(for: .vehicle_siren))
    var device: DeviceEntity
    
    init() {}
    
    init(device: DeviceEntity) {
        self.device = device
    }
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let car_state = data_device["car_state"] as? [String: Any],
           let siren = car_state["siren"] as? Bool {
            if siren == true {
                return "Сирена включена"
            } else  {
                return "Сирена выключена"
            }
        }
        return "Нет ответа"
    }

    func perform() async throws -> some ProvidesDialog & IntentResult {
        if device.id == -1{
            device = try await $device.requestValue("Выберите устройство")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/siren", funcParse: parseResponse, params: ["enable": true])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleSirenActionIntentOff: AppIntent {
    static var title: LocalizedStringResource = "Выключить сирену"
    static var description: IntentDescription = "Контроль состояния автомобильной сирены"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_siren),
        optionsProvider: DeviceActionProvider(for: .vehicle_siren))
    var device: DeviceEntity
    
    init() {}
    
    init(device: DeviceEntity) {
        self.device = device
    }
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let car_state = data_device["car_state"] as? [String: Any],
           let siren = car_state["siren"] as? Bool {
            if siren == true {
                return "Сирена включена"
            } else  {
                return "Сирена выключена"
            }
        }
        return "Нет ответа"
    }

    func perform() async throws -> some ProvidesDialog & IntentResult {
        if device.id == -1 {
            device = try await $device.requestValue("Выберите устройство")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/siren", funcParse: parseResponse, params: ["enable": false])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleBlockActionIntentActive: AppIntent {
    static var title: LocalizedStringResource = "Включить блокировку двигателя"
    static var description: IntentDescription = "Активация блокировки транспортного средства"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_block),
        optionsProvider: DeviceActionProvider(for: .vehicle_block))
    
    var device: DeviceEntity
    
    init() {}
    
    init(device: DeviceEntity) {
        self.device = device
    }
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let car_state = data_device["car_state"] as? [String: Any],
           let engine_block = car_state["engine_block"] as? Bool {
            if engine_block == true {
                return "Блокировка двигателя включена"
            } else  {
                return "Блокировка двигателя выключена"
            }
        }
        return "Нет ответа"
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/block", funcParse: parseResponse, params: ["enable": true])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct VehicleBlockActionIntentOff: AppIntent {
    static var title: LocalizedStringResource = "Выключить блокировку двигателя"
    static var description: IntentDescription = "Деактивация блокировки транспортного средства"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .vehicle_block),
        optionsProvider: DeviceActionProvider(for: .vehicle_block))
    
    var device: DeviceEntity
    
    init() {}
    
    init(device: DeviceEntity) {
        self.device = device
    }
    
    func parseResponse(_ data: [String: Any]) -> String {
        if let data_device = data["device"] as? [String: Any],
           let car_state = data_device["car_state"] as? [String: Any],
           let engine_block = car_state["engine_block"] as? Bool {
            if engine_block == true {
                return "Блокировка двигателя включена"
            } else  {
                return "Блокировка двигателя выключена"
            }
        }
        return "Нет ответа"
    }

    func perform() async throws -> some ProvidesDialog & IntentResult {
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/vehicle/actions/block", funcParse: parseResponse, params: ["enable": false])
        
        print("response11", response)

        return .result(
            dialog: .init("\(response)"))
    }
}


@available(iOS 18.0, *)
struct ControlCircuitsActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Установить температуру в контуре отопления"
    static var description: IntentDescription = "Устанавливает заданную температуру для отопительного контура. Переводит контур в ручной режим управления."
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .circuits_target_temp),
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
        print("dvvv1", device)
        if device.id == -1 {
            print("dvvv")
            device = try await $device.requestValue("Выберите устройство")
        }
        
        if heating_circuit.id == -1 {
            heating_circuit = try await $heating_circuit.requestValue("Выберите отопительный контур")
        }
        
        func parseResponse(_ data: [String: Any]) -> String {
            if let data_device = data["device"] as? [String: Any],
               let circuits = data_device["circuits"] as? [String: Any],
               let new_target_temp = circuits["target_temp"] as? Int {
                    return "Установлена целевая температура \(new_target_temp)"
            }
            return "Нет ответа"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/circuits/\(heating_circuit.id)/actions/target-temp", funcParse: parseResponse,params: ["target_temp": target_temp])
        
        print("response11", response)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

@available(iOS 18.0, *)
struct ControlModesActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Активация режима отопления"
    static var description: IntentDescription = "Активирует заданный режим отопления ко всем контурам"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .modes_activate),
        optionsProvider: DeviceActionProvider(for: .modes_activate))
    var device: DeviceEntity
    
    @Parameter(
        title: "Режим отопления",
        description: "Выберите режим отопления",
        default: DeviceElementControlModes(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderModes(for: .modes_activate)
    )
    var modes: DeviceElementControlModes
    
    init() {}
    
    init(device: DeviceEntity, modes: DeviceElementControlModes) {
        self.device = device
        self.modes = modes
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        if device.id == -1 {
            device = try await $device.requestValue("Выберите устройство")
        }
        if modes.id == -1 {
            modes = try await $modes.requestValue("Выберите режим отопления")
        }
        print("modes", modes)
        
        func parseResponse(_ data: [String: Any]) -> String {
            if let data_device = data["device"] as? [String: Any],
               let modes = data_device["modes"] as? [String: Any],
               let current_mode = modes["current_mode"] as? Int {
                    return "В контуре установлен режим \(current_mode)"
            }
            return "Нет ответа"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/modes/\(modes.id)/actions/activate", funcParse: parseResponse)
        
        print("response11", response)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

@available(iOS 18.0, *)
struct ControlTriggerActionIntentSimple: AppIntent {
    static var title: LocalizedStringResource = "Активация простой кнопки"
    static var description: IntentDescription = "Отправляет команду активации пользовательского элемента управления"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .controls_trigger),
        optionsProvider: DeviceActionProvider(for: .controls_trigger))
    var device: DeviceEntity
    
    @Parameter(
        title: "Кнопка",
        description: "Выберите кнопку управления",
        default: DeviceElementControlTriggerSimple(element_name: "Выбор", id: -1, entity_type: nil),
        optionsProvider: DeviceElementActionProviderTriggerSimple(for: .controls_trigger)
    )
    var button: DeviceElementControlTriggerSimple
    
    init() {}
    
    init(device: DeviceEntity, button: DeviceElementControlTriggerSimple) {
        self.device = device
        self.button = button
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        if device.id == -1 {
            device = try await $device.requestValue("Выберите устройство")
        }
        
        if button.id == -1 {
            button = try await $button.requestValue("Выберите кнопку управления")
        }
        
        func parseResponse(_ data: [String: Any]) -> String {
            return "Команда отправлена"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/controls/\(button.id)/actions/trigger", funcParse: parseResponse)
        
        print("response11", response)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

@available(iOS 18.0, *)
struct ControlTriggerActionIntentComplex: AppIntent {
    static var title: LocalizedStringResource = "Активация сложной кнопки"
    static var description: IntentDescription = "Отправляет команду активации пользовательского элемента управления"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .controls_trigger),
        optionsProvider: DeviceActionProvider(for: .controls_trigger))
    var device: DeviceEntity
    
    @Parameter(
        title: "Кнопка",
        description: "Выберите кнопку управления",
        default: DeviceElementControlTriggerComplex(element_name: "Выбор", id: -1, entity_type: nil),
        optionsProvider: DeviceElementActionProviderTriggerComplex(for: .controls_trigger)
    )
    var button: DeviceElementControlTriggerComplex
    
    @Parameter(
        title: "Действие",
        description: "Выберите действие для кнопки")
    var action_button: ComplexActionEnum
        
    
    init() {}
    
    init(device: DeviceEntity, button: DeviceElementControlTriggerComplex) {
        self.device = device
        self.button = button
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        if device.id == -1 {
            device = try await $device.requestValue("Выберите устройство")
        }
        
        if button.id == -1 {
            button = try await $button.requestValue("Выберите кнопку управления")
        }
        let paramsStr = action_button == ComplexActionEnum.enabled ? true: false
        
        func parseResponse(_ data: [String: Any]) -> String {
            return "Команда отправлена"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/controls/\(button.id)/actions/trigger", funcParse: parseResponse, params: ["target_state":paramsStr])
        
        print("response11", response)

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
        default: getDefaultValue(targetType: .quard_zones_activate),
        optionsProvider: DeviceActionProvider(for: .quard_zones_activate))
    
    var device: DeviceEntity
    
    @Parameter(
        title: "Охранная зона",
        description: "Выберите охранную зону",
        default: DeviceElementControlGuard(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderGuard(for: .controls_trigger)
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
        if device.id == -1{
            device = try await $device.requestValue("Выберите устройство")
        }
        
        if guard_zone.id == -1{
            device = try await $device.requestValue("Выберите охранную зону")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/guard-zones/\(guard_zone.id)/actions/activate",funcParse: parseResponse, params: ["enable": true])
        
        print("response11", response)

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
        default: getDefaultValue(targetType: .quard_zones_activate),
        optionsProvider: DeviceActionProvider(for: .quard_zones_activate))
    
    var device: DeviceEntity
    
    @Parameter(
        title: "Охранная зона",
        description: "Выберите охранную зону",
        default: DeviceElementControlGuardDisable(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderGuardDisable(for: .controls_trigger)
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
        if device.id == -1{
            device = try await $device.requestValue("Выберите устройство")
        }
        
        if guard_zone.id == -1{
            device = try await $device.requestValue("Выберите охранную зону")
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/guard-zones/\(guard_zone.id)/actions/activate",funcParse: parseResponse, params: ["enable": false])
        
        print("response11", response)

        return .result(
            dialog: IntentDialog("\(response)"))
    }
}

@available(iOS 18.0, *)
struct ControlScenariosActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Запуск предустановленного сценария"
    static var description: IntentDescription = "Активириует выполнение сценария на выбранном устройстве"
    
    @Parameter(
        title: "Устройство",
        description: "Выберите устройство для управления",
        default: getDefaultValue(targetType: .scenarios_activate),
        optionsProvider: DeviceActionProvider(for: .scenarios_activate))
    var device: DeviceEntity
    
    @Parameter(
        title: "Сценарий",
        description: "Выберите сценарий",
        default: DeviceElementControlScenarios(element_name: "Выбор", id: -1),
        optionsProvider: DeviceElementActionProviderScenarios(for: .controls_trigger)
    )
    var scenarios: DeviceElementControlScenarios
    
    init() {}
    
    init(device: DeviceEntity, scenarios: DeviceElementControlScenarios) {
        self.device = device
        self.scenarios = scenarios
    }
    
    func perform() async throws -> some ProvidesDialog & IntentResult {
        if device.id == -1 {
            device = try await $device.requestValue("Выберите устройство")
        }
        
        if scenarios.id == -1 {
            scenarios = try await $scenarios.requestValue("Выберите сценарий")
        }
        
        func parseResponse(_ data: [String: Any]) -> String {
            return "Команда отправлена"
        }
        
        let response = try await performDeviceRequest(device: device, apiUrl: "/devices/\(device.id)/scenarios/\(scenarios.id)/actions/activate", funcParse: parseResponse)
        
        print("response11", response)

        return .result(
            dialog: .init("\(device.device_name) + \(response)"))

    }
}

