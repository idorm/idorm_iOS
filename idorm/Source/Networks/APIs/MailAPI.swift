import Foundation

import Moya

enum EmailAPI {
  case emailAuthentication(email: String)
  case pwAuthentication(email: String)
  case emailVerification(email: String, code: String)
  case pwVerification(email: String, code: String)
}

extension EmailAPI: TargetType {
  var baseURL: URL {
    return URL(string: APIService.baseURL)!
  }
  
  var path: String {
    switch self {
    case .emailAuthentication: return "/email"
    case .pwAuthentication: return "/email/password"
      
    case .emailVerification(let email, _):
      return "/verifyCode/\(email)"
    case .pwVerification(let email, _):
      return "/verifyCode/password/\(email)"
    }
  }
  
  var method: Moya.Method {
    switch self {
    default: return .post
    }
  }
  
  var task: Moya.Task {
    switch self {
    case let .emailAuthentication(email), let .pwAuthentication(email):
      return .requestParameters(parameters: [
        "email": email
      ], encoding: JSONEncoding.default)
      
    case .emailVerification(_,let code), .pwVerification(_, let code):
      return .requestParameters(parameters: [
        "code": code
      ], encoding: JSONEncoding.default)
    }
  }
  
  var headers: [String : String]? {
    return APIService.basicHeader()
  }
}
