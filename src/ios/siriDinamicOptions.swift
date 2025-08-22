import Foundation
import AppIntents

@available(iOS 16.0, *)
struct Short: AppEntity {
    typealias DefaultQuery = DeviceQuery

    static var defaultQuery = DefaultQuery()

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Device")

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
struct DeviceOptionsProvider: DynamicOptionsProvider {

    func results() async throws -> [Short] {
        guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["is_auth"] as? Bool) != true }

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