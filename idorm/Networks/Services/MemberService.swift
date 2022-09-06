//
//  EmailService.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

struct Response: Codable {
  let message: String
}

class MemberService {
  // MARK: - 로그인 요청
  static func LoginAPI(email: String, password: String) -> Observable<Data?> {
    let body: Parameters = [
      "email": email,
      "password": password
    ]
    
    return APIService.load(MemeberServerConstants.loginURL, httpMethod: .post, body: body)
    }
}
