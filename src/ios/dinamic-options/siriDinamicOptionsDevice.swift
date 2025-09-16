import Foundation
import AppIntents

enum TypeIntent: String {
    case circuits_target_temp = "circuits_target_temp"
    case modes_activate = "modes_activate"
    case controls_trigger = "controls_trigger"
    case guard_zones_activate = "guard_zones_activate"
    case scenarios_activate = "scenarios_activate"
    case vehicle_guard = "vehicle_guard"
    case vehicle_start = "vehicle_start"
    case vehicle_siren = "vehicle_siren"
    case vehicle_block = "vehicle_block"
}

@available(iOS 18.0, *)
class DeviceQueryContext {
    static let shared = DeviceQueryContext()
    var targetType: TypeIntent?
}

@available(iOS 18.0, *)
struct DeviceEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Device Entity"))
    
    var id: String
    
    var device_id: Int
    
    var device_name: String
    
    var target_type: TypeIntent.RawValue?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title:"\(device_name)")}
    
    init(device_id: Int, device_name: String, target_type: TypeIntent.RawValue?) {
        self.device_id = device_id
        self.device_name = device_name
        self.target_type = target_type
        self.id = "\(device_id)_\(target_type ?? "nil"))"
    }
    
    static let defaultQuery = DeviceQuery()

}

@available(iOS 18.0, *)
struct DeviceQuery: EntityQuery {
    
    func entities(for identifiers: [DeviceEntity.ID]) async throws -> [DeviceEntity] {
        let target_type = DeviceQueryContext().targetType
        return loadDevices(type: target_type?.rawValue).filter { identifiers.contains($0.id) }
    }
    func suggestedEntities() async throws -> [DeviceEntity] {
        let target_type = DeviceQueryContext().targetType
        return loadDevices(type: target_type?.rawValue)
    }
    func defaultResult() async -> DeviceEntity? {
        try? await suggestedEntities().first
    }
}

@available(iOS 18.0, *)
struct DeviceActionProvider: DynamicOptionsProvider {
    let targetType: TypeIntent
    init(for targetType: TypeIntent) {
        self.targetType = targetType
    }
    
    func results() async throws -> [DeviceEntity] {
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["type"] as? String) == targetType.rawValue }
        
        return filtered.compactMap { item -> DeviceEntity? in
            guard let device_id = item["device_id"] as? Int,
                  let device_name = item["device_name"] as? String else { return nil }

            return DeviceEntity(
                device_id: device_id,
                device_name: device_name,
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
        .disabled: DisplayRepresentation("деактивировать"),
        .enabled: DisplayRepresentation("запустить стандартную процедуру автозапуска (подогрев, затем пуск двигателя)"),
        .engine: DisplayRepresentation("запустить только двигатель"),
        .webasto: DisplayRepresentation("запустить только подогреватель"),
        .delay: DisplayRepresentation("увеличить время автозапуска"),
        ]
}


@available(iOS 18.0, *)
private func loadDevices(type: TypeIntent.RawValue? = nil) -> [DeviceEntity] {
    guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
        return []
    }
    let filtered = type == nil ? items : items.filter{ ($0["type"] as? String) == type}
    
    return filtered.compactMap { item in
        guard let device_id = item["device_id"] as? Int,
              let device_name = item["device_name"] as? String,
              let target_type = item["type"] as? String else { return nil }
        return DeviceEntity(device_id: device_id, device_name: device_name, target_type: target_type)
    }
}

@available(iOS 18.0, *)
extension TypeIntent {
    func defaultDeviceValue() -> DeviceEntity? {
      
        guard let devices = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return DeviceEntity(device_id: -1, device_name: "Устройства не найдены",  target_type: nil)
        }
        
        let filtered = devices.filter { ($0["type"] as? String) == self.rawValue }
        guard let first_device = filtered.first,
              let device_name = first_device["device_name"] as? String,
              let device_id = first_device["device_id"] as? Int else {
            return DeviceEntity(device_id: -1, device_name: "Устройства не найдены", target_type: nil)
        }
        
        return DeviceEntity(device_id: device_id , device_name: device_name, target_type: self.rawValue)
    }
}
