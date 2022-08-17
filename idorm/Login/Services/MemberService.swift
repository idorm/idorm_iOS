//
//  LoginService.swift
//  idorm
//
//  Created by 김응철 on 2022/08/16.
//

import Foundation
import RxSwift
import RxCocoa

class MemberService {
  static func postLogin(loginRequestModel: LoginRequestModel) -> Observable<(response: HTTPURLResponse, data: Data)> {
    guard let url = URL(string: "https://idorm.inuappcenter.kr:443/login") else {
      fatalError("URL is incorrect!")
    }
    guard let data = try? JSONEncoder().encode(loginRequestModel) else {
      fatalError("Error encoding data!")
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: request)
  }
}

