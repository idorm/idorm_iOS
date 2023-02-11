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

extension MemberAPI {
  static func loginProcess(_ response: Response) {
    guard let token = response.response?.headers.value(for: "authorization") else {
      fatalError("Can't found Token!")
    }
    
    let member = MemberAPI.decode(
      ResponseModel<MemberResponseModel.Member>.self,
      data: response.data
    ).data
    
    MemberStorage.shared.saveMember(member)
    TokenStorage.saveToken(token: token)
  }
}
