import RxSwift
import RxCocoa

final class Logger {
  static let instance = Logger()
  private init() {}
  
  let authenticationType = BehaviorRelay<AuthenticationType>(value: .signUp)
  let currentEmail = BehaviorRelay<String>(value: "")
  let currentPassword = BehaviorRelay<String>(value: "")
}
