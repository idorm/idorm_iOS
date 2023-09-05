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
    case .changePassword_Login:
      return "/auth/password"
    case .changePassword_Logout:
      return "/auth/password"
    case .changeNickname:
      return "/member/nickname"
    case .retrieveMember:
      return "/member"
    case .withdrawal:
      return "/member"
    case .saveProfilePhoto:
      return "/member/profile-photo"
    case .deleteProfileImage:
      return "/member/profile-photo"
    case .logoutFCM:
      return "/member/fcm"
    case .updateFCM:
      return "/member/fcm"
    }
  }
}
