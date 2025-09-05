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