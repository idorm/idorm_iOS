//
//  MemberAPI+Header.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import Foundation

extension MemberAPI {
  func getHeader() -> NetworkHeaderType {
    switch self {
    case .login, .updateFCM:
      return .fcmJson
    case .register, .updatePassword:
      return .normalJsonWithoutToken
    default:
      return .normalJson
    }
  }
}
