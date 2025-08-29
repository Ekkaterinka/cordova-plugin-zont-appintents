import Foundation
import AppIntents

enum TypeIntent {
    case circuits_target_temp
    case modes_activate
    case controls_trigger
    case controls_set_voltage
    case quard_zones_activate
    case scenarios_activate
    case vehicle_guard
    case vehicle_start
    case vehicle_siren
    case vehicle_block
}

@available(iOS 16.0, *)
struct Short: AppEntity {
    typealias DefaultQuery = DeviceQuery

    static var defaultQuery = DefaultQuery()

    static var typeDisplayName: LocalizedStringResource = "Выбор"
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Выбор")
    static var placeholder = LocalizedStringResource("Выберите")


    var device_name: String
    var id: Int

    var displayRepresentation: DisplayRepresentation {
        .init(title: .init(stringLiteral:device_name))}

}

@available(iOS 16.0, *)
struct DeviceQuery: EntityQuery {

    func entities(for identifiers: [Short.ID]) async throws -> [Short] {
        loadDevices().filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [Short] {
        loadDevices()
    }
}

@available(iOS 16.0, *)
struct VehicleGuardActionProvider: DynamicOptionsProvider {
    func results() async throws -> [Short] {
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["type"] as? TypeIntent) == TypeIntent.vehicle_guard }
        
        return filtered.compactMap { item -> Short? in
            guard let id = item["device_id"] as? Int,
                  let device_name = item["device_name"] as? String else { return nil }

            return Short(
                device_name: device_name,
                id: id
            )
        }
    }
}

@available(iOS 16.0, *)
enum EnableGuardEnum: String, AppEnum {
    case tab1 = "Активировать охрану"
    case tab2 = "Деактивировать охрану"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Enable Guard")
   
    static var caseDisplayRepresentations: [EnableGuardEnum: DisplayRepresentation] = [
        .tab1: "Активировать охрану",
        .tab2: "Деактивировать охрану",
        ]
}

@available(iOS 16.0, *)
struct VehicleStartActionProvider: DynamicOptionsProvider {
    func results() async throws -> [Short] {
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["type"] as? TypeIntent) == TypeIntent.vehicle_start }
        
        return filtered.compactMap { item -> Short? in
            guard let id = item["device_id"] as? Int,
                  let device_name = item["device_name"] as? String else { return nil }

            return Short(
                device_name: device_name,
                id: id
            )
        }
    }
}

@available(iOS 16.0, *)
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

@available(iOS 16.0, *)
struct VehicleSirenActionProvider: DynamicOptionsProvider {
    func results() async throws -> [Short] {
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["type"] as? TypeIntent) == TypeIntent.vehicle_siren }
        
        return filtered.compactMap { item -> Short? in
            guard let id = item["device_id"] as? Int,
                  let device_name = item["device_name"] as? String else { return nil }

            return Short(
                device_name: device_name,
                id: id
            )
        }
    }
}

@available(iOS 16.0, *)
enum VehicleSirenEnum: String, AppEnum {
    case tab1 = "Активировать сирену"
    case tab2 = "Деактивировать сирену"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Enable Siren")
   
    static var caseDisplayRepresentations: [VehicleSirenEnum: DisplayRepresentation] = [
        .tab1: "Активировать сирену",
        .tab2: "Деактивировать сирену",
        ]
}

@available(iOS 16.0, *)
struct VehicleBlockActionProvider: DynamicOptionsProvider {
    func results() async throws -> [Short] {
        guard let items = UserDefaults.standard.array(forKey: "ZONT_devices") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["type"] as? TypeIntent) == TypeIntent.vehicle_block }
        
        return filtered.compactMap { item -> Short? in
            guard let id = item["device_id"] as? Int,
                  let device_name = item["device_name"] as? String else { return nil }

            return Short(
                device_name: device_name,
                id: id
            )
        }
    }
}

@available(iOS 16.0, *)
enum VehicleBlockEnum: String, AppEnum {
    case tab1 = "Активировать блокировку двигателя"
    case tab2 = "Деактивировать блокировку двигателя"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Enable Block")
   
    static var caseDisplayRepresentations: [VehicleBlockEnum: DisplayRepresentation] = [
        .tab1: "Активировать блокировку двигателя",
        .tab2: "Деактивировать блокировку двигателя",
        ]
}


@available(iOS 16.0, *)
private func loadDevices() -> [Short] {
    guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]] else {
        return []
    }
    return items.compactMap { item in
        guard let id = item["device_id"] as? Int,
              let device_name = item["device_name"] as? String else { return nil }
        return Short(device_name: device_name, id: id)
    }
}