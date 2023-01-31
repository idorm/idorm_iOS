//
//  MemberAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MemberAPI {
  func getMethod() -> Moya.Method {
    switch self {
    case .login: return .post
    case .register: return .post
    case .changePassword_Login, .changePassword_Logout:
      return .patch
    case .changeNickname: return .patch
    case .retrieveMember: return .get
    case .withdrawal: return .delete
    }
  }
}
