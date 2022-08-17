//
//  EmailService.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa

class EmailService {
  static func authenticateEmail(email: String) -> Observable<(response: HTTPURLResponse, data: Data)> {
    struct Request: Codable {
      let email: String
    }
    
    guard let url = URL(string: "https://idorm.inuappcenter.kr:443/email") else {
      fatalError("URL is incorrect!")
    }
    
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
  
  static func verifyEmailCode(email: String, code: String) -> Observable<(response: HTTPURLResponse, data: Data)> {
    struct Request: Codable {
      let code: String
    }
    
    let request = Request(code: code)
    guard let body = try? JSONEncoder().encode(request) else { fatalError("Error Encoding data!") }
    
    let components = URLComponents(string: "https://idorm.inuappcenter.kr:443/verifyCode/\(email)")
    guard let url = components?.url else { fatalError("URL is incorrect!") }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = body
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
}
