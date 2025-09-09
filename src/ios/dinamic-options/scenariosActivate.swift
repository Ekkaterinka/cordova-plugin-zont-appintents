import Foundation
import AppIntents


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
        guard let intent = device else {
            return []
        }
    
        return loadDevicesControlScenarios(device: intent.device)
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

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device_id }
    
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
