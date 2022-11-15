import Foundation

import RxSwift
import RxCocoa
import Alamofire
import Moya

final class MemberService {
  
  static let shared = MemberService()
  private init() {}
  
  /// 로그인 요청 API
  func LoginAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.loginURL
    return APIService.load(url, httpMethod: .post, body: body, encoding: .json)
  }
  
  /// 회원가입 요청 API
  func registerAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.registerURL
    return APIService.load(url, httpMethod: .post, body: body, encoding: .json)
  }
  
  /// 로그아웃 상태에서 비밀번호 바꾸기 API
  func changePasswordAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.changePasswordURL
    return APIService.load(url, httpMethod: .patch, body: body, encoding: .json)
  }
  
  /// 멤버 닉네임 변경 API
  func changeNicknameAPI(from nickname: String) ->
  Observable<AFDataResponse<Data>> {
    let url = MemberServerConstants.changeNicknameURL
    let body: Parameters = [
      "nickname": nickname
    ]
    
    return APIService.load(url, httpMethod: .patch, body: body, encoding: .json)
  }
  
  /// 멤버 정보 단건 조회
  func memberAPI() -> Observable<AFDataResponse<Data>> {
    let url = MemberServerConstants.memberURL
    return APIService.load(url, httpMethod: .get, body: nil, encoding: .json)
    
  }
}

enum MemberAPI {
  case login(id: String, pw: String)
  case register(id: String, pw: String)
  case changePassword(id: String, pw: String)
  case changeNickname(nickname: String)
  case retrieveMember
}

extension MemberAPI: TargetType {
  var baseURL: URL { return URL(string: APIService.baseURL)! }
  
  var path: String {
    switch self {
    case .login: return "/login"
    case .register: return "/register"
    case .changePassword: return "/changepassword"
    case .changeNickname: return "/member/nickname"
    case .retrieveMember: return "/member"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .login: return .post
    case .register: return .post
    case .changePassword: return .patch
    case .changeNickname: return .patch
    case .retrieveMember: return .get
    }
  }
  
  var task: Task {
    switch self {
    case let .login(id, pw), let .register(id, pw), let .changePassword(id, pw):
      let params = ["email": id,
                    "password": pw]
      return .requestParameters(parameters: params, encoding: JSONEncoding.default)
      
    case .changeNickname(let nickname):
      let params = ["nickname": nickname]
      return .requestParameters(parameters: params, encoding: JSONEncoding.default)
      
    case .retrieveMember:
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    return APIService.basicHeader()
  }
}
