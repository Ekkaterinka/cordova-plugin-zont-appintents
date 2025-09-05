import Foundation
import AppIntents


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