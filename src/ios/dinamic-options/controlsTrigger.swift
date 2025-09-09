import Foundation
import AppIntents


@available(iOS 18.0, *)
enum ComplexActionEnum: String, AppEnum {
    
    case enabled = "Включить"
    case disabled = "Выключить"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Complex Action")
   
    static var caseDisplayRepresentations: [ComplexActionEnum: DisplayRepresentation] = [
        .enabled: "Включить",
        .disabled: "Выключить (только для сложных кнопок)",
        ]
}

@available(iOS 18.0, *)
struct DeviceElementControlTriggerComplex: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Element Control"))
    static let defaultQuery = DeviceElementControlQueryTriggerComplex()
    var id: Int
    
    var element_name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(element_name)")}
    
    init(element_name: String,id: Int) {
        self.id = id
        self.element_name = element_name
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
        guard let intent = device else {
            return []
        }
    
        return loadDevicesControlTriggerComplex(device: intent.device)
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

    let filtered1:[[String: Any]] = items.filter { ($0["device_id"] as? Int) == device.device_id }
    
    guard let filtered2:[String: Any] = filtered1.filter({ ($0["type"] as? String) == device.target_type }).first,
          let entity_ids = (filtered2["entity_ids"] as? [[String: Any]]) else {
        return []
    }
    
    return entity_ids.compactMap { item -> DeviceElementControlTriggerComplex? in
        guard let id = item["entity_id"] as? Int,
              let element_name = item["entity_name"] as? String else { return nil }

        return DeviceElementControlTriggerComplex(
            element_name: element_name,
            id: id
        )
    }
}
