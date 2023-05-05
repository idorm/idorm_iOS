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
    case .login: return "/v2/login"
    case .register: return "/register"
    case .changePassword_Login: return "/member/password"
    case .changePassword_Logout: return "/password"
    case .changeNickname: return "/member/nickname"
    case .retrieveMember: return "/member"
    case .withdrawal: return "/member"
    case .saveProfilePhoto: return "/member/profile-photo"
    }
  }
}
