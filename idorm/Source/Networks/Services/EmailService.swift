//
//  EmailService.swift
//  idorm
//
//  Created by 김응철 on 2022/09/07.
//

import Foundation
import RxSwift
import Alamofire

final class EmailService {
  /// 이메일 인증 코드 전송 API
  static func registerEmailAPI(email: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email
    ]
    
    let url = EmailServerConstants.emailAuthenticationURL
    return APIService.load(url, httpMethod: .post, body: body)
  }
  
  static func passwordEmailAPI(email: String) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "email": email
    ]
    
    let url = EmailServerConstants.emailAuthentication_PasswordURL
    return APIService.load(url, httpMethod: .post, body: body)
  }
  
  /// 이메일 코드 검증 API
  static func verifyCodeAPI(email: String, code: String, type: RegisterType) -> Observable<AFDataResponse<Data>> {
    let path = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let body: Parameters = [
      "code": code
    ]
    
    if type == .findPW {
      let url = EmailServerConstants.verifyEmailCode_PasswordURL + "/\(path)"
      return APIService.load(url, httpMethod: .post, body: body)
    } else {
      let url = EmailServerConstants.verifyEmailCodeURL + "/\(path)"
      return APIService.load(url, httpMethod: .post, body: body)
    }
  }
}
