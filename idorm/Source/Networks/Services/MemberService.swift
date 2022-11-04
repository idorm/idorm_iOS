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
    return APIService.load(url, httpMethod: .post, body: body)
  }
  
  /// 회원가입 요청 API
  static func registerAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.registerURL
    return APIService.load(url, httpMethod: .post, body: body)
  }
  
  /// 로그아웃 상태에서 비밀번호 바꾸기 API
  static func changePasswordAPI(email: String, password: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    let url = MemberServerConstants.changePasswordURL
    return APIService.load(url, httpMethod: .patch, body: body)
  }
}
