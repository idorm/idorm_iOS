import Foundation

import RxSwift
import RxMoya
import Moya

enum MemberAPI {
  case login(id: String, pw: String)
  case register(id: String, pw: String, nickname: String)
  case changePassword_Login(pw: String)
  case changePassword_Logout(id: String, pw: String)
  case changeNickname(nickname: String)
  case retrieveMember
  case withdrawal
}

extension MemberAPI: TargetType {
  var baseURL: URL { return URL(string: APIService.baseURL)! }
  
  var path: String {
    switch self {
    case .login: return "/login"
    case .register: return "/register"
    case .changePassword_Login: return "/member/password"
    case .changePassword_Logout: return "/password"
    case .changeNickname: return "/member/nickname"
    case .retrieveMember: return "/member"
    case .withdrawal: return "/member"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .login: return .post
    case .register: return .post
    case .changePassword_Login, .changePassword_Logout:
      return .patch
    case .changeNickname: return .patch
    case .retrieveMember: return .get
    case .withdrawal: return .delete
    }
  }
  
  var task: Task {
    switch self {
    case let .login(id, pw), let .changePassword_Logout(id, pw):
      return .requestParameters(parameters: [
        "email": id,
        "password": pw
      ], encoding: JSONEncoding.default)
      
    case .changePassword_Login(let pw):
      return .requestParameters(parameters: [
        "password": pw
      ], encoding: JSONEncoding.default)
      
    case let .register(id, pw, nickname):
      return .requestParameters(parameters: [
        "email": id,
        "nickname": nickname,
        "password": pw
        ], encoding: JSONEncoding.default)
      
    case .changeNickname(let nickname):
      return .requestParameters(parameters: [
        "nickname": nickname
      ], encoding: JSONEncoding.default)
      
    case .retrieveMember, .withdrawal:
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    return APIService.basicHeader()
  }
}
