//
//  EmailService.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa

class LoginService {
  // MARK: - 로그인 요청
  static func postLogin(email: String, password: String) -> ResponseResult {
    struct Request: Codable {
      let email: String
      let password: String
    }
    
    let requestModel = Request(email: email, password: password)
    let url = URL(string: "https://idorm.inuappcenter.kr:443/login")!
    let data = try! JSONEncoder().encode(requestModel)
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return URLSession.shared.rx.response(request: request)
    }
  
  // MARK: - 이메일 인증 요청
  static func authenticateEmail(email: String, type: LoginType) -> Observable<(response: HTTPURLResponse, data: Data)> {
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
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = data
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
  
  // MARK: - 이메일 인증 검증
  static func verifyEmailCode(email: String, code: String, type: LoginType) -> Observable<(response: HTTPURLResponse, data: Data)> {
    struct Request: Codable {
      let code: String
    }
    
    let request = Request(code: code)
    guard let body = try? JSONEncoder().encode(request) else { fatalError("Error Encoding data!") }
    var urlString: String = ""
    
    if type == .singUp {
      urlString = "https://idorm.inuappcenter.kr:443/verifyCode/\(email)"
    } else {
      urlString = "https://idorm.inuappcenter.kr:443/verifyCode/password/\(email)"
    }
    
    let url = URL(string: urlString)!
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = body
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
  
  // MARK: - 회원가입 요청
  static func registerMember(email: String, password: String) -> Observable<(response: HTTPURLResponse, data: Data)> {
    struct Request: Codable {
      let email: String
      let password: String
    }
    
    let request = Request(email: email, password: password)
    let urlString = "https://idorm.inuappcenter.kr:443/register"
    let url = URL(string: urlString)!
    guard let body = try? JSONEncoder().encode(request) else { fatalError("Error Encoding data!") }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = body
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
}
