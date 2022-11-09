import Foundation

final class RegisterInfomation {
  
  private init() {}
  static let shared = RegisterInfomation()
  
  var registerType: RegisterType = .findPW
  
  var email: String?
  
  var password: String?
}
