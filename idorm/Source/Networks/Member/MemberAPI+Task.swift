//
//  MemberAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MemberAPI {
  func getTask() -> Task {
    switch self {
    case let .login(id, pw), let .changePassword_Logout(id, pw):
      return .requestParameters(parameters: [
        "email": id,
        "password": pw
      ], encoding: JSONEncoding.default)
      
    case .changePassword_Login(let pw):
      return .requestParameters(parameters: [
        "password": pw
      ], encoding: JSONEncoding.default)
      
    case let .register(id, pw, nickname):
      return .requestParameters(parameters: [
        "email": id,
        "nickname": nickname,
        "password": pw
        ], encoding: JSONEncoding.default)
      
    case .changeNickname(let nickname):
      return .requestParameters(parameters: [
        "nickname": nickname
      ], encoding: JSONEncoding.default)
      
    case .retrieveMember, .withdrawal:
      return .requestPlain
    }
  }
}