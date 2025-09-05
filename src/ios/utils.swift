import AppIntents
import SwiftUI

@available(iOS 18.0, *)
private func performDeviceRequest(device: DeviceEntity, apiUrl: String, funcParse: ([String: Any])->String, params: [String: Any]? = nil) async throws -> String {
    guard device.id != -1 || device.id != -2 else {
        return "Выберите устройство"
    }
    
    guard let token = UserDefaults.standard.object(forKey: "ZONT_token") as? String else {
        return "Пожалуйста авторизуйтесь в приложении ZONT"
    }
    
    //zont.microline.ru
    
    let baseUrl = "https://my.zont.online/api/widget/v3"

    guard let url = URL(string: baseUrl + apiUrl) else {
        return "Ошибка: не верный URL"
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("\(token)", forHTTPHeaderField: "X-ZONT-Token")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("app-widget-ios", forHTTPHeaderField: "X-ZONT-Client")
    
    if let params = params {
        print("params", params)
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
    }

    let (data, _) = try await URLSession.shared.data(for: request)
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return String(data: data, encoding: .utf8) ?? "Нет ответа"
    }
    print("performDeviceRequest", json)
    if json["ok"] as? Bool == true {
        return funcParse(json)
    }  else {
        if json["error_ui"] != nil {
            return "Ошибка: \(json["error_ui"] ?? ""))"
        } else if json["error"] != nil {
            switch json["error"] as? String {
            case "bad_device_response":
                return "прибор ответил ошибкой"
            case "command_failed":
                return "Команда не выполнена"
            case "command_ok_confirmation_not_received":
                return "Команда отправлена, но подтверждение не получено"
            case "device_is_offline":
                return "устройство офлайн"
            case "device_not_found":
                return "устройство не найдено"
            case "timeout":
                return "таймаут"
            case "unsupported_device_type":
                return "тип устройства не поддерживается"
            case "engine_is_already_running":
                return "двигатель уже запущен"
            default:
                return "Ошибка запроса: \(json["error"] ?? ""))"
            }
        } else {
            return "Устройство не на связи"
        }
    }
}
