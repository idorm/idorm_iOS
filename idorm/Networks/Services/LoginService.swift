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
  static func postLogin(email: String, password: String) -> ServerResponse {
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
