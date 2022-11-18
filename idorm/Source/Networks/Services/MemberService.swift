import Foundation

import RxSwift
import RxCocoa
import Alamofire
import Moya
import RxMoya

final class MemberService {
  
  static let instance = MemberService()
  private init() {}
  
  let provider = MoyaProvider<MemberAPI>()
  private let disposeBag = DisposeBag()
  

  
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
