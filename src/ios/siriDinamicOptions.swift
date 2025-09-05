import Foundation
import AppIntents

enum TypeIntent: String {
    case circuits_target_temp = "circuits_target_temp"
    case modes_activate = "modes_activate"
    case controls_trigger = "controls_trigger"
    case quard_zones_activate = "quard_zones_activate"
    case scenarios_activate = "scenarios_activate"
    case vehicle_guard = "vehicle_guard"
    case vehicle_start = "vehicle_start"
    case vehicle_siren = "vehicle_siren"
    case vehicle_block = "vehicle_block"
}

@available(iOS 18.0, *)
struct DeviceEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Entity"))
    static let defaultQuery = DeviceQuery()
    
    var id: Int

    @Property(title: "Choose")
    
    var device_name: String
    
    var target_type: TypeIntent.RawValue?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(device_name)")}
    
    init(device_name: String,id: Int, target_type: TypeIntent.RawValue?) {
        self.id = id
        self.device_name = device_name
        if let target_type {
            self.target_type = target_type
        }
    }
}

@available(iOS 18.0, *)
struct DeviceQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [DeviceEntity] {
        loadDevices().filter { identifiers.contains($0.id) }
    }
    func suggestedEntities() async throws -> [DeviceEntity] {
        loadDevices()
    }
    func defaultResult() async -> DeviceEntity? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceActionProvider: DynamicOptionsProvider {
    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceEntity] {
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["type"] as? String) == targetType.rawValue }
        
        return filtered.compactMap { item -> DeviceEntity? in
            guard let id = item["device_id"] as? Int,
                  let device_name = item["device_name"] as? String else { return nil }

            return DeviceEntity(
                device_name: device_name,
                id: id,
                target_type: targetType.rawValue
            )
        }
    }
}

@available(iOS 18.0, *)
enum CommandStartEnum: String, AppEnum {
    case disabled = "деактивировать"
    case enabled = "запустить стандартную процедуру автозапуска (подогрев, затем пуск двигателя)"
    case engine = "запустить только двигатель"
    case webasto = "запустить только подогреватель"
    case delay = "увеличить время автозапуска"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Command Start")
   
    static var caseDisplayRepresentations: [CommandStartEnum: DisplayRepresentation] = [
        .disabled: "деактивировать",
        .enabled: "запустить стандартную процедуру автозапуска (подогрев, затем пуск двигателя)",
        .engine: "запустить только двигатель",
        .webasto: "запустить только подогреватель",
        .delay: "увеличить время автозапуска",
        ]
}

@available(iOS 18.0, *)
enum ComplexActionEnum: String, AppEnum {
    case enabled = "Включить"
    case disabled = "Выключить"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Complex Action")
   
    static var caseDisplayRepresentations: [ComplexActionEnum: DisplayRepresentation] = [
        .enabled: "Включить",
        .disabled: "Выключить",
        ]
}

@available(iOS 18.0, *)
private func loadDevices() -> [DeviceEntity] {
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }
    return items.compactMap { item in
        guard let id = item["device_id"] as? Int,
              let device_name = item["device_name"] as? String,
              let target_type = item["type"] as? String else { return nil }
        return DeviceEntity(device_name: device_name, id: id, target_type: target_type)
    }
}

@available(iOS 18.0, *)
func getDefaultValue(targetType: TypeIntent) -> DeviceEntity? {
  
    guard let devices = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return DeviceEntity(device_name: "Устройства не найдены", id: -1, target_type: nil)
    }
    
    let filtered = devices.filter { ($0["type"] as? String) == targetType.rawValue }
    guard let first_device = filtered.first,
          let device_name = first_device["device_name"] as? String,
          let id = first_device["device_id"] as? Int else {
        return DeviceEntity(device_name: "Устройства не найдены", id: -1, target_type: nil)
    }
    
    return DeviceEntity(device_name: device_name, id: id , target_type: targetType.rawValue)
}


@available(iOS 18.0, *)
struct DeviceElementControlCircuits: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryCircuits()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int) {
        self.id = id
        self.element_name = element_name
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryCircuits: EntityQuery {
    @IntentParameterDependency<ControlCircuitsActionIntent>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlCircuits] {
        loadDevicesControlCircuits(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlCircuits] {
        loadDevicesControlCircuits(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlCircuits? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderCircuits: DynamicOptionsProvider {
    @IntentParameterDependency<ControlCircuitsActionIntent>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlCircuits] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlCircuits? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String else { return nil }

            return DeviceElementControlCircuits(
                element_name: element_name,
                id: id
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlCircuits(device: DeviceEntity?) -> [DeviceElementControlCircuits] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlCircuits? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String else { return nil }

        return DeviceElementControlCircuits(
            element_name: element_name,
            id: id
        )
    }
}


@available(iOS 18.0, *)
struct DeviceElementControlModes: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryModes()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int) {
        self.id = id
        self.element_name = element_name
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryModes: EntityQuery {
    @IntentParameterDependency<ControlModesActionIntent>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlModes] {
        loadDevicesControlModes(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlModes] {
        loadDevicesControlModes(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlModes? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderModes: DynamicOptionsProvider {
    @IntentParameterDependency<ControlModesActionIntent>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlModes] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlModes? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String else { return nil }

            return DeviceElementControlModes(
                element_name: element_name,
                id: id
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlModes(device: DeviceEntity?) -> [DeviceElementControlModes] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlModes? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String else { return nil }

        return DeviceElementControlModes(
            element_name: element_name,
            id: id
        )
    }
}


@available(iOS 18.0, *)
struct DeviceElementControlTriggerSimple: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryTriggerSimple()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    var entity_type: String?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int, entity_type: String?) {
        self.id = id
        self.element_name = element_name
        if let entity_type {
            self.entity_type = entity_type
        }
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryTriggerSimple: EntityQuery {
    @IntentParameterDependency<ControlTriggerActionIntentSimple>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlTriggerSimple] {
        loadDevicesControlTriggerSimple(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlTriggerSimple] {
        loadDevicesControlTriggerSimple(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlTriggerSimple? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderTriggerSimple: DynamicOptionsProvider {
    @IntentParameterDependency<ControlTriggerActionIntentSimple>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlTriggerSimple] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlTriggerSimple? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String,
                  let entity_type = item["entity_type"] as? String else { return nil }

            return DeviceElementControlTriggerSimple(
                element_name: element_name,
                id: id,
                entity_type: entity_type
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlTriggerSimple(device: DeviceEntity?) -> [DeviceElementControlTriggerSimple] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = (filtered2["entity_ids"] as? [[String: Any]])?.filter({ ($0["entity_type"] as? String) == "simple" }) else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlTriggerSimple? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String,
              let entity_type = item["entity_type"] as? String else { return nil }

        return DeviceElementControlTriggerSimple(
            element_name: element_name,
            id: id,
            entity_type: entity_type
        )
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlTriggerComplex: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryTriggerComplex()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    var entity_type: String?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int, entity_type: String?) {
        self.id = id
        self.element_name = element_name
        if let entity_type {
            self.entity_type = entity_type
        }
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryTriggerComplex: EntityQuery {
    @IntentParameterDependency<ControlTriggerActionIntentComplex>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlTriggerComplex] {
        loadDevicesControlTriggerComplex(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlTriggerComplex] {
        loadDevicesControlTriggerComplex(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlTriggerComplex? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderTriggerComplex: DynamicOptionsProvider {
    @IntentParameterDependency<ControlTriggerActionIntentComplex>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlTriggerComplex] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlTriggerComplex? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String,
                  let entity_type = item["entity_type"] as? String else { return nil }

            return DeviceElementControlTriggerComplex(
                element_name: element_name,
                id: id,
                entity_type: entity_type
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlTriggerComplex(device: DeviceEntity?) -> [DeviceElementControlTriggerComplex] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = (filtered2["entity_ids"] as? [[String: Any]])?.filter({ ($0["entity_type"] as? String) == "complex" }) else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlTriggerComplex? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String,
              let entity_type = item["entity_type"] as? String else { return nil }

        return DeviceElementControlTriggerComplex(
            element_name: element_name,
            id: id,
            entity_type: entity_type
        )
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlGuard: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryGuard()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int) {
        self.id = id
        self.element_name = element_name
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryGuard: EntityQuery {
    @IntentParameterDependency<ControlGuardActionIntentEnable>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlGuard] {
        loadDevicesControlGuard(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlGuard] {
        loadDevicesControlGuard(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlGuard? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderGuard: DynamicOptionsProvider {
    @IntentParameterDependency<ControlGuardActionIntentEnable>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlGuard] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlGuard? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String else { return nil }

            return DeviceElementControlGuard(
                element_name: element_name,
                id: id
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlGuard(device: DeviceEntity?) -> [DeviceElementControlGuard] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlGuard? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String else { return nil }

        return DeviceElementControlGuard(
            element_name: element_name,
            id: id
        )
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlGuardDisable: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryGuardDisable()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int) {
        self.id = id
        self.element_name = element_name
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryGuardDisable: EntityQuery {
    @IntentParameterDependency<ControlGuardActionIntentDisable>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlGuardDisable] {
        loadDevicesControlGuardDisable(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlGuardDisable] {
        loadDevicesControlGuardDisable(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlGuardDisable? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderGuardDisable: DynamicOptionsProvider {
    @IntentParameterDependency<ControlGuardActionIntentDisable>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlGuardDisable] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlGuardDisable? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String else { return nil }

            return DeviceElementControlGuardDisable(
                element_name: element_name,
                id: id
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlGuardDisable(device: DeviceEntity?) -> [DeviceElementControlGuardDisable] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlGuardDisable? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String else { return nil }

        return DeviceElementControlGuardDisable(
            element_name: element_name,
            id: id
        )
    }
}


@available(iOS 18.0, *)
struct DeviceElementControlScenarios: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryScenarios()
    var id: Int

    @Property(title: "Choose")
    
    var element_name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int) {
        self.id = id
        self.element_name = element_name
    }
}

@available(iOS 18.0, *)
struct DeviceElementControlQueryScenarios: EntityQuery {
    @IntentParameterDependency<ControlScenariosActionIntent>(\.$device)
    var device

    func entities(for identifiers: [Int]) async throws -> [DeviceElementControlScenarios] {
        loadDevicesControlScenarios(device: device?.device).filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [DeviceElementControlScenarios] {
        loadDevicesControlScenarios(device: device?.device)
    }
    func defaultResult() async -> DeviceElementControlScenarios? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceElementActionProviderScenarios: DynamicOptionsProvider {
    @IntentParameterDependency<ControlScenariosActionIntent>(\.$device)
    var device

    let targetType: TypeIntent
    init(for type: TypeIntent) {
        self.targetType = type
    }
    
    func results() async throws -> [DeviceElementControlScenarios] {
        guard let device else {
            return []
        }
    
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device.id }
        
        guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == targetType.rawValue }).first,
              let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
            return []
        }
        
        return entity_ids.compactMap { item -> DeviceElementControlScenarios? in
            guard let id = item["entity_id"] as? Int,
                  let element_name = item["entity_name"] as? String else { return nil }

            return DeviceElementControlScenarios(
                element_name: element_name,
                id: id
            )
        }
    }
}

@available(iOS 18.0, *)
private func loadDevicesControlScenarios(device: DeviceEntity?) -> [DeviceElementControlScenarios] {
    guard let device else {
        return []
    }
    
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = filtered2["entity_ids"] as? [[String: Any]] else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlScenarios? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String else { return nil }

        return DeviceElementControlScenarios(
            element_name: element_name,
            id: id
        )
    }
}


