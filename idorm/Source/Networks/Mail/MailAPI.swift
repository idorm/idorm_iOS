import Foundation

import Moya

enum MailAPI {
  case emailAuthentication(email: String)
  case pwAuthentication(email: String)
  case emailVerification(email: String, code: String)
  case pwVerification(email: String, code: String)
}

extension MailAPI: BaseTargetType {
  func getHeader() -> NetworkHeaderType {
    return .normalJson
  }
  
  static let provider = MoyaProvider<MailAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? {
    return [
      "Content-Type": "application/json"
    ]
  }
}
