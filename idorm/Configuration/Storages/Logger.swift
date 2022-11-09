import Foundation

final class Logger {
  
  private init() {}
  static let shared = Logger()
  
  var registerType: RegisterType = .findPW
  
  var email: String?
  
  var password: String?
}
