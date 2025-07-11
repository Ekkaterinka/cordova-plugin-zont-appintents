import Foundation

class TokenManager {
    static var shared = TokenManager()
    private init() {}
    
    private var _token: String?
    
    var token: String? {
        get { _token }
        set { _token = newValue }
    }
    
    func hasValidToken() -> Bool {
        return _token != nil && !_token!.isEmpty
    }
}