import Foundation

final class Logger {
  static let instance = Logger()
  private init() {}
  
  var authenticationType: AuthenticationType = .signUp
  var email: String?
  var password: String?
}
