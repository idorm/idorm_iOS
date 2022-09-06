//
//  PutEmailService.swift
//  idorm
//
//  Created by 김응철 on 2022/08/25.
//

import Foundation
import RxSwift

class PutEmailService {
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
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = data
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
  }
}

