import Foundation
import AppIntents


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