import Foundation

final class TokenStorage {
  
  static let shared = TokenStorage()
  private init() {}
  
  func saveToken(token: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(token, forKey: "Token")
  }
  
  func loadToken() -> String {
    let userDefaults = UserDefaults.standard
    guard let token = userDefaults.string(forKey: "Token") else { return "" }
    return token
  }
  
  func removeToken() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "Token")
  }
  
  func hasToken() -> Bool {
    if loadToken() != "" {
      return true
    } else {
      return false
    }
  }
}
