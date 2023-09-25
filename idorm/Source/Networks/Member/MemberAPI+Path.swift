//
//  MemberAPI+Path.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MemberAPI {
  func getPath() -> String {
    switch self {
    case .login:
      return "/auth/login"
    case .register:
      return "/auth/register"
    case .updatePassword:
      return "/auth/password"
    case .updateNickname:
      return "/member/nickname"
    case .getUser:
      return "/member"
    case .deleteUser:
      return "/member"
    case .createProfilePhoto:
      return "/member/profile-photo"
    case .deleteProfilePhoto:
      return "/member/profile-photo"
    case .logout:
      return "/member/fcm"
    case .updateFCM:
      return "/member/fcm"
    }
  }
}
