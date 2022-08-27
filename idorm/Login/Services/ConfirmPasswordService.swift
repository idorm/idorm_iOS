//
//  ConfirmPasswordService.swift
//  idorm
//
//  Created by 김응철 on 2022/08/27.
//

import Foundation
import RxSwift
import RxCocoa

class ConfirmPasswordService {
  // MARK: - 회원가입 요청
  func registerUser(email: String, password: String) -> ServerResponse {
    struct Request: Codable {
      let email: String
      let password: String
    }
    
    let request = Request(email: email, password: password)
    let url = URL(string: "https://idorm.inuappcenter.kr:443/register")!
    guard let body = try? JSONEncoder().encode(request) else { fatalError() }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpBody = body
    urlRequest.httpMethod = NetworkType.post.rawValue
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
  
  // MARK: - 로그인 요청
  func postLogin(email: String, password: String) -> ServerResponse {
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
}
