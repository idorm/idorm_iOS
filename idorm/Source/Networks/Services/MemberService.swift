import Foundation

import RxSwift
import RxCocoa
import Alamofire

final class MemberService {
  /// 로그인 요청 API
  static func LoginAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.loginURL
    return APIService.load(url, httpMethod: .post, body: body, encoding: .json)
  }
  
  /// 회원가입 요청 API
  static func registerAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.registerURL
    return APIService.load(url, httpMethod: .post, body: body, encoding: .json)
  }
  
  /// 로그아웃 상태에서 비밀번호 바꾸기 API
  static func changePasswordAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.changePasswordURL
    return APIService.load(url, httpMethod: .patch, body: body, encoding: .json)
  }
  
  /// 멤버 닉네임 변경 API
  static func changeNicknameAPI(from nickname: String) ->
  Observable<AFDataResponse<Data>> {
    let url = MemberServerConstants.changeNicknameURL
    let body: Parameters = [
      "nickname": nickname
    ]
    
    return APIService.load(url, httpMethod: .patch, body: body, encoding: .json)
  }
  
  /// 멤버 정보 단건 조회
  static func memberAPI() -> Observable<AFDataResponse<Data>> {
    let url = MemberServerConstants.memberURL
    return APIService.load(url, httpMethod: .get, body: nil, encoding: .json)
  }
}
