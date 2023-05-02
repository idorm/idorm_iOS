//
//  MailAPI+Path.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MailAPI {
  func getPath() -> String {
    switch self {
    case .emailAuthentication: return "/email"
    case .pwAuthentication: return "/email/password"
    case .emailVerification(let email, _):
      return "/verifyCode/\(email)"
    case .pwVerification(let email, _):
      return "/verifyCode/password/\(email)"
    }
  }
}
