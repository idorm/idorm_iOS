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
      
    case .patchPassword:
      return .patch
      
    case .changeNickname:
      return .patch
      
    case .retrieveMember:
      return .get
      
    case .withdrawal:
      return .delete
      
    case .saveProfilePhoto:
      return .post
      
    case .deleteProfileImage:
      return .delete
      
    case .logoutFCM:
      return .delete
      
    case .updateFCM:
      return .patch
    }
  }
}
