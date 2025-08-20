import Foundation
import AppIntents

struct DeviceOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [Option<Int>] {
        guard let items = UserDefaults.standard.array(forKey: "device_shortcuts") as? [[String: Any]] else {
            return []
        }

        let filtered = items.filter { ($0["in_auth"] as? Bool) == true }

        return filtered.compactMap { item in
            guard let id = item["device_id"] as? Int,
                  let title = item["title"] as? String else { return nil }

            return Option(
                title: LocalizedStringResource(stringLiteral: title),
                value: id
            )
        }
    }
}