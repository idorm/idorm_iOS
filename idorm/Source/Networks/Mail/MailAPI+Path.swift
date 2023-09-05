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
    case .emailAuthentication:
      return "/auth/email"
    case .pwAuthentication:
      return "/auth/email/password"
    case .emailVerification(let email, _):
      return "/auth/verifyCode/\(email)"
    case .pwVerification(let email, _):
      return "/auth/verifyCode/password/\(email)"
    }
  }
}
