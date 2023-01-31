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

extension MemberAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<MemberAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Task { getTask() }
  var headers: [String : String]? { getJsonHeader() }
}
