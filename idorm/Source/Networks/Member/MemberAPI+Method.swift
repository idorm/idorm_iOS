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
    case .login:
      return .post
      
    case .register:
      return .post
      
    case .updatePassword:
      return .patch
      
    case .updateNickname:
      return .patch
      
    case .getUser:
      return .get
      
    case .deleteUser:
      return .delete
      
    case .createProfilePhoto:
      return .post
      
    case .deleteProfilePhoto:
      return .delete
      
    case .logout:
      return .delete
      
    case .updateFCM:
      return .patch
    }
  }
}
