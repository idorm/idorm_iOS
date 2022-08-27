//
//  AuthNumberViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/27.
//

import RxSwift
import Foundation

class AuthNumberService {
  // MARK: - 이메일 인증 검증
  static func verifyEmailCode(email: String, code: String, type: LoginType) -> ServerResponse {
    struct Request: Codable {
      let code: String
    }
    
    let request = Request(code: code)
    guard let body = try? JSONEncoder().encode(request) else { fatalError("Error Encoding data!") }
    var urlString: String = ""
    let encodedEmailString = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    if type == .singUp {
      urlString = "https://idorm.inuappcenter.kr:443/verifyCode/\(encodedEmailString)"
    } else {
      urlString = "https://idorm.inuappcenter.kr:443/verifyCode/password/\(encodedEmailString)"
    }
    print(urlString)
    
    let url = URL(string: urlString)!
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = NetworkType.post.rawValue
    urlRequest.httpBody = body
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
  
  // MARK: - 이메일 인증 요청
  static func authenticateEmail(email: String, type: LoginType) -> ServerResponse {
    struct Request: Codable {
      let email: String
    }
    var urlString: String = ""
    
    if type == .singUp {
      urlString = "https://idorm.inuappcenter.kr:443/email"
    } else {
      urlString = "https://idorm.inuappcenter.kr:443/email/password"
    }
    
    let url = URL(string: urlString)!
    let request = Request(email: email)
    guard let data = try? JSONEncoder().encode(request) else {
      fatalError("Error encoding data!")
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = NetworkType.post.rawValue
    urlRequest.httpBody = data
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
}
