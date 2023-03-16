//
//  MailAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MailAPI {
  func getTask() -> Task {
    switch self {
    case let .emailAuthentication(email), let .pwAuthentication(email):
      return .requestParameters(parameters: [
        "email": email
      ], encoding: JSONEncoding.default)
      
    case .emailVerification(_,let code), .pwVerification(_, let code):
      return .requestParameters(parameters: [
        "code": code
      ], encoding: JSONEncoding.default)
    }
  }
}
